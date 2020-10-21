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
#include<QStandardPaths>
#include<QFile>
#include "../datahandl/sockethandler.h"
#include "../datahandl/messagemodel.h"

#include "../datahandl/datamodel.h"
#include"getoffsetimage.h"

#ifdef USE_OSS_AUTHENTICATION
#include "./cloudclassroom/cloudclassManager/YMHttpClient.h"
#include "./cloudclassroom/cloudclassManager/YMEncryption.h"
#endif

#if 1

const double scrollRate = 0.618;//屏幕比例常量

class TrailBoard : public QQuickPaintedItem
{
    Q_OBJECT
public:

    //  TrailBoard();
    explicit TrailBoard(QQuickPaintedItem *parent = 0);
    //    virtual ~TrailBoard();

    //设置画笔颜色
    Q_INVOKABLE void setPenColor(int pencolors);
    //改变画笔尺寸
    Q_INVOKABLE void changeBrushSize(double size);

    //设置鼠标类型
    Q_INVOKABLE void setCursorShapeTypes(int types);
    //设置橡皮的大小
    Q_INVOKABLE void setEraserSize(double size);
    //回撤
    Q_INVOKABLE void undo();

    //增加一页
    Q_INVOKABLE void addPage();

    //删除一页
    Q_INVOKABLE void deletePage();

    //跳转某一页
    Q_INVOKABLE void goPage(int pageIndex);

    //画几何图形
    Q_INVOKABLE void drawLocalGraphic(QString cmd, double backGroundHeight, double ImageY);

    //上传图片成功后发送额指令
    Q_INVOKABLE void upLoadSendUrlHttp(QString https);

    //设置图片的比例系数
    Q_INVOKABLE void setPictureRate(double widthRate, double heightRate);

    //设置表情的url
    Q_INVOKABLE void setInterfaceUrls(QString urls);

    //判断表情是否在本地存在
    Q_INVOKABLE QString justImageIsExisting(QString urls);

    //开始上课
    Q_INVOKABLE  void startClassBegin();

    //处理翻页请求
    Q_INVOKABLE void handlePageRequest(bool requests);

    //学生离开教室老师离开教室
    Q_INVOKABLE void leaveClassroom();
    //主动断开
    Q_INVOKABLE void disconnectSocket(bool autoReconnect);//断开连接

    //处理学生离开教室请求
    Q_INVOKABLE  void handlLeaveClassroom(bool leaves);

    //处理b学生进入教室请求
    Q_INVOKABLE  void handlEnterClassroom(bool enters);

    //临时退出
    Q_INVOKABLE void temporaryExitWidget();

    //家庭作业
    Q_INVOKABLE void sendTopicContent(QString tags, QString names, bool status);

    //处理可见信息
    Q_INVOKABLE void handlCoursewareNameInfor(QString contents);

    //设置音频的播放
    Q_INVOKABLE void  setVideoStream(QString types, QString staues, QString times, QString address);

    //设置发送的内容
    Q_INVOKABLE void  setSendStudentId(QString contents);

    //直接发送信息
    Q_INVOKABLE void  directSendInformation(QString contents);

    //主动断开连接
    Q_INVOKABLE void  disconnectSocket();

    //主动退出教室
    Q_INVOKABLE void selectWidgetType(int types);

    //设发送评价
    Q_INVOKABLE  void setSendTopicContent( bool status1,  bool status2,  bool status3, QString tags );

    //保存学生的评价信息
    Q_INVOKABLE  void setSaveStuEvaluationContents( int stuSatisfiedFlag, QString optionId, QString otherReason );

    //设置申请翻页
    Q_INVOKABLE void setApplyPage();

    //控制本地摄像头
    Q_INVOKABLE void setOperationVideoOrAudio(QString userId,  QString videos,  QString audios);

    //ip切换
    Q_INVOKABLE  void setChangeOldIpToNew();

    //发送延迟信息
    Q_INVOKABLE void setSigSendIpLostDelay(QString infor);

    //发送结束课程请求
    Q_INVOKABLE void setSendEndLessonRequest();

    //提交学生作业答案
    Q_INVOKABLE void sendStudentAnswerToTeacher(QJsonObject questionInfo);

    Q_INVOKABLE  void sendOpenAnswerParse(QString planId, QString columnId, QString questionId, QString childQuestionId, bool isOpen);

    Q_INVOKABLE  void sendOpenCorrect(QString planId, QString columnId, QString questionId, QString childQuestionId, bool isOpen);


    //点击栏目发送命令
    Q_INVOKABLE void selectedMenuCommand(int pageIndex/*页索引*/, int planId /*讲义Id*/, int cloumnId /*栏目Id*/);

    //滚动长图命令
    Q_INVOKABLE void updataScrollMap(double scrollY);

