#ifndef TOOLBAR_H
#define TOOLBAR_H

#include <QObject>
#include "../controlcenter/controlcenter.h"

class ToolBar: public QObject
{
  Q_OBJECT
public:
    explicit ToolBar(QObject *parent = 0);
    ~ToolBar();


    //设置鼠标形状
    Q_INVOKABLE void selectShape(int shapeType);
    //设置画笔尺寸
    Q_INVOKABLE void setPaintSize(double size);
    //设置画笔颜色
    Q_INVOKABLE void setPaintColor(int color);
    //设置橡皮大小
    Q_INVOKABLE void setErasersSize(double size);

    //回撤轨迹数据
    Q_INVOKABLE void undoTrail();
    //清除多个轨迹数据
    Q_INVOKABLE void clearTrails();

    Q_INVOKABLE void uninit();

    // 加载课件
    Q_INVOKABLE void insertCourseWare(QJsonArray imgUrlList, QString fileId,QString h5Url,int coursewareType);

    // 跳转课件页,type 1翻页 2加页 3减页
    Q_INVOKABLE void goCourseWarePage(int type,int pageNo,int totalNumber);

    // 得到课件偏移量
    Q_INVOKABLE void getOffsetImage(QString imageUrl, double offsetY);

    // h5动画播放
    Q_INVOKABLE void sendH5PlayAnimation(int step);

    // 滚动长图
    Q_INVOKABLE void updataScrollMap(double scrollY);

    // 设置当前图片高度
    Q_INVOKABLE void setCurrentImageHeight(int height);

    Q_INVOKABLE void initVideoChancel();// 初始化频道
    Q_INVOKABLE void changeChanncel();// 切换频道
    Q_INVOKABLE void closeAudio(QString status);// 关闭音频
    Q_INVOKABLE void closeVideo(QString status);// 关闭视频
    Q_INVOKABLE void setStayInclassroom();// 设置留在教室
    Q_INVOKABLE void exitChannel();// 退出频道

    //用户授权
    Q_INVOKABLE void setUserAuth(QString userId, int up, int trail,int audio,int video);

    //全体禁言
    Q_INVOKABLE void allMute(int muteStatus);

    Q_INVOKABLE void uploadLog();// 上传日志

private:
    ControlCenter* m_control;
signals:
    void sigSynCoursewareType(int courseware, QString h5Url);
    void sigPromptInterface(QString interfaces);
    void sigJoinroom(unsigned int uid, QString userId, int status);

    void sigCurrentImageHeight(double imageHeight);
    void reShowOffsetImage(int width, int height);

public slots:
    void onSigEnterOrSync(int sync );//同步信息

};

#endif // TOOLBAR_H
