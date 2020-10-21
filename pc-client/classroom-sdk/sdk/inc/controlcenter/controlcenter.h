/*******************************************************************************
 *  Copyright(c) 2000-2019 YM
 *  All rights reserved.
 *
 *  FileName:  controlcenter.h
 *  Description: control center class
 *
 *  Author: ccb
 *  Date: 2019/06/20 11:35:00
 *  Version: V4.5.1
 *
 *  History:
 *  <author>     <time>        <version>    <desc>
 *  ccb          2019/06/20    V4.5.1       创建文件
*******************************************************************************/

#ifndef CONTROLCENTER_H
#define CONTROLCENTER_H
#include <QObject>
#include <QMutex>
#include <QString>
#include <QStringList>
#include <QJsonObject>
#include <QQmlContext>
#include <QtCore/qglobal.h>
#include "datamodel.h"
#include"imageprovider.h"
#include "getoffsetimage.h"

#if defined(CONTROLCENTER_LIBRARY)
#  define CONTROLCENTERSHARED_EXPORT Q_DECL_EXPORT
#else
#  define CONTROLCENTERSHARED_EXPORT
#endif

class CoursewareCenter;
class AudioVideoCenter;
class WhiteBoardCenter;
class SocketManagerCenter;
class CONTROLCENTERSHARED_EXPORT ControlCenter : public QObject
{
    Q_OBJECT
public:
    ~ControlCenter();
    static ControlCenter* getInstance();
    //初始化控制中心
    void initControlCenter(const QString &pluginDirPath, const QString &configFilePath, int screenWidth, int screenHeight);
    //反初始化控制中心
    void uninitControlCenter(); 
    // 用户授权
    void setUserAuth(QString userId, int up, int trail,int audio,int video);

    ImageProvider* getImageProvider();
    GetOffsetImage* getGetOffsetImageInstance();

public:
    /************************WhiteBoard***********************************************/
    //设置鼠标形状
    void selectShape(int shapeType);
    //设置画笔尺寸
    void setPaintSize(double size);
    //设置画笔颜色
    void setPaintColor(int color);
    //设置橡皮大小
    void setErasersSize(double size);
    //绘制图像
    void drawImage(const QString &image);
    //绘制图形
    void drawGraph(const QString &graph);
    //绘制表情
    void drawExpression(const QString &expression);
    //绘制教鞭位置
    void drawPointerPosition(double xpoint, double  ypoint);
    //回撤
    void undoTrail();
    //清屏
    void clearTrails();
    //绘制整屏轨迹
    void drawTrails();

    /************************IM****************************************************/
    //消息异步推送
    void asynSendMessage(const QString &message);
    //消息同步推送
    void syncSendMessage(const QString &message);

    /************************课件****************************************************/
    void insertCourseWare(QJsonArray imgUrlList, QString fileId, QString h5Url, int coursewareType);// 加载课件
    void goCourseWarePage(int type, int pageNo, int totalNumber);// 跳转课件页,type 1翻页 2加页 3减页
    void getOffsetImage(QString imageUrl, double offsetY);
    void setCurrentImageHeight(int height); // 设置当前图片高度
    void updataScrollMap(double scrollY);// 滚动长图
    void sendH5PlayAnimation(int step);// H5动画播放
    void drawCoursewarePage();      // 画一页

    /************************音视频****************************************************/
    void initVideoChancel();// 初始化频道
    void changeChanncel();// 切换频道
    void closeAudio(QString status);// 关闭音频
    void closeVideo(QString status);// 关闭视频
    void setStayInclassroom();// 设置留在教室
    void exitChannel();// 退出频道
    void allMute(int muteStatus);// 全体禁音

    /************************其他****************************************************/
    void processMsg(const QString &command, const QJsonObject &jsonMsg, const QString& message);
    void sendLocalMessage(QString message, bool asynSend, bool drawPage);

private:
    ControlCenter(QObject *parent = 0);

    void doSocketAck(const QJsonObject &jsonObj);
    void doSocketEnterRoom(const QJsonObject & jsonMsg);
    void doSocketExitRoom(const QJsonObject & jsonObj);
    void doSocketDrawTrails(const QString &command, const QJsonObject &jsonObj, QString &msg);    //及时通讯信息-需要重绘画板
    void doSocketUsersStatus(QJsonValue &contentValue);

    //获取指定目录及其子目录下文件的全路径
    QStringList getFilePathNameOfSplAndChildDir(QString dirPath);
    //获取在指定目录下的目录的路径
    QStringList getDirPathOfSplDir(QString dirPath);
    // 获取指定目录下的文件路径+名称
    QStringList getFilePathNameOfSplDir(const QString &dirPath);
    //获取配置文件信息
    int getConfigFileInfo(const QString &configFilePath);

    //确认退出房间
    void finishRespExitRoom(void);
    //更新用户状态
    void updateUserState(QJsonValue content);
    //同步历史记录
    bool syncUserHistroyReq(QJsonArray& userHistroyData);
    //同步完成
    void syncUserHistroyComplete(void);
    //解析命令
    void processUserCommandOp(const QString& command, const QJsonObject &jsonMsg, QString& message);
    QString getMessageCommand(const QJsonObject &jsonMsg);
    QString getMessageUid(const QJsonObject &jsonMsg);
    quint32 getMessageSN(const QJsonObject &jsonMsg);
    int getCurrentPage(QString docId);// 通过docId得到当前页
    int getCurrentCoursewarePage();// 获取当前页码

    QString parseMessageDockId(QString& message);
    QString parseMessagePageId(QString& message);
    void parseDocMessage(QString& fromUid, QString& message);
    void parseOperationMessage(QString& fromUid, QString& message);
    void parseTrailMessage(QString& fromUid, QString& message);
    void parsePageMessage(QString& fromUid, QString& message);
    void parseAnimationMessage(QString message);
    bool parseCoursewareInfo(QString& message);

    void cachePonitMessage(QString& fromUid, const QJsonObject &jsonMsg);
    void cacheAVMessage(QString& fromUid, const QJsonObject &jsonMsg);
    void cacheAuthMessage(QString& fromUid, const QJsonObject &jsonMsg);
    void cacheMuteAllMessage(QString& fromUid, const QJsonObject &jsonMsg);
    void cacheZoomMessage(QString& fromUid, const QJsonObject &jsonMsg);
    void cacheStartClass(void);

    quint64 createTimeStamp(void);    //毫秒级别时间邮戳
    void initRectInfo(int width, int height);
    QJsonObject stringToJsonParse(const QString &message);

signals:
    void renderVideoFrameImage(unsigned int uid, QImage image, int rotation);// 传送视频图片帧的信号
    void sigJoinroom(unsigned int uid, QString userId, int status);
    void sigCurrentImageHeight(double imageHeight);
    void reShowOffsetImage(int width, int height);

    void sigEnterOrSync(int  sync);
    void sigSendUserId(QString userId);
    void sigIsCourseWare(bool isCourseware);
    void sigUserAuth(QString userId,int up,int trail,int audio,int video,bool isSynStatus);

private:
    static QMutex m_instanceMutex;
    static ControlCenter* m_controlCenter;

    CoursewareCenter* m_coursewareCenter;
    AudioVideoCenter* m_audioVideoCenter;
    WhiteBoardCenter* m_whiteBoardCenter;
    SocketManagerCenter* m_socketManagerCenter;
};

#endif // CONTROLCENTER_H
