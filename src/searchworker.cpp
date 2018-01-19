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
#include <QRegularExpression>
#include <QRegularExpressionMatch>
#include <QMimeDatabase>
#include <QMimeType>
//#include <QDebug>
#include "globals.h"
#include "dbsqlite.h"

// Max. directory depth when symlinks enabled
#define MAXDIRDEPTH 20
//count elapsed time
//#include <ctime>

SearchWorker::SearchWorker(QObject *parent) :
    QThread(parent),
    m_cancelled(NotCancelled)
{
    QSettings settings;

    connect(&m_profile, SIGNAL(settingsChanged()), this, SIGNAL(profileSettingsChanged()));
    connect(&m_profile, SIGNAL(nameChanged()), this, SIGNAL(profileNameChanged()));
    m_defLang = settings.value("langSetting", "default").toString();
    //qDebug()<<"Searchworker constructor";
}

SearchWorker::~SearchWorker()
{
    //qDebug()<<"Searchworker destructor";
}

void SearchWorker::startSearch(QString profilename, QString searchTerm)
{
    if (isRunning()) {
        emit errorOccurred(tr("Search already in progress"), "");
        return;
    }
    if (profilename.isEmpty() || searchTerm.isEmpty()) {
        emit errorOccurred(tr("Bad search parameters"), "");
        return;
    }

    m_profile.setName(profilename);

    if (!m_profile.isWhiteList()) {
        emit errorOccurred(tr("Profile configuration error!"), tr("Check profile whitelist..."));
        return;
    }

    m_searchTerm = searchTerm;
    //m_currentDirectory = directory;
    m_cancelled.storeRelease(NotCancelled);
    m_alreadySearchedNotes = false;

    start();
}

void SearchWorker::cancel()
{
    m_cancelled.storeRelease(Cancelled);
}

void SearchWorker::run()
{
    while ( m_profile.isWhiteList() ) {
        m_directory = m_profile.getNextFromWhiteList();
        QString errMsg = searchRecursively(m_directory, m_searchTerm);
        if (!errMsg.isEmpty())
            emit errorOccurred(errMsg, m_currentDirectory);
    }
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

    //profile settings;
    bool enableRegEx = m_profile.getBoolOption(Profile::EnableRegEx);
    bool hiddenSetting = m_profile.getBoolOption(Profile::SearchHiddenFiles);
    bool enableSymlinks = m_profile.getBoolOption(Profile::EnableSymlinks);
    bool singleMatchSetting = m_profile.getBoolOption(Profile::SingleMatchSetting);
    bool enableNotes = m_profile.getBoolOption(Profile::EnableNotes);
    bool enableFileDir = m_profile.getBoolOption(Profile::EnableFileDir);
    
    QHash<SearchWorker::WorkSet, bool> enabler;
    enabler[SearchWorker::EnableMimeType] = true; //m_profile.getBoolOption(Profile::EnableMimeType);
    enabler[SearchWorker::EnableTxt] = m_profile.getBoolOption(Profile::EnableTxt);
    enabler[SearchWorker::EnableHtml] = m_profile.getBoolOption(Profile::EnableHtml);
    enabler[SearchWorker::EnableSrc] = m_profile.getBoolOption(Profile::EnableSrc);
    enabler[SearchWorker::EnableApps] = m_profile.getBoolOption(Profile::EnableApps);
    enabler[SearchWorker::EnableSqlite] = m_profile.getBoolOption(Profile::EnableSqlite);

    //prepare for regEx
    const QRegularExpression searchExpr(searchTerm, QRegularExpression::UseUnicodePropertiesOption);
    if(!searchExpr.isValid()) enableRegEx=false;

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

        if (enableFileDir)
            if ( enableRegEx ? filename.contains(searchExpr) : filename.contains(searchTerm, Qt::CaseInsensitive) )
                emit matchFound(fullpath, searchtype, "", matchline, 0);

        if (enableSymlinks) {
            //skip deep subdirs when symlinks enabled
            if (fullpath.count("/") > MAXDIRDEPTH) continue;
        }
        else {
            QFileInfo info(fullpath);
            // skip symlinks to prevent infinite loops
            if (info.isSymLink()) continue;
        }
        if ( !m_profile.isInBlackList(fullpath) ) {
            QString errmsg = searchRecursively(fullpath, searchTerm);
            if (!errmsg.isEmpty())
                return errmsg;
        }
    }

    // search files
    if (enableFileDir) {
        searchtype = "FILE";
        matchline = "";
        names = dir.entryList(QDir::Files | hidden);
        for (int i = 0 ; i < names.count() ; ++i) {
            // stop if cancelled
            if (m_cancelled.loadAcquire() == Cancelled)
                return QString();

            QString filename = names.at(i);
            QString fullpath = dir.absoluteFilePath(filename);

            if ( enableRegEx ? filename.contains(searchExpr) : filename.contains(searchTerm, Qt::CaseInsensitive) )
                emit matchFound(fullpath, searchtype, "", matchline, 0);
        }
    }
    
    // create table of file lists qualified for search
    QHash<SearchWorker::WorkSet, QStringList> filesTab = createFileTable(dir,hidden,enabler);

    // search inside filtered files (*.txt)
    if (enabler[SearchWorker::EnableTxt])
        if ( addSearchTXT("TXT", searchTerm, dir, filesTab, singleMatchSetting) == QString() ) return QString();

    // search inside filtered files (*.html)
    if (enabler[SearchWorker::EnableHtml])
        if ( addSearchTXT("HTML", searchTerm, dir, filesTab, singleMatchSetting) == QString() ) return QString();

    // search inside filtered files (*.cpp, *.c, *.h, *.py, *.sh, *.qml, *.js)
    if (enabler[SearchWorker::EnableSrc])
        if ( addSearchTXT("SRC", searchTerm, dir, filesTab, singleMatchSetting) == QString() ) return QString();

    // search inside filtered files (*.desktop)
    if (enabler[SearchWorker::EnableApps])
        if ( addSearchTXT("APPS", searchTerm, dir, filesTab, singleMatchSetting) == QString() ) return QString();

    // search inside raw sqlite files (*.sqlite, *.sqlite3, *db)
    if (enabler[SearchWorker::EnableSqlite])
        if ( addSearchSqlite("SQLITE", searchTerm, dir, filesTab, singleMatchSetting) == QString() ) return QString();

    // search inside Notes sqlite db

    if ( !m_alreadySearchedNotes ) {
        if (enableNotes)
            if ( addSearchNotes("NOTES", searchTerm, singleMatchSetting) == QString() ) return QString();
        m_alreadySearchedNotes = true;
    }

    return QString();
}

// create table of file lists qualified for search
QHash<SearchWorker::WorkSet, QStringList> SearchWorker::createFileTable(QDir dir, QDir::Filter hidden, QHash<SearchWorker::WorkSet, bool> enabler)
{
    QHash<SearchWorker::WorkSet, QStringList> wtab;
    QStringList filetypefilters;

    if (!enabler[SearchWorker::EnableMimeType]) {
        if (enabler[SearchWorker::EnableTxt]) {
            filetypefilters.clear();
            filetypefilters << "*.txt";
            wtab[SearchWorker::EnableTxt] = dir.entryList(filetypefilters, QDir::Files | hidden);
        }
        if (enabler[SearchWorker::EnableHtml]) {
            filetypefilters.clear();
            filetypefilters << "*.html" << "*.htm";
            wtab[SearchWorker::EnableHtml] = dir.entryList(filetypefilters, QDir::Files | hidden);
        }
        if (enabler[SearchWorker::EnableSrc]) {
            filetypefilters.clear();
            filetypefilters << "*.cpp" << "*.c" << "*.h" << "*.py" << "*.sh" << "*.qml" << "*.js";
            wtab[SearchWorker::EnableSrc] = dir.entryList(filetypefilters, QDir::Files | hidden);
        }
        if (enabler[SearchWorker::EnableApps]) {
            filetypefilters.clear();
            filetypefilters << "*.desktop";
            wtab[SearchWorker::EnableApps] = dir.entryList(filetypefilters, QDir::Files | hidden);
        }
        if (enabler[SearchWorker::EnableSqlite]) {
            filetypefilters.clear();
            filetypefilters << "*.sqlite" << "*.sqlite3" << "*.db";
            wtab[SearchWorker::EnableSqlite] = dir.entryList(filetypefilters, QDir::Files | hidden);
        }
    }

    if (enabler[SearchWorker::EnableMimeType]) {
        filetypefilters.clear();
        QStringList names = dir.entryList(filetypefilters, QDir::Files | hidden);
        QMimeDatabase db;
        for (int i = 0 ; i < names.count() ; ++i) {
            QString fullpath = dir.absoluteFilePath(names.at(i));
            QMimeType mime = db.mimeTypeForFile(fullpath);
            if ( mime.inherits("application/x-sqlite3") ) {
                if (enabler[SearchWorker::EnableSqlite]) wtab[SearchWorker::EnableSqlite].append(names.at(i)); }
            else if ( mime.inherits("application/x-desktop") ) {
                if (enabler[SearchWorker::EnableApps]) wtab[SearchWorker::EnableApps].append(names.at(i)); }
            else if ( mime.inherits("text/html") ) {
                if (enabler[SearchWorker::EnableHtml]) wtab[SearchWorker::EnableHtml].append(names.at(i)); }
            else if ( mime.inherits("text/x-csrc") || mime.inherits("application/x-shellscript")
                   || mime.inherits("text/x-python") || mime.inherits("text/x-qml") ) {
                if (enabler[SearchWorker::EnableSrc]) wtab[SearchWorker::EnableSrc].append(names.at(i)); }
            else if ( mime.inherits("text/plain") ) {
                if (enabler[SearchWorker::EnableTxt]) wtab[SearchWorker::EnableTxt].append(names.at(i)); }
        }
    }
    return wtab;
}

    
// additional search module for searchRecursively (TXT,HTML,SRC,APPS)
QString SearchWorker::addSearchTXT(QString searchtype, QString searchTerm, QDir dir, QHash<SearchWorker::WorkSet, QStringList> filesTab, bool singleMatch)
{
    QStringList names;

    if (searchtype == "HTML") names = filesTab[SearchWorker::EnableHtml];
    if (searchtype == "TXT")  names = filesTab[SearchWorker::EnableTxt];
    if (searchtype == "SRC")  names = filesTab[SearchWorker::EnableSrc];
    if (searchtype == "APPS") names = filesTab[SearchWorker::EnableApps];

    for (int i = 0 ; i < names.count() ; ++i) {
        // stop if cancelled
        if (m_cancelled.loadAcquire() == Cancelled) return QString();

        //QString filename = "In file: " + names.at(i);
        QString filename = names.at(i);
        QString fullpath = dir.absoluteFilePath(filename);
        QString displabel = fullpath;

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
QString SearchWorker::addSearchSqlite(QString searchtype, QString searchTerm, QDir dir, QHash<SearchWorker::WorkSet, QStringList> filesTab, bool singleMatch)
{
    QString displabel = "";
    QStringList names;

    if (searchtype == "SQLITE") names = filesTab[SearchWorker::EnableSqlite];
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
                    QSqlQuery* query = db.getTxtColumnQueryAll(tables.at(j), fields.at(k));
                    if (query != NULL)
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

    //prepare fo RegEx
    bool enableRegEx = m_profile.getBoolOption(Profile::EnableRegEx);
    const QRegularExpression searchExpr(searchTerm, QRegularExpression::UseUnicodePropertiesOption);
    if(!searchExpr.isValid()) enableRegEx=false;

    while (!intxt->atEnd()) {
        if (m_cancelled.loadAcquire() == Cancelled)
            return false;
        QString linetxt = intxt->readLine();
        int findpos=0;
        QRegularExpressionMatch matchR;
        //search for several occurences of search text in one line
        while ( (findpos = (enableRegEx ? (matchR = searchExpr.match(linetxt, findpos)).capturedStart()
                                        : linetxt.indexOf(searchTerm, findpos, Qt::CaseInsensitive))) != -1) {
            //prepate line for output
            if (findpos>10) matchline = "\u2026" + linetxt.mid(findpos-10,120);
            else matchline = linetxt.left(120);
            if(matchcount==0) firstmatchline=matchline;
            enableRegEx ? findpos=matchR.capturedEnd() : findpos+=searchTerm.size();
            matchcount++;

            if(!singleMatch) {
                //found result
                //APPS only on single match
                if(searchtype != "APPS") emit matchFound(fullpath, searchtype, displabel, matchline, 0);
            }
            if (m_cancelled.loadAcquire() == Cancelled)
                return false;
        }
    }
    if( singleMatch && (matchcount >0) ) {
        //found result
        if(searchtype == "APPS") {
            displabel = prepareForApps(intxt);
            matchcount = (-1)*matchcount;
            if(displabel.size()>0)
                emit matchFound(fullpath, searchtype, displabel, firstmatchline, matchcount);
        }
        else emit matchFound(fullpath, searchtype, displabel, firstmatchline, matchcount);
    }
    return true;
}

QString SearchWorker::prepareForApps(QTextStream *stream)
{
    bool isDesktop = false;
    bool isApp = false;
    bool isEnabled = true;
    QString name, name_l, lang, locale, icon, comment, comment_l, defLang;


    if(m_defLang == "default") locale = QLocale::system().name();
    else locale = m_defLang;

    lang = locale.split("_")[0];
    stream->seek(0);
    while (!stream->atEnd()) {
        if (m_cancelled.loadAcquire() == Cancelled) return QString();
        QString line = stream->readLine();
        if(line.contains("[Desktop Entry]")) isDesktop = true;
        if(line.contains("Type=Application")) isApp = true;
        if(line.startsWith("Icon=")) icon = line.split("=")[1];
        if(line.startsWith("Name=")) name = line.split("=")[1];
        if(line.startsWith("Name[" +lang+ "]=")) name_l = line;
        if(line.startsWith("Name[" +locale+ "]=")) name_l = line;
        if(line.startsWith("Comment=")) comment = line.split("=")[1];
        if(line.startsWith("Comment[" +lang+ "]=")) comment_l = line;
        if(line.startsWith("Comment[" +locale+ "]=")) comment_l = line;
        if(line.startsWith("X-apkd-packageName=")) comment = line.split("=")[1];
        if(line.startsWith("NoDisplay=true")) isEnabled = false;
    }

    if(name_l.size()>0) name = name_l.split("=")[1];
    if(comment_l.size()>0) comment = comment_l.split("=")[1];
    if(isDesktop && isApp && isEnabled) return name + "::" + icon + "::" + comment;
    return QString();
}
