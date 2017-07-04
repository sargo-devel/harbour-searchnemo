#ifndef TXTFILEVIEW_H
#define TXTFILEVIEW_H


#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QRegularExpression>
#include <QDebug>
#include "profile.h"

class TxtFileView : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString profilename READ profilename() WRITE setProfilename(QString) NOTIFY profilenameChanged())
    Q_PROPERTY(QString fullpath READ fullpath() WRITE setFullpath(QString) NOTIFY fullpathChanged())
    Q_PROPERTY(QString stxt READ stxt() WRITE setStxt(QString) NOTIFY stxtChanged())
    Q_PROPERTY(int allmatchcount READ allmatchcount WRITE setAllmatchcount NOTIFY allmatchcountChanged)
    Q_PROPERTY(QString disptxt READ disptxt WRITE setDisptxt NOTIFY disptxtChanged)
    Q_PROPERTY(QString disptxtplain READ disptxtplain)

public:
    explicit TxtFileView(QObject *parent = 0);
    //TxtFileView(const QString& fullpath);
    ~TxtFileView();
    Q_INVOKABLE QString getAll();
    Q_INVOKABLE void getFirst();
    Q_INVOKABLE void getNext();

    // property accessors
    QString profilename() const {return m_profile.name();}
    void setProfilename(QString profilename) {m_profile.setName(profilename); emit profilenameChanged();}
    QString fullpath() const {return m_fullpath;}
    virtual void setFullpath(QString fullpath);
    QString stxt() const {return m_stxt;}
    void setStxt(QString stxt);
    int allmatchcount() const {return m_allmatchcount;}
    void setAllmatchcount(int allmatchcount);
    QString disptxt() const { return m_disptxt;}
    void setDisptxt(QString disptxt);
    QString disptxtplain() const { return m_disptxtplain;}

signals:
    void stxtChanged();
    void allmatchcountChanged();
    void disptxtChanged();
    void fullpathChanged();
    void profilenameChanged();

public slots:

protected:
    Profile m_profile;
    QFile m_file;
    QString m_fullpath;  // fullpath of file to search
    QString m_stxt;  // text to search for
    QRegularExpression m_stxtRe; // regex to search for
    bool m_isRegEx;  // must be set true if m_stxtRe is valid RegExp
    int m_allmatchcount; //all occurrences of stxt in file, must be delivered as parameter from outside
    int m_hits; //current occurrences of stxt in file
    QString m_disptxt; // result block of text to display (with markups)
    QString m_disptxtplain; // result block of text to display (plain)
    QTextStream m_stream;
    QStringList m_txtbuffer; //contains whole text prepared for display (with markups), each entry contains one line
    QStringList m_plaintxtbuffer; //contains whole text prepared for display (without markups), each entry contains one line
    QList<int> m_txtbufidx; //index for m_txtbuffer containing nr of chars in each line
    int m_stxtidx; //contains index of first line in m_txtbuffer which contains stxt

    int m_maxbefore; //max nr of virt. lines before first found text
    int m_maxbuflen; //max nr of virt. lines in whole displayed text
    int m_maxlinelen; //max nr of chars in one virt. line

    bool isBufferSizeOk();
    bool isMaxBeforeOk();
    void prepareRegex();
    QString addBoldMarks(QString txtline);
    void getBlock();
};

#endif // TXTFILEVIEW_H
