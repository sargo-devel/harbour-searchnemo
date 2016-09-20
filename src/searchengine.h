#ifndef SEARCHENGINE_H
#define SEARCHENGINE_H

#include <QDir>

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
    Q_PROPERTY(bool running READ running() NOTIFY runningChanged())

public:
    explicit SearchEngine(QObject *parent = 0);
    ~SearchEngine();

    // property accessors
    QString profilename() const { return m_profilename; }
    void setProfilename(QString profilename);
    bool running() const;

    // callable from QML
    Q_INVOKABLE void search(QString searchTerm);
    Q_INVOKABLE void cancel();

signals:
    void profilenameChanged();
    void runningChanged();

    void progressChanged(QString directory);
    void matchFound(QString fullname, QString filename, QString absoluteDir,
                    QString fileIcon, QString fileKind, QString searchtype, QString displabel, QString matchline, int matchcount);
    void workerDone();
    void workerErrorOccurred(QString message, QString filename);

private slots:
    void emitMatchFound(QString fullpath, QString searchtype, QString displabel, QString matchline, int matchcount);

private:
    QString m_profilename;
    QString m_errorMessage;
    SearchWorker *m_searchWorker;
};

#endif // SEARCHENGINE_H
