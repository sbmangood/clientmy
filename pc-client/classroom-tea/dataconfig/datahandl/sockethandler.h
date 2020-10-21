#ifndef SOCKETHANDLER_H
#define SOCKETHANDLER_H

#include <QObject>
#include <QAbstractSocket>
#include <QMutex>
#include <QTime>
#include <QMap>
#include <QDebug>
#include "./messagemodel.h"
#include "./datamodel.h"
#include "./ymtcpsocket.h"
#include "./cloudclassroom/cloudclassManager/YMHttpClient.h"
#include"../YMCommon/qosManager/YMQosManager.h"
#include "./cloudclassroom/cloudclassManager/YMEncryption.h"
#include "../../../pc-common/AudioVideoSDKs/AudioVideoManager.h"

class QTcpSocket;
class QTimer;

class SocketHandler : public QObject
{
    Q_OBJECT
public:
    explicit SocketHandler(QObject *parent = 0);
    void sendLocalMessage(QString cmd, bool append, bool drawPage);
    int getCurrentPage(QString docId);

    void excuteMsg(QString &msg, QString &fromUser);

    void clearRecord();

    //ip切换
    void onChangeOldIpToNew();

    void setFirstPage(int pages);
    void disconnectSocket(bool reconnect);
signals:
    void sigEnterOrSync(int  sync);
    void sigExitRoomIds(QString ids);//退出教室的id
    void sigDroppedRoomIds(QString ids); //掉线
    void sigSendUserId(QString userId);
    void sigUserIdExitClassroom(QString userId);
    void sigEnterRoomRequest(QString userId);
    void sigSendHttpUrl(QString urls);
    //处理结束课程
    void sigStudentEndClass( QString usrid);
    void sigStartClassTimeData(QString times);
    void sigNetworkOnline(bool online);//网络是否在线状态信号
    void sigChangedWay(QString supplier);//切换通道命令信号
    void sigChangedPage();//跳转分页
    void sigOneStartClass();//第一次开课重置讲义
    void sigStudentAppversion(bool status,bool canImportReportImg);//学生当前版本号 如果小于3.0版本则不支持新讲义
    void sigInterNetChange(int netWorkStatus);
    void sigListenMicophone();//老师退出或者异常退出，且学生仍留在教室信号
    void sigDisapperListenMicophone(); //隐藏对话框: "老师已退出, 学生停留在教室, 是否立即开始与学生沟通?"
    void sigJoinMicCommand();//上麦命令
    void sigSetStartClassStatus(int iStatus); //设置收到start class的响应后的状态

    void sigStuChangeVersionToOld();//学生之前用新版本上课 后来换成老版本 弹窗提示老师学生版本过低

    void sigCancleInsertHomeWork();//学生版本过低不能导入课堂作业

    //关闭摄像头操作
    void  sigUserIdCameraMicrophone(QString usrid, QString camera,  QString microphone, bool bShowCameraMsg, bool bShowMicMsg);

    //允许操作权限
    void sigAuthtrail(QMap<QString, QString>);

    //教鞭坐标
    void sigPointerPosition(double xPoint, double yPoint);

    //getbackAisle 返回原来的通道
    void getbackAisle();
    void sigStartLessonFail(QString userId);//其它人已经上课，上课失败

    void sigHideTeaWaitHandMicView(int handMic);//隐掉老师等待cc接麦的界面
    void sigShowCCWhetherHoldMicView(int handMic);//显示cc是否接麦界面

    void sigChangedV2ToV1(); // 腾讯V2切换至V1通道

public slots:
    void undo();
    void addPage();
    void deletePage();
    void goPage(int pageIndex);
    void picture(QString url, double width, double height);
    void clearScreen();
    //判断自动切换ip的结果
    void justChangeIp(bool isSuccess);
    void autoChangeIp();
    void interNetworkChange();

    void sendReportImgs(QJsonArray imgarry);

    void socketTimeOut();//socket链接超时

private slots:
    void readMessage(QString line);//接收消息
    void sendMessage(QString message);
    void sendMessage();
    void sendAudioQuality();

    void sendC2cDelay();

