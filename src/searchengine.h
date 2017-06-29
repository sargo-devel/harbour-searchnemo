#ifndef SEARCHENGINE_H
#define SEARCHENGINE_H

#include <QDir>
//#include <QDebug>

class SearchWorker;

/**
 * @brief The SearchEngine is a front-end for the SearchWorker class.
 * These two classes could be merged, but it is clearer to keep the background thread
 * in its own class.
 */
class SearchEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString profilename READ profilename() WRITE setProfilename(QString) NOTIFY profilenameChanged())
    Q_PROPERTY(int maxResultsPerSection READ maxResultsPerSection() NOTIFY maxResultsPerSectionChanged())
    Q_PROPERTY(bool enableAppsRunDirect READ enableAppsRunDirect() NOTIFY enableAppsRunDirectChanged())
    Q_PROPERTY(bool running READ running() NOTIFY runningChanged())

public:
    explicit SearchEngine(QObject *parent = 0);
    ~SearchEngine();

    // property accessors
    QString profilename() const { return m_profilename; }
    void setProfilename(QString profilename);
    int maxResultsPerSection() const { return m_maxResultsPerSection; }
    bool enableAppsRunDirect() const { return m_enableAppsRunDirect; }
    bool running() const;

    // callable from QML
    Q_INVOKABLE void search(QString searchTerm);
    Q_INVOKABLE void cancel();
    Q_INVOKABLE void reloadProfile();

signals:
    void runningChanged();

    void progressChanged(QString directory);
    void matchFound(QString fullname, QString filename, QString absoluteDir,
                    QString fileIcon, QString fileKind, QString searchtype, QString displabel, QString matchline, int matchcount);
    void workerDone();
    void workerErrorOccurred(QString message, QString filename);

    void profilenameChanged();
    void profileSettingsChanged();
    void maxResultsPerSectionChanged();
    void enableAppsRunDirectChanged();

private slots:
    void emitMatchFound(QString fullpath, QString searchtype, QString displabel, QString matchline, int matchcount);
    void emitMaxResultsPerSection();
    void emitEnableAppsRunDirect();

private:
    QString m_profilename;
    int m_maxResultsPerSection;
    bool m_enableAppsRunDirect;
    QString m_errorMessage;
    SearchWorker *m_searchWorker;
    QStringList m_iconPathList;
    void createIconPathList();
    QString getIconPath(QString name);
};

#endif // SEARCHENGINE_H
