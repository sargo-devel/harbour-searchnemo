#include "searchengine.h"
#include <QDateTime>
#include <QIcon>
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

    connect(m_searchWorker, SIGNAL(profileSettingsChanged()), this, SIGNAL(profileSettingsChanged()));
    connect(m_searchWorker, SIGNAL(profileSettingsChanged()), this, SLOT(emitMaxResultsPerSection()));
    connect(m_searchWorker, SIGNAL(profileNameChanged()), this, SIGNAL(profilenameChanged()));

    //for icons recognition
    createIconPathList();
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

void SearchEngine::emitMaxResultsPerSection()
{
    m_maxResultsPerSection = m_searchWorker->getProfileOption_MaxResultsPerSection();
    emit maxResultsPerSectionChanged();
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

        qDebug()<<"ikonka="<<icon;
    }
    emit matchFound(fullpath, info.fileName(), info.absoluteDir().absolutePath(),
                    icon, info.kind(), searchtype, displabel, matchline, matchcount);
}

QString SearchEngine::getIconPath(QString name)
{
    QString path;
    QFileInfo check(name);

    if(check.exists()) return name;
    foreach(QString dir, m_iconPathList) {
        path = dir+name+".png";
        QFileInfo file(path);
        if (file.exists()) return path;
    }
    return "image://theme/icon-m-sailfish";
}

void SearchEngine::createIconPathList()
{
    m_iconPathList.clear();
    m_iconPathList.append("/usr/share/icons/hicolor/86x86/apps/");
    m_iconPathList.append("/usr/share/themes/jolla-ambient/meegotouch/z1.0/icons/");
    m_iconPathList.append("/usr/share/themes/sailfish-default/meegotouch/z1.0/icons/");
    m_iconPathList.append("/var/lib/apkd/");
}
