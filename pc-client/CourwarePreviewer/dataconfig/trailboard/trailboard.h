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
#include "../datahandl/messagemodel.h"
#include "../datahandl/datamodel.h"
#include "./videovoice/operationchannel.h"
#include "./cloudclassroom/cloudclassManager/YMHttpClient.h"
#include "./cloudclassroom/cloudclassManager/YMEncryption.h"

#if 1

class TrailBoard : public QQuickPaintedItem
{
        Q_OBJECT
    public:

        //  TrailBoard();
        explicit TrailBoard(QQuickPaintedItem *parent = 0);
        //    virtual ~TrailBoard();
        //设置课堂轨迹
        Q_INVOKABLE void setAllTrails( QByteArray trailData);
        //显示课件
        Q_INVOKABLE void setCourseware(QString message);

        //设置画笔颜色
        Q_INVOKABLE void setPenColor(int pencolors);
        //改变画笔尺寸
        Q_INVOKABLE void changeBrushSize(double size);

        //设置鼠标类型
        Q_INVOKABLE void setCursorShapeTypes(int types);
        //回撤
        Q_INVOKABLE void undo();
        //清屏
        Q_INVOKABLE  void clearScreen();

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

        //同意学生申请结束课程
        Q_INVOKABLE void agreeEndLesson(int types);

        //设发送评价
        Q_INVOKABLE  void setSendTopicContent( QString param1,  QString param2,  QString param3 );
        //设置申请翻页
        Q_INVOKABLE void setApplyPage();

        //控制本地摄像头
        Q_INVOKABLE void setOperationVideoOrAudio(QString userId,  QString videos,  QString audios);

        //控制学生端打开摄像头
        Q_INVOKABLE void setOpenSutdentVideo(QString videoType);

        //ip切换
        Q_INVOKABLE  void setChangeOldIpToNew();

        //通道切换
        Q_INVOKABLE void setAisle(QString aisle);

        //发送延迟信息
        Q_INVOKABLE void setSigSendIpLostDelay(QString infor);

        //用户授权
        Q_INVOKABLE void setUserAuth(QString userId, QString authStatus);

        //
        Q_INVOKABLE QString  justImageIsExisting(QString urls);

        //收回分页权限
        Q_INVOKABLE void setRecoverPage();

        //结束课程之前发送退出教室命令
        Q_INVOKABLE void finishClassRoom();

        //获取当前上课总时长
        Q_INVOKABLE void getCurrentCourseTotalTimer();

        //点击栏目发送命令
        Q_INVOKABLE void selectedMenuCommand(int pageIndex/*页索引*/, int planId /*讲义Id*/, int cloumnId /*栏目Id*/);

        //点击讲义发送命令
        Q_INVOKABLE void lectureCommand(QJsonObject lectureObjecte);

        //发送练习题命令
        Q_INVOKABLE void startExercise(QString questionId, int planId, int columnId);

        //提交练习题命令
        Q_INVOKABLE void commitExercise(QString questionId, int planId, int columnId);

        //传递自动转图片之后发送的讲义图片命令
        Q_INVOKABLE void autoConvertImage(
            int pageIndex,/*页码索引*/
            QString imageUrl,
            int imgWidth,/*图片宽度*/
            int imgHeight,/*图片高度*/
            QString planId,/*对应的讲义id*/
            int cloumnId,/*对应的题目ID*/
            QString quetisonId/*对应的题ID，如果没有为0*/
        );

        //老师结束练习命令
        Q_INVOKABLE void stopQuestion(QString questionId);

        //学生提交答案图片
        Q_INVOKABLE void commitAnswerPicture(QString imageUrl, int imgWidth, int imgHeight);

        //打开答案解析
        Q_INVOKABLE void openAnswerAnalysis(QString planId, int columnId, QString questionId, QString childQuestionId);

        //关闭答案解析
        Q_INVOKABLE void closeAnswerAnalysis(QString planId, int columnId, QString questionId);

        //打开批改面板
        Q_INVOKABLE void openCorrect(QString planId, int columnId, QString questionId);

        //批改命令
        Q_INVOKABLE void correctCommand(
            QString planId,//对应的讲义id
            int columnId,//对应的栏目ID
            QString quetisonId,//对应的题Id
            QString childQuestionId, //小题Id
            int correctType,//批改类型 0 正确 1 错误 2 半对半错
            double score,//得分
            QString errorReason,//你多写两个字符",//错因
            int errorTypeId //错误类型Id
        );

        //关闭批改面板命令
        Q_INVOKABLE void closeModifyPanle(
            int planId,/*对应的讲义id*/
            int columnId,//对应的栏目ID
            QString quetisonId//对应的题ID
        );

        //滚动长图命令
        Q_INVOKABLE void updataScrollMap(double scrollY);

        //获取课件当前页
        Q_INVOKABLE int getCursorPage(QString docId);

        //根据图片偏移量获取图片位置进行显示
        Q_INVOKABLE void getOffsetImage(QString imageUrl, double offsetY);

