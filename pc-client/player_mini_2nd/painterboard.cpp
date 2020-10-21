﻿#include "painterboard.h"
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonParseError>
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QTimer>
#include <QUrl>
#include <QMutexLocker>
#include <QStandardPaths>
#include <QDateTime>
#include <QDir>
#include <QWaitCondition>
#include "./filecrypt.h"
#include "QSettings"
#include <QTextCodec>
#include "./cloudclassroom/cloudclassManager/getoffsetimage.h"
#include "./cloudclassroom/cloudclassManager/YMUserBaseInformation.h"

#ifdef USE_OSS_AUTHENTICATION
#include "./cloudclassroom/cloudclassManager/YMEncryption.h"
#include "./cloudclassroom/cloudclassManager/YMUserBaseInformation.h"
#endif

//协议指令管理--begin
const QString kSocketCmd = "cmd";
const QString kSocketSn = "sn";
const QString kSocketMn = "mn";
const QString kSocketVer = "v";
const QString kSocketLid = "lid";
const QString kSocketUid = "uid";
const QString kSocketTs = "ts";
const QString kSocketHb = "hb";
const QString kSocketAck = "ack";
const QString kSocketContent = "content";
const QString kSocketEnterRoom = "enterRoom";
const QString kSocketExitRoom = "exitRoom";
const QString kSocketEnterFailed = "enterFailed";
const QString kSocketFinish = "finish";
const QString kSocketUsersStatus = "usersStatus";
const QString kSocketSynFin = "synFin";
const QString kSocketTrail = "trail";
const QString kSocketPoint = "point";
const QString kSocketDoc = "doc";
const QString kSocketDocUrls = "urls";
const QString kSocketAV = "av";
const QString kSocketPage = "page";
const QString kScoketPageId = "pageId";
const QString kSocketAuth = "auth";
const QString kSocketMuteAll = "muteAll";
const QString kSocketKickOut = "kickOut";
const QString kSocketZoom = "zoom";
const QString kSocketTk = "tk";
const QString kSocketRwnd = "rwnd";
const QString kSocketAppVersion = "appVersion";
const QString kSocketSysInfo = "sysInfo";
const QString kSocketDevInfo = "deviceInfo";
const QString kSocketUserType = "userType";
const QString kSocketPlat = "plat";
const QString kSocketIsOnline = "isOnline";
const QString kSocketCode = "code";
const QString kSocketIncludeSelf = "includeSelf";
const QString kSocketSynMn = "synMn";
const QString kSocketHttpData = "data";
const QString kSocketHttpMsgs = "msgs";
const QString kSocketDocPageNo = "pageNo";
const QString kSocketDocTotalNum = "totalNum";
const QString kSocketDocDockId = "dockId";
const QString kSocketAVFlag = "flag";
const QString kSocketTime = "time";
const QString kSocketPageOpType = "type";
const QString kSocketAuthUp = "up";
const QString kSocketAuthAudio = "audio";
const QString kSocketAuthVideo = "video";
const QString kSocketMuteAllRet = "ret";
const QString kSocketTEA = "TEA";
const QString kSocketTPC = "T";
const QString kSocketSPC = "S";
const QString kSocketSTU = "STU";
const QString kSocketPointX = "x";
const QString kSocketPointY = "y";
const QString kSocketOnlineState = "isOnline";
const QString kSocketDockDefault = "DEFAULT";
const QString kSocketDockDefaultZero = "000000";
const QString kSocketSuccess = "success";
const QString kSocketImages = "images";
const QString kSocketRatio = "ratio";
const QString kSocketOffsetX = "offsetX";
const QString kSocketOffsetY = "offsetY";
const QString kSocketOperation = "operation";
const QString kSocketReward = "reward";
const QString kSocketRoll = "roll";
const QString kSocketResponder = "responder";
const QString kSocketTimer = "timer";
const QString kSocketFlag = "flag";
const QString kSocketType = "type";
const QString kSocketStartClass = "startClass";
const QString kSocketStart = "start";
const QString kSocketEnd = "end";
const QString kSocketH5Url = "h5Url";
const QString kSocketDocType = "docType";
const QString kSocketPlayAnimation = "playAnimation";
const QString kSocketStep = "step";
const QString kSocketPageNo = "pageNo";
const QString kSocketPageId = "pageId";
//协议指令管理--end

