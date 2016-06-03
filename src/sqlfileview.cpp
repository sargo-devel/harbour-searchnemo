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

#include <QtCore/qmath.h>
#include <QSettings>
#include "sqlfileview.h"
#include "dbsqlite.h"

SqlFileView::SqlFileView(QObject *parent) : TxtFileView(parent)
{
   m_displabel = "";
   m_element = "";

   //qDebug() << "Konstruktor SqlFileView";
}

SqlFileView::~SqlFileView()
{
    //qDebug() << "Destruktor SqlFileView";
}

void SqlFileView::setFullpath(QString fullpath)
{
    if (m_fullpath == fullpath)
        return;

    m_fullpath = fullpath;

    if ( fullpath == QString() ) return; //folder does not exist
    DbSqlite db( m_fullpath );
    //displabel schema owner:table:column:row
    QStringList lst = m_displabel.split(":");
    m_element = db.getSingleElement(lst.at(1), lst.at(2), lst.at(3).toInt());
    if( m_element != "") {
        m_stream.setString(&m_element, QIODevice::ReadOnly);
    }
    else
    {
        qDebug() << "Error: SQlite element open fail.";
    }
    emit fullpathChanged();
}

void SqlFileView::setDisplabel(QString displabel)
{
    m_displabel = displabel;
    emit displabelChanged();
}

//get fields names of complete row of table given in m_displabel
QStringList SqlFileView::getRowNames() const
{
    DbSqlite db( m_fullpath );
    //displabel schema owner:table:column:row
    QStringList lst = m_displabel.split(":");
    QHash<QString, QString> row = db.getSingleRow(lst.at(1), lst.at(3).toInt());
    return row.keys();
}

//get fields values of complete row of table given in m_displabel
QStringList SqlFileView::getRowValues() const
{
    DbSqlite db( m_fullpath );
    //displabel schema owner:table:column:row
    QStringList lst = m_displabel.split(":");
    QHash<QString, QString> row = db.getSingleRow(lst.at(1), lst.at(3).toInt());
    return row.values();
}
