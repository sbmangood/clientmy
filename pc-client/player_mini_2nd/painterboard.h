#ifndef PAINTERBOARD_H
#define PAINTERBOARD_H

#include <QMap>
#include <QObject>
#include <QTimer>
#include <QPainter>
#include <QMutex>
#include <QJsonArray>
#include <QQuickPaintedItem>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include "cloudclassroom/cloudclassManager/imageprovider.h"
#include "cloudclassroom/cloudclassManager/YMMiniclassManagerAdapter.h"

#ifdef USE_OSS_AUTHENTICATION
#include "cloudclassroom/cloudclassManager/YMHttpClient.h"
#endif

//一条消息model
class Msg
{
    public:
        Msg(QString msg = "", QString uid = "", long long t = 0, QString m_currentPage = "") :
            message(msg), userId(uid), timestamp(t), currentPage(m_currentPage)
        {}
        QString message;
        QString userId;
        QString currentPage;
        long long timestamp;
};
//一页消息model
class PageModel
{
    public:
#ifdef USE_OSS_AUTHENTICATION
        PageModel(QString bg = "", int isCourware = 0, QString questionId = "", QString columnType = "0", double offSetY = 0.0, long expiredTime = 0) :
            bgimg(bg), isCourware(isCourware), questionId(questionId), columnType(columnType), offsetY(offSetY), expiredTime(expiredTime)
#else
        PageModel(QString bg = "", int isCourware = 0, QString questionId = "", QString columnType = "0", double offSetY = 0.0) :
            bgimg(bg), isCourware(isCourware), questionId(questionId), columnType(columnType), offsetY(offSetY)
#endif  //#ifdef USE_OSS_AUTHENTICATION
        {
        }

        QList<Msg> getMsgs()
        {
            return this->m_msg;
        }

        void addMsg(QString userId, QString msg, QString currentPage)
        {
            Msg m;
            m.message = msg;
            m.userId = userId;
            m.currentPage = currentPage;
            m_msg.append(m);
        }

        void clear()
        {
            m_msg.clear();
        }

        void clear(QString userId)
        {
            for (int i = 0; i < msgs.size(); ++i)
            {
                if (msgs.at(i).userId == userId)
                {
                   msgs.removeAt(i);
                   i = 0;
                }
            }
        }

        QList<Msg> m_msg;
        QVector<Msg> msgs;
        int isCourware;
        QString bgimg;
        double width, height;
        int totalPage;
        int currentPage;
        QString questionId;
        QString columnType;
        double offsetY;

#ifdef USE_OSS_AUTHENTICATION
        long expiredTime;
#endif
};

//H5课件model
class H5dataModel
{
public:
    H5dataModel(QString docId,QString courseWareType,QString pageNo,QString url,int currentAnimStep):
        m_docId(docId),m_courseWareType(courseWareType),m_pageNo(pageNo),m_url(url),m_currentAnimStep(currentAnimStep)
    {

    }

public:
    QString m_docId;
    QString m_courseWareType;
    QString m_pageNo;
    QString m_url;
    int m_currentAnimStep;
};

class PainterBoard : public QQuickPaintedItem
{
        Q_OBJECT
    public:
        explicit PainterBoard(QQuickPaintedItem *parent = 0);//QString lessonId,QString filePath,QString trailName,QSize size,

        ~PainterBoard();

    protected:
        void paint(QPainter *painter);

    signals:
        void changeBgimg(QString url, double width, double height, QString questionId);
        void sigSetCurrentTime(int time);
        void sigChangePlayBtnStatus(int status);//1播放状态显示暂停 0暂停状态 显示播放
        void sigSetTotalTime(int seconds);
        void sigPlayerMedia(QString startTime, QString vaType, QString fileUrl, QString controlType);
        void sigPlayerAudio(QString audioPaht);
        void sigSeek(long long values);
        void sigPlayer();
        void sigPlanInfo(QJsonObject planInfo, QString planId,QString planType); //获取讲义信息
        void sigColumnInfo(QString columnId, QString planId, QString pageIndex); //栏目选择信号
        void sigQuestionInfo(QString questionId, QString planId, QString columnId); //做题信号
        void sigIsOpenAnswer(bool answerStatus, QString questionId, QString childQuestionId); //打开关闭答案解析面板 (打开:true，关闭:false)
        void sigIsOpenCorrect(bool correctStatus);//打开关闭批改面板 (打开:true，关闭:false)
        void sigCommitImage(QString imageUrl, int imageHeight); //学生提交图片
        void sigZoomInOut(double offsetX, double offsetY, double zoomRate); //滚动信号
        void sigCurrentQuestionId(QString planId, QString columnId, QString questionId); //当前题目显示
        void sigCurrentImageHeight(double height);
        void sigCursorPointer(double pointx, double pointy);
        void sigReward();//奖励信号
        void sigResponder(QJsonObject responderData);//抢答信号  type:1 发起抢答，2 学生抢答，3 抢答失败，4关闭抢答，5抢答成功
        void sigRoll(QJsonObject rollDataJson);//随机选人 type: 1 开始动画，2 选择结果，3 关闭窗口
        void sigTimer(QJsonObject timerDataJson);//计时器   //type 1 计时 2 倒计时 byte类型  //flag 1 开始，2 暂停， 3 重置, 4 关闭
        void sigSynCoursewareInfo(QJsonObject jsonObj);
        void sigSynCoursewareType(int coursewareType,QString h5Url,QString token);
        void sigSynCoursewarePage(int page);//H5同步当前页
        void sigPageOpera(QString type);//add:加一页，delete:删一页
        void sigPlayAnimation(QString pageId,int step);//设置播放动画
        void sigPlayMediaTips();//音视课件弹窗提醒

