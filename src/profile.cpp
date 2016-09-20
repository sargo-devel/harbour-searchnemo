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
#include "profile.h"
#include "settings.h"
//#include <QList>

Profile::Profile(QObject *parent, QString name) : QObject(parent)
{
//    m_name=name;
    //if( m_name.isEmpty() ) m_name=tr("Default");


//    m_whiteList.append("/home/nemo/Music");
//    m_whiteList.append("/usr/share/applications");
//    m_whiteList.append("/home/nemo/Pictures");
//    m_whiteList.append("/home/nemo/Documents");
//    m_blackList.append("/home/nemo/Documents/bazy");
//    m_blackList.append("/home/nemo/Pictures/Jolla");

//    writeWhiteList();
//    writeBlackList();


//    readWhiteList(); //get whitelist from file
//    resetWhiteList();
//    readBlackList(); //get blacklist from file

    setNewName(name);

}

Profile::~Profile()
{
}

//Function sets new name of profile, reads all settigs from file, resets index
void Profile::setNewName(QString profilename)
{
    m_name = profilename;
    readWhiteList(); //get whitelist from file
    resetWhiteList();
    readBlackList(); //get blacklist from file
    readOptions();
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

    settings.writeStringList(m_name + " Whitelist", m_whiteList);
}

//Function writes blacklist to settings file. It assumes valid profile name.
void Profile::writeBlackList()
{
    Settings settings;

    settings.writeStringList(m_name + " Blacklist", m_blackList);
}

void Profile::readOptions()
{
    Settings settings;

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

bool Profile::getOption(Options key)
{
    switch( key )
    {
    case searchHiddenFiles:
        return m_searchHiddenFiles;
        break;
    case enableSymlinks:
        return m_enableSymlinks;
        break;
    case singleMatchSetting:
        return m_singleMatchSetting;
        break;
    case enableTxt:
        return m_enableTxt;
        break;
    case enableHtml:
        return m_enableHtml;
        break;
    case enableSrc:
        return m_enableSrc;
        break;
    case enableSqlite:
        return m_enableSqlite;
        break;
    case enableNotes:
        return m_enableNotes;
        break;

    default:
        return false;
        break;
    }
}
