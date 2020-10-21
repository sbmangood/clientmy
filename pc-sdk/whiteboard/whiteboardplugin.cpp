#include "whiteboardplugin.h"
#include "whiteboard.h"

#include <qqml.h>

WhiteBoardPlugin::WhiteBoardPlugin(QObject *parent)
    :QQmlExtensionPlugin(parent)
    ,m_whiteBoardCallBack(nullptr)
{

}

WhiteBoardPlugin::~WhiteBoardPlugin()
{

}

void WhiteBoardPlugin::registerTypes(const char *uri)
{
    qmlRegisterType<WhiteBoard>(uri, 1, 0, "WhiteBoard");
}

void WhiteBoardPlugin::setUserAuth(const QString &userId, int userRole, int trailState)
{
    WhiteBoard::getInstance()->setUserAuth(userId, userRole, trailState);
}

void WhiteBoardPlugin::selectShape(int shapeType)
{
    WhiteBoard::getInstance()->setCursorShapeTypes(shapeType);
}

void WhiteBoardPlugin::setPaintSize(double size)
{
    WhiteBoard::getInstance()->changeBrushSize(size);
}

void WhiteBoardPlugin::setPaintColor(int color)
{
    WhiteBoard::getInstance()->setPenColor(color);
}

void WhiteBoardPlugin::setErasersSize(double size)
{
    WhiteBoard::getInstance()->setEraserSize(size);
}

void WhiteBoardPlugin::drawImage(const QString &image)
{

}

void WhiteBoardPlugin::drawGraph(const QString &graph)
{

}

void WhiteBoardPlugin::drawExpression(const QString &expression)
{

}

void WhiteBoardPlugin::drawPointerPosition(double xpoint, double  ypoint)
{
    WhiteBoard::getInstance()->onSigPointerPosition(xpoint, ypoint);
}

void WhiteBoardPlugin::undoTrail()
{
    WhiteBoard::getInstance()->undo();
}

void WhiteBoardPlugin::clearTrails()
{
    WhiteBoard::getInstance()->clearScreen();
}

void WhiteBoardPlugin::drawTrails(const QString &imageUrl, double width, double height, double offsetY, const QString &questionId)
{
//    bool isLongImg = (questionId == "") ? false :  (imageUrl == ""  ? false : true);
    WhiteBoard::getInstance()->drawPage(questionId, offsetY, true);
    WhiteBoard::getInstance()->onSigSendUrl(imageUrl, width, height);
}

void WhiteBoardPlugin::setWhiteBoardCallBack(IWhiteBoardCallBack* whiteBoardCallBack)
{
    m_whiteBoardCallBack = whiteBoardCallBack;
    WhiteBoard::getInstance()->setWhiteBoardCallBack(whiteBoardCallBack);
}

