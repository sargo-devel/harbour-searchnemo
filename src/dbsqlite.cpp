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

#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QSettings>
#include <QDebug>
#include "dbsqlite.h"

#define M_NOTESDBPATH ".local/share/jolla-notes/QML/OfflineStorage/Databases/"
#define M_LOCALSHARE ".local/share/"

DbSqlite::DbSqlite(const QString &path)
{
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(path);

    if (!m_db.open())
    {
        //qDebug() << "Error: connection with database fail: " << path;
    }
    else
    {
        if (NULL == m_queryp) m_queryp = new QSqlQuery(m_db);
        //qDebug() << "Database: connection ok: " << path;
    }
}

DbSqlite::~DbSqlite()
{
    if (NULL != m_queryp) {
        delete m_queryp;
        m_queryp = NULL;
    }
    QString connection = m_db.connectionName();

    if (m_db.isOpen())
    {
        m_db.close();
        //qDebug() << "Database: connection closed: " << m_db.databaseName();
    }
    m_db = QSqlDatabase();
    QSqlDatabase::removeDatabase(connection);
}

int DbSqlite::nrOfNoteEntries() const
{
    int nr=0;

    QSqlQuery query("SELECT count(*) FROM notes");
    if(query.exec()) {
        if(query.next())
            nr = query.value(0).toInt();
    }
    return nr;
}

QString DbSqlite::findNotesFileName()
{
    QDir dir(QDir::homePath() + "/" + M_NOTESDBPATH);
    if (!dir.exists()) return QString();
    QStringList names = dir.entryList(QDir::Files);
    for (int i = 0 ; i < names.count() ; ++i) {
        QString filename = names.at(i);
        if (filename.endsWith("sqlite")) {
            QString inifilename = filename;
            QFile inifile( dir.absoluteFilePath(inifilename.remove(".sqlite").append(".ini")) );
            if( inifile.exists() ) {
                QSettings inisettings( dir.absoluteFilePath(inifilename), QSettings::IniFormat );
                if( inisettings.value("Name").toString() == "silicanotes" ) {
                    return dir.absoluteFilePath(filename);
                }
            }
        }
    }
    return QString();
}

QString DbSqlite::getNote(int index) const
{
    QString note;
    QSqlQuery query;

    query.prepare("SELECT body FROM notes WHERE pagenr=(:index)");
    query.bindValue(":index", index);
    if(query.exec()) {
        if(query.next())
            note = query.value(0).toString();
    }
    return note;
}

//get all tables
QStringList DbSqlite::getAllTables() const
{
    return m_db.tables(QSql::Tables);
}

// returns all txt column headers in a given table
QStringList DbSqlite::getAllTxtColumns(QString table) const
{
    QStringList list;
    QSqlQuery query;
    query.prepare("PRAGMA table_info(" + table + ")");
    if(query.exec())
        while (query.next()) {
            if( query.value(2).toString() == "TEXT" ) list.append(query.value(1).toString());
        }
    return list;
}

// returns number of rows in a given table, which contain searched text
int DbSqlite::countAllRows(QString table) const
{
    int nr=0;

    QSqlQuery query("SELECT count(*) FROM " + table);
    if(query.exec()) {
        if(query.next())
            nr = query.value(0).toInt();
    }
    return nr;
}

// returns an element in a given table and field and index
QString DbSqlite::getSingleElement(QString table, QString field, int idx) const
{
    QString element;
    QSqlQuery query;

    //get index field
    QString idxfield = "";
    query.prepare("PRAGMA table_info(" + table + ")");
    if(query.exec())
        while (query.next())
            if( query.value(5).toInt() == 1 ) idxfield = query.value(1).toString();
    if (idxfield == "") idxfield = "_rowid_";
    //popraw z _rowid_ dla tabel, gdzie primary key nie jest int

    //prepare single element query
    QString s;
    query.prepare("SELECT " +field+ " FROM " +table+ " WHERE " +idxfield+ " = " +s.setNum(idx) );
    if(query.exec()) {
        if(query.next())
            element = query.value(0).toString();
    }
    return element;
}

// returns complete row in a given table and index
QHash<QString, QString> DbSqlite::getSingleRow(QString table, int idx) const
{
    QStringList nameslist;
    QHash<QString, QString> row;
    QSqlQuery query;

    //get index field and table fields
    QString idxfield = "";
    query.prepare("PRAGMA table_info(" + table + ")");
    if(query.exec())
        while (query.next()) {
            if( query.value(5).toInt() == 1 ) idxfield = query.value(1).toString();
            nameslist.append(query.value(1).toString());
        }
    if (idxfield == "") idxfield = "_rowid_";
    //popraw z _rowid_ dla tabel, gdzie primary key nie jest int

    //prepare single element query
    QString s;
    query.prepare("SELECT * FROM " +table+ " WHERE " +idxfield+ " = " +s.setNum(idx) );
    if(query.exec()) {
        if(query.next())
            for(int i=0; i<nameslist.count(); i++)
                row.insert(nameslist.at(i),query.value(i).toString());
    }
    return row;
}


// returns pointer to an executed search query (value0=index, value1=txtfield)
QSqlQuery* DbSqlite::getTxtColumnQuery(QString table, QString field, QString searchtxt)
{
    //get index field
    QSqlQuery query;
    QString idxfield = "";
    query.prepare("PRAGMA table_info(" + table + ")");
    if(query.exec())
        while (query.next())
            if( query.value(5).toInt() == 1 ) idxfield = query.value(1).toString();
    if (idxfield == "") idxfield = "_rowid_";
    //popraw z _rowid_ dla tabel, gdzie primary key nie jest int

    QSettings settings;
    QString maxres = settings.value("maxResultsPerSection", 50).toString();
    m_queryp->prepare("SELECT " +idxfield+ "," +field+ " FROM " +table+ " WHERE " +field+ " LIKE \"%" +searchtxt+
                    "%\" LIMIT " +maxres );
    if(m_queryp->exec()) return m_queryp;
    return NULL;
}

QString DbSqlite::getOwner(QString fullpath)
{
    int idx = fullpath.lastIndexOf(M_LOCALSHARE);
    int s = QString(M_LOCALSHARE).size();
    if( idx == -1) return fullpath.mid(fullpath.lastIndexOf("/"));
    int len = fullpath.indexOf("/",idx+s)-(idx+s);
    return fullpath.mid(idx+s,len);
}
