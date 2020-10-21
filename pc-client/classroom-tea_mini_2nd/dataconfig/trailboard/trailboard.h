#ifndef TRAILBOARD_H
#define TRAILBOARD_H


#include <QQmlApplicationEngine>
#include <QtQuick>
#include <QDebug>
#include <QMutex>
#include <QCursor>
#include <QPainterPath>
#include <QPolygon>
#include <QRegion>
#include <qDebug>
#include <QPainter>
#include <QQuickPaintedItem>
#include <QTimer>
#include <QQuickItem>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QTransform>
#include <QProcess>
#include "../datahandl/sockethandler.h"
#include "./dataconfig/datahandl/messagemodel.h"
#include "../datahandl/datamodel.h"
#include "./cloudclassroom/cloudclassManager/YMHttpClient.h"

#if 1

class TrailBoard : public QObject
{
        Q_OBJECT
    public:

        //  TrailBoard();
        explicit TrailBoard(QObject *parent = 0);
        //    virtual ~TrailBoard();

        //显示课件
        Q_INVOKABLE void setCourseware(QString message);

        //小班课翻页
        Q_INVOKABLE void miniClassGoPage(int type,int pageNo,int totalNumber);//type1翻页 2加页 3删页

        //开始上课
        Q_INVOKABLE  void startClassBegin();

        //主动断开
        Q_INVOKABLE void disconnectSocket(bool autoReconnect);//断开连接

        //临时退出
        Q_INVOKABLE void temporaryExitWidget();

        //处理可见信息
        Q_INVOKABLE void handlCoursewareNameInfor(QString contents);

        //设置音频的播放
        Q_INVOKABLE void  setVideoStream(QString types, QString staues, QString times, QString address,QString fileId,QString suffix);

        //主动断开连接
        Q_INVOKABLE void  disconnectSocket();

        //ip切换
        Q_INVOKABLE  void setChangeOldIpToNew();

        //通道切换
        Q_INVOKABLE void setAisle(QString aisle);

        //发送延迟信息
        Q_INVOKABLE void setSigSendIpLostDelay(QString infor);

        //用户授权
        Q_INVOKABLE void setUserAuth(QString userId, int up, int trail,int audio,int video);

        //
        Q_INVOKABLE QString  justImageIsExisting(QString urls);

        //结束课程之前发送退出教室命令
        Q_INVOKABLE void finishClassRoom();

        //滚动长图命令
        Q_INVOKABLE void updataScrollMap(double scrollY);

        //获取课件当前页
        Q_INVOKABLE int getCursorPage(QString docId);

        //根据图片偏移量获取图片位置进行显示
        Q_INVOKABLE void getOffsetImage(QString imageUrl, double offsetY);

        //设置当前图片高度
        Q_INVOKABLE void setCurrentImageHeight(int height);
        Q_INVOKABLE int getNetworkStatus();//当前网络状态 无线 有线
        Q_INVOKABLE void uploadLoadingImgFailLog(QString data);//课件加载失败日志上传
        Q_INVOKABLE void allMute(int muteStatus);//全体禁音

        //缓存云盘课件内容
        Q_INVOKABLE void insertCourseWare(QJsonArray imgUrlList, QString fileId,QString h5Url,int coursewareType);

        //随机选人
        Q_INVOKABLE void sendRandomSelectMsg(QString userId, int type, QString userName);
        //发送奖杯
        Q_INVOKABLE void sendReward(QString userId, QString userName);

        //抢答器
        Q_INVOKABLE void sendResponderMsg(int runTimes, int types);

        //计时器 倒计时
        Q_INVOKABLE void sendTimerMsg(int timerType, int flag, int timesec);

        //h5动画播放
        Q_INVOKABLE void sendH5PlayAnimation(int step);

    signals:
        void sigChangeCurrentPage(int currentPage); //设置当前的页
        void sigChangeTotalPage(int totalPage); //设置全部当前的总页数
        void sigSendUrl(QString urls, double width, double height, bool isLongImg, QString questionId);
        void sigDroppedRoomIds(QString ids); //掉线
        void sigSendUserId(QString userId);//传递Id用做读取数据
        void sigToolWidgetHide();//底下工具栏隐藏
        void sigToolWidgetShow();//底下工具栏显示
        void sigNetworkOnline(bool online);//网络是否在线信号
        void autoChangeIpResult(QString autoChangeIpStatus);

