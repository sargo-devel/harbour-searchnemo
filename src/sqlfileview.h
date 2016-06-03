#ifndef SQLFILEVIEW_H
#define SQLFILEVIEW_H

#include "txtfileview.h"
#include <QHash>

class SqlFileView : public TxtFileView
{
    Q_OBJECT

    Q_PROPERTY(QString displabel READ displabel WRITE setDisplabel NOTIFY displabelChanged)

public:
    explicit SqlFileView(QObject *parent = 0);
    //SqlFileView(const QString& fullpath);
    ~SqlFileView();

    //get fields names of complete row of table given in m_displabel
    Q_INVOKABLE QStringList getRowNames() const;
    //get fields values of complete row of table given in m_displabel
    Q_INVOKABLE QStringList getRowValues() const;

    // changed virtual property accessors
    void setFullpath(QString fullpath);
    // property accessors
    QString displabel() const { return m_displabel; }
    void setDisplabel(QString displabel);

signals:
    void displabelChanged();

public slots:

private:
    QString m_displabel; //contains owner:table:column:row of database
    QString m_element; //open element
};

#endif // SQLFILEVIEW_H
