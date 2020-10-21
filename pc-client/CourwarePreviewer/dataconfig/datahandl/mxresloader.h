#ifndef MXRESLOADER_H
#define MXRESLOADER_H

#include <QObject>
#include <QFile>
#include <QDesktopServices>
#include <QProcess>
#include <QDebug>

class MxResLoader : public QObject
{
        Q_OBJECT

        Q_PROPERTY(QString polygonPanelFrame READ polygonPanelFrame)
        Q_PROPERTY(QString ellipsePanelFrame READ ellipsePanelFrame)


    public:
        explicit MxResLoader(QObject *parent = 0);
        virtual ~MxResLoader();
    signals:

    public slots:

    private:
        QString polygonPanelFrame(); //读取图形内容
        QString ellipsePanelFrame();//圆形

};

#endif // MXRESLOADER_H