        void sigOneStartClass();//第一次开课重置讲义
        void sigCursorPointer(bool statues, int pointx, int pointy);  //发送教鞭位置跟状态
        void sigSendHttpUrl(QString urls);
        void sigOffsetY(double offsetY);
        void sigStudentAppversion(bool status);//学生当前版本号 如果小于3.0版本则不支持新讲义
        void sigCurrentImageHeight(double height);
        void sigOssSignUrl(QString ossUrl);
        void sigJoinClassroom(QString userId);//学生进入教室信号

        //提示窗口
        void sigPromptInterface(QString interfaces);
        void sigStartClassTimeData(QString times);

        //关闭教室
        void sigCloseAllWidgets();

        //上传成功返回
        void sigEndWidget();

        void sigSendDocIDPageNo(QString contents);

        void updateFileurlCOntent();

        //退出教室的id
        void sigExitRoomIds(QString ids);

        //教鞭坐标
        void sigPointerPosition(double xPoint, double yPoint);
        //关闭摄像头操作
        void  sigUserIdCameraMicrophone(QString usrid, int status);

        //视频控制
        void sigVideoAudioUrl(int flag, int time, QString dockId);

        //删除分页判断是否为分页信号
        void sigIsCourseWare(bool isCourseware);

        //集中画布
        void sigFocusTrailboard();
        //当前上课总时间
        void sigCurrentLessonTimer(int lessonTimer);

        //自动连接网络三次
        void sigAutoConnectionNetwork();
        //老课件暂未生成信号
        void sigGetCoursewareFaill();
        //网络变化信号
        void sigInterNetChange(int netStatus);

        //用户权限信号
        void sigUserAuth(QString userId,int up,int trail,int audio,int video,bool isSynStatus);
        void sigStartResponder(QJsonObject responderData);//开始抢答
        void sigIsOnline(int uid,QString onlineStatus);
        void sigSynCoursewareType(int docType,QString h5Url);
        void sigSynCoursewareInfo(QJsonObject jsonObj);
        void sigSynCoursewareStep(QString pageId,int step);
        void sigClearScreen();//清屏信号

    public slots:
        void drawPage(MessageModel model);//画一页
        void slotsStartClass(QString startTimer);

        //操作权限
        void onSigAuthtrail(QMap<QString, QString> contents);

        //同步信息
        void onSigEnterOrSync(int  sync );

        //关闭摄像头操作
        void  onSigUserIdCameraMicrophone(QString usrid, QString camera,  QString microphone);


        void onHttpFinished();

        void onSigSendUrl(QString urls, double width, double height);
        void onSigSendDocIDPageNo(QString docs );
        //根据滚动坐标获取图片
        void getOffSetImage(double offsetX, double offsetY, double zoomRate);

    private:
        QPointF m_currentPoint;

        QMutex m_tempTrailMutex;
        QPixmap m_tempTrail;
        QVector<QPointF> m_currentTrail;//当前正在书写的轨迹坐标点集合
        double m_eraserSize;//橡皮大小
        // QSize boardSize; //画布大小
        int m_pointCount;
        QVector<QPointF> listr;
        QVector<QPointF> culist;
        QVector<QPointF> listt;
        MessageModel bufferModel;
        SocketHandler * m_handler;
        QTimer  * m_pointerTimer;//教鞭隐藏时间
        QMap<QString, QString> m_userBrushPermissions;//操作权限
        QMap<QString, long> m_bufferOssKey;


        QPoint m_init;
        int m_cursorShape;
        int m_currentImageHeight;
        double currentImagaeOffSetY;//还原轨迹属性

        YMHttpClient * m_httpClient;
        QString m_httpUrl;
        QNetworkAccessManager  * m_httpAccessmanger;//评价信息
        //QPixmap tempTrail;

};
#endif



#endif // TRAILBOARD_H
