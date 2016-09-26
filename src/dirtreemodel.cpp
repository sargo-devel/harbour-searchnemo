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

#include "dirtreemodel.h"
#include <QDebug>

DirtreeModel::DirtreeModel() :
    m_dir(QStandardPaths::writableLocation(QStandardPaths::HomeLocation),
          QString(),
          QDir::Name | QDir::IgnoreCase | QDir::LocaleAware,
          QDir::AllDirs | QDir::NoDot | QDir::Hidden)
{
    load();
    m_start=true;
    initStartList();
}

DirtreeModel::~DirtreeModel()
{
}

void DirtreeModel::filterHidden(bool hidden)
{
    if(hidden) {
        m_dir.setFilter(QDir::AllDirs | QDir::NoDot);
    qDebug()<<"Filter on="<<m_dir.filter();
    }
    else {
        m_dir.setFilter(QDir::AllDirs | QDir::NoDot | QDir::Hidden);
        qDebug()<<"Filter off="<<m_dir.filter();
    }
}

bool DirtreeModel::isFilterHidden()
{
    qDebug()<<"aaa="<<QDir::Filters( QDir::AllDirs|QDir::NoDot );
    qDebug()<<"bbb="<<m_dir.filter();
    if (m_dir.filter() == QDir::Filters( QDir::AllDirs|QDir::NoDot|QDir::Hidden )) qDebug()<<"ok";
    if (m_dir.filter() == QDir::Filters( QDir::AllDirs|QDir::NoDot ) ) return true;
    return false;
}

void DirtreeModel::loadStartList()
{
    beginResetModel();
    m_start=true;
    endResetModel();
    emit pathChanged();
}

void DirtreeModel::initStartList()
{
    SPar par;

    par.isDir = false;
    par.fileName = tr("Home");
    par.filePath = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
    m_startlist.append(par);
    par.fileName = tr("SD card");
    par.filePath = sdcardPath();
    m_startlist.append(par);
    par.fileName = tr("Android storage");
    par.filePath = QStandardPaths::writableLocation(QStandardPaths::HomeLocation) + QString("/android_storage");
    m_startlist.append(par);
    par.fileName = "/";
    par.filePath = "/";
    m_startlist.append(par);
}

int DirtreeModel::rowCount(const QModelIndex& parent) const
{
    if ( parent.isValid() ) return 0;
    if(m_start) return m_startlist.size();
    return m_files.size();
}

QVariant DirtreeModel::data(const QModelIndex& index, int role) const
{
    if(m_start) {
        SPar par = m_startlist[index.row()];
        switch (role)
        {
        case NameRole:
            return par.fileName;
        case PathRole:
            return par.filePath;
        case IsDirRole:
            return par.isDir;
        default:
            return QVariant();
        }
    }

    const QFileInfo& info = m_files[index.row()];
    switch (role)
    {
    case NameRole:
        return info.fileName();
    case PathRole:
        return info.filePath();
    case IsDirRole:
        return info.isDir();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> DirtreeModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[PathRole] = "path";
    roles[IsDirRole] = "isDir";
    return roles;
}

void DirtreeModel::load()
{
    m_files = m_dir.entryInfoList();
}

QString DirtreeModel::path()
{
    if(m_start) return tr("Select");
    return m_dir.path();
}

void DirtreeModel::setPath(const QString& path)
{
    if(m_start) m_start=false;
    beginResetModel();
    m_dir.setPath(path);
    load();
    endResetModel();
    emit pathChanged();
}

void DirtreeModel::cd(const QString& path)
{
    if(m_start) m_start=false;
    beginResetModel();
    m_dir.cd(path);
    load();
    endResetModel();
    emit pathChanged();
}

QString DirtreeModel::sdcardPath() const
{
    // get sdcard dir candidates
    QDir dir("/media/sdcard");
    if (!dir.exists())
        return QString();
    dir.setFilter(QDir::AllDirs | QDir::NoDotAndDotDot);
    QStringList sdcards = dir.entryList();
    if (sdcards.isEmpty())
        return QString();

    // remove all directories which are not mount points
    QStringList mps = mountPoints();
    QMutableStringListIterator i(sdcards);
    while (i.hasNext()) {
        QString dirname = i.next();
        QString abspath = dir.absoluteFilePath(dirname);
        if (!mps.contains(abspath))
            i.remove();
    }

    // none found, return empty string
    if (sdcards.isEmpty())
        return QString();

    // if only one directory, then return it
    if (sdcards.count() == 1)
        return dir.absoluteFilePath(sdcards.first());

    // if multiple directories, then return "/media/sdcard", which is the parent for them
    return "/media/sdcard";
}

QStringList DirtreeModel::mountPoints() const
{
    // read /proc/mounts and return all mount points for the filesystem
    QFile file("/proc/mounts");
    if (!file.open(QFile::ReadOnly | QFile::Text)) {
        return QStringList();
    }
    QTextStream in(&file);
    QString result = in.readAll();

    // split result to lines
    QStringList lines = result.split(QRegExp("[\n\r]"));

    // get columns
    QStringList dirs;
    foreach (QString line, lines) {
        QStringList columns = line.split(QRegExp("\\s+"), QString::SkipEmptyParts);
        if (columns.count() < 6) { // skip broken mount points
            continue;
        }

        QString dir = columns.at(1);
        dirs.append(dir);
    }

    return dirs;
}
