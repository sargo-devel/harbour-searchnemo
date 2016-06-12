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

#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QScopedPointer>
#include <QQuickView>
#include <QQmlEngine>
#include <QGuiApplication>
#include <QTranslator>
#include <QSettings>
#include <QQmlContext>
#include <QtQuick/QQuickPaintedItem>

#include "searchengine.h"
#include "filedata.h"
#include "txtfileview.h"
#include "notesfileview.h"
#include "sqlfileview.h"
#include "consolemodel.h"
#include "settings.h"

int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/template.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));

    QTranslator defaultTranslator;
    QString locale = "en_US";
    if(!defaultTranslator.load("harbour-searchnemo-" + locale, SailfishApp::pathTo("translations").toLocalFile())) {
        qDebug() << "Couldn't load translation for locale "<< locale << " from " << SailfishApp::pathTo("translations").toLocalFile();
    }
    app->installTranslator(&defaultTranslator);

    QSettings settings;
    QString langSet = settings.value("langSetting", "default").toString();
    QTranslator translator;
    locale = langSet;
    qDebug() << "get locale=" <<locale;
    if (locale == "default") locale = QLocale::system().name();
    qDebug() << "set locale=" <<locale;
    if(!translator.load("harbour-searchnemo-" + locale, SailfishApp::pathTo("translations").toLocalFile())) {
        qDebug() << "Couldn't load translation for locale "<< locale << " from " << SailfishApp::pathTo("translations").toLocalFile();
    }
    app->installTranslator(&translator);

    qmlRegisterType<SearchEngine>("harbour.searchnemo.SearchEngine", 1, 0, "SearchEngine");
    qmlRegisterType<FileData>("harbour.searchnemo.FileData", 1, 0, "FileData");
    qmlRegisterType<TxtFileView>("harbour.searchnemo.TxtFileView", 1, 0, "TxtFileView");
    qmlRegisterType<NotesFileView>("harbour.searchnemo.NotesFileView", 1, 0, "NotesFileView");
    qmlRegisterType<SqlFileView>("harbour.searchnemo.SqlFileView", 1, 0, "SqlFileView");
    qmlRegisterType<ConsoleModel>("harbour.searchnemo.ConsoleModel", 1, 0, "ConsoleModel");
    qmlRegisterType<Settings>("harbour.searchnemo.Settings", 1, 0, "Settings");

    QString homedir=QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
    //qDebug() << "homedir=" << homedir;
    QString dirname=settings.value("startDir", "").toString();
    if (dirname.isEmpty()) dirname=homedir;
    if (argc > 1) dirname = QString(argv[1]);
    QString startDir=(QDir(dirname).exists())?dirname:homedir;
    qDebug() << "startDir=" << startDir;

    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->setSource(SailfishApp::pathTo("qml/harbour-searchnemo.qml"));
    view->rootObject()->setProperty("startDir", startDir);
    view->show();

    return app->exec();
}