PainterBoard::PainterBoard(QQuickPaintedItem *parent) : QQuickPaintedItem(parent),
    currentCourse("DEFAULT"), currentPage(0), playTime(0), videoTotalTime(0),
    currentSectionIndex(0), currentMessageIndex(-1),m_mediaStatus(true)
{
#ifdef USE_OSS_AUTHENTICATION
    m_httpClient = YMHttpClient::defaultInstance();
    m_httpUrl = m_httpClient->getRunUrl(1);
#endif

    //初始化默认的第一页
    QVector<PageModel> list;
    PageModel model;
    model.bgimg = "";
    model.isCourware = 0;
    model.height = 1.0;
    model.width = 1.0;
    list.append(model);
    pages.insert("DEFAULT", list);

    connect(this, SIGNAL(heightChanged()), this, SLOT(onCtentsSizeChanged()));
    connect(this, SIGNAL(widthChanged()), this, SLOT(onCtentsSizeChanged()));
    trailPixmap = QPixmap(this->width(), this->height());
    trailPixmap.fill(QColor(255, 255, 255, 0));

    timeTask = new QTimer(this);
    connect(timeTask, &QTimer::timeout, this, &PainterBoard::incrementTime);
    task = new QTimer(this);
    connect(task, &QTimer::timeout, this, &PainterBoard::play);
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    QDir dir;
    if (!dir.exists(docPath + "/YiMi/"))
    {
        dir.mkpath(docPath + "/YiMi/");
    }
    m_isPlayer = false;
    isTips = true;
    setRenderTarget(QQuickPaintedItem::FramebufferObject);

    connect(GetOffsetImage::instance(), SIGNAL(sigCurrentImageHeight(double)), this, SIGNAL(sigCurrentImageHeight(double)));

    QSettings reg("HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\", QSettings::NativeFormat);
    reg.beginGroup("BIOS");
    QString deviceInfo = reg.value("SystemManufacturer").toString().remove("#").append("|").append(reg.value("SystemSKU").toString().remove("#"));

    deviceInfo.remove("\r").remove("\n").remove("\\").remove("\u0002").remove("/").remove("}").remove("{").remove(";").remove(":").remove(",").remove("\"").remove("]").remove("[");
    YMUserBaseInformation::deviceInfo = QString::fromUtf8(deviceInfo.toUtf8());
}

#ifdef USE_OSS_AUTHENTICATION
//OSS过期重新签名URL
QString PainterBoard::getOssSignUrl(QString key)
{
    QVariantMap  reqParm;
    reqParm.insert("key", key);
    reqParm.insert("expiredTime", 1800 * 1000);
    reqParm.insert("token", YMUserBaseInformation::token);

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    QString httpUrl = m_httpClient->getRunUrl(0);
    QString url = "https://" + httpUrl + "/api/oss/make/sign"; //环境切换要注意更改
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject allDataObj = QJsonDocument::fromJson(dataArray).object();
    //qDebug() << "***********allDataObj********" << url<< reqParm;
    //qDebug() << "=======aaa=========" << allDataObj << key;

    if(allDataObj.value("result").toString().toLower() == "success")
    {
        QString url = allDataObj.value("data").toString();
        //qDebug() << "*********url********" << url;
        return url;
    }
    else
    {
        qDebug() << "PainterBoard::getOssSignUrl" << allDataObj;
    }

    return "";
}

QString PainterBoard::checkOssSign(QString imgUrl)
{
    //重新验签处理返回URL
    if(imgUrl != "")
    {
        long current_second = QDateTime::currentDateTime().toTime_t();
        PageModel model = pages[currentCourse].at(currentPage);
        //qDebug() << "==ssssssssss==" << current_second - model.expiredTime << current_second << model.expiredTime;
        if(model.expiredTime == 0 || current_second - model.expiredTime >= 1800)//30分钟该页重新请求一次验签
        {
            QString oldImgUrl = model.bgimg;
            int indexOf = oldImgUrl.indexOf(".com");
            int midOf = oldImgUrl.indexOf("?");
            QString key = oldImgUrl.mid(indexOf + 4, midOf - indexOf - 4);
            QString newImgUrl = getOssSignUrl(key);

            //qDebug() << "=====drawPage::key=====" << imgUrl << newImgUrl;
            if(newImgUrl == "")
            {
                return imgUrl;
            }

            pages[currentCourse][currentPage].expiredTime = current_second;
            pages[currentCourse][currentPage].bgimg = newImgUrl;//.setImageUrl(newImgUrl,model.width,model.height);
            return newImgUrl;
        }
    }
    return imgUrl;
}
#endif //#ifdef USE_OSS_AUTHENTICATION

//界面尺寸变化
void PainterBoard::onCtentsSizeChanged()
{
    trailPixmap = QPixmap(this->width(), this->height());
    trailPixmap.fill(QColor(255, 255, 255, 0));
    StudentData::gestance()->midWidth = this->width();

    StudentData::gestance()->midHeight = this->height();// - StudentData::gestance()->spacingSize;
    GetOffsetImage::instance()->currentTrailBoardHeight = this->height();// - StudentData::gestance()->spacingSize;

    foreach (Msg mess, bufferModel.getMsgs())
    {
        this->drawLine(mess.message);
    }

    qDebug() << "==TrailBoard::onCtentsSizeChanged==" << this->width() << this->height() << GetOffsetImage::instance()->currrentImageHeight;
    update();
}

//根据偏移量截图
void PainterBoard::getOffsetImage(QString imageUrl, double offsetY)
{
    QImage tempImage;
    GetOffsetImage::instance()->currentBeBufferedImage = tempImage;
    currentImagaeOffSetY = offsetY;
    GetOffsetImage::instance()->getOffSetImage(imageUrl, offsetY);
    //qDebug() << "****************TrailBoard::getOffsetImage********" << offsetY;
}

void PainterBoard::getOffSetImage(double offsetX, double offsetY, double zoomRate)
{
    currentImagaeOffSetY = qAbs(offsetY);//记录当前图的偏移量
    GetOffsetImage::instance()->getOffSetImage(offsetY);
    //获取轨迹信息
    //qDebug() << "****TrailBoard::getOffSetImage******" << offsetY;
    onCtentsSizeChanged();
}

void PainterBoard::setPlaySpeed()
{

}

void PainterBoard::setCurrentImgHeight(double height)
{
    m_currentImageHeight = height;
    GetOffsetImage::instance()->currrentImageHeight = height;
}

double PainterBoard::changeYPoinToLocal(double pointY)
{
    //qDebug() << "********TrailBoard::changeYPoinToLocal**********" << pointY << currentImagaeOffSetY << StudentData::gestance()->midHeight <<  GetOffsetImage::instance()->currrentImageHeight << this->height();
    double tempHeight = GetOffsetImage::instance()->currrentImageHeight > this->height() ? GetOffsetImage::instance()->currrentImageHeight : this->height();
    pointY = ((pointY * tempHeight) - (currentImagaeOffSetY * this->height())) / this->height();
    //qDebug() << "====current::pointY===" << pointY;
    return pointY;
}

double PainterBoard::changeYPoinToSend(double pointY)
{
    //qDebug() << "********TrailBoard::changeYPoinToSend*******" << pointY << currentImagaeOffSetY << GetOffsetImage::instance()->currrentImageHeight << this->height();
    double tempHeight = GetOffsetImage::instance()->currrentImageHeight > this->height() ? GetOffsetImage::instance()->currrentImageHeight : this->height();
    pointY = (pointY + currentImagaeOffSetY) * this->height() / tempHeight;
    return pointY;
}

void PainterBoard::setData(const QString& lessonId,const QString& date, const QString& filePath, const QString& trailName,const int& protocolType)
{
    m_lessonId = lessonId;
    m_date = date;
    m_filePath = filePath;
    m_trailName = trailName;
    m_protocolType = protocolType;
    readTrailFile();
}

PainterBoard::~PainterBoard()
{
    pages.clear();
}

void PainterBoard::paint(QPainter *painter)
{
    painter->setRenderHint(QPainter::Antialiasing);
    QPixmap pixmap = trailPixmap.scaled(this->width(), this->height()); //, Qt::IgnoreAspectRatio,Qt::SmoothTransformation );
    painter->drawPixmap(0, 0, pixmap);
}

void PainterBoard::incrementTime()
{
    playTime++;
    emit sigSetCurrentTime(playTime);
}

void PainterBoard::stop()
{
    task->stop();
    timeTask->stop();
    currentSectionIndex = 0;
    currentMessageIndex = -1;
    playTime = 0;
    emit sigSetCurrentTime(0);
    this->clear();
}

void PainterBoard::setMediaStatus(bool mediaStatus)
{
    m_mediaStatus = mediaStatus;
    if(mediaStatus)
    {
        emit sigPlayerMedia(QString::number(m_playTime), m_avType, m_avUrl, m_controlType);
    }
}

//播放
void PainterBoard::play()
{
    if (task->isActive()) task->stop();
    Msg thisMsg = getThisMsg();
    //qDebug() << "===thisMsg===" << thisMsg.message << currentMessageIndex << currentSectionIndex;
    if (thisMsg.userId != "")
    {
        //currentMessageIndex==0表示新开始了一段 需要播放此段的音频
        if (currentMessageIndex == 0)
        {
            if (currentSectionIndex < trails.size())
            {
                sigPlayerAudio(audios.at(currentSectionIndex));
                sigPlayer();
                timeTask->start(1000);
            }
        }
        //计算下一条消息与本消息的时间间隔设置下一条消息的播放时间
        if (currentMessageIndex == trails.at(currentSectionIndex).size() - 1)
        {
            //如果本段只有一条消息 直接开始播放
            task->start(0);
            if(!timeTask->isActive())
            {
                timeTask->start(1000);
            }
            //qDebug() << "currentMessageIndex::" << currentMessageIndex << currentSectionIndex <<  trails.at(currentSectionIndex).size();
        }
        else
        {
            Msg nextMsg = getNextMsg();
            int sleepTime = nextMsg.timestamp - thisMsg.timestamp;
            if (nextMsg.userId != "")
            {
                sleepTime = sleepTime < 0 ? 0 : sleepTime;
                task->start(sleepTime);
                if(!timeTask->isActive())
                {
                    timeTask->start(1000);
                }
                qDebug() << "sleepTime::" << sleepTime;
            }
        }
        //播放本条消息
        excuteMsg(thisMsg.message, thisMsg.userId, true, thisMsg.timestamp);
        update();
        if(m_mediaStatus == false)
        {
            return;
        }
        //qDebug() << "==m_isPlayer==" << m_isPlayer << m_currentUrl << m_avUrl << m_controlType;
        if(m_isPlayer )
        {
            if (m_currentUrl == m_avUrl && (m_controlType == "stop" || m_controlType == "pause"))
            {
                long long currentPlayerTime = thisMsg.timestamp - m_currentTime + m_startTime.toLongLong();
                emit sigPlayerMedia(QString::number(currentPlayerTime), m_avType, m_avUrl, m_controlType);
            }
            else  if( (m_controlType == "stop" || m_controlType == "pause"))
            {
                emit sigPlayerMedia(m_startTime, m_avType, m_avUrl, m_controlType);
                m_isPlayer = false;
            }
            else if (m_currentUrl != m_avUrl)
            {
                m_currentUrl = m_avUrl;
                long long currentPlayerTime = thisMsg.timestamp - m_currentTime + m_startTime.toLongLong();
                emit sigPlayerMedia(QString::number(currentPlayerTime), m_avType, m_avUrl, m_controlType);
            }
            /*如果需要快进到某个时间节点则启用下列代码*/
            //long long currentPlayerTime = thisMsg.timestamp - m_currentTime + m_startTime.toLongLong();
            //emit sigPlayerMedia(QString::number(currentPlayerTime),m_avType,m_avUrl,m_controlType);
        }
        else if(!m_isPlayer)
        {
            if(isTips && m_avUrl != "")
            {
                emit sigPlayMediaTips();
                this->pause();
                isTips = false;
                return;
            }
            m_playTime = thisMsg.timestamp - m_currentTime + m_startTime.toLongLong();
            emit sigPlayerMedia(QString::number(m_playTime), m_avType, m_avUrl, m_controlType);
            m_currentUrl = m_avUrl;
            m_isPlayer = false;//(m_controlType == "stop" || m_controlType == "pause") ? false : true;
        }
    }

    if(playTime >= videoTotalTime) //播放结束 初始化
    {
        pause();
        currentSectionIndex = 0;
        currentMessageIndex = -1;
        playTime = 0;
        emit sigSetCurrentTime(playTime);
        emit sigChangePlayBtnStatus(0);
        this->clear();
    }
}
//暂停
void PainterBoard::pause()
{
    if (task->isActive()) task->stop();
    if (timeTask->isActive()) timeTask->stop();
}

void PainterBoard::start()
{
    if (playTime == 0) //从头开始播放
    {
        currentSectionIndex = 0;
        currentMessageIndex = -1;
        bufferModel.clear();
        onCtentsSizeChanged();
        task->start(0);
        timeTask->start(1000);
        emit sigZoomInOut(0,0,0);
        this->clear();
    }
    else
    {
        int currentSection = -1, totalTime = 0;
        for (int i = 0; i < times.size(); ++i)
        {
            totalTime += times.at(i);
            if (playTime - totalTime <= 0)
            {
                //计算当前的播放时间在哪一段
                //当前播放时间依次减去每一段的播放时间如果在减去某一段的播放时间小于零则当前播放时间在这一段
                currentSection = i;
                //qDebug() << "===currentSection===" << currentSection;
                break;
            }
        }

        if(totalTime <= playTime)
        {
            //播放到最后结束播放 初始化播放状态
            pause();
            currentSectionIndex = 0;
            currentMessageIndex = -1;
            playTime = 0;
            emit sigSetCurrentTime(playTime);
            emit sigChangePlayBtnStatus(0);
        }
        else
        {
            //判断具体播放到哪一条命令 currentSectionRime为本段的已播放时间
            long long currSectionTime = playTime - (totalTime - times.at(currentSection));
            currentSectionIndex = currentSection;
            //qDebug() << "******currSectionTime*****" << currSectionTime << currentSection << playTime << totalTime << times.at(currentSection) << currentSectionIndex;
            QVector<Msg> msgs = trails.at(currentSectionIndex);
            if(msgs.size() <= 1)
            {
                //如果此段只有小于一条消息 此段的播放时间为0 直接开始播放这一段的命令
                currentMessageIndex = -1;
                task->start(0);
                timeTask->start(1000);
            }
            else
            {
                //先计算此播放时间对应的命令上的时间currSectionPlayTime
                //查找currSectionPlayTime在哪两条命令之间，计算播放下条命令的时间
                //把当前存储的分页清空重新给命令分配页数，之后画出当前页播放下条命令
                long long  currSectionPlayTime = msgs.at(0).timestamp + currSectionTime * 1000;

                clear();//清空当前页
                for (int i = 0; i < msgs.size() - 1; ++i)
                {
                    currentMessageIndex = i;
                    if (currSectionPlayTime >= msgs.at(i).timestamp && currSectionPlayTime <= msgs.at(i + 1).timestamp)
                    {
                        //重新分配当前页
                        for (int k = 0; k < currentSectionIndex + 1; ++k)
                        {
                            int index = trails.at(k).size();
                            if (k == currentSectionIndex)
                            {
                                index = i + 1;
                            }
                            for (int j = 0; j < index; ++j)
                            {
                                Msg m = trails.at(k).at(j);
                                excuteMsg(m.message, m.userId, true, m.timestamp);
                            }
                        }

                        //画出当前页
#ifdef USE_OSS_AUTHENTICATION
                        PageModel model = pages[currentCourse].at(currentPage);
                        model.bgimg = checkOssSign(model.bgimg);
                        drawPage(model);//pages[currentCourse].at(currentPage));
#else
                        drawPage(pages[currentCourse].at(currentPage));
#endif
                        update();
                        int currentAudioIndex = currentSectionIndex;
                        if(currentSectionIndex >= audios.size())
                        {
                            --currentAudioIndex;
                        }
                        //设置下一条命令的播放时间
                        sigPlayerAudio(audios.at(currentAudioIndex));
                        sigPlayer();
                        sigSeek(currSectionTime);

                        int sleepTime = msgs.at(i + 1).timestamp - currSectionPlayTime;
                        sleepTime = sleepTime < 0 ? 0 : sleepTime;
                        task->start(sleepTime);
                        timeTask->start(1000);
                        break;
                    }
                }
            }
        }
    }
    if(m_currentDocType == 3)
    {
        updateH5SynCousewareInfo();
    }
}


//快进、倒退播放
void PainterBoard::seekTime(const int& rate)
{
    if (task->isActive()) task->stop();
    if (timeTask->isActive()) timeTask->stop();
    playTime = rate;
    m_isPlayer = false;
    m_currentUrl = "";
    m_controlType = "";
    m_avUrl = "";
    onCtentsSizeChanged();
    m_h5Model.clear();
    this->start();//->play();
}


void PainterBoard::clear()
{
    bufferModel.clear();
    pages.clear();
    QVector<PageModel> list;
    PageModel model;
    model.bgimg = "";
    model.isCourware = 0;
    model.height = 1.0;
    model.width = 1.0;
    model.offsetY = 0.0;
    model.questionId = "";
    model.columnType = "0";
    list.append(model);
    pages.insert("DEFAULT", list);
    currentCourse = "DEFAULT";
    currentPage = 0;
    currentMessageIndex = -1;
    emit sigSynCoursewareType(0,"",YMUserBaseInformation::token);
    changeBgimg("", 1, 1, "");
    onCtentsSizeChanged();
    m_h5Model.clear();
}

Msg PainterBoard::getThisMsg()
{
    for (; currentSectionIndex < trails.size(); ++currentSectionIndex)
    {
        for (++currentMessageIndex; currentMessageIndex < trails.at(currentSectionIndex).size(); ++currentMessageIndex)
        {
            return trails.at(currentSectionIndex).at(currentMessageIndex);
        }
        currentMessageIndex = -1;
    }
    Msg msg;
    return msg;//播放结束
}

Msg PainterBoard::getNextMsg()
{
    int index = currentMessageIndex + 1;
    for (int i = currentSectionIndex; i < trails.size(); ++i)
    {
        for (int j = index; j < trails.at(currentSectionIndex).size(); ++j)
        {
            return trails.at(currentSectionIndex).at(j);
        }
        index = 0;
    }
    Msg msg;
    return msg;//播放结束
}

//解析encrypt轨迹文件
void PainterBoard::readTrailFile()
{
    QList<QString> ts;
    if(m_protocolType == 1)
    {
        ts = FileCrypt::decrypt(m_filePath + "/" + m_trailName);
    }
    else
    {
        ts = FileCrypt::analysisFile(m_filePath + "/" + m_trailName);
    }
    int currentIndex = 0;
    for (int i = 0; i < ts.size(); i++)
    {
        QString line = ts.at(i);
        QJsonParseError jsonParseError;

        QJsonDocument document = QJsonDocument::fromJson(line.toUtf8(), &jsonParseError);
        if(QJsonParseError::NoError != jsonParseError.error || !document.isObject())
        {
            continue;
        }
        QJsonObject jsonObj = document.object();
        if(jsonObj.contains(kSocketCmd))
        {
            //qDebug() << "====line=====" << line;
            QString command = jsonObj.value(kSocketCmd).toString();            
            if(command == kSocketStart)
            {
                QString uid = jsonObj.value(kSocketUid).toVariant().toString();
                qlonglong timestamp = jsonObj.value(kSocketTs).toVariant().toLongLong();
                Msg m;
                m.message = line;
                m.userId = uid;
                m.timestamp = timestamp;

                QVector<Msg> msgs;
                msgs.append(m);
                trails.append(msgs);
                currentIndex++;
                if(i == 0)
                {
                    currentIndex = 0;
                }
                trails[currentIndex].append(m);
                QJsonObject jsonContent  = jsonObj.value(kSocketContent).toObject();
                QString mp3Num = QString::number(jsonContent.value("num").toInt());
                audios.append(m_filePath + "/" + mp3Num + ".mp3");
            }

            if(command == kSocketTrail || command == kSocketPoint || command == kSocketDoc || command == kSocketAV || command == kSocketPage || command == kSocketZoom || command == kSocketPlayAnimation || command == kSocketAuth
                    || command == kSocketEnd || command == kSocketImages || command == kSocketOperation || command ==kSocketReward || command == kSocketRoll || command == kSocketTimer || command == kSocketResponder)
            {
                QString uid = jsonObj.value(kSocketUid).toVariant().toString();
                qlonglong timestamp = jsonObj.value(kSocketTs).toVariant().toLongLong();//uid_timestamp.at(1).mid(0, uid_timestamp.at(1).length() - 1);
                Msg m;
                m.message = line;
                m.userId = uid;
                m.timestamp = timestamp;

                if(currentIndex == 0 && trails.size() == 0)
                {
                    QVector<Msg> msgs;
                    msgs.append(m);
                    trails.append(msgs);
                    audios.append(m_filePath + "/0.mp3");
                }

                trails[currentIndex].append(m);
            }
        }
    }

    bool isAddTime = false;
    //计算每一段的播放时间 以及总的播放时间
    for (int k = 0; k < trails.size(); k++)
    {
        QVector<Msg> msgs = trails.at(k);
        if (msgs.size() == 0)
        {
            times.append(0);
        }
        else
        {
            if(msgs.at(0).message == "" || msgs.at(0).timestamp == 0)
            {
                continue;
            }
            if(isAddTime)
            {
                Msg mf = msgs.at(0);
                Msg ml = msgs.at(msgs.size() - 1);

                times.append((ml.timestamp - mf.timestamp) / 1000);
                videoTotalTime += (ml.timestamp - mf.timestamp) / 1000;
                continue;
            }
            if(msgs.at(0).message.contains(kSocketStart))// || msgs.at(k).message.contains(kSocketEnd))
            {
                isAddTime = true;
                Msg mf = msgs.at(0);
                Msg ml = msgs.at(msgs.size() - 1);

                times.append((ml.timestamp - mf.timestamp) / 1000);
                videoTotalTime += (ml.timestamp - mf.timestamp) / 1000;
            }
        }
    }

    emit sigSetTotalTime(videoTotalTime);
}

void PainterBoard::updateH5SynCousewareInfo()
{
    if(m_currentDocType == 3)//H5课件同步处理
    {
        QMap<QString,int> synH5dataModel;
        for(int i = 0; i < m_h5Model.size();i++)
        {
            if(m_h5Model.at(i).m_docId.contains(currentCourse))
            {
                synH5dataModel.insert(m_h5Model.at(i).m_pageNo,m_h5Model.at(i).m_currentAnimStep);
            }
        }
        QJsonObject h5SynObj;
        QJsonArray h5SynArray;
        h5SynObj.insert("lessonId",StudentData::gestance()->m_lessonId);
        h5SynObj.insert("h5Url",m_currentCourseUrl);
        h5SynObj.insert("courseWareId",currentCourse);
        h5SynObj.insert("courseWareType",m_currentDocType);
        h5SynObj.insert("currentPageNo",currentPage);

        for(int k = 0; k < pages[currentCourse].size(); k++)
        {
            QJsonObject pageInfosObj;
            pageInfosObj.insert("courseWareType",pages[currentCourse][k].isCourware);
            pageInfosObj.insert("pageNo",k);
            pageInfosObj.insert("url","");
            int currentAnimStep = 0;
            QMap<QString,int>::const_iterator it;
            for( it = synH5dataModel.constBegin(); it != synH5dataModel.constEnd(); ++it)
            {
                if(it.key() == QString::number(k))
                {
                    currentAnimStep = it.value();
                    break;
                }
            }
            pageInfosObj.insert("currentAnimStep",currentAnimStep);
            h5SynArray.append(pageInfosObj);
        }
        h5SynObj.insert("pageInfos",h5SynArray);
        emit sigSynCoursewareInfo(h5SynObj);
        qDebug() << "====AAAA====" << h5SynObj;
    }
}

//画线
void PainterBoard::drawLine(QString line)
{
    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(line.toUtf8(), &err);
    if (err.error == QJsonParseError::NoError)
    {
        if(!doc.isObject())
        {
            //qDebug() << "invalid message:" << line;
            return;
        }
        QJsonValue cmdVal = doc.object().take(kSocketCmd);
        if (!cmdVal.isString())
        {
            //qDebug() << "invalid message:" << line;
            return;
        }
        QString command = cmdVal.toString();
        QJsonValue contentVal = doc.object().take("content");
        if (!contentVal.isObject())
        {
            //qDebug() << "invalid message:" << line;
            return;
        }
        QJsonObject contentObj = contentVal.toObject();

        if(command == kSocketTrail)
        {
            QJsonArray trailArr = contentObj.take("pts").toArray();
            double  factor = 1000000.000000;
            QString color = contentObj.take("color").toString();
            double width = contentObj.take("width").toInt() / factor;
            int type = contentObj.take("type").toInt();
            QVector<QPointF> points;
            qint32 factorVal = 0;
            double x = 0, y = 0;
            for (int i = 0; i < trailArr.size(); ++i)
            {
                factorVal = trailArr[i].toInt();
                if(i % 2 == 0)
                {
                    x = factorVal / factor;
                }
                if(i % 2 == 1)
                {
                    y = factorVal / factor;
                    y = changeYPoinToLocal(y);
                    points.append(QPointF(x, y));
                }
            }
            drawBezier(points, width * StudentData::gestance()->midHeight / this->height(), QColor("#" + color), type == 1 ? 1 : 2);
        }
        else if(command == "ellipse")
        {
            double rectX = contentObj.take("rectX").toString().toDouble();
            double rectY = contentObj.take("rectY").toString().toDouble();
            rectY = changeYPoinToLocal(rectY);
            double rectWidth = contentObj.take("rectWidth").toString().toDouble();
            double rectHeight = contentObj.take("rectHeight").toString().toDouble();

            double angle = contentObj.take("angle").toString().toDouble();
            double width = contentObj.take("width").toString().toDouble();

            QString color = contentObj.take("color").toString();
            drawEllipse(QRectF(rectX, rectY, rectWidth, rectHeight), 0.00099, QColor("#" + color), angle);
        }
        else if(command == "polygon")
        {
            QJsonArray trailArr = contentObj.take("trail").toArray();
            QString color = contentObj.take("color").toString();
            double width = contentObj.take("width").toString().toDouble();
            QVector<QPointF> points;
            for (int i = 0; i < trailArr.size(); ++i)
            {
                double x = trailArr[i].toObject().take("x").toString().toDouble();
                double y = trailArr[i].toObject().take("y").toString().toDouble();
                y = changeYPoinToLocal(y);
                points.append(QPointF(x, y));
            }
            drawLine(points, 0.001, QColor("#" + color), 1);
        }

    }
    else
    {
        qDebug() << "play video json parse error:" << line;
    }
}
//画贝塞尔曲线
void PainterBoard::drawBezier(const QVector<QPointF> &points, double size, QColor penColor, int type)
{
    QMutexLocker locker(&m_tempTrailMutex);
    QPainter painter;
    trailPixmap = trailPixmap.scaled(this->width(), this->height());
    painter.begin(&trailPixmap);
    painter.setPen(QPen(QBrush(penColor), size, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
    painter.setRenderHint(QPainter::Antialiasing);
    painter.scale(this->width(), this->height());

    if(type == 2)
    {
        painter.setCompositionMode(QPainter::CompositionMode_Clear);
    }

    if(points.size() > 3)
    {
        painter.drawPolyline(QPolygonF(points));
    }
    else
    {
        QVector<QPointF> addPointF;
        double x = points.at(0).x() + 0.000001;
        double y = points.at(0).y() + 0.000001;
        addPointF.append(QPointF(points.at(0).x(), points.at(0).y()));
        addPointF.append(QPointF(x, y));
        painter.drawPolyline(addPointF.data(), addPointF.size());
    }
    painter.end();
    update();
    //qDebug() << "==PainterBoard::drawBezier==" << this->width() << this->height();
}

void PainterBoard::drawPage(PageModel model)
{
    //qDebug() << "=======drawPage========" << this->height() << this->width() << model.offsetY;

    trailPixmap = QPixmap(this->width(), this->height());
    trailPixmap.fill(QColor(255, 255, 255, 0));

    GetOffsetImage::instance()->currrentImageHeight = this->height();

    if(model.height < 1)//截图设置图片高度
    {
        currentImagaeOffSetY = 0;
        model.offsetY = 0;
        GetOffsetImage::instance()->currrentImageHeight = StudentData::gestance()->midHeight * model.height;
    }
    if(model.height == 1)//上传图片设置图片高度
    {
        currentImagaeOffSetY = 0;
        model.offsetY = 0;
        GetOffsetImage::instance()->currrentImageHeight = StudentData::gestance()->midHeight;//  this->height();//
    }
    if(model.height == 1 && model.questionId != "" && model.questionId == "-2")//新讲义截图、上传图片处理
    {
        currentImagaeOffSetY = 0;
        model.offsetY = 0;
        GetOffsetImage::instance()->currrentImageHeight = StudentData::gestance()->midHeight;//  this->height();//
    }
    if(model.height == 1 && model.questionId != "" && model.questionId == "-1")//老课件截图、上传图片处理
    {
        currentImagaeOffSetY = 0;
        model.offsetY = 0;
        GetOffsetImage::instance()->currrentImageHeight = StudentData::gestance()->midHeight;//  this->height();//
    }
    if(model.height == 1 && model.questionId != "" && model.questionId != "-1" && model.questionId != "-2")
    {
        GetOffsetImage::instance()->currrentImageHeight = m_currentImageHeight;
    }

    emit sigZoomInOut(0, model.offsetY, 1.0);

    foreach (Msg mess, model.msgs)
    {
        bufferModel.addMsg("temp", mess.message, mess.currentPage);
        this->drawLine(mess.message);
    }

    if(_isnan(model.width) == 1)
    {
        model.width =  _fpclass(model.width);
    }
    if(_isnan(model.height) == 1)
    {
        model.height = _fpclass(model.height);
    }
    //qDebug() << "*******PainterBoard::drawPage*******" << model.width << model.height << model.bgimg;
    //qDebug() << "====width::length====" << _isnan(model.width) << _fpclass(model.width);
    emit changeBgimg(model.bgimg, model.width, model.height, model.questionId);
}

void PainterBoard::excuteMsg(QString msg, QString fromUser, bool draw, long long currentTime)
{
    QJsonParseError err;
    QJsonDocument document = QJsonDocument::fromJson(msg.toUtf8(), &err);
    if (err.error == QJsonParseError::NoError)
    {
        QString domain = document.object().take("domain").toString();
        QString command = document.object().take(kSocketCmd).toString();
        QJsonValue contentVal = document.object().take(kSocketContent);
        //qDebug() << "======contentVal=====" << document << command << currentCourse << currentPage;

        if(m_protocolType == 2)
        {
            if(command == kSocketTrail)//画笔 橡皮操作
            {
                Msg m;
                m.message = msg;
                m.userId = fromUser;
                m.timestamp = 0;
                pages[currentCourse][currentPage].msgs.append(m);
                if(draw)
                {
                    bufferModel.addMsg("temp", msg, QString::number(currentPage));
                    drawLine(msg);
                }
            }
            else if(command == kSocketDoc)//选择课件处理
            {
                QString docId  = contentVal.toObject().take("dockId").toString();
                int docType = contentVal.toObject().take(kSocketDocType).toInt();
                QString h5Url = contentVal.toObject().take(kSocketH5Url).toString();
                m_currentDocType = docType;
                m_currentCourseUrl = h5Url;

                emit sigSynCoursewareType(docType, h5Url,YMUserBaseInformation::token);

                QJsonObject docObj = contentVal.toObject();
                QJsonArray imgArray;
                if(docObj.contains(kSocketDocUrls))
                {
                    imgArray =  docObj.take(kSocketDocUrls).toArray();
                }
                else
                {
                    QJsonObject diskData = miniClassMgr.getCloudDiskFileInfo(docId);
                    imgArray = diskData.value("data").toObject().value(kSocketImages).toArray();
                }
                if (pages.contains("DEFAULT"))
                {
                    pages.insert(docId, pages.value("DEFAULT"));
                    pages.remove("DEFAULT");
                    currentCourse = docId;
                    currentPage = pages[currentCourse].size();
                    for (int i = 0; i < imgArray.size(); ++i)
                    {
                        PageModel model;
                        model.isCourware = 1;
                        model.bgimg = imgArray.at(i).toString();
                        model.width = 1.0;
                        model.height = 1.0;
                        model.offsetY = 0.0;
                        model.questionId = "";
                        model.columnType = "0";
                        pages[currentCourse].append(model);
                    }
                }
                else if (!pages.contains(docId))
                {
                    QVector<PageModel> list;
                    PageModel model;
                    model.isCourware = 0;
                    model.bgimg = "";
                    model.width = 1.0;
                    model.height = 1.0;
                    list.append(model);
                    pages.insert(docId, list);
                    pageSave.insert(currentCourse, currentPage);
                    currentCourse = docId;
                    currentPage = 1;
                    for (int i = 0; i < imgArray.size(); ++i)
                    {
                        PageModel model1;
                        model1.isCourware = 1;
                        model1.bgimg = imgArray.at(i).toString();
                        model1.width = 1.0;
                        model1.height = 1.0;
                        model.offsetY = 0.0;
                        model.questionId = "";
                        model.columnType = "0";
                        pages[currentCourse].append(model1);
                    }
                }
                else
                {
                    currentCourse = docId;
                    currentPage = pageSave.value(currentCourse, 0);
                }
                if(draw)
                {
                    bufferModel.clear();
                    drawPage(pages[currentCourse].at(currentPage));
                }
                if(m_currentDocType == 3)
                {
                    updateH5SynCousewareInfo();
                }
            }
            else if(command == kSocketPage)// 1 翻页 2 插入空白页 3 删页
            {
                int type = contentVal.toObject().take("type").toInt();
                bufferModel.clear();
                if(type == 1)
                {
                    int pageI = contentVal.toObject().take("pageNo").toInt();
                    pageI = pageI < 0 ? 0 : pageI;
                    if (pageI > pages[currentCourse].size() - 1)
                        pageI = pages[currentCourse].size() - 1;
                    currentPage = pageI;
                    if(draw)
                    {
                        drawPage(pages[currentCourse].at(currentPage)); // model);//
                    }
                    if(m_currentDocType == 3)
                    {
                        emit sigSynCoursewarePage(currentPage);
                    }
                }
                if(type == 2)
                {
                    PageModel model;
                    model.isCourware = 0;
                    model.bgimg = "";
                    model.width = 1.0;
                    model.height = 1.0;
                    model.questionId = "";
                    pages[currentCourse].insert(++currentPage, model);
                    if(draw)
                    {
                        drawPage(pages[currentCourse].at(currentPage));
                    }
                    if(m_currentDocType == 3)
                    {
                        emit sigPageOpera("add");
                    }
                }
                if(type == 3)
                {
                    if (pages[currentCourse].size() == 1)
                    {
                        pages[currentCourse].removeAt(0);
                        PageModel model;
                        model.isCourware = 0;
                        model.bgimg = "";
                        model.width = 1.0;
                        model.height = 1.0;
                        model.offsetY = 0.0;
                        model.questionId = "";
                        model.columnType = "0";
                        pages[currentCourse].append(model);
                        return;
                    }
                    pages[currentCourse].removeAt(currentPage);
                    currentPage = currentPage >= pages[currentCourse].size() ? pages[currentCourse].size() - 1 : currentPage;
                    if(draw)
                    {
                        drawPage(pages[currentCourse].at(currentPage));
                    }
                    if(m_currentDocType == 3)
                    {
                        emit sigPageOpera("delete");
                    }
                }
            }
            else if(command == kSocketZoom)//滚动缩放
            {
                double  factor = 1000000.000000;
                double offsetX = contentVal.toObject().take("offsetX").toDouble();
                double offsetY = contentVal.toObject().take("offsetY").toDouble() / factor;
                int ratio = contentVal.toObject().take("ratio").toInt();
                emit sigZoomInOut(offsetX, offsetY, ratio);
                qDebug() << "===offsetY===" << offsetY;
            }
            else if(command == kSocketReward)//奖励
            {
                QString uid = contentVal.toObject().take("uid").toString();
                if(YMUserBaseInformation::type == "TEA")
                {
                    emit sigReward();
                }
                if(uid == YMUserBaseInformation::id)
                {
                    emit sigReward();
                }
            }
            else if(command == kSocketRoll)//随机选人
            {
                QJsonObject rollDataObj = contentVal.toObject();
                int type = rollDataObj.value("type").toInt();
                QString uid = rollDataObj.value("uid").toString();
                //qDebug() << "==kSocketRoll==" << uid << YMUserBaseInformation::id << type<< rollDataObj;
                emit sigRoll(rollDataObj);
            }
            else if(command == kSocketResponder)//抢答
            {
                QJsonObject responderObj = contentVal.toObject();
                emit sigResponder(responderObj);
            }
            else if(command == kSocketTimer)//计时器 倒计时
            {
                QJsonObject timerObj = contentVal.toObject();
                emit sigTimer(timerObj);
            }
            else if(command == kSocketOperation)//清屏，撤销操作
            {
                int type = contentVal.toObject().take("type").toInt();// 1 清屏 2 撤销,
                QString userId = document.object().take(kSocketUid).toString();
                if(type == 1)
                {
                    bufferModel.clear();
                    PageModel pagemodel = pages[currentCourse].at(currentPage);
                    pagemodel.clear(userId);
                    drawPage(pagemodel);
                }
                if(type == 2)
                {
                    bufferModel.clear();
                    QVector<Msg> msgs = pages[currentCourse][currentPage].msgs;
                    int lastIndex = -1;
                    for(int i = 0; i < msgs.size(); i++)
                    {
                        if (msgs.at(i).userId == userId)
                        {
                            lastIndex = i;
                        }
                    }
                    if (lastIndex != -1)
                    {
                        pages[currentCourse][currentPage].msgs.removeAt(lastIndex);
                    }
                    drawPage(pages[currentCourse].at(currentPage));
                }
            }
            else if(command == kSocketPoint)//教鞭
            {
                double pointx = contentVal.toObject().value("x").toDouble();
                double pointy = contentVal.toObject().value("y").toDouble();
                double  factor = 1000000.000000;
                pointx = pointx / factor;
                pointy = pointy / factor;
                pointy = changeYPoinToLocal(pointy);
                emit sigCursorPointer(this->width() * pointx, this ->height() * pointy);
            }
            else if(command == kSocketAV)//音视频课件
            {
                int flag = contentVal.toObject().value("flag").toInt();
                int time = contentVal.toObject().value("time").toInt();
                QString docId = contentVal.toObject().value("dockId").toString();
                QString suffix;
                if(!videoPathMap.contains(docId))
                {
                    m_avUrl = contentVal.toObject().value("path").toString();
                    suffix = contentVal.toObject().value("suffix").toString();
                    if(suffix.contains("mp3") || suffix.contains("wma") || suffix.contains("wav"))
                    {
                        m_avType = "audio";
                    }
                    if(suffix.contains("mp4") || suffix.contains("avi") || suffix.contains("wmv") || suffix.contains("rmvb"))
                    {
                        m_avType = "video";
                    }
                    videoPathMap.insert(docId,m_avUrl);
                }
                else
                {
                    m_avUrl  = videoPathMap.find(docId).value();
                    int lastIndex = m_avUrl.lastIndexOf(".");
                    suffix = m_avUrl.mid(lastIndex + 1,m_avUrl.length() - 1);
                    if(suffix.contains("mp3") || suffix.contains("wma") || suffix.contains("wav"))
                    {
                        m_avType = "audio";
                    }
                    if(suffix.contains("mp4") || suffix.contains("avi") || suffix.contains("wmv") || suffix.contains("rmvb"))
                    {
                        m_avType = "video";
                    }
                }
                if(flag == 0)
                {
                    m_controlType = "play";
                }
                else if(flag == 1)
                {
                    m_controlType = "pause";
                }
                else if(flag == 2)
                {
                    m_controlType = "stop";
                }
                m_startTime = QString::number(time);
            }
            else if(command == kSocketPlayAnimation)//H5课件动画
            {
                int step  = contentVal.toObject().take(kSocketStep).toInt();
                QString pageId = contentVal.toObject().take(kSocketPageId).toString();
                QString dockId = contentVal.toObject().take(kSocketDocDockId).toString();
                int pageNo = contentVal.toObject().take(kSocketPageNo).toInt();
                m_h5Model.append(H5dataModel(dockId,"3",QString::number(pageNo),"",step));
                emit sigPlayAnimation(pageId,step);
            }
        }
        if(m_protocolType == 1)
        {
            //一对一解析的命令
            if (domain == "draw" && command == "courware")
            {
                QJsonObject contentObj = contentVal.toObject();
                QString docId = contentObj.take("docId").toString();
                QJsonArray arr = contentObj.take("urls").toArray();
                if (pages.contains("DEFAULT"))
                {
                    pages.insert(docId, pages.value("DEFAULT"));
                    pages.remove("DEFAULT");
                    currentCourse = docId;
                    currentPage = pages[currentCourse].size();
                    for (int i = 0; i < arr.size(); ++i)
                    {
                        PageModel model;
                        model.isCourware = 1;
                        model.bgimg = arr.at(i).toString();
                        model.width = 1.0;
                        model.height = 1.0;
                        model.offsetY = 0.0;
                        model.questionId = "";
                        model.columnType = "0";
                        pages[currentCourse].append(model);
                    }
                }
                else if (!pages.contains(docId))
                {
                    QVector<PageModel> list;
                    PageModel model;
                    model.isCourware = 0;
                    model.bgimg = "";
                    model.width = 1.0;
                    model.height = 1.0;
                    list.append(model);
                    pages.insert(docId, list);
                    pageSave.insert(currentCourse, currentPage);
                    currentCourse = docId;
                    currentPage = 1;
                    for (int i = 0; i < arr.size(); ++i)
                    {
                        PageModel model1;
                        model1.isCourware = 1;
                        model1.bgimg = arr.at(i).toString();
                        model1.width = 1.0;
                        model1.height = 1.0;
                        model.offsetY = 0.0;
                        model.questionId = "";
                        model.columnType = "0";
                        pages[currentCourse].append(model1);
                    }
                }
                else
                {
                    currentCourse = docId;
                    currentPage = pageSave.value(currentCourse, 0);
                }
                if(draw)
                {
#ifdef USE_OSS_AUTHENTICATION
                    PageModel model = pages[currentCourse].at(currentPage);
                    model.bgimg = checkOssSign(model.bgimg);
                    drawPage(model);//pages[currentCourse].at(currentPage));
#else
                    drawPage(pages[currentCourse].at(currentPage));
#endif
                }
            }
            else if (domain == "page" && command == "goto")
            {

                int pageI = contentVal.toObject().take("page").toString().toInt();
                pageI = pageI < 0 ? 0 : pageI;
                if (pageI > pages[currentCourse].size() - 1)
                    pageI = pages[currentCourse].size() - 1;
                currentPage = pageI;

                //qDebug() << "====goPage=======" << currentCourse << draw << currentPage;
                if(draw)
                {
                    bufferModel.clear();

#ifdef USE_OSS_AUTHENTICATION
                    PageModel model = pages[currentCourse].at(currentPage);
                    model.bgimg = checkOssSign(model.bgimg);
                    drawPage(model);//pages[currentCourse].at(currentPage));
#else
                    drawPage(pages[currentCourse].at(currentPage)); // model);//
#endif
                }

                QStringList strList = currentCourse.split("|");

                if(strList.size() > 1)
                {
                    QString planId = strList.at(0);
                    QString columnId = strList.at(1);

                    if(pages.contains(currentCourse))
                    {
                        if(pages[currentCourse].size() > 1)
                        {
                            QString questionId = pages[currentCourse].at(currentPage).questionId;
                            emit sigCurrentQuestionId(planId, columnId, questionId);
                            //qDebug() << "=====sigCurrentQuestionId========" << currentPage << planId << columnId << questionId;
                        }
                    }
                }

            }
            else if (domain == "page" && command == "insert")
            {
                bufferModel.clear();
                //qDebug() << "=====inset::page====";
                PageModel model;
                model.isCourware = 0;
                model.bgimg = "";
                model.width = 1.0;
                model.height = 1.0;
                model.questionId = "";
                pages[currentCourse].insert(++currentPage, model);
                if(draw)
                {
                    drawPage(pages[currentCourse].at(currentPage));
                }
            }
            else if (domain == "page" && command == "delete")
            {
                bufferModel.clear();
                if (pages[currentCourse].size() == 1)
                {
                    pages[currentCourse].removeAt(0);
                    PageModel model;
                    model.isCourware = 0;
                    model.bgimg = "";
                    model.width = 1.0;
                    model.height = 1.0;
                    model.offsetY = 0.0;
                    model.questionId = "";
                    model.columnType = "0";
                    pages[currentCourse].append(model);
                    return;
                }
                pages[currentCourse].removeAt(currentPage);
                currentPage = currentPage >= pages[currentCourse].size() ? pages[currentCourse].size() - 1 : currentPage;
                if(draw)
                {

#ifdef USE_OSS_AUTHENTICATION
                    PageModel model = pages[currentCourse].at(currentPage);
                    model.bgimg = checkOssSign(model.bgimg);
                    drawPage(model);//pages[currentCourse].at(currentPage));
#else
                    drawPage(pages[currentCourse].at(currentPage));
#endif
                }
            }
            else if (domain == "draw" && command == "picture")
            {
                bufferModel.clear();
                QString url = contentVal.toObject().take("url").toString();
                double width = contentVal.toObject().take("width").toString().toDouble();
                double height = contentVal.toObject().take("height").toString().toDouble();
                PageModel model;
                model.isCourware = 0;
                model.bgimg = url;
                model.width = width;
                model.height = height;
                model.questionId = "-2";
                model.offsetY = 0.0;
                model.columnType = "0";
                QStringList questionList = currentCourse.split("|");
                if(questionList.size() > 1)
                {
                    model.questionId = "-1";
                }
                //qDebug() << "==currentPage==" << currentPage << currentCourse << pages[currentCourse].size();
                pages[currentCourse].insert(++currentPage, model);
                //qDebug() << "==11currentPage11==" << model.questionId;
                if(draw)
                {
                    //qDebug() << "++++page++++";
#ifdef USE_OSS_AUTHENTICATION
                    PageModel model = pages[currentCourse].at(currentPage);
                    model.bgimg = checkOssSign(model.bgimg);
                    drawPage(model);//pages[currentCourse].at(currentPage));
#else
                    drawPage(pages[currentCourse].at(currentPage));
#endif
                }
            }
            else if (domain == "draw" &&
                     (command == "trail" || command == "polygon" || command == "ellipse"))
            {
                Msg m;
                m.message = msg;
                m.userId = fromUser;
                m.timestamp = 0;
                pages[currentCourse][currentPage].msgs.append(m);
                if(draw)
                {
                    bufferModel.addMsg("temp", msg, QString::number(currentPage));
                    drawLine(msg);
                }
            }
            else if (domain == "control" && command == "cursor")
            {
                QJsonObject dataObj = contentVal.toObject();
                //qDebug() << "========cursor=======" << dataObj;
                double pointx = dataObj.value("X").toString().toDouble();
                double pointy = dataObj.value("Y").toString().toDouble();
                pointy = changeYPoinToLocal(pointy);
                emit sigCursorPointer(this->width() * pointx, this ->height() * pointy);
                return;
            }
            else if (domain == "draw" && command == "undo")
            {
                QVector<Msg> msgs = pages[currentCourse][currentPage].msgs;
                int lastIndex = -1;
                for(int i = 0; i < msgs.size(); i++)
                {
                    if (msgs.at(i).userId == fromUser)
                    {
                        lastIndex = i;
                    }
                }
                if (lastIndex != -1)
                {
                    pages[currentCourse][currentPage].msgs.removeAt(lastIndex);
                }
                if(draw)
                {
#ifdef USE_OSS_AUTHENTICATION
                    PageModel model = pages[currentCourse].at(currentPage);
                    model.bgimg = checkOssSign(model.bgimg);
                    drawPage(model);//pages[currentCourse].at(currentPage));
#else
                    drawPage(pages[currentCourse].at(currentPage));
#endif
                }
            }
            else if (domain == "draw" && command == "clear")
            {
                pages[currentCourse][currentPage].msgs.clear();
                if(draw)
                {
#ifdef USE_OSS_AUTHENTICATION
                    PageModel model = pages[currentCourse].at(currentPage);
                    model.bgimg = checkOssSign(model.bgimg);
                    drawPage(model);//pages[currentCourse].at(currentPage));
#else
                    bufferModel.clear();
                    drawPage(pages[currentCourse].at(currentPage));
#endif

                }
            }
            else if(command == "avControl")
            {
                QString startTime = contentVal.toObject().take("startTime").toString();
                QString fileUrl = contentVal.toObject().take("avUrl").toString();
                QString controlType = contentVal.toObject().take("controlType").toString();
                QString avType = contentVal.toObject().take("avType").toString();

                m_startTime = startTime;
                m_avUrl = fileUrl;
                m_controlType = controlType;
                m_avType = avType;
                m_currentTime = currentTime;
                //qDebug() << "===========" <<m_startTime <<controlType << avType ;
            }
            else if(domain == "draw" && command == "lessonPlan")
            {
                QJsonObject contentObj = contentVal.toObject();
                //qDebug() << "======lessonPlan::contentObj====" << contentObj;
                QString planId = contentObj.value("planId").toInt();
                QString planType = QString::number(contentObj.value("planType").toInt());
                QJsonArray columnsArray = contentObj.value("columns").toArray();
                if(columnsArray.size() <= 0)
                {
                    //qDebug() << "======columnsArray=====" << columnsArray.size();
                    currentPage = 1;
                    return;
                }
                QString itemId;
                for(int i = 0; i < columnsArray.size(); i++)
                {
                    QJsonObject columnObj =  columnsArray.at(i).toObject();
                    QString columnId = columnObj.value("columnId").toString();
                    QJsonArray questionsArray = columnObj.value("questions").toArray();
                    if(i == 0 )
                    {
                        itemId = columnId;
                    }
                    QString docId = planId + "|" + columnId;
                    if (pages.contains("DEFAULT"))
                    {
                        pages.insert(docId, pages.value("DEFAULT"));
                        pages.remove("DEFAULT");
                        currentCourse = docId;
                        currentPage = pages[currentCourse].size();
                        for(int z = 0; z < questionsArray.size(); z++)
                        {
                            QString questionId = questionsArray.at(z).toString();
                            //qDebug() << "=======questionId::Data222=========" << questionId << currentCourse;
                            pages[currentCourse].append(PageModel("", 1, questionId, columnId, 0.0));
                        }
                        //qDebug() << "=======DEFAULT=======" << pages.size();
                    }
                    else if (!pages.contains(docId))
                    {
                        QVector<PageModel> list;
                        list.append(PageModel("", 0, "", columnId, 0.0));
                        pages.insert(docId, list);
                        pageSave.insert(currentCourse, currentPage);
                        currentCourse = docId;
                        currentPage = 1;
                        for(int z = 0; z < questionsArray.size(); z++)
                        {
                            QString questionId = questionsArray.at(z).toString();
                            //qDebug() << "=======questionId::Data111=========" << currentPage << questionId << currentCourse;
                            pages[currentCourse].append(PageModel("", 1, questionId, columnId, 0.0));
                        }
                    }
                    else
                    {
                        pageSave.insert(currentCourse, currentPage);
                        currentCourse = docId;
                    }
                }
                emit sigPlanInfo(contentObj, planId,planType);
                //qDebug() << "====lessonPlanInfo===" << contentObj;
            }
            else if(domain == "draw" && command == "column")
            {
                bufferModel.clear();
                onCtentsSizeChanged();
                QJsonObject contentObj = contentVal.toObject();
                QString columnId = contentObj.value("columnId").toString();
                int pageIndex = contentObj.value("pageIndex").toString().toInt();
                QString planId = contentObj.value("planId").toString();
                QString docId = planId + "|" + columnId;
                //qDebug() << "======column::contentObj======" << contentObj;
                //qDebug() << "========columnInfo::data=======" << pageIndex << pages[docId].size();
                if(pages.contains(docId))
                {
                    if(pages[docId].size() > 1)
                    {
                        currentCourse = docId;
                        if(pageIndex > pages[docId].size())
                        {
                            pageIndex = 0;
                        }
                        emit sigQuestionInfo(pages[docId].at(pageIndex).questionId, planId, columnId);
                    }
                }
                emit sigColumnInfo(columnId, planId, QString::number(pageIndex));
                //qDebug() << "====columnInfo===" << contentObj;
            }
            else if(domain == "draw" && command == "question" )
            {
                QJsonObject contentObj = contentVal.toObject();
                QString columnId = contentObj.value("columnId").toString();
                QString planId = contentObj.value("planId").toString();
                QString questionId = contentObj.value("questionId").toString();
                emit sigQuestionInfo(questionId, planId, columnId);
                //qDebug() << "====questionInfo===" << contentObj;

            }
            else if(domain == "control" && command == "openCorrect" )
            {
                QJsonObject contentObj = contentVal.toObject();
                emit sigIsOpenCorrect(true);
                //qDebug() << "====openCorrectInfo===" << contentObj;
            }
            else if(domain == "control" && command == "closeCorrect" )
            {
                QJsonObject contentObj = contentVal.toObject();
                emit sigIsOpenCorrect(false);
                //qDebug() << "====closeCorrectInfo===" << contentObj;
            }
            else if(domain == "control" && command == "openAnswerParsing" )
            {
                QJsonObject contentObj = contentVal.toObject();
                QString questionId = contentObj.value("questionId").toString();
                QString childQuestionId = contentObj.value("childQuestionId").toString();
                emit sigIsOpenAnswer(true, questionId, childQuestionId);
                //qDebug() << "====openAnswerParsing===" << questionId << childQuestionId;
            }
            else if(domain == "control" && command == "closeAnswerParsing" )
            {
                QJsonObject contentObj = contentVal.toObject();
                QString questionId = contentObj.value("questionId").toString();
                QString childQuestionId = contentObj.value("childQuestionId").toString();
                emit sigIsOpenAnswer(false, questionId, childQuestionId);
                //qDebug() << "====closeAnswerParsing===" << contentObj;
            }
            else if(domain == "draw" && command == "autoPicture")
            {
                QJsonObject contentObj = contentVal.toObject();
                //qDebug() << "====answerPicture===" << contentObj;
                QString imageUrl = contentObj.value("imageUrl").toString();
                int imageHeight = contentObj.value("imgHeight").toString().toInt();
                //emit sigCommitImage(imageUrl,imageHeight);
            }
        }
    }
    else
    {
        qDebug() << QStringLiteral("json 解析错误:") << msg;
    }
}
//画线
void PainterBoard::drawLine(const QVector<QPointF> &points, double brushWidth, QColor color, int type)
{
    if(points.size() == 0) return;
    QPen pen(QBrush(color), brushWidth, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin);
    QPainter painter;
    painter.begin(&trailPixmap);
    painter.setPen(pen);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.scale(this->width(), this->height());
    if(type == 2)
    {
        painter.setCompositionMode(QPainter::CompositionMode_Clear);
    }
    painter.drawPolyline(QPolygonF(points));
    painter.end();
    update();
    //this->paint(painter);
}

//画椭圆
void PainterBoard::drawEllipse(const QRectF &rect, double brushWidth, QColor color, double angle)
{
    QPen pen(QBrush(color), brushWidth, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin);
    QPainter painter;
    painter.begin(&trailPixmap);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.save();
    painter.translate((rect.x() + rect.width() * 0.5) * this->width(), (rect.y() + rect.height() * 0.5) * this->height());
    painter.rotate(angle);
    painter.scale(this->width(), this->height());
    painter.setPen(pen);
    //平移画布到矩形中心点
    painter.drawEllipse(QRectF(-rect.width() * 0.5, -rect.height() * 0.5, rect.width(), rect.height()));
    painter.end();
    update();
    //qDebug() << "==PainterBoard::drawEllipse==";
}