#include "searchengine.h"
#include <QDateTime>
#include "searchworker.h"
#include "statfileinfo.h"
#include "globals.h"

SearchEngine::SearchEngine(QObject *parent) :
    QObject(parent)
{
    m_profilename = "";
    m_searchWorker = new SearchWorker;
    connect(m_searchWorker, SIGNAL(matchFound(QString, QString, QString, QString, int)), this, SLOT(emitMatchFound(QString, QString, QString, QString, int)));

    // pass worker end signals to QML
    connect(m_searchWorker, SIGNAL(progressChanged(QString)),
            this, SIGNAL(progressChanged(QString)));
    connect(m_searchWorker, SIGNAL(done()), this, SIGNAL(workerDone()));
    connect(m_searchWorker, SIGNAL(errorOccurred(QString, QString)),
            this, SIGNAL(workerErrorOccurred(QString, QString)));

    connect(m_searchWorker, SIGNAL(started()), this, SIGNAL(runningChanged()));
    connect(m_searchWorker, SIGNAL(finished()), this, SIGNAL(runningChanged()));
}

SearchEngine::~SearchEngine()
{
    // is this the way to force stop the worker thread?
    m_searchWorker->cancel(); // stop possibly running background thread
    m_searchWorker->wait();   // wait until thread stops
    delete m_searchWorker;    // delete it
}

void SearchEngine::setProfilename(QString profilename)
{
    if (m_profilename == profilename)
        return;

    m_profilename = profilename;

    emit profilenameChanged();
}

bool SearchEngine::running() const
{
    return m_searchWorker->isRunning();
}

void SearchEngine::search(QString searchTerm)
{
    // if search term is not empty, then restart search
    if (!searchTerm.isEmpty()) {
        m_searchWorker->cancel();
        m_searchWorker->wait();
        m_searchWorker->startSearch(m_profilename, searchTerm);
    }
}

void SearchEngine::cancel()
{
    m_searchWorker->cancel();
}

void SearchEngine::emitMatchFound(QString fullpath, QString searchtype, QString displabel, QString matchline, int matchcount)
{
    StatFileInfo info(fullpath);
    emit matchFound(fullpath, info.fileName(), info.absoluteDir().absolutePath(),
                    infoToIconName(info), info.kind(), searchtype, displabel, matchline, matchcount);
}
