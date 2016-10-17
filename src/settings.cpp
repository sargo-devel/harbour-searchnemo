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

#include <QSettings>
#include <QDir>
#include <QStandardPaths>
//#include <QDebug>
#include "settings.h"
#include "dirtreemodel.h"

Settings::Settings(QObject *parent) : QObject(parent)
{
}

Settings::~Settings()
{
}

void Settings::addDefaultSet()
{
    QString name = tr("Home dir");
    remove(name + " Whitelist");
    remove(name + " Blacklist");
    remove(name + " Options");
    remove(name + " Sections");
    QStringList list = readStringList("ProfilesList");
    remove("ProfilesList");
    if(!list.contains(name)) list.append(name);
    writeStringList("ProfilesList",list);
    write(name + " Options/description", tr("Entire home directory with hidden files"));
    writeStringList(name + " Whitelist",
                    QStringList(QStandardPaths::writableLocation(QStandardPaths::HomeLocation)));

    name = tr("SD card");
    remove(name + " Whitelist");
    remove(name + " Blacklist");
    remove(name + " Options");
    remove(name + " Sections");
    list.clear();
    list = readStringList("ProfilesList");
    remove("ProfilesList");
    if(!list.contains(name)) list.append(name);
    writeStringList("ProfilesList",list);
    write(name + " Options/description", tr("Entire SD card with hidden files"));
    writeStringList(name + " Whitelist", QStringList(DirtreeModel::sdcardPath()));

    name = tr("Applications");
    remove(name + " Whitelist");
    remove(name + " Blacklist");
    remove(name + " Options");
    remove(name + " Sections");
    list.clear();
    list = readStringList("ProfilesList");
    remove("ProfilesList");
    if(!list.contains(name)) list.append(name);
    writeStringList("ProfilesList",list);
    write(name + " Options/description", tr("All installed applications"));
    writeStringList(name + " Whitelist", QStringList("/usr/share/applications"));
    write(name+" Options/maxResultsPerSection", 200);
    write(name+" Sections/enableTxtSection", false);
    write(name+" Sections/enableHtmlSection", false);
    write(name+" Sections/enableSrcSection", false);
    write(name+" Sections/enableAppsSection", true);
    write(name+" Sections/enableSqliteSection", false);
    write(name+" Sections/enableNotesSection", false);
    write(name+" Sections/enableFileDirSections", false);

    name = tr("Entire tree");
    remove(name + " Whitelist");
    remove(name + " Blacklist");
    remove(name + " Options");
    remove(name + " Sections");
    list.clear();
    list = readStringList("ProfilesList");
    remove("ProfilesList");
    if(!list.contains(name)) list.append(name);
    writeStringList("ProfilesList",list);
    write(name + " Options/description", tr("Entire dir tree. Warning: very long search"));
    writeStringList(name + " Whitelist", QStringList("/"));
}

QString Settings::read(QString key, QString defaultValue)
{
    QSettings settings;
    //qDebug()<<"string";
    return settings.value(key, defaultValue).toString();
}

bool Settings::read(QString key, bool defaultValue)
{
    QSettings settings;
    //qDebug()<<"bool";
    return settings.value(key, defaultValue).toBool();
}

int Settings::read(QString key, int defaultValue)
{
    QSettings settings;
    //qDebug()<<"int"<<key;
    return settings.value(key, defaultValue).toInt();
}

void Settings::write(QString key, QString value)
{
    QSettings settings;

    if (settings.value(key).toString() == value) return;
    settings.setValue(key, value);
    //qDebug()<<"string";
    emit settingsChanged();
}

void Settings::write(QString key, int value)
{
    QSettings settings;

    if (settings.value(key).toInt() == value) return;
    settings.setValue(key, value);
    //qDebug()<<"int";
    emit settingsChanged();
}

void Settings::write(QString key, bool value)
{
    QSettings settings;

    //if (settings.value(key).toBool() == value) return;
    settings.setValue(key, value);
    //qDebug()<<"bool";
    emit settingsChanged();
}

void Settings::remove(QString group)
{
    QSettings settings;

    settings.remove(group);
    emit settingsChanged();
}

void Settings::writeStringList(QString group, QStringList list)
{
    QSettings settings;

    settings.beginWriteArray(group);
    for (int i = 0; i < list.size(); ++i) {
        settings.setArrayIndex(i);
        settings.setValue("list", list.at(i));
    }
    settings.endArray();
    emit settingsChanged();
}

QStringList Settings::readStringList(QString group)
{
    QSettings settings;
    QStringList list;

    int size = settings.beginReadArray(group);
    for (int i = 0; i < size; ++i) {
        settings.setArrayIndex(i);
        list.append( settings.value("list").toString() );
    }
    settings.endArray();
    return list;
}

void Settings::copyGroups(QString srcgrp, QString dstgrp)
{
    QSettings settings;
    QStringList keys, values;

    //read
    settings.beginGroup(srcgrp);
    keys=settings.childKeys();
    for (int i=0; i<keys.size(); i++) {
        values.append(settings.value(keys.at(i)).toString());
    }
    settings.endGroup();

    //write
    settings.beginGroup(dstgrp);
    for(int i=0; i<keys.size(); i++) {
        settings.setValue(keys.at(i), values.at(i));
    }
    settings.endGroup();
    emit settingsChanged();
}

void Settings::copyArrays(QString srcarr, QString dstarr)
{
    QStringList list;

    list=readStringList(srcarr);
    if (list.size() > 0) writeStringList(dstarr, list);
}

//checks if name exists in list
bool Settings::nameExists(QStringList list, QString name)
{
    return list.contains(name);
}

bool Settings::dirExists(QString dir)
{
    return QDir(dir).exists();
}
