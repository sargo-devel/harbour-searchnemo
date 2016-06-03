/*
    SearchNemo - A program for search text in local files
    Copyright (C) 2016 SargoDevel
    Contact: SargoDevel <sargo-devel@go2.pl>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License version 3.

    This program is distributed WITHOUT ANY WARRANTY.
    See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "searchworker.h"
#include <QDateTime>
#include <QSettings>
#include <QDebug>
#include "globals.h"
#include "dbsqlite.h"

//count elapsed time
//#include <ctime>

SearchWorker::SearchWorker(QObject *parent) :
    QThread(parent),
    m_cancelled(NotCancelled)
{
}

SearchWorker::~SearchWorker()
{
}

void SearchWorker::startSearch(QString directory, QString searchTerm)
{
    if (isRunning()) {
        emit errorOccurred(tr("Search already in progress"), "");
        return;
    }
    if (directory.isEmpty() || searchTerm.isEmpty()) {
        emit errorOccurred(tr("Bad search parameters"), "");
        return;
    }

    m_directory = directory;
    m_searchTerm = searchTerm;
    m_currentDirectory = directory;
    m_cancelled.storeRelease(NotCancelled);
    m_alreadySearchedNotes = false;
    start();
}

void SearchWorker::cancel()
{
    m_cancelled.storeRelease(Cancelled);
}

void SearchWorker::run() Q_DECL_OVERRIDE
{
    QString errMsg = searchRecursively(m_directory, m_searchTerm.toLower());
    if (!errMsg.isEmpty())
        emit errorOccurred(errMsg, m_currentDirectory);

    emit progressChanged("");
    emit done();
}

QString SearchWorker::searchRecursively(QString directory, QString searchTerm)
{
    // skip some system folders - they don't really have any interesting stuff
    if (directory.startsWith("/proc") ||
            directory.startsWith("/sys/block"))
        return QString();

    QDir dir(directory);
    if (!dir.exists())  // skip "non-existent" directories (found in /dev)
        return QString();

    // update progress
    m_currentDirectory = directory;
    emit progressChanged(m_currentDirectory);


    QSettings settings;
    bool hiddenSetting = settings.value("searchHiddenFiles", true).toBool();
    bool singleMatchSetting = settings.value("showOnlyFirstMatch", true).toBool();
    bool enableTxt = settings.value("Sections/enableTxtSection",true).toBool();
    bool enableHtml = settings.value("Sections/enableHtmlSection",true).toBool();
    bool enableSrc = settings.value("Sections/enableSrcSection",true).toBool();
    bool enableSqlite = settings.value("Sections/enableSqliteSection",true).toBool();
    bool enableNotes = settings.value("Sections/enableNotesSection",true).toBool();

    QDir::Filter hidden = hiddenSetting ? QDir::Hidden : (QDir::Filter)0;

    // search dirs
    QString searchtype = "DIR";
    QString matchline = "";
    QStringList names = dir.entryList(QDir::NoDotAndDotDot | QDir::AllDirs | QDir::System | hidden);
    for (int i = 0 ; i < names.count() ; ++i) {
        // stop if cancelled
        if (m_cancelled.loadAcquire() == Cancelled)
            return QString();

        QString filename = names.at(i);
        QString fullpath = dir.absoluteFilePath(filename);

        if (filename.toLower().indexOf(searchTerm) >= 0)
            emit matchFound(fullpath, searchtype, "", matchline, 0);

        QFileInfo info(fullpath); // skip symlinks to prevent infinite loops
        if (info.isSymLink())
            continue;

        QString errmsg = searchRecursively(fullpath, searchTerm);
        if (!errmsg.isEmpty())
            return errmsg;
    }

    // search files
    searchtype = "FILE";
    matchline = "";
    names = dir.entryList(QDir::Files | hidden);
    for (int i = 0 ; i < names.count() ; ++i) {
        // stop if cancelled
        if (m_cancelled.loadAcquire() == Cancelled)
            return QString();

        QString filename = names.at(i);
        QString fullpath = dir.absoluteFilePath(filename);

        if (filename.toLower().indexOf(searchTerm) >= 0)
            emit matchFound(fullpath, searchtype, "", matchline, 0);
    }

    // search inside filtered files (*.txt)
    if (enableTxt)
        if ( addSearchTXT("TXT", searchTerm, dir, hidden, singleMatchSetting) == QString() ) return QString();

    // search inside filtered files (*.html)
    if (enableHtml)
        if ( addSearchTXT("HTML", searchTerm, dir, hidden, singleMatchSetting) == QString() ) return QString();

    // search inside filtered files (*.cpp, *.c, *.py, *.sh)
    if (enableSrc)
        if ( addSearchTXT("SRC", searchTerm, dir, hidden, singleMatchSetting) == QString() ) return QString();

    // search inside raw sqlite files (*.sqlite, *db)
    if (enableSqlite)
        if ( addSearchSqlite("SQLITE", searchTerm, dir, hidden, singleMatchSetting) == QString() ) return QString();

    // search inside Notes sqlite db

    if ( !m_alreadySearchedNotes ) {
        if (enableNotes)
            if ( addSearchNotes("NOTES", searchTerm, singleMatchSetting) == QString() ) return QString();
        m_alreadySearchedNotes = true;
    }

    return QString();
}

// additional search module for searchRecursively (TXT,HTML,SRC)
QString SearchWorker::addSearchTXT(QString searchtype, QString searchTerm, QDir dir, QDir::Filter hidden, bool singleMatch)
{

    QStringList filetypefilters;

    if (searchtype == "HTML") filetypefilters << "*.html" << "*.htm";
    if (searchtype == "TXT") filetypefilters << "*.txt";
    //if (searchtype == "PDF") filetypefilters << "*.pdf";
    if (searchtype == "SRC") filetypefilters << "*.cpp" << "*.c" << "*.py" << "*.sh";

    QStringList names = dir.entryList(filetypefilters, QDir::Files | hidden);
    for (int i = 0 ; i < names.count() ; ++i) {
        // stop if cancelled
        if (m_cancelled.loadAcquire() == Cancelled) return QString();

        //QString filename = "In file: " + names.at(i);
        QString filename = names.at(i);
        QString fullpath = dir.absoluteFilePath(filename);
        QString displabel = filename;

        QFile file(fullpath);
        if (file.open(QIODevice::ReadOnly | QIODevice::Text))  {
            QTextStream intxt(&file);
            if(!searchTxtLoop(&intxt, searchtype, searchTerm, singleMatch, fullpath, displabel)) return QString();
        }
    }
    return("Ok");
}

// additional search module for searchRecursively (NOTES)
QString SearchWorker::addSearchNotes(QString searchtype, QString searchTerm, bool singleMatch)
{
    QString displabel = "";

    QString fullpath = DbSqlite::findNotesFileName();
    //qDebug() << "fullpath=" << fullpath;
    if ( fullpath == QString() ) return QString(); //Notes folder does not exist
    DbSqlite db( fullpath );

    for (int i = 1 ; i <= db.nrOfNoteEntries() ; ++i) {
        // stop if cancelled
        if (m_cancelled.loadAcquire() == Cancelled) return QString();
        QString note=db.getNote(i);
        QTextStream intxt(&note);

        QString s;
        // it is important to have note number at the end after space
        displabel= tr("Note nr") + " " + s.setNum(i);
        if(!searchTxtLoop(&intxt, searchtype, searchTerm, singleMatch, fullpath, displabel)) return QString();
    }
    return("Ok");
}

// additional search module for searchRecursively (SQLITE)
QString SearchWorker::addSearchSqlite(QString searchtype, QString searchTerm, QDir dir, QDir::Filter hidden, bool singleMatch)
{
    QString displabel = "";
    QStringList filetypefilters;

    if (searchtype == "SQLITE") filetypefilters << "*.sqlite" << "*.db";
    QStringList names = dir.entryList(filetypefilters, QDir::Files | hidden);
    QString notesfullpath = DbSqlite::findNotesFileName();
    for (int i = 0 ; i < names.count(); ++i) {

        //count elapsed time
        //clock_t start = clock();

        QString filename = names.at(i);
        QString fullpath = dir.absoluteFilePath(filename);
        if ( fullpath != notesfullpath ) {
            DbSqlite db( fullpath );
            QStringList tables = db.getAllTables();
            for (int j = 0; j < tables.count(); ++j) {
                QStringList fields = db.getAllTxtColumns(tables.at(j));
                for (int k = 0; k < fields.count(); ++k) {
                    QSqlQuery* query = db.getTxtColumnQuery(tables.at(j), fields.at(k), searchTerm);
                    while (query->next())
                    {
                        // stop if cancelled
                        if (m_cancelled.loadAcquire() == Cancelled) return QString();

                        QString idxel = query->value(0).toString();
                        QString singleelement = query->value(1).toString();
                        QTextStream intxt(&singleelement);
                        displabel=  db.getOwner(fullpath) + ":" + tables.at(j) + ":" + fields.at(k) + ":" + idxel;
                        if(!searchTxtLoop(&intxt, searchtype, searchTerm, singleMatch, fullpath, displabel)) return QString();
                    }
                }
                fields.clear();
            }
        }
        //count elapsed time
        //clock_t finish = clock();
        //qDebug() << "Time elapsed=" << 1.0*(finish - start)/CLOCKS_PER_SEC;
    }
    return("Ok");
}

bool SearchWorker::searchTxtLoop(QTextStream *intxt, QString searchtype, QString searchTerm, bool singleMatch, QString fullpath, QString displabel)
{
    int matchcount=0;
    QString matchline = "";
    QString firstmatchline = "";
    while (!intxt->atEnd()) {
        if (m_cancelled.loadAcquire() == Cancelled)
            return false;
        QString linetxt = intxt->readLine();
        if (linetxt.contains(searchTerm, Qt::CaseInsensitive)) {
            QString linetxtcopy = linetxt;
            //prepate line for output
            int findpos=linetxt.indexOf(searchTerm, 0, Qt::CaseInsensitive);
            if (findpos>5) matchline = "..." + linetxt.mid(findpos-5,120);
            else matchline = linetxt.left(120);
            if(matchcount==0) firstmatchline=matchline;
            if(!singleMatch) emit matchFound(fullpath, searchtype, displabel, matchline, 0);
            //search for several occurences of search text in one line
            int mcnt=0;
            while ((mcnt = linetxtcopy.indexOf(searchTerm, mcnt, Qt::CaseInsensitive)) != -1) {
                mcnt++;
                matchcount++;
                if (m_cancelled.loadAcquire() == Cancelled)
                    return false;
            }
        }
    }
    if( singleMatch && (matchcount >0) ) {
        emit matchFound(fullpath, searchtype, displabel, firstmatchline, matchcount);
    }
    return true;
}
