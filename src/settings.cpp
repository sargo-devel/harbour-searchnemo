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
#include "settings.h"

Settings::Settings(QObject *parent) : QObject(parent)
{
}

Settings::~Settings()
{
}

QString Settings::read(QString key, QString defaultValue)
{
    QSettings settings;
    return settings.value(key, defaultValue).toString();
}

void Settings::write(QString key, QString value)
{
    QSettings settings;

    if (settings.value(key) == value) return;
    settings.setValue(key, value);
    emit settingsChanged();
}

bool Settings::dirExists(QString dir)
{
    return QDir(dir).exists();
}
