#ifndef NOTESFILEVIEW_H
#define NOTESFILEVIEW_H

#include "txtfileview.h"

class NotesFileView : public TxtFileView
{
    Q_OBJECT

    // property accessors
    Q_PROPERTY(QString notenr READ notenr WRITE setNotenr NOTIFY notenrChanged)

public:
    explicit NotesFileView(QObject *parent = 0);
    //NotesFileView(const QString& fullpath);
    ~NotesFileView();

    // changed virtual property accessors
    void setFullpath(QString fullpath);
    // property accessors
    QString notenr() const { QString str; return str.setNum(m_notenr);}
    void setNotenr(QString notenr);

signals:
    void notenrChanged();

public slots:

private:
    int m_notenr; //note nr in Notes database
    QString m_note; //open note content
};

#endif // NOTESFILEVIEW_H