    public:
        //增加播放时间
        Q_INVOKABLE void incrementTime();
        //播放命令
        Q_INVOKABLE void play();
        //暂停播放
        Q_INVOKABLE void pause();
        //开始播放
        Q_INVOKABLE void start();

        //停止播放
        Q_INVOKABLE void stop();

        //快进快退跳转
        Q_INVOKABLE void seekTime(const int& rate);
        //设置课件相关参数 protocolType 1= 1V1 2 =1VM
        Q_INVOKABLE void setData(const QString& lessonId,
                                 const QString& date,
                                 const QString& filePath,
                                 const QString& trailName,
                                 const int& protocolType);

        //根据图片偏移量获取图片位置进行显示
        Q_INVOKABLE void getOffsetImage(QString imageUrl, double offsetY);

        //设置 当前图片的高度
        Q_INVOKABLE void setCurrentImgHeight(double height);
        //设置播放倍s速  1x 2x 3x 5x
        Q_INVOKABLE void setPlaySpeed();
        //设置是否播放音视频状态
        Q_INVOKABLE void setMediaStatus(bool mediaStatus);

    public:
        QString m_lessonId;
        QString m_filePath;//轨迹文件所在目录
        QString m_trailName;//轨迹文件名
        QString m_date;//
        bool m_isPlayer;
        double m_currentImageHeight;
        int m_currentDocType;//1:老课件 2:结构化课件 3:H5课件
        QString m_currentCourseUrl;
        QList<H5dataModel> m_h5Model;
        bool m_mediaStatus;//媒体播放状态true：允许播放 false:不播放
        bool isTips;//提醒一次标记

    private:
        void clear();
        Msg getThisMsg();//获取本次需要播放的轨迹
        Msg getNextMsg();//获取下次需要播放的轨迹
        void readTrailFile();//读取解析轨迹文件
        void drawLine(QString line);//解析处理命令
        //画贝塞尔曲线
        void drawBezier(const QVector<QPointF> &points, double size, QColor penColor, int type);
        //画一页 此页上的所有轨迹
        void drawPage(PageModel model);
        //处理消息 给消息分页
        void excuteMsg(QString msg, QString fromUser, bool isDraw = false, long long currentTime = 0);
        //画一条线
        void drawLine(const QVector<QPointF> &points, double brushWidth, QColor color, int type);
        //画椭圆
        void drawEllipse(const QRectF &rect, double brushWidth, QColor color, double angle);
        //设置H5课件同步信息
        void updateH5SynCousewareInfo();
#ifdef USE_OSS_AUTHENTICATION
        QString getOssSignUrl(QString key);//获取OSS重新签名的URL
        QString checkOssSign(QString imgUrl);//检查是否需要验签
#endif

    public:
        QPixmap trailPixmap;
        QVector<QVector<Msg> > trails;//此课时所有轨迹 按上课时的分段保存
        int currentSectionIndex, currentMessageIndex; //trails当前分段索引，trails当前分段当前消息索引
        QSize boardSize;
        QMap<QString, QVector<PageModel> > pages;//每个课件每一页的内容
        QMap<QString, int> pageSave;//每个课件的当前显示页码
        int currentPage;//当前页
        QString currentCourse;//当前课件
        QTimer *task;//播放命令任务
        QTimer *timeTask;//播放时间任务
        QVector<int> times;//每段上课时间
        QVector<QString> audios;//每段音频
        int playTime;//当前已播放时间
        QMutex m_tempTrailMutex;
        QString m_startTime;
        QString m_avType;
        QString m_controlType;
        QString m_avUrl;
        long long m_currentTime;
        qlonglong m_playTime;
        QString m_currentUrl;
        double currentImagaeOffSetY;//还原轨迹属性
        PageModel bufferModel;
        static  PainterBoard * m_painterBoard;
        YMMiniclassManagerAdapter miniClassMgr;
        QMap<QString,QString> videoPathMap;//音视频缓存路径
        int m_protocolType;// 1 = 1V1; 2 = 1VM

#ifdef USE_OSS_AUTHENTICATION
        YMHttpClient * m_httpClient;
        QString m_httpUrl;
#endif

    public:
        int videoTotalTime;//录播总时间时间
        double changeYPoinToLocal(double pointY);// 转换Y坐标 将接收到的坐标转换为当前坐标
        double changeYPoinToSend(double pointY);//  将当前坐标转换为 发送时的坐标

    public slots:
        void onCtentsSizeChanged();
        //根据滚动坐标获取图片
        void getOffSetImage(double offsetX, double offsetY, double zoomRate);

};

#endif // PAINTERBOARD_H
