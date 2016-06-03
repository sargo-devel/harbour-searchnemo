#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>


class Settings : public QObject
{
    Q_OBJECT


public:
    explicit Settings(QObject *parent = 0);
    ~Settings();

    // access settings
    Q_INVOKABLE QString read(QString key, QString defaultValue = QString());
    Q_INVOKABLE void write(QString key, QString value);
signals:
    void settingsChanged();

public slots:

private:

};

#endif // SETTINGS_H
