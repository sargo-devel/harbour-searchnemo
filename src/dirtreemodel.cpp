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
          QDir::AllDirs | QDir::NoDot)
{
    load();
    qDebug() << "Dirtree constructor m_dir=" << m_dir.absolutePath();
}

DirtreeModel::~DirtreeModel()
{
}

int DirtreeModel::rowCount(const QModelIndex& parent) const
{
    if ( parent.isValid() ) return 0;
    return m_files.size();
}

QVariant DirtreeModel::data(const QModelIndex& index, int role) const
{
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
    return m_dir.path();
}

void DirtreeModel::setPath(const QString& path)
{
    beginResetModel();
    m_dir.setPath(path);
    load();
    endResetModel();
    emit pathChanged();
}

void DirtreeModel::cd(const QString& path)
{
    beginResetModel();
    m_dir.cd(path);
    load();
    endResetModel();
    emit pathChanged();
}