    void reGetCourseImg();

signals:
    void sigUsersInRoom(QList<QString> users);
    void sigBrushPermisions(QMap<QString, QString> brushPermisions);
    void sigPagePermisions(QMap<QString, QString> pagePermisions);
    void sigSupplier(QString supplier);
    void sigVideoType(QString videoType);
    void sigDrawLine(QString command);
    // void sigAuthtrail(QMap<QString, QString>);
    void sigEnterFailed();
    //视频控制
    void sigAvUrl( QString avType, QString startTime, QString controlType, QString avUrl );
    //自动切换线路结果
    // autoChangeIpStatus 自动切换IP状态 showAutoChangeIpview 显示网络不好; autoChangeIpSuccess 自动切换ip 成功; autoChangeIpFail 自动切换ip失败
    void autoChangeIpResult(QString autoChangeIpStatus);
    void sigCurrentLessonTimer(int lessonTimer);//当前上课总时间
    void sigAutoConnectionNetwork();//自动连接服务器信号
    void sigAnalysisQuestionAnswer(long lessonId, QString questionId, QString planId, QString columnId); //提交练习题命令解析信号
    void sigZoomInOut(double offsetX, double offsetY, double zoomRate); //
    void sigIsOpenCorrect(bool isOpenStatus);//打开关闭批改面板
    void sigIsOpenAnswer(bool isOpenStatus, QString questionId, QString childQuestionId); //打开关闭答案解析
    void sigSynColumn(QString planId, QString columnId); //同步菜单栏
    void sigSynQuestionStatus(bool status);//同步开始做题按钮状态 true 开始做题，false 停止做题
    void sigRequestMicrophone(int status,QString userId);//申请获取麦克风权限
    void sigReponseMicrophone(int status);//响应是否同意麦克风权限

    void sigOtherGetMicOrder();//响应别人获得麦克风权限

    void sigReportFinished();//试听课报告生成了
    void sigCorrect(QJsonValue questionData); //开始批改界面
    void sigSyncCorrect(bool status);//同步批改页面
    void sigUpdateUserStatus();//更新教室内成员状态
    void sigQuestionAnswerFailed();//提交图片失败信号

    void sigRequestVideoSpan();

    //课件信号

    /*讲义信号
         *属性介绍：当前题目ID：讲义Id,栏目Id，题目Id, 题目类型(0:题目，1:课件截图，2:空白页),offsetY:坐标，questionBtnStatus：题目状态
         */
    void sigCurrentQuestionId(
            QString planId,
            QString columnId,
            QString questionId,
            double offsetY,
            bool questionBtnStatus);

    void sigPlanChange(long lessonId, long planId, long itemId); //当前讲义信号

    void sigCurrentColumn(long planId, long columnId); //当前栏目

    void sigOffsetY(double offsetY);//当前图片的偏移量

    void sigDrawPage(MessageModel model);//当前页的所有数据

    //删除分页时判断当前是不是课件页 如果是 发此信号提示 此页为课件页 不能被删除
    void sigIsCourseWare();

    void sigChangeCurrentPage(int currentPage); //设置当前的页
    void sigChangeTotalPage(int totalPage); //设置全部当前的总页数
    //当前的图像信息
    void sigSendUrl(QString urls, double width, double height, bool isLongImg, QString questionId,bool beShowedAsLongImg);

    void sigVideoSpan(QString videoSpan);

    void sigShowAllCourseImg(QJsonArray imgArray,QJsonArray contentArray,QString courseId);

public:
    //课件相关参数
    int m_currentPage;//当前页
    QString m_currentCourse;//当前课件
    QString m_currentPlanId;//当前讲义Id
    QString m_currentColumnId;//当前栏目Id
    QString m_currentQuestionId;//当前题目Id
    bool m_currentQuestionButStatus;//当前开始做题按钮状态
    double offsetY;//当前滚动的坐标
    QMap<QString, QList<MessageModel> > m_pages;//每个课件每一页的内容
    QMap<QString, int> m_pageSave;//缓存每个课件的当前显示页码
    //MessageModel currentBeBufferModel;//当前被缓存的课件model
#ifdef USE_OSS_AUTHENTICATION
    MessageModel currentBeBufferModel = MessageModel(0, "", 1.0, 1.0, "", "0", 0, false, 0);
#else
    MessageModel currentBeBufferModel = MessageModel(0, "", 1.0, 1.0, "", "0", 0, false);
#endif
    bool m_sysnStatus;//同步状态标示 false 没有同步完成  true 已同步完成  与课件有关联
    bool m_isGotoPageRequst;

    bool m_hasConnectServer = false;//是否已经连接到socket

    //重设优选ip列表
    void restGoodIpList();

private:
    YMTCPSocket *m_socket;
    QString m_message;//接收的消息
    QTimer *m_netTimer;
    QTimer *m_sendMsgTask;
    QTimer *m_sendAudioQualityTask;//发送语音质量
    QTimer *m_socketOutTimeTimer;//判断socket链接是否超时
    QTimer *m_reGetCourseImgTask;//重新获取课件背景图
    QList<QString> m_sendMsgs;
    QMutex m_sendMsgsMutex;
    bool m_response;//服务端是否给消息响应
    QString m_lastSendMsg;//上一次发送的消息
    int m_sendMsgNum;//发送的消息编号
    QString m_lastRecvNum;
    QString m_lastRecvMsg;
    QTime m_lastHBTime;//上次心跳时间
    QString m_enterRoomMsg;
    bool m_canSend;//是否已经成功进入教室可发送其他消息

