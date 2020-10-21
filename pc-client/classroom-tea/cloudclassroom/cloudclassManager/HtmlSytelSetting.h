#ifndef HTMLSYTELSETTING_H
#define HTMLSYTELSETTING_H

#include <QObject>
#include <QFile>
#include <QIODevice>
#include <QStandardPaths>
#include <QTextStream>
#include <QDir>
#include <QDebug>

class HtmlSytelSetting : public QObject
{
        Q_OBJECT
    public:
        explicit HtmlSytelSetting(QObject * parent = 0);

    public:
        Q_INVOKABLE void updateHtml(QString content);

    signals:
        void sigUpdateSuccess(QString htmlUrl);
};

#endif // HTMLSYTELSETTING_H