    //获取前课件类型
    Q_INVOKABLE int getCurrentCourwareType();


    //获得课堂评价原因内容
    Q_INVOKABLE void  getUnsatisfactoryOptions();

    //获取是否启用不满意不扣课时 弹窗
    Q_INVOKABLE bool  checkReduceLesson();

    Q_INVOKABLE int getNetworkStatus();//当前网络状态 无线 有线
    Q_INVOKABLE void deviceLoad();//当前电脑设备信息
    Q_INVOKABLE void operationClearScreen(int type,int pageNo,int totalNum);

    //抢答器
    Q_INVOKABLE void sendResponderMsg(int types);

#ifdef USE_OSS_AUTHENTICATION
    Q_INVOKABLE void getOssSignUrl(QString ImgUrl);//题库题目进行验签
    Q_INVOKABLE void updateOssSignStatus(bool status);
#endif

public slots:
    void reNewCloudModifyPageData(QJsonValue questionData, bool isVisible);

protected:
    //画图
    void paint(QPainter *painter);

    void mousePressEvent(QMouseEvent *event);
    void mouseMoveEvent(QMouseEvent *event);
    void mouseReleaseEvent(QMouseEvent *event);

    void mouseDoubleClickEvent(QMouseEvent *event);


signals:
    void sigChangeCurrentPage(int currentPage); //设置当前的页
    void sigChangeTotalPage(int totalPage); //设置全部当前的总页数
    void sigSendUrl(QString urls, double width, double height);
    void sigDroppedRoomIds(QString ids); //掉线
    void sigToolWidgetHide();//底下工具栏隐藏
    void sigToolWidgetShow();//底下工具栏显示

    // void sigCursorPointer(bool statues , int pointx , int pointy);//发送教鞭位置跟状态
    void sigSendHttpUrl(QString urls);

    //提示窗口
    void sigPromptInterface(QString interfaces);
    void sigStartClassTimeData(QString times);

    //关闭教室
    void sigCloseAllWidgets();


    //上传成功返回
    void sigEndWidget();

    void sigSendDocIDPageNo(QString contents);

    void updateFileurlCOntent();

    //鼠标按压
    void sigMousePress();
    //退出教室的id
    void sigExitRoomIds(QString ids);

    //教鞭坐标
    void sigPointerPosition(double xPoint, double yPoint);
    //关闭摄像头操作
    void  sigUserIdCameraMicrophone(QString usrid, QString camera,  QString microphone);

    //视频控制
    void sigVideoAudioUrl( QString avType, QString startTime, QString controlType, QString avUrl );

    //集中画布
    void sigFocusTrailboard();

    //没有网络
    void justNetConnect(bool hasNetConnect);

    //自动切换ip
    void autoChangeIpResult(QString autoChangeIpStatus);



    //*** ******************************
    //加载新的讲义课件
    void sigShowNewCourseware(QJsonValue coursewareData);
    //加载新课件的对应的栏目
    void sigShowNewCoursewareItem(QJsonValue coursewareItemData);
    //开始练习
    void sigStarAnswerQuestion(QJsonValue questionData);
    //停止练习
    void sigStopAnswerQuestion(QJsonValue questionData);

    //打开答案解析 questionData 包含题目所在的 讲义id 对应的栏目 以及对应的 题的id
    void sigOpenAnswerParsing(QJsonValue questionData);
    //关闭答案解析
    void sigCloseAnswerParsing(QJsonValue questionData);
    //打开批改面板 /**/
    void sigOpenCorrect(QJsonValue questionData, bool isVisible);
    //关闭批改面板
    void sigCloseCorrect(QJsonValue questionData);
    //开始批改界面
    void sigCorrect(QJsonValue questionData);
    //转图后的讲义图片
    void sigAutoPicture(QJsonValue questionData);

    //隐藏提醒显示界面 显示画板
    void sigHideQuestionView(bool hideColumnMenu);

    //更新当行栏目ui
    void sigUpdateCloumMenuIndex(int columnId);

    //更新当前批改和 解析面板
    void sigUpdateCloudModifyPageView(QJsonObject questionData);

    //滚动长图命令
    void sigZoomInOut(double offsetX, double offsetY, double zoomRate);

    //获取课件列表失败
    void sigGetLessonListFail();

    //new 发送当前图 转化后的长度
    void sigCurrentImageHeight(double imageHeight);

    //获取课堂评价所有的原因成功信号
    void sigGetUnsatisfactoryOptions(QJsonObject optionsData);

