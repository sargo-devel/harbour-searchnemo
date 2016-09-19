#ifndef PROFILE_H
#define PROFILE_H

#include <QObject>
#include <QStringList>

class Profile: public QObject
{
    Q_OBJECT

public:
    explicit Profile(QObject *parent = 0, QString name = "Default");
    ~Profile();

    bool isWhiteList();         //Function checks if whitelist is not empty and compares its size with index
    bool isInBlackList(QString dir);      //returns true if dir belongs to blacklist
    QString getNextFromWhiteList();
    void resetWhiteList();

signals:

public slots:
private:
    QString m_name;             //profile name
    QStringList m_whiteList;    //whitelist of search directories
    int m_indexWhiteList;       //indicates current position in white list
    QStringList m_blackList;    //blacklist of search directories
    bool m_searchHiddenFiles;   //enable/disable search in hidden files
    bool m_enableSymlinks;      //enable/disable follow symlinks

    void readWhiteList();       //Function reads whitelist from settings file
    void readBlackList();       //Function reads whitelist from settings file
    void writeWhiteList(); //Function writes whitelist to settings file
    void writeBlackList(); //Function writes blacklist to settings file

    struct Login1 {
        QString userName;
        QString password;
    };

    QList<Login1> logins;
    Login1 x;


};

#endif // PROFILE_H
