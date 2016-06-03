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
#include "txtfileview.h"

#define M_MAXBEFORE 3
#define M_MAXBUFLEN 14
#define M_MAXLINELEN 45

TxtFileView::TxtFileView(QObject *parent) : QObject(parent)
{
   m_fullpath = "";
   m_stxt = "";
   m_disptxt = "";
   m_allmatchcount = 0;
   m_hits = 0;

   m_maxbefore = M_MAXBEFORE;
   m_maxbuflen = M_MAXBUFLEN;
   m_maxlinelen = M_MAXLINELEN;
   m_txtbuffer = QStringList();
   m_txtbufidx = QList<int>();
   m_stxtidx = -1;
   //qDebug() << "Konstruktor TxtFileView";

}

TxtFileView::~TxtFileView()
{
    m_file.close();
    //qDebug() << "Destruktor TxtFileView";
}

void TxtFileView::setFullpath(QString fullpath)
{
    if (m_fullpath == fullpath)
        return;

    m_fullpath = fullpath;

    m_file.setFileName(m_fullpath);
    if (!m_file.open(QIODevice::ReadOnly | QIODevice::Text))
    {

        qDebug() << "Error: file open fail";
    }
    else
    {
        m_stream.setDevice(&m_file);
        //qDebug() << "File open ok: " << m_fullpath;
    }
    emit fullpathChanged();
}

void TxtFileView::setStxt(QString stxt)
{
    m_stxt = stxt;
    emit stxtChanged();
}

void TxtFileView::setAllmatchcount(int allmatchcount)
{
    m_allmatchcount = allmatchcount;
    emit allmatchcountChanged();
}

void TxtFileView::setDisptxt(QString disptxt)
{
    m_disptxt=disptxt;
    emit disptxtChanged();
}

QString TxtFileView::getAll()
{
    return m_stream.readAll();
}

void TxtFileView::getBlock()
{
    while ( (!isBufferSizeOk() || (m_stxtidx < 0)) && (!m_stream.atEnd()) ) {
        QString line =  m_stream.readLine();
        m_txtbufidx.append(line.count());
        if (line.contains(m_stxt, Qt::CaseInsensitive)) {
            line=addBoldMarks(line);
            if( m_stxtidx < 0 ) m_stxtidx = m_txtbufidx.count() - 1;
        }
        m_txtbuffer.append(line);
        if (!isMaxBeforeOk()) {
            m_txtbuffer.removeFirst();
            m_txtbufidx.removeFirst();
            if (m_stxtidx > -1) m_stxtidx--;
        }
    }

    // prepare plain output text
    QStringList tmpbuf = m_txtbuffer;
    tmpbuf.replaceInStrings("<b><u>" + m_stxt + "</u></b>", m_stxt, Qt::CaseInsensitive);
    m_disptxtplain = tmpbuf.join("\n");

    // prepare output text with markups
    QSettings settings;
    bool singleMatchSetting = settings.value("showOnlyFirstMatch", true).toBool();
    QString header = "";
    if (singleMatchSetting)
        header = QString(tr("<b>[%1/%n hit(s)]</b><br>", "", m_allmatchcount)).arg(m_hits);
    m_txtbuffer.replaceInStrings("&", "&amp;");
    m_disptxt = header + m_txtbuffer.join("<br>");
    emit disptxtChanged();
}

void TxtFileView::getFirst()
{

    m_txtbuffer.clear();
    m_txtbufidx.clear();
    m_stxtidx = -1;
    m_hits = 0;
    m_stream.seek(0);
    getBlock();
}

void TxtFileView::getNext()
{
    if( !m_stream.atEnd() && (m_hits != m_allmatchcount) ) {
        if (!m_txtbuffer.isEmpty()) {
            m_txtbuffer.removeFirst();
            m_txtbufidx.removeFirst();
            if (m_stxtidx > -1) m_stxtidx=-1;
        }
        getBlock();
    }
}

QString TxtFileView::addBoldMarks(QString txtline)
{
    int i=0;

    while ((i = txtline.indexOf(m_stxt, i, Qt::CaseInsensitive)) != -1) {
        txtline.insert(i+m_stxt.size(),"</u></b>");
        txtline.insert(i,"<b><u>");
        i+=7;
        m_hits++;
    }
    return txtline;
}

bool TxtFileView::isMaxBeforeOk()
// returns true if nr of virt. lines before line containing stxt is <= m_maxbefore
// and other conditions..
{
    int sum = 0;
    int idx;
    (m_stxtidx > -1) ? idx=m_stxtidx : idx=m_txtbufidx.size();
    for(int i=0; i<idx; i++)
        sum+= qCeil( qreal(m_txtbufidx.at(i))/qreal(m_maxlinelen));
    if( sum > m_maxbefore ) {/*qDebug() << "isMaxBeforeOk=false";*/ return false;}
    return true;
}

bool TxtFileView::isBufferSizeOk()
// returns true if lenght of buffer in virt. lines >= m_maxbuflen
// (each line counted as no longer then m_maxlinelen)
{
    int sum=0;

    for(int i=0; i<m_txtbufidx.size(); i++)
        sum+= qCeil( qreal(m_txtbufidx.at(i))/qreal(m_maxlinelen));
    if( sum < m_maxbuflen) return false;
    return true;
}
