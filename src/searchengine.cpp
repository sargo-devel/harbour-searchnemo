#include "searchengine.h"
#include <QDateTime>
#include <QIcon>
#include "searchworker.h"
#include "statfileinfo.h"
#include "globals.h"
#include <QDebug>

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

    connect(m_searchWorker, SIGNAL(profileSettingsChanged()), this, SIGNAL(profileSettingsChanged()));
    connect(m_searchWorker, SIGNAL(profileSettingsChanged()), this, SLOT(emitMaxResultsPerSection()));
    connect(m_searchWorker, SIGNAL(profileSettingsChanged()), this, SLOT(emitEnableAppsRunDirect()));
    connect(m_searchWorker, SIGNAL(profileSettingsChanged()), this, SLOT(emitEnableRegEx()));
    connect(m_searchWorker, SIGNAL(profileNameChanged()), this, SIGNAL(profilenameChanged()));
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
    m_searchWorker->setProfile(m_profilename);
//    emit profilenameChanged();
}

void SearchEngine::reloadProfile()
{
    m_searchWorker->setProfile(m_profilename);
}

void SearchEngine::emitMaxResultsPerSection()
{
    m_maxResultsPerSection = m_searchWorker->getProfileOption_MaxResultsPerSection();
    emit maxResultsPerSectionChanged();
}

void SearchEngine::emitEnableAppsRunDirect()
{
    m_enableAppsRunDirect = m_searchWorker->getProfileOption_EnableAppsRunDirect();
    emit enableAppsRunDirectChanged();
}

void SearchEngine::emitEnableRegEx()
{
    m_enableRegEx = m_searchWorker->getProfileOption_EnableRegEx();
    emit enableRegExChanged();
}

void SearchEngine::setEnableRegEx(bool regex)
{
    m_enableRegEx = regex;
    m_searchWorker->setProfileOption_EnableRegEx(regex);
    emit enableRegExChanged();
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
    QString icon = infoToIconName(info);
    if(searchtype == "APPS") {
        //displabel comes from searchworker in form "name::icon"
        QStringList list = displabel.split("::");
        displabel = list[0];
        icon = getIconPath(list[1]);
        matchline = list[2].size() == 0 ? tr("Application") : list[2];
    }
    emit matchFound(fullpath, info.fileName(), info.absoluteDir().absolutePath(),
                    icon, info.kind(), searchtype, displabel, matchline, matchcount);
}

QString SearchEngine::getIconPath(QString name)
{
    QFileInfo check(name);

    if(check.exists()) return name;
    return "image://theme/"+name;

    //return "image://theme/icon-m-sailfish";
}
