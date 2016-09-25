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

//#include <QSettings>
#include <QDebug>
#include "profile.h"
#include "settings.h"
//#include <QList>

Profile::Profile(QObject *parent) : QObject(parent)
{
    m_unsaved=false;
}

Profile::~Profile()
{
    writeAll();
    qDebug()<<"profile destructed";
}

//Function sets new name of profile, reads all settigs from file, resets index
void Profile::setName(QString profilename)
{
    writeAll();
    m_name = profilename;
    readWhiteList(); //get whitelist from file
    resetWhiteList();
    readBlackList(); //get blacklist from file
    readOptions();
    emit nameChanged();
}

//Function checks if whitelist is not empty and compares its size with index
bool Profile::isWhiteList()
{
    if ( m_indexWhiteList < m_whiteList.size() ) return true;
    return false;
}

//Function returns true if dir belongs to blacklist
bool Profile::isInBlackList(QString dir)
{
    for ( int i = 0; i < m_blackList.size(); i++ ) {
       if( m_blackList.at(i).indexOf(dir) >= 0 ) return true;
    }
    return false;
}

//Function gets current entry from whitelist and increments index
QString Profile::getNextFromWhiteList()
{
    if ( isWhiteList() ) {
        m_indexWhiteList++;
        return m_whiteList.at(m_indexWhiteList-1);
    }
    return QString();
}

//Function sets index to begin of whitelist
void Profile::resetWhiteList()
{
        m_indexWhiteList=0;
}

void Profile::reloadWBLists()
{
    m_whiteList.clear();
    readWhiteList();
    m_blackList.clear();
    readBlackList();
}

//Function reads whitelist from settings file. It assumes valid profile name.
void Profile::readWhiteList()
{
    Settings settings;

    m_whiteList = settings.readStringList(m_name + " Whitelist");
}

//Function reads blacklist from settings file. It assumes valid profile name.
void Profile::readBlackList()
{
    Settings settings;

    m_blackList = settings.readStringList(m_name + " Blacklist");
}

//Function writes whitelist to settings file. It assumes valid profile name.
void Profile::writeWhiteList()
{
    Settings settings;

    settings.remove(m_name + " Whitelist");
    settings.writeStringList(m_name + " Whitelist", m_whiteList);
}

//Function writes blacklist to settings file. It assumes valid profile name.
void Profile::writeBlackList()
{
    Settings settings;

    settings.remove(m_name + " Blacklist");
    settings.writeStringList(m_name + " Blacklist", m_blackList);
}

void Profile::readOptions()
{
    Settings settings;

    m_description = settings.read(m_name+" Options/description", QString(""));
    m_searchHiddenFiles = settings.read(m_name+" Options/searchHiddenFiles", true);
    m_enableSymlinks = settings.read(m_name+" Options/enableSymlinks", false);
    m_singleMatchSetting = settings.read(m_name+" Options/showOnlyFirstMatch", true);
    m_maxResultsPerSection = settings.read(m_name+" Options/maxResultsPerSection", 50);
    m_enableTxt = settings.read(m_name+" Sections/enableTxtSection", true);
    m_enableHtml = settings.read(m_name+" Sections/enableHtmlSection", true);
    m_enableSrc = settings.read(m_name+" Sections/enableSrcSection", true);
    m_enableSqlite = settings.read(m_name+" Sections/enableSqliteSection", true);
    m_enableNotes = settings.read(m_name+" Sections/enableNotesSection", true);

}

void Profile::writeOptions()
{
    Settings settings;

    settings.write(m_name+" Options/description", m_description);
    settings.write(m_name+" Options/searchHiddenFiles", m_searchHiddenFiles);
    settings.write(m_name+" Options/enableSymlinks", m_enableSymlinks);
    settings.write(m_name+" Options/showOnlyFirstMatch", m_singleMatchSetting);
    settings.write(m_name+" Options/maxResultsPerSection", m_maxResultsPerSection);
    settings.write(m_name+" Sections/enableTxtSection", m_enableTxt);
    settings.write(m_name+" Sections/enableHtmlSection", m_enableHtml);
    settings.write(m_name+" Sections/enableSrcSection", m_enableSrc);
    settings.write(m_name+" Sections/enableSqliteSection", m_enableSqlite);
    settings.write(m_name+" Sections/enableNotesSection", m_enableNotes);
}

void Profile::writeAll()
{
    if (m_unsaved) {
        writeOptions();
        writeWhiteList();
        writeBlackList();
        m_unsaved=false;
    }
}

bool Profile::getBoolOption(Options key)
{
    switch( key )
    {
    case SearchHiddenFiles:
        return m_searchHiddenFiles;
        break;
    case EnableSymlinks:
        return m_enableSymlinks;
        break;
    case SingleMatchSetting:
        return m_singleMatchSetting;
        break;
    case EnableTxt:
        return m_enableTxt;
        break;
    case EnableHtml:
        return m_enableHtml;
        break;
    case EnableSrc:
        return m_enableSrc;
        break;
    case EnableSqlite:
        return m_enableSqlite;
        break;
    case EnableNotes:
        return m_enableNotes;
        break;

    default:
        return false;
        break;
    }
}

int Profile::getIntOption(Options key)
{
    switch( key )
    {
    case MaxResultsPerSection:
        return m_maxResultsPerSection;
        break;

    default:
        return 0;
        break;
    }
}

void Profile::setOption(Options key, bool value)
{
    switch( key )
    {
    case SearchHiddenFiles:
        m_searchHiddenFiles=value;
        m_unsaved=true;
        break;
    case EnableSymlinks:
        m_enableSymlinks=value;
        m_unsaved=true;
        break;
    case SingleMatchSetting:
        m_singleMatchSetting=value;
        m_unsaved=true;
        break;
    case EnableTxt:
        m_enableTxt=value;
        m_unsaved=true;
        break;
    case EnableHtml:
        m_enableHtml=value;
        m_unsaved=true;
        break;
    case EnableSrc:
        m_enableSrc=value;
        m_unsaved=true;
        break;
    case EnableSqlite:
        m_enableSqlite=value;
        m_unsaved=true;
        break;
    case EnableNotes:
        m_enableNotes=value;
        m_unsaved=true;
        break;

    default:
        break;
    }
}

void Profile::setOption(Options key, int value)
{
    switch( key )
    {
    case MaxResultsPerSection:
        m_maxResultsPerSection=value;
        m_unsaved=true;
        break;

    default:
        break;
    }
}
