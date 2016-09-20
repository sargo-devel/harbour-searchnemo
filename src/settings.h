#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QStringList>

class Settings : public QObject
{
    Q_OBJECT


public:
    explicit Settings(QObject *parent = 0);
    ~Settings();

    // access settings
    Q_INVOKABLE QString read(QString key, QString defaultValue = QString());
    Q_INVOKABLE bool read(QString key, bool defaultValue);
    Q_INVOKABLE int read(QString key, int defaultValue);
    Q_INVOKABLE void write(QString key, QString value);
    Q_INVOKABLE bool dirExists(QString dir);
    Q_INVOKABLE QStringList readStringList(QString group);
    Q_INVOKABLE void writeStringList(QString group, QStringList list);

signals:
    void settingsChanged();

public slots:

private:

};

#endif // SETTINGS_H
