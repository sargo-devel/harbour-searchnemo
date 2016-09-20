#ifndef SEARCHWORKER_H
#define SEARCHWORKER_H

#include <QThread>
#include <QDir>
#include <QTextStream>
#include "profile.h"

/**
 * @brief SearchWorker does searching in the background.
 */
class SearchWorker : public QThread
{
    Q_OBJECT

public:
    explicit SearchWorker(QObject *parent = 0);
    ~SearchWorker();

    void startSearch(QString profilename, QString searchTerm);

    void cancel();

signals: // signals, can be connected from a thread to another

    void progressChanged(QString directory);

    void matchFound(QString fullname, QString searchtype, QString displabel, QString matchline, int matchcount);

    // one of these is emitted when thread ends
    void done();
    void errorOccurred(QString message, QString filename);

protected:
    void run();

private:
    enum CancelStatus {
        Cancelled = 0, NotCancelled = 1
    };

    QString searchRecursively(QString directory, QString searchTerm);
    QString addSearchTXT(QString searchtype, QString searchTerm, QDir dir, QDir::Filter hidden, bool singleMatch);
    QString addSearchNotes(QString searchtype, QString searchTerm, bool singleMatch);
    QString addSearchSqlite(QString searchtype, QString searchTerm, QDir dir, QDir::Filter hidden, bool singleMatch);
    bool searchTxtLoop(QTextStream *intxt, QString searchtype, QString searchTerm, bool singleMatch, QString fullpath, QString displabel);
    bool m_alreadySearchedNotes;

    Profile m_profile;
    QString m_directory;
    QString m_searchTerm;
    QAtomicInt m_cancelled; // atomic so no locks needed
    QString m_currentDirectory;
};

#endif // SEARCHWORKER_H