    //网络变化信号:有线、无线
    void sigInterNetChange(int netStatus);
    void sigCPURate(int cpuRate);//CPU使用率
    void sigTrophy(QString userId);//奖杯信号
    void sigAuthChange(QString userId,int up,int trail,int audio,int video);//授权信号
    void sigMuteChange(QString userId,int muteStatus);//全体禁音、恢复
    void sigResetTimerView(QJsonObject timerData);//重设计时器界面
    void sigPlayAv(QJsonObject avData);//播放音视频文件
    void sigStartRandomSelectView(QJsonObject randomData);//开始随机选人
    void sigStartResponder(QJsonObject responderData);//开始抢答


#ifdef USE_OSS_AUTHENTICATION
    //签名信号
    void sigOssSignUrl(QString ossUrl);
#endif

public slots:
    void changeOperateStatus(int status);
    void changePenColor(QColor color);
    void drawPage(MessageModel model);//画一页
    void drawRemoteLine(QString command);//画一条命令

    void openPolygonPanel(int points);
    void openEllipsePanel();
    void changeEraserSize(double size);

    //操作权限
    void onSigAuthtrail(QMap<QString, QString> contents);

    void clearScreen(int type,int pageNo,int totalNum);


    //教鞭位置
    void  onSigPointerPosition(double xpoint, double  ypoint);
    //隐藏教鞭
    void onPointerTimerout();
    //界面尺寸变化
    void onCtentsSizeChanged();

    //同步信息
    void onSigEnterOrSync(int  sync );

    //关闭摄像头操作
    void  onSigUserIdCameraMicrophone(QString usrid, QString camera,  QString microphone);


    void onHttpFinished();

    void onSigSendUrl(QString urls, double width, double height);
    void onSigSendDocIDPageNo(QString docs );

    //上传评价成功
    void onFinishedReply(QNetworkReply* reply);

    //处理结束课程
    void onStudentEndClass( QString usrid);


    //根据滚动命令的 offset值来获取所需的图片 //new
    void getOffSetImage(double offsetX, double offsetY, double zoomRate);

    //获取不满意不扣课时具体信息成功
    void onGetUnsatisfactoryOptionsFinished(QNetworkReply* reply);

    void creatRoomFail();

    void videoQulaity(); //音视频质量信息

public:
    //当前图片的偏移量 //new
    double currentImagaeOffSetY = 0.0;

    //判断当前要画的点是不是在屏幕内
    bool currentPointShouldShow(double pointY);

    double changeYPoinToLocal(double pointY);// 转换Y坐标 将接收到的坐标转换为当前坐标
    double changeYPoinToSend(double pointY);//  将当前坐标转换为 发送时的坐标

private:
    //解析轨迹命令
    void parseTrail(QString command);
    //本地鼠标移动两点画线
    void drawLocalLine();
    //画椭圆
    void drawEllipse(const QRectF &rect, double brushWidth, QColor color, double angle);
    //根据多个点画线
    void drawLine(const QVector<QPointF> &points, double brushWidth, QColor color, int type);
    //绘制贝塞尔曲线
    void drawBezier( QVector<QPointF> &points, double size, QColor penColor, int type);
    void sendTrailMsg(const QVector<QPointF> &points);
    //设置鼠标形状
    void setCursorShape();

public:
    //    SocketHandler * handler;
    bool m_isloadImage;




private:
    QPointF m_lastPoint;
    QPointF m_currentPoint;

    QMutex m_tempTrailMutex;
    QPixmap m_tempTrail;

    QColor m_penColor;
    int m_operateStatus; //0教鞭 1轨迹 2橡皮
    QVector<QPointF> m_currentTrail;//当前正在书写的轨迹坐标点集合
    QVector<QPointF> listr;
    QVector<QPointF> culist;
    QVector<QPointF> listt;
    double m_brushSize;//画笔大小
    double m_eraserSize;//橡皮大小
    // QSize boardSize; //画布大小
    int m_pointCount;

    SocketHandler * m_handler;


    QTimer  * m_pointerTimer;//教鞭隐藏时间
    QTimer *m_videoInfoTime;

    QMap<QString, QString> m_userBrushPermissions;//操作权限


    QPoint m_init;
    int m_cursorShape;


    double m_pictureWidthRate;
    double m_pictureHeihtRate;
    bool debugMake;

    QNetworkAccessManager  * m_httpAccessmanger;//评价信息
    //QPixmap tempTrail;

#ifdef USE_OSS_AUTHENTICATION
    MessageModel bufferModel = MessageModel(0, "", 1.0, 1.0, 1, 0);
#else
    MessageModel bufferModel = MessageModel(0, "", 1.0, 1.0, 1);
#endif

#ifdef USE_OSS_AUTHENTICATION
    YMHttpClient * m_httpClient;
    QString m_httpUrl;
    QMap<QString, long> m_bufferOssKey;
#endif

};
#endif



#endif // TRAILBOARD_H
