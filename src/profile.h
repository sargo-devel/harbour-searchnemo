#ifndef PROFILE_H
#define PROFILE_H

#include <QObject>
#include <QStringList>

class Profile: public QObject
{
    Q_OBJECT

public:
    enum Options {
        searchHiddenFiles,
        enableSymlinks,
        singleMatchSetting,
        enableTxt,
        enableHtml,
        enableSrc,
        enableSqlite,
        enableNotes
    };

    explicit Profile(QObject *parent = 0, QString name = "Default");
    ~Profile();

    void setNewName(QString profilename); //sets new name of profile, reads all settigs from file, resets index
    bool isWhiteList();                   //Function checks if whitelist is not empty and compares its size with index
    bool isInBlackList(QString dir);      //returns true if dir belongs to blacklist
    QString getNextFromWhiteList();
    void resetWhiteList();
    bool getOption(Options key);          //returns value of a given option key


signals:

public slots:
private:
    QString m_name;             //profile name
    QStringList m_whiteList;    //whitelist of search directories
    int m_indexWhiteList;       //indicates current position in white list
    QStringList m_blackList;    //blacklist of search directories
    bool m_searchHiddenFiles;   //enable/disable search in hidden files
    bool m_enableSymlinks;      //enable/disable follow symlinks
    bool m_singleMatchSetting;  //enable/disable cumulative (single) results match
    int m_maxResultsPerSection; //sets max nr of results in each section
    bool m_enableTxt;           //enable/disable TXT section
    bool m_enableHtml;          //enable/disable HTML section
    bool m_enableSrc;           //enable/disable SRC section
    bool m_enableSqlite;        //enable/disable SQLITE section
    bool m_enableNotes;         //enable/disable NOTES section

    void readWhiteList();       //Function reads whitelist from settings file
    void readBlackList();       //Function reads whitelist from settings file
    void writeWhiteList();      //Function writes whitelist to settings file
    void writeBlackList();      //Function writes blacklist to settings file
    void readOptions();         //Function reads all option from settings file
    void writeOptions();         //Function writes all option to settings file
};

#endif // PROFILE_H