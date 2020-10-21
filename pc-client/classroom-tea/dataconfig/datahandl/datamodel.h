#ifndef DATAMODEL
#define DATAMODEL


#include <QString>
#include <QList>
#include <QObject>
#include <stdio.h>
#include <QSet>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>
#include <QMessageBox>
#include <QDateTime>
#include <QSysInfo>
#include <QSettings>
#include <QStandardPaths>
#include <QDir>
#include <QStringList>
#include <QTextCodec>
#include <QMap>
#include <QDebug>
#include <QNetworkInterface>
#include <QPair>
#include <debuglog.h>
#include "./cloudclassroom/cloudclassManager/YMUserBaseInformation.h"

class AudioVideoPlaySetting
{

public:
    AudioVideoPlaySetting()
        :m_avType(""),
         m_startTime(""),
         m_controlType(""),
         m_avUrl(""),
         playTime(0),
         currentTime(0),
         isHasSynchronize(false),
         m_camera("1"),
         m_microphone("1")
    {

    }
    virtual ~AudioVideoPlaySetting()
    {
    }

    QString m_avType;
    QString m_startTime;
    QString m_controlType;
    QString m_avUrl;
    long long playTime;
    long long currentTime;
    bool isHasSynchronize;//标示 是否从同步中解析过数据 如果解析过 在开始上课时不发视频命令
    QString m_camera;
    QString m_microphone;

};

class Teacher
{

public:
    Teacher()
    {
        m_camera = "1";
        m_microphone = "1";
    }
    virtual ~Teacher()
    {
    }

    QString m_teacherId;
    QString m_teacherUrl;
    QString m_teacherName;
    QString m_teachPhone;

    QString m_camera;
    QString m_microphone;
signals:
protected slots:

};


class Student
{

public:
    Student()
    {
        m_camera = "1";
        m_microphone = "1";
    }
    virtual ~Student()
    {
    }

    QString m_studentId;

    QString m_listenId;//旁听Id

    QString m_studentAId;
    QString m_studentUrl;
    QString m_studentType;
    QString m_studentName;

    QString m_camera;
    QString m_microphone;

};


class SettingFile
{

public:
    virtual ~SettingFile()
    {

    }

    static SettingFile  * gestance()
    {
        static SettingFile * settingFile = new SettingFile();

        return settingFile;
    }
    //得到所有的ip列表
    QStringList getAllIpList()
    {
        if (m_settings != NULL)
        {
            m_settings->beginGroup("ItemLost");
            QStringList list = m_settings->childKeys();
            m_settings->endGroup();
            return list;
        }
        else
        {
            return QStringList("");
        }
    }

    //设置ip的丢失包
    void setIpLost(QString name, QString editnum)
    {
        if (m_settings != NULL)
        {
            m_settings->beginGroup("ItemLost");
            m_settings->setValue(name, editnum);
            m_settings->endGroup();

        }

    }

    //设置ip的延时
    void setIpDelay(QString name, QString editnum)
    {
        if (m_settings != NULL)
        {
            m_settings->beginGroup("ItemDelay");
            m_settings->setValue(name, editnum);
            m_settings->endGroup();

        }

    }

    //设置选中的ip ipitem
    void setSelectItem(QString name, QString editnum)
    {
        if (m_settings != NULL)
        {
            m_settings->beginGroup("SelectItem");
            m_settings->setValue(name, editnum);
            m_settings->endGroup();

        }

    }

    //获得ip的丢失包
    QString  getIpLost(QString name)
    {
        if (m_settings != NULL)
        {
            m_settings->beginGroup("ItemLost");
            QString str =  m_settings->value(name).toString();
            m_settings->endGroup();
            return str;
        }
        else
        {
            return QString("");
        }
    }

    //获得ip的延时
    QString  getIpDelay(QString name)
    {
        if (m_settings != NULL)
        {
            m_settings->beginGroup("ItemDelay");
            QString str =  m_settings->value(name).toString();
            m_settings->endGroup();
            return str;
        }
        else
        {
            return QString("");
        }
    }


    //获得ip的延时 ipitem
    QString  getSelectItem(QString name)
    {
        if (m_settings != NULL)
        {
            m_settings->beginGroup("SelectItem");
            QString str =  m_settings->value(name).toString();
            m_settings->endGroup();
            return str;
        }
        else
        {
            return QString("");
        }
    }



private:
    SettingFile()
    {
        QString docPath = DebugLog::getDocumentDir();//QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
        QString systemPublicFilePath;
        if (docPath == "")
        {
            systemPublicFilePath = "C:/";
        }
        else
        {
            systemPublicFilePath = docPath + "/";
        }
        systemPublicFilePath += "YiMi/temp/";
        QDir dir;
        if( !dir.exists(systemPublicFilePath))
        {
            dir.mkdir(systemPublicFilePath);
        }

        QString fileName = systemPublicFilePath + "/stuconfig.ini";
        m_settings = new QSettings (fileName, QSettings ::IniFormat);
        m_settings->setIniCodec(QTextCodec::codecForName("UTF-8"));
    }

private:
    QSettings * m_settings;
};


class StudentData
{

public:

    virtual ~StudentData()
    {
        m_cameraPhone.clear();
    }

    static StudentData  * gestance()
    {
        static StudentData * m_studentDatash = new StudentData();



        return m_studentDatash;
    }


    void insertIntoOnlineId(QString ids)
    {
        qDebug() << "====insertIntoOnlineId===" << ids;
        m_onlineId.insert(ids);
    }
    void removeOnlineId(QString ids)
    {
        qDebug() << "====removeOnlineId===" << ids;
        m_onlineId.remove(ids);
    }
    bool justIdIsExit(QString ids)
    {
        //判断当前是否是持麦者并且学生是否在线
        qDebug() << "=======aaaaaaaaaaaaaaaaaaaadddd========" << StudentData::gestance()->m_onlineId
                 << StudentData::gestance()->m_selfStudent.m_studentId
                 << m_JoinMicId;
        if(StudentData::gestance()->m_onlineId.contains(StudentData::gestance()->m_selfStudent.m_studentAId)
                && m_JoinMicId.contains(StudentData::gestance()->m_selfStudent.m_studentId)){
            return true;
        }
        return false;
        //return  m_onlineId.contains(ids);
    }

    bool justUserIsOnline(QString userId)
    {
        return  m_onlineId.contains(userId);
    }

    void setDocumentParsing(QString backDatas)
    {
        QString strDllFile = StudentData::gestance()->strAppFullPath;
        strDllFile = strDllFile.replace(StudentData::gestance()->strAppName, "Qtyer.dll"); //得到dll文件的绝对路径
        if(QFile::exists(strDllFile))
        {
            QSettings * m_setting = new QSettings(strDllFile, QSettings::IniFormat);
            m_setting->beginGroup("Beauty");
            int beautyType = m_setting->value("type").toInt();
            m_setting->endGroup();
            if(beautyType == 1)
            {
                beautyIsOn = false;
            }
            m_setting->beginGroup("EnvironmentType");
            int environmentType = m_setting->value("isPublic_Test").toInt();
            m_setting->endGroup();
            if(environmentType == 1)
            {
                m_isPublicEnvironment = true;
            }

        }
        // QString backData =  QStringLiteral(backData);

        m_student.clear();
        QStringList listIndor = backDatas.split("###");
        QString backData;
        QString backDataOne;
        QString studentId;
        for(int i = 0 ; i < listIndor.count() ; i++)

        {
            if(i == 0)
            {
                backData = listIndor[0];
            }
            if(i == 1)
            {
                backDataOne = listIndor[1];
            }
        }
        QJsonParseError errors;
        QJsonDocument documets = QJsonDocument::fromJson(backDataOne.toUtf8(), &errors);
        if(errors.error == QJsonParseError::NoError)
        {
            if(documets.isObject())
            {
                QJsonObject jsonObjsa = documets.object();
                if(m_selectItemAddress.length() > 0)
                {
                    m_address = m_selectItemAddress;
                }
                else

                {
                    m_address = jsonObjsa.take("address").toString();
                    m_selectItemAddress =  m_address;
                }

                m_port = jsonObjsa.take("port").toString().toInt();
                m_udpPort = jsonObjsa.take("udpPort").toString().toInt();
                m_apiVersion  = jsonObjsa.take("apiVersion").toString();
                m_appVersion  = jsonObjsa.take("appVersion").toString();
                m_token = jsonObjsa.take("token").toString();
                m_plat = jsonObjsa.take("plat").toString();
                if(m_plat == "")//试听课非试听课兼容
                {
                    m_plat = "T";
                }
                m_StaticPlat = m_plat;

                studentId = jsonObjsa.take("id").toString();
                m_selfStudent.m_listenId = studentId;
                m_selfStudent.m_studentId = studentId;
                YMUserBaseInformation::token = m_token;
                YMUserBaseInformation::apiVersion = m_apiVersion;
                YMUserBaseInformation::appVersion = m_appVersion;
                qDebug() << "====m_appVersion======" << m_plat << m_apiVersion << m_appVersion;
                //新增字段
                m_logTime = jsonObjsa.take("logTime").toString();
                m_userName = jsonObjsa.take("userName").toString();
                m_selfStudent.m_studentName = m_userName;
                //m_sysInfo  = jsonObjsa.take("sysInfo").toString();
                m_mD5Pwd  = jsonObjsa.take("MD5Pwd").toString();
                m_deviceInfo = jsonObjsa.take("deviceInfo").toString();
                m_phone = jsonObjsa.take("mobileNo").toString();
                //m_lessonType = jsonObjsa.value("lessonType").toString();
                if(jsonObjsa.value("lessonType").toString().contains("O")) //O 订单课 A试听课
                {
                    m_lessonType = 10;
                }else
                {
                    m_lessonType = 0;
                }
                m_headPicture = jsonObjsa.value("headPicture").toString();
                m_listenUsername = jsonObjsa.value("userName").toString();
                //qDebug()<<"m_phone =="<<m_phone << m_lessonType;
                QString  lat = jsonObjsa.take("lat").toString();
                QString  lng = jsonObjsa.take("lng").toString();
                if(lat.length() <= 0)
                {
                    lat = "0" ;
                }
                if(lng.length() <= 0)
                {
                    lng = "0" ;
                }
                m_lat = lat;//坐标
                m_lng = lng;//坐标

            }
        }
        if(studentId.length() < 1)
        {
            return;
        }
        QString indors;
        QJsonParseError error;
        QJsonDocument documet = QJsonDocument::fromJson(backData.toUtf8(), &error);
        if(error.error == QJsonParseError::NoError)
        {
            DebugLog::gestance()->log("datamodel::setDocumentParsing::readFile");
            if(documet.isObject())
            {
                QJsonObject jsonObjs = documet.object();
                if(jsonObjs.contains("data"))
                {
                    QJsonObject jsonObj = jsonObjs.take("data").toObject();

                    QString qqSign = jsonObj.take("qqSign").toString();
                    m_qqSign = qqSign;

                    int socketFlag = jsonObj.take("socketFlag").toInt();
                    if(socketFlag == 1)
                    {
                        m_isTcpProtocol = true;
                    }
                    else if(socketFlag == 2)
                    {
                        m_isTcpProtocol = false;
                    }

                    int offSingle= jsonObj.take("offSingle").toInt();
                    YMUserBaseInformation::offSingle = offSingle;
                    YMUserBaseInformation::reportFlag = jsonObj.take("reportFlag").toInt();

                    YMUserBaseInformation::applicationType = jsonObj.take("applicationType").toInt();
                    m_applicationType = YMUserBaseInformation::applicationType;
                    if(backData.contains("lessonType"))
                    {
                        m_lessonType = jsonObj.take("lessonType").toInt();
                    }
                    YMUserBaseInformation::lessonType = m_lessonType;

                    if(backData.contains("subjectId"))
                    {
                        m_subjectId = jsonObj.value("subjectId").toInt();
                    }else
                    {
                        m_subjectId = -1;
                    }

                    YMUserBaseInformation::subjectId = m_subjectId;
                    qDebug()<<"====setDocumentParsing=="<< YMUserBaseInformation::applicationType << YMUserBaseInformation::lessonType << YMUserBaseInformation::subjectId << __LINE__;

                    QString lessonId = QString("%1").arg( jsonObj.take("lessonId").toInt() );
                    m_lessonId = lessonId;
                    YMUserBaseInformation::lessonId = lessonId;
                    QString startTime = jsonObj.take("startTime").toString();
                    QDateTime startTimeDate = QDateTime::fromString(startTime, "yyyy-MM-dd hh:mm:ss");
                    QString startTimes = startTimeDate.toString("hh:mm");
                    //  qDebug()<<"startTime=="<<startTime;

                    QString endTime = jsonObj.take("endTime").toString();
                    QDateTime endTimeDate = QDateTime::fromString(endTime, "yyyy-MM-dd hh:mm:ss");
                    QString endTimes = endTimeDate.toString("hh:mm");
                    //qDebug()<<"endTimes=="<<endTimes;

                    m_classTimeLen = (endTimeDate.toTime_t() - startTimeDate.toTime_t() ) / 60 ;
                    //  qDebug()<<"m_classTimeLen =="<<m_classTimeLen;
                    m_startToEndTime = startTimes + " - " + endTimes;
                    // qDebug()<<"m_startToEndTime=="<<m_startToEndTime;
                    QString title_short = jsonObj.take("title_short").toString();
                    QString name_short = title_short.remove(m_lessonId);
                    name_short = name_short.remove(startTimes);
                    name_short = name_short.remove(endTimes);
                    name_short = name_short.remove("-");
                    name_short = name_short.remove(" ");
                    //qDebug()<<"name_short=="<<name_short;

                    m_curriculum =  name_short;

                    QJsonObject teacher = jsonObj.take("teacher").toObject();
                    QString  headPicture = teacher.take("headPicture").toString();
                    m_teacher.m_teacherUrl = headPicture;


                    QString  realName = teacher.take("realName").toString();
                    m_teacher.m_teacherName = realName;
                    QString  teacherId = QString("%1").arg( teacher.take("teacherId").toInt() );
                    m_teacher.m_teacherId = teacherId;


                    QString  mobileNo = teacher.take("mobileNo").toString();

                    m_teacher.m_teachPhone = mobileNo;
                    functionSwitch = teacher.take("functionSwitch").toObject();

                    QJsonArray students = jsonObj.take("student").toArray();
                    foreach (QJsonValue student, students)
                    {
                        Student student1;
                        QString  headPictures = student.toObject().take("headPicture").toString();
                        student1.m_studentUrl =  headPictures;

                        QString  realNames = student.toObject().take("realName").toString();
                        student1.m_studentName = realNames;


                        QString  mobileNos = student.toObject().take("mobileNo").toString();

                        QString  ids = QString("%1").arg( student.toObject().take("id").toInt() );
                        student1.m_studentId = ids;
                        m_selfStudent.m_studentAId = ids;
                        YMUserBaseInformation::id = ids;

                        QString  types = student.toObject().take("type").toString();
                        if( types == "A" )
                        {
                            YMUserBaseInformation::aStudentName = realNames;
                        }
                        m_selfStudent.m_studentType = "TEA";

                        student1.m_studentType = types;

                        //                        m_selfStudent.m_studentId = teacherId;

                        m_student.append(student1);
                    }
                }
                //DebugLog::gestance()->log("datamodel::setDocumentParsing::success");
            }
        }

    }

    //得到用户的摄像头状态
    QString getUserCamcera(QString userId)
    {
        QMap<QString, QPair<QString, QString> >::iterator it =  m_cameraPhone.begin() ;

        QString status = "1";
        for(; it != m_cameraPhone.end() ; it++)
        {
            if(it.key() == userId)
            {
                status = it.value().first;
            }
        }
        //qDebug() << "getUserCamcera" << userId << status;
        return status;
    }

    //得到用户话筒状态
    QString getUserPhone(QString userId)
    {
        QMap<QString, QPair<QString, QString> >::iterator it =  m_cameraPhone.begin() ;
        QString status = "1";
        for(; it != m_cameraPhone.end() ; it++)
        {
            //qDebug() << "getUserPhone::"  << it.key() << it.value() ;
            if(it.key() == userId)
            {
                status = it.value().second;
            }
        }
        return status;
    }

    //设置话筒的状态
    void  setUserPhone(QString userId, QString status)
    {
        QMap<QString, QPair<QString, QString> >::iterator it =  m_cameraPhone.begin() ;
        QString astr;
        int just = 0;
        for(; it != m_cameraPhone.end() ; it++)
        {
            if(it.key() == userId)
            {
                astr = it.value().first;
                just = 1;
            }

        }
        if(just == 1)
        {
            QPair<QString, QString> pair(astr, status);
            m_cameraPhone.insert(userId, pair);
        }

    }

    //设置用户的摄像头状态
    void setUserCamcera(QString userId, QString status)
    {

        QMap<QString, QPair<QString, QString> >::iterator it =  m_cameraPhone.begin() ;
        QString astr;
        int just = 0;
        for(; it != m_cameraPhone.end() ; it++)
        {
            if(it.key() == userId)
            {
                astr = it.value().second;
                just = 1;
            }
        }
        if(just == 1)
        {
            QPair<QString, QString> pair(status, astr);
            m_cameraPhone.insert(userId, pair);
        }
        //qDebug() << "setUserCamcera" << userId << status;
    }

    bool isCouldUseNewBoard()
    {
        return couldUseNewBoard;
    }

    void setCouldUseNewBoard(bool iscCouldUseNewBoard)
    {
        couldUseNewBoard = iscCouldUseNewBoard;
    }

    void insertUserTypeInfo(QString userId, QString userType)
    {
        m_userTypeInfo.insert(userId,userType);
    }

    //根据用户id查询用户类型
    QString getUserTypeById(QString userId)
    {
        if(m_userTypeInfo.contains(userId))
        {
            return m_userTypeInfo.find(userId).value();
        }
        return "";
    }
    QList<Student> m_student;
    Teacher m_teacher;
    QString m_lessonId;
    QString m_apiVersion;
    QString m_appVersion;
    QString m_token;
    QString m_curriculum; //课程名称
    bool m_dataInsertion;
    QString m_qqSign;
    QString m_channelKey;
    QString m_shewangSign;
    QString m_audioName;
    QString m_headPicture;
    QString m_listenUsername;

    QString m_logTime;//登录客户端时间
    QString m_userName;//登录时的用户名


    QSet<QString> m_onlineId;
    QMap<QString,QString> m_userTypeInfo;//存储用户的类型信息
    QString m_ccId;//cc的id

    QString m_address; //socket使用的IP地址
    QString m_tempAddress = "";//缓存上次链接的ip地址
    int m_currentServerDelay = 0; //当前服务器的延迟信息
    int m_currentServerLost = 0;//当前服务器的丢包信息
    QString m_startToEndTime;

    bool m_hasConnectServer = false;

    //========================
    //lessonType 0,1    试听课
    //lessonType 10     订单课
    //subjectId  0      演示课
    int m_applicationType; //0不是标准试听课, 1是
    int m_lessonType;
    int m_subjectId;

    //========================
    QJsonArray lessonCommentConfigInfo;//课程结束时评价的配置

    int m_port; //socket使用的端口
    int m_udpPort = 5120;
    //协议类型 isTcpProtocol  true 为tcp协议   false为 udp协议
    bool m_isTcpProtocol = true;//默认 tcp协议

    Student m_selfStudent;

    //QString


    QString m_mD5Pwd;
    QString m_sysInfo;
    QString m_phone;
    QString m_deviceInfo;

    QString m_camera;
    QString m_microphone;//本地的摄像头状态
    QString m_selectItemAddress; //选中ip

    QMap<QString, QPair<QString, QString> > m_cameraPhone; //存储所有的摄像头状态

    QString m_lat;//坐标
    QString m_lng;//坐标

    QString m_plat;//类型状态 T:老师 L:旁听
    QString m_StaticPlat; //Temp.ini文件中的值, 不会被修改

    int m_classTimeLen;//一节课的课程时间 分钟显示

    double midHeight; // 中间画板高度
    double midWidth;
    double fullWidth;
    double fullHeight;

    bool couldUseNewBoard =  true;//是否可以使用16:9的画板
    QString tempRecordVersion = "";//记录第一次开课时的录播版本号

#ifdef USE_OSS_AUTHENTICATION
    bool coursewareSignOff = false;
#endif

    QString strAppName; //记录当前应用程序的名称
    QString strAppFullPath; //记录当前应用程序的路径 + 名称, 方便加载dll文件的时候, 使用
    QString strAppFullPath_LogFile; //记录当前应用程序日志文件的路径 + 名称, 方便日志上传的服务器
    QString strAgoraFullPath_LogFile; //记录声网SDK的日志文件路径 + 名称, 方便日志上传的服务器

    QJsonObject functionSwitch;//通道开关标示


    //是否开启美颜
    bool beautyIsOn = true;//美颜是否开启
    bool m_isPublicEnvironment = false;//是否是公测环境
    QList< QImage > hasBeautyImageList;//存储被美颜过的图像

    QString m_JoinMicId = "";//当前上麦者的id

    bool couldDirectExit = true;//填写课堂报告的时候是不是可以直接退出

    //qos上报用字段
    QString receivedFrameRate;//视频接收帧率",--声网-QQ专用
    QString videoLost = "";//端到端视频丢包率",---声网、网易专用
    QString audioLost;//端到端音频丢包率",---声网、网易专用
    QString sendLossRate;//"发送丢包率"，QQ专用
    QString recvLossRate;//"接收丢包率" ,----QQ专用

    QMap<long, QMap<QString, QJsonObject>> allCoursewareData;//所有课件的信息

private:
    StudentData()
    {
        m_camera = "1";
        m_microphone = "0";
        m_classTimeLen = 0;
        m_cameraPhone.clear();
        m_selectItemAddress = "";
        if( SettingFile::gestance()->getAllIpList().count() > 0 )
        {
            QString ipitem = "";
            ipitem = SettingFile::gestance()->getSelectItem("ipitem");
            if(ipitem.length() > 0)
            {
                m_selectItemAddress = ipitem;
            }
        }


        m_sysInfo =  QSysInfo::prettyProductName();
        m_deviceInfo = QSysInfo::buildCpuArchitecture();
        m_sysInfo.remove("#");
        m_sysInfo.remove("\n");
        m_deviceInfo.remove("#");
        m_deviceInfo.remove("\n");

    }

    //static StudentData * m_studentDatash ;

};

class TemporaryParameter
{
public:
    TemporaryParameter()
    {
        m_onlineId.clear();
        m_selectItem = false;
        m_supplier = "1";
        m_videoType = "1";
        m_userBrushPermissions = "0";
        m_userPagePermissions = "0";
        m_isAlreadyClass = false;
        m_techerEnerRoom = false;
        m_teacherIsOnline = false;
        m_astudentIsOnline = false;
        m_timeTotaltime = 0;
        m_uerIds = "";
        m_ipContents.clear();
        m_userBrushPermissionsId.clear();
        m_isStartClass = false;

        int types = 0;
        QList<QNetworkInterface> list = QNetworkInterface::allInterfaces();
        foreach (QNetworkInterface netInterface, list)
        {
            if (!netInterface.isValid())
                continue;

            //  qDebug() << "********************";

            QNetworkInterface::InterfaceFlags flags = netInterface.flags();
            if (flags.testFlag(QNetworkInterface::IsRunning)
                    && !flags.testFlag(QNetworkInterface::IsLoopBack))    // 网络接口处于活动状态
            {
                if(types == 0)
                {
                    m_netWorkMode = netInterface.name();//netInterface.hardwareAddress();
                }
                types++;

            }
        }

        m_netWorkMode.remove("#");
        m_netWorkMode.remove("\n");
    }
    virtual ~TemporaryParameter()
    {
    }
    void insertIntoOnlineId(uint ids)
    {
        m_onlineId.insert(ids);
    }
    void removeOnlineId(uint ids)
    {
        m_onlineId.remove(ids);
    }
    bool justIdIsExit(uint ids)
    {
        return  m_onlineId.contains(ids);
    }


    static TemporaryParameter  * gestance()
    {

        static TemporaryParameter * temporaryParameter = new TemporaryParameter();

        return temporaryParameter;
    }
    int m_pageNo;
    QString m_currentCourse;
    QString m_docs;
    QString m_supplier; //当前通道
    QString m_videoType; //当前音频
    QString m_tempSupplier = "1";
    QString m_timeLens;
    int m_timeTotaltime;


    QString m_userBrushPermissions;//操作权限0为无权限
    QMap<QString, QString> m_userBrushPermissionsId;//每个用户的书写权限
    QString m_userPagePermissions;//翻页权限0为无权限

    bool m_isAlreadyClass; //检测是否已经上过课
    bool m_isStartClass;//是否已经开课

    bool m_techerEnerRoom;//老师有没进入房间

    bool m_teacherIsOnline; //老师是否在线为了B类型学生
    bool m_astudentIsOnline; //A学生是否在线为了B类型学生
    bool m_isFinishLesson = false;//结束课程标记，结束课程不接收重连机制

    QString m_uerIds;
    QString m_uerIdsAuthy;


    QMap<QString, QString> m_phoneType; //记录设备的类型, 比如: IOS, key是user id
    QMap<QString, QString> m_phoneVersion; //记录设备的版本信息, 比如: 3.10.2121, key是user id


    //检测声网通道延迟信息
    QMap<QString, QString> m_ipContents;

    QString m_netWorkMode;//判断是无线还是有线
    bool m_selectItem;//判断是否是点击切换频道
    QSet<uint> m_onlineId;//用于存储a通道的数据

    QString m_qqVoiceVersion = "6.0.0";// 腾讯SDK版本
    bool m_isUsingTencentV2 = false;// 正在使用腾讯V2通道


    //新增
    int m_beginClassTimeData;//是否开始上课
    QString m_userId;//翻页用户的id
    QString m_exitRoomId;//退出学生的id
    QString m_exitRequestId;
    QString m_enterRoomRequest;
    QString m_droppedRoomIds;
    QString m_cameraNames;
    QMap<QString, int> m_pageSave;
    QMap<QString, QList<QString> > m_coursewareName;
    //初始化音视频播放状态
    AudioVideoPlaySetting avPlaySetting;
    QVariantList goodIpList;//优化Ip列表

    //进入教室的状态
    QString enterRoomStatus = "N";// N 初次进入教室的状态  R 重连  C 切换服务器

    //声网 码率
    QString bitRate = "";

    //音视频详细信息
    QString s_VideoQulaity;
    QString s_VideoRxRate;
    QString s_VideoDelay;
    QString s_VideoLost;
    QString s_VideoVolume;


};
#endif // DATAMODEL

