import QtQuick 2.2
import Sailfish.Silica 1.0
import harbour.searchnemo.ConsoleModel 1.0


ConsoleModel {
    //id: consoleModel

    // called when open command exits
    onProcessExited: {
        if (exitCode === 0) {
            if (isApkFile()) {
                notificationPanel.showTextWithTimer(qsTr("Install launched"),
                                           qsTr("If nothing happens, then the package is probably faulty."));
                return;
            }
            if (!isRpmFile())
                notificationPanel.showTextWithTimer(qsTr("Open successful"),
                                           qsTr("Sometimes the application stays in the background"));
        } else if (exitCode === 1) {
            notificationPanel.showTextWithTimer(qsTr("Internal error"),
                                           "xdg-open exit code 1");
        } else if (exitCode === 2) {
            notificationPanel.showTextWithTimer(qsTr("File not found"),
                                           page.file);
        } else if (exitCode === 3) {
            notificationPanel.showTextWithTimer(qsTr("No application to open the file"),
                                           qsTr("xdg-open found no preferred application"));
        } else if (exitCode === 4) {
            notificationPanel.showTextWithTimer(qsTr("Action failed"),
                                           "xdg-open exit code 4");
        } else if (exitCode === -88888) {
            notificationPanel.showTextWithTimer(qsTr("xdg-open not found"), "");

        } else if (exitCode === -99999) {
            notificationPanel.showTextWithTimer(qsTr("xdg-open crash?"), "");

        } else {
            notificationPanel.showTextWithTimer(qsTr("xdg-open error"), "exit code: "+exitCode);
        }
    }
}
