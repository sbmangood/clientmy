#include "mxresloader.h"

MxResLoader::MxResLoader(QObject *parent) : QObject(parent)
{

}

MxResLoader::~MxResLoader()
{

}

QString MxResLoader::polygonPanelFrame()
{
    QFile editframesource;
    editframesource.setFileName(":/PolygonPanelWidget.qml");

    if(!editframesource.open(QIODevice::ReadOnly))
    {
        return "";
    }
    else
    {
        QString editframestring = editframesource.readAll();
        editframesource.close();

        return editframestring;
    }
}
//圆形
QString MxResLoader::ellipsePanelFrame()
{
    QFile editframesource;
    editframesource.setFileName(":/EllipsePanelWidget.qml");

    if(!editframesource.open(QIODevice::ReadOnly))
    {
        return "";
    }
    else
    {
        QString editframestring = editframesource.readAll();
        editframesource.close();

        return editframestring;
    }
}