        //提交图片失败给学生发送失败命令
        Q_INVOKABLE void commitAnserFail(QString questionId, QString planId, QString columnId);
#ifdef USE_OSS_AUTHENTICATION
        Q_INVOKABLE void getOssSignUrl(QString ImgUrl);//题库题目进行验签
        Q_INVOKABLE void updateOssSignStatus(bool status);
#endif

    public:
        double changeYPoinToLocal(double pointY);// 转换Y坐标 将接收到的坐标转换为当前坐标
        double changeYPoinToSend(double pointY);//  将当前坐标转换为 发送时的坐标

    protected:
        //画图
        void paint(QPainter *painter);

        void mousePressEvent(QMouseEvent *event);
        void mouseMoveEvent(QMouseEvent *event);
        void mouseReleaseEvent(QMouseEvent *event);

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
        void sigCurrentQuestionId(QString planId, QString columnId, QString questionId, double offsetY, bool questionBtnStatus); //当前题目信息：讲义、栏目、题目Id信号
        void sigOneStartClass();//第一次开课重置讲义
        void sigCursorPointer(bool statues, int pointx, int pointy);  //发送教鞭位置跟状态
        void sigSendHttpUrl(QString urls);
        void sigOffsetY(double offsetY);
        void sigPlanChange(long lessonId, long planId, long itemId); //讲义同步信号
        void sigCurrentColumn(long planId, long columnId); //栏目同步信号
        void sigIsOpenCorrect(bool isOpenStatus);//打开关闭批改面板
        void sigIsOpenAnswer(bool isOpenStatus, QString questionId, QString childQuestionId); //打开关闭答案解析
        void sigSynColumn(QString planId, QString columnId); //同步菜单栏
        void sigSynQuestionStatus(bool status);//同步开始做题按钮状态 true 开始做题，false 停止做题
        void sigStudentAppversion(bool status);//学生当前版本号 如果小于3.0版本则不支持新讲义
        void sigCurrentImageHeight(double height);
        void sigOssSignUrl(QString ossUrl);

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
        //鼠标弹起
        void sigMouseRelease();
        //退出教室的id
        void sigExitRoomIds(QString ids);

        //教鞭坐标
        void sigPointerPosition(double xPoint, double yPoint);
        //关闭摄像头操作
        void  sigUserIdCameraMicrophone(QString usrid, int status);

        //视频控制
        void sigVideoAudioUrl( QString avType, QString startTime, QString controlType, QString avUrl );

        //删除分页判断是否为分页信号
        void sigIsCourseWare();

        //集中画布
        void sigFocusTrailboard();
        //当前上课总时间
        void sigCurrentLessonTimer(int lessonTimer);

        //自动连接网络三次
        void sigAutoConnectionNetwork();

        //提交练习题命令解析
        void sigAnalysisQuestionAnswer(long lessonId, QString questionId, QString planId, QString columnId);

    public slots:
        void changeOperateStatus(int status);
        void changePenColor(QColor color);
        void drawPage(MessageModel model);//画一页
        void drawRemoteLine(QString command);//画一条命令

        void openPolygonPanel(int points);
        void openEllipsePanel();
        void changeEraserSize(double size);

        void changedWay(QString supplier);//网络切换命令信号
        void changedPage();//跳转分页
        void slotsStartClass(QString startTimer);

        //操作权限
        void onSigAuthtrail(QMap<QString, QString> contents);

        //界面尺寸变化
        void onCtentsSizeChanged();

        //同步信息
        void onSigEnterOrSync(int  sync );

        //关闭摄像头操作
        void  onSigUserIdCameraMicrophone(QString usrid, QString camera,  QString microphone);


        void onHttpFinished();

        void onSigSendUrl(QString urls, double width, double height);
        void onSigSendDocIDPageNo(QString docs );
        //根据滚动坐标获取图片
        void getOffSetImage(double offsetX, double offsetY, double zoomRate);

        //处理结束课程
        void onStudentEndClass( QString usrid);

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
        void drawBezier(const QVector<QPointF> &points, double size, QColor penColor, int type);
        void sendTrailMsg(const QVector<QPointF> &points);
        //设置鼠标形状
        void setCursorShape();

    private:
        QPointF m_lastPoint;
        QPointF m_currentPoint;

        QMutex m_tempTrailMutex;
        QPixmap m_tempTrail;

        QColor m_penColor;
        int m_operateStatus; //0教鞭 1轨迹 2橡皮
        QVector<QPointF> m_currentTrail;//当前正在书写的轨迹坐标点集合
        double m_brushSize;//画笔大小
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

        double m_pictureWidthRate;
        double m_pictureHeihtRate;
        double currentImagaeOffSetY;//还原轨迹属性

        YMHttpClient * m_httpClient;
        QString m_httpUrl;
        QNetworkAccessManager  * m_httpAccessmanger;//评价信息
        //QPixmap tempTrail;

};
#endif



#endif // TRAILBOARD_H
