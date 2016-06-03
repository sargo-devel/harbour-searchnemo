#ifndef DBSQLITE_H
#define DBSQLITE_H

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QHash>

class DbSqlite
{
public:
    // Constructor sets up connection with db and opens it
    // @param path - absolute path to db file
    DbSqlite(const QString& path);

     //Close the db connection
    ~DbSqlite();

    // returns number of entries in notes table
    int nrOfNoteEntries() const;
    // returns file name of notes database
    static QString findNotesFileName();
    // returns complete note
    QString getNote(int index) const;

    //get all tables
    QStringList getAllTables() const;
    // returns all txt column headers in a given table
    QStringList getAllTxtColumns(QString table) const;
    // returns number of rows in a given table
    int countAllRows(QString table) const;
    // returns an element in a given table and field
    QString getSingleElement(QString table, QString field, int idx) const;
    // returns complete row in a given table and index
    QHash<QString, QString> getSingleRow(QString table, int idx) const;
    // returns pointer to an executed search query (value0=index, value1=txtfield)
    QSqlQuery* getTxtColumnQuery(QString table, QString field, QString searchtxt);
    // returns the owner of the given filename
    QString getOwner(QString fullpath);

private:
    QSqlDatabase m_db;
    QSqlQuery* m_queryp = NULL;
};

#endif // DBSQLITE_H