    QMap<QString, QString> m_userBrushPermissions;//每个用户的书写权限
    QMap<QString, QString> m_userPagePermissions;//每个用户的翻页权限
    QString m_supplier;//音视频供应商 1声网 2 腾讯
    QString m_videoType;//音视频状态 1仅音频 2音视频
    QString m_includeSelfMsg;
    QString m_JoinMicId;//上麦者的Id

    bool m_isInit;//是不是第一次上课
    int m_firstPage;//是不是第一次翻页

    int currentReloginTimes;//记录当前重新登录的次数
    bool isAutoChangeIping = false;//是否正在自动切换ip
    bool isFirstConnect = true;
    bool isDisconnectBySelf = true;
    //记录当前的链接次数  便于切换ip
    int currentAutoChangeIpTimes = 0;

    YMHttpClient * m_httpClient;
    QString m_httpUrl;

    QString oldRecordVersion = "2.3.2";//录播的旧版本号
    QString newRecorderVersion = "3.10.19";//录播的新版本号
    int lowestNewBoardCode = 31135;//支持新画板的最低版本号
    bool correctViewIsOpen = false;//批改面板的 状态

    int lowestInsertHomeWorkCode = 40450;//支持课后作业导入的最低版本号

    int currentNetWorkType = -1;//当前连接的网络类型

    bool m_isServerChangeIp = false;//切换ip的命令是不是来自服务端

    int reGetCourseTimes = 0;//重复获取课件图片数次
    bool hasRegetContentSuccess = false;//是否获取题目内容成功

private:
    void parseMsg(QString &num, QString &fromUser, QString &msg);
    void newConnect();
    void startSendMsg();
    void stopSendMsg();
    void startSendAudioQuality();
    void stopSendAudioQuality();
    void checkTimeOut();
    ~SocketHandler();
public:
#ifdef USE_OSS_AUTHENTICATION
    QString getOssSignUrl(QString key);//获取OSS重新签名的URL
    QString checkOssSign(QString imgUrl);//检查是否需要验签
#endif
    //根据课件id 以及传入的页数获取 该页的数据
    void drawCurrentPageData(QString currentCourseId, int pageIndex);//画当前页的数据

    bool justCurrentPageIsCourse(QString currentCourseId, int pageIndex);//判断当前页是否为课件

    void insertReportPicture(QString imgUrl);//插入课堂报告的图片

    //获取当前结构化课件的栏目信息 与 drawModle 信号有一致之处 后边进一步优化
    void getCurrentColumnData(QString currentCourseId, int pageIndex);

    //跳转到新栏目时 修改当前课件栏目 获取当前栏目信息 contentObj 栏目信息
    void drawCurrentColumnData(QJsonObject contentObj);

    //删除当前页
    void deleteCurrentPage();

    //插入空白页
    void insertBlankPage();

    //根据出入页数进行翻页
    void goPageByindex(int pageIndex);

    //发送出 当前件的数据信息 （同步完成时使用）
    void currentCourseDataStatus();

    //获取当前课件的当前页数
    int getCourseCurrentPage(QString courseId);

    //将讲义重置为默认状态 （默认状态只有一个空白页）
    void setCourseInDefaultStatus();

    //插入图片
    void insertPicture(QString url,double width,double height);

    //在当前页添加轨迹
    void addTrailInCurrentPage(QString userId,QString trailMsg);

    //撤销当前的轨迹
    void unDoCurrentTrail(QString userId);

    //清空当前页的数据信息
    void clearCurrentPageTrail();

    //设置当前页是否开始练习的状态
    void setCurrentQuestionStatus(bool status);

    //插入做题时生成的图片
    void insertAutoPicture(QString imageUrl, double imgWidth, double imgHeight);

    //设置当前课件的偏移量
    void setCurrentCursorOffsetY(double yValue);

    //添加普通的课件
    void addCommonCourse(QString courseId,QJsonArray imgArry);

    //添加结构化课件
    void addStructCourse(QString courseId, QJsonArray columnsArray);

    //获取当前的课件id
    QString getCurrentCourseId();

    //获取当前课件的大小
    int getCurrentCourseSize();

    //获取当前课件的当前所处的页数
    int getCurrentCourseCurrentIndex();

    //判断课件是否包含默认页
    bool justCourseHasDefaultPage();

    //获取默认课件的总页数
    int getDefaultCourseSize();

    //初始化默认课件页
    void initDefaultCourse();

    //改变当前课件的索引
    void changeCurrentCursouIndex(int indexs);

    //显示当前课件的缩略图
    void showCurrentCourseThumbnail();

    //获取当前被缓存的课件model
    MessageModel getCurrentMsgModel();

    //判断当前页是不是空白页
    bool justCurrentPageIsBlank();

    //对当前的bufferModel添加轨迹
    void addTrailInCurrentBufferModel(QString userId,QString trailMsg);

    QString getAllStructImgByid(QString courseId,QString questionId);//根据courseid获取课件的图片信息
    QString getAllStructTitleByid(QString courseId,QString questionId);//根据courseid获取课件的title信息
};

#endif // SOCKETHANDLER_H
