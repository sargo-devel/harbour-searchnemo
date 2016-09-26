#ifndef DIRTREEMODEL_H
#define DIRTREEMODEL_H

#include <QAbstractListModel>
#include <QtQuick>

class DirtreeModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString path READ path() WRITE setPath(QString&) NOTIFY pathChanged())

public:
    enum ItemRole {
        NameRole = Qt::UserRole + 1,
        PathRole,
        IsDirRole
    };

    DirtreeModel();
    ~DirtreeModel();

    // methods needed by ListView
    int rowCount(const QModelIndex& parent = QModelIndex()) const;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;
    QHash<int, QByteArray> roleNames() const;

    QString path();
    void setPath(const QString& path);

    Q_INVOKABLE void cd(const QString& path);
    Q_INVOKABLE bool isStartSet() { return m_start; }
    Q_INVOKABLE void filterHidden(bool hidden);
    Q_INVOKABLE bool isFilterHidden();
    Q_INVOKABLE void loadStartList();

signals:
    void pathChanged();

private:

    struct SPar {
        QString fileName;
        QString filePath;
        bool isDir;
    };
    QList<SPar> m_startlist;

    QString m_path;
    QDir m_dir;
    QFileInfoList m_files;
    bool m_start;

    void load();
    void initStartList();
    QString sdcardPath() const;
    QStringList mountPoints() const;

};

#endif // DIRTREEMODEL_H
