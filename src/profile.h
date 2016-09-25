#ifndef PROFILE_H
#define PROFILE_H

#include <QObject>
#include <QStringList>
#include <QDebug>

class Profile: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name() WRITE setName(QString) NOTIFY nameChanged())
    Q_ENUMS(Options)

public:
    enum Options {
        SearchHiddenFiles,
        EnableSymlinks,
        SingleMatchSetting,
        EnableTxt,
        EnableHtml,
        EnableSrc,
        EnableSqlite,
        EnableNotes,
        MaxResultsPerSection
    };

    explicit Profile(QObject *parent = 0);
    ~Profile();

    QString name() const {return m_name;}
    void setName(QString profilename); //sets new name of profile, reads all settigs from file, resets index
    Q_INVOKABLE QString description() const {return m_description;}
    Q_INVOKABLE void setDescription(QString dsc) {m_description=dsc; m_unsaved=true;}

    Q_INVOKABLE bool getBoolOption(Options key);            //returns value of a given option key
    Q_INVOKABLE int getIntOption(Options key);              //returns value of a given option key
    Q_INVOKABLE void setOption(Options key, int value);     //sets value of a given option key (+unsaved)
    Q_INVOKABLE void setOption(Options key, bool value);    //sets value of a given option key (+unsaved)
    Q_INVOKABLE void writeAll();                            //Writes all settings to file (if changes detected)
    Q_INVOKABLE int countWhiteList() {return m_whiteList.size();}
    Q_INVOKABLE int countBlackList() {return m_blackList.size();}

    bool isWhiteList();                   //Function checks if whitelist is not empty and compares its size with index
    bool isInBlackList(QString dir);      //returns true if dir belongs to blacklist
    QString getNextFromWhiteList();
    void resetWhiteList();                  //resets whitelist index

signals:
    void nameChanged();

public slots:
private:
    QString m_name;             //profile name
    QString m_description;      //profile description
    bool m_unsaved;             //set to true if thera are some pending changes to save in config file
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
