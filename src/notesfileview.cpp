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
#include "notesfileview.h"

#include "dbsqlite.h"

NotesFileView::NotesFileView(QObject *parent) : TxtFileView(parent)
{
   m_notenr = 0;
   //qDebug() << "Konstruktor NotesFileView";
}

NotesFileView::~NotesFileView()
{
    //qDebug() << "Destruktor NotesFileView";
}

void NotesFileView::setFullpath(QString fullpath)
{
    if (m_fullpath == fullpath)
        return;

    m_fullpath = fullpath;

    if ( fullpath == QString() ) return; //Notes folder does not exist
    DbSqlite db( m_fullpath );
    if ( (m_notenr > 0) && (m_notenr <= db.nrOfNoteEntries()) ) {
        m_note = db.getNote(m_notenr);
        m_stream.setString(&m_note, QIODevice::ReadOnly);
    }
    else
    {
        qDebug() << "Error: file open fail";
    }
    emit fullpathChanged();
}

void NotesFileView::setNotenr(QString notenr)
{
    bool ok;

    m_notenr = notenr.mid(notenr.lastIndexOf(" ")+1).toInt(&ok);
    //if (!ok) qDebug() << "notenr conversion failed: " << notenr;
    //qDebug() << "m_notenr changed: " << m_notenr;
    emit notenrChanged();
}
