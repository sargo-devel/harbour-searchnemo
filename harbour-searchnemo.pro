# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-searchnemo

CONFIG += sailfishapp

QT += sql

SOURCES += src/harbour-searchnemo.cpp \
    src/searchengine.cpp \
    src/searchworker.cpp \
    src/statfileinfo.cpp \
    src/globals.cpp \
    src/filedata.cpp \
    src/jhead/jhead-api.cpp \
    src/jhead/exif.c \
    src/jhead/gpsinfo.c \
    src/jhead/iptc.c \
    src/jhead/jpgfile.c \
    src/jhead/jpgqguess.c \
    src/jhead/makernote.c \
    src/consolemodel.cpp \
    src/dbsqlite.cpp \
    src/txtfileview.cpp \
    src/notesfileview.cpp \
    src/sqlfileview.cpp \
    src/settings.cpp \
    src/dirtreemodel.cpp \
    src/profile.cpp

OTHER_FILES += qml/harbour-searchnemo.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-searchnemo.changes.in \
    rpm/harbour-searchnemo.spec \
    rpm/harbour-searchnemo.yaml \
    translations/*.ts \
    harbour-searchnemo.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
##CONFIG += sailfishapp_i18n_idbased
# CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-searchnemo-de_DE.ts
TRANSLATIONS += translations/harbour-searchnemo-pl_PL.ts
TRANSLATIONS += translations/harbour-searchnemo-en_US.ts
TRANSLATIONS += translations/harbour-searchnemo-sv_SE.ts
TRANSLATIONS += translations/harbour-searchnemo-it_IT.ts

#translations.files = translations/*.qm
#translations.path = /usr/share/$${TARGET}
#INSTALLS += translations

# automatic generation of the translation .qm files from .ts files
##system(lrelease -idbased -markuntranslated ! $$PWD/translations/*.ts)

DISTFILES += \
    todo.txt \
    qml/pages/SearchPage.qml \
    qml/pages/About.qml \
    qml/pages/HtmlView.qml \
    qml/pages/FileView.qml \
    qml/pages/DetailsView.qml \
    qml/pages/TxtView.qml \
    qml/pages/SqlView.qml \
    qml/pages/NotesView.qml \
    qml/pages/SelectCopy.qml \
    qml/pages/ConsModel.qml \
    qml/pages/viewadds/FileInfoColumn.qml \
    qml/pages/viewadds/SearchButtons.qml \
    qml/components/CenteredField.qml \
    qml/components/DirPopup.qml \
    qml/components/DoubleMenuItem.qml \
    qml/components/InteractionBlocker.qml \
    qml/components/LetterSwitch.qml \
    qml/components/NotificationPanel.qml \
    qml/components/ProgressPanel.qml \
    qml/components/Spacer.qml \
    qml/pages/functions.js \
    qml/pages/viewadds/fileviewfunctions.js \
    qml/pages/SettingsPage.qml \
    qml/pages/SqlRecordView.qml \
    qml/pages/viewadds/AnimatedHeader.qml \
    translations/harbour-searchnemo-sv_SE.ts \
    qml/pages/DirTree.qml

HEADERS += \
    src/searchengine.h \
    src/searchworker.h \
    src/statfileinfo.h \
    src/globals.h \
    src/filedata.h \
    src/jhead/jhead-api.h \
    src/jhead/jhead.h \
    src/consolemodel.h \
    src/dbsqlite.h \
    src/txtfileview.h \
    src/notesfileview.h \
    src/sqlfileview.h \
    src/settings.h \
    src/dirtreemodel.h \
    src/profile.h

#lupdate_only {
#    TRANSLATIONS = translations/*.ts
#}
