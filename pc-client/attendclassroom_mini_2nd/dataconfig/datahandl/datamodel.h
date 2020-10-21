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
#include <QSettings>

#include"./cloudclassroom/cloudclassManager/YMUserBaseInformation.h"

#define MSG_BOX_TITLE  QString(u8"溢米辅导")

//用当前的环境的枚举类型
enum enumEnvironment
{
    ENVIRONMENT_API = 1,
    ENVIRONMENT_STAGE = 2,
    ENVIRONMENT_PRE = 3,
    ENVIRONMENT_DEV = 4,

    ENVIRONMENT_MAX = 100,
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
        int m_uid;
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
            m_uid = 0;
        }

        virtual ~Student()
        {
        }

        QString m_studentId;
        QString m_studentUrl;
        QString m_studentType;
        QString m_studentName;

        QString m_camera;
        QString m_microphone;
        int m_uid;
        QString m_isVideo;
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
        QString getIpDelay(QString name)
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
        QString getSelectItem(QString name)
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
            QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
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
    private:
        enumEnvironment m_enEnvironment;

    public:
        //得到当前环境的类型
        enumEnvironment getCurrentEnvironmentType()
        {
            return m_enEnvironment;
        }

        virtual ~StudentData()
        {
            m_cameraPhone.clear();
        }

        static StudentData  * gestance()
        {
            static StudentData * m_studentDatash = new StudentData();
            return m_studentDatash;
        }

        void addReward(QString userId)
        {
            if(m_reward.contains(userId))
            {
               int values = m_reward.find(userId).value() + 1;
               m_reward[userId] = values;
            }
            else
            {
                m_reward.insert(userId,1);
            }
        }

        void insertIntoOnlineId(QString ids)
        {
            m_onlineId.insert(ids);
        }

        void removeOnlineId(QString ids)
        {
            m_onlineId.remove(ids);
        }

        bool justIdIsExit(QString ids)
        {
            return  m_onlineId.contains(ids);
        }

        //获取 环境所需的 url
        void getRunUrl()
        {
            QString tempUrl = "api.yimifudao.com/v2.4";

            //=====================================
            //检查文件: Qtyer.dll, 是否存在
            //不存在的话, 提示文件不存在, 不是提示: 课件加载失败
            QString strDllFile = StudentData::gestance()->strAppFullPath;
            strDllFile = strDllFile.replace(StudentData::gestance()->strAppName, "Qtyer.dll"); //得到dll文件的绝对路径
            qDebug() << "datamodel getRunUrl" << qPrintable(strDllFile);

            QString strMsg = QString(u8"文件: %1, 不存在, 程序将退出." ) .arg(strDllFile);
            if(!QFile::exists(strDllFile))
            {
                QMessageBox::critical(NULL, MSG_BOX_TITLE, strMsg, QMessageBox::Ok, QMessageBox::Ok);
                qDebug() << "datamodel getRunUrl file not exist, file: " << qPrintable(strDllFile);
                exit(1);
            }

            //=====================================
            QSettings * m_setting = new QSettings(strDllFile, QSettings::IniFormat);

            // 环境类型  测试环境 0  正式环境 1 手动配置
            m_setting->beginGroup("EnvironmentType");

            int environmentType = m_setting->value("type").toInt();
            m_setting->endGroup();

            //====================
            //正式环境
            if(environmentType == 1)
            {
                m_setting->beginGroup("Study");
                tempUrl =  m_setting->value("formal").toString();//, "jyhd.yimifudao.com"
                //m_setting->setValue("stage", "stage-jyhd.yimifudao.com");
                m_setting->endGroup();
                teachingUrl = tempUrl;

                m_setting->beginGroup("V2.4");
                tempUrl = m_setting->value("formal").toString();//, "api.yimifudao.com/v2.4"
                //m_setting->setValue("stage", "stage-api.yimifudao.com/v2.4");
                m_setting->endGroup();
                apiUrl = tempUrl;
            }
            //====================
            //测试环境
            else if(environmentType == 0)
            {
                m_setting->beginGroup("Study");
                tempUrl =  m_setting->value("stage").toString();//, "jyhd.yimifudao.com"
                //m_setting->setValue("stage", "stage-jyhd.yimifudao.com");
                m_setting->endGroup();
                teachingUrl = tempUrl;

                m_setting->beginGroup("V2.4");
                tempUrl = m_setting->value("stage").toString();//, "api.yimifudao.com/v2.4"
                // m_setting->setValue("stage", "stage-api.yimifudao.com/v2.4");
                m_setting->endGroup();
                apiUrl = tempUrl;
            }

            //=====================================
            if(apiUrl == "")
            {
                apiUrl = "api.yimifudao.com/v2.4"; //api 全局url 默认值api.yimifudao.com/v2.4
            }

            if(teachingUrl == "")
            {
                teachingUrl = "jyhd.yimifudao.com";//教学全局url 默认值 jyhd.yimifudao.com
            }

            //=====================================
            //设置当前的开发环境
            if(apiUrl.contains("pre-"))
            {
                m_enEnvironment = ENVIRONMENT_PRE;
            }
            else if(apiUrl.contains("stage-"))
            {
                m_enEnvironment = ENVIRONMENT_STAGE;
            }
            else if(apiUrl.contains("dev-"))
            {
                m_enEnvironment = ENVIRONMENT_DEV;
            }
            else
            {
                m_enEnvironment = ENVIRONMENT_API;
            }

            m_setting->beginGroup("MiniClass");
            YMUserBaseInformation::miniUrl = m_setting->value("miniUrl").toString();
            YMUserBaseInformation::miniH5 = m_setting->value("miniH5").toString();
            m_setting->endGroup();
            qDebug() << "getRunUrl" << tempUrl;
        }

        void setDocumentParsing(QString backDatas)
        {
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

                    m_port = jsonObjsa.value("tcpPort").toString().toInt();
                    m_httpPort = jsonObjsa.value("httpPort").toString().toInt();
                    m_tcpPort = jsonObjsa.value("tcpPort").toString().toInt();
                    m_udpPort = jsonObjsa.take("udpPort").toString().toInt();
                    m_lessonType = jsonObjsa.take("lessonType").toString();
                    m_apiVersion  = jsonObjsa.take("apiVersion").toString();
                    m_appVersion  = jsonObjsa.take("appVersion").toString();
                    m_token = jsonObjsa.take("token").toString();
                    YMUserBaseInformation::apiVersion = m_apiVersion;
                    YMUserBaseInformation::appVersion = m_appVersion;
                    YMUserBaseInformation::token = m_token;
                    studentId = jsonObjsa.take("id").toString();
                    m_logTime = jsonObjsa.take("logTime").toString();
                    m_userName = jsonObjsa.take("userName").toString();

                    //m_sysInfo  = jsonObjsa.take("sysInfo").toString();
                    m_mD5Pwd  = jsonObjsa.take("MD5Pwd").toString();
                    m_deviceInfo = jsonObjsa.take("deviceInfo").toString();
                    m_phone = jsonObjsa.take("mobileNo").toString();
                    //qDebug()<<"m_phone =="<<m_phone;
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
            //QString indors;
            QJsonParseError error;
            QJsonDocument documet = QJsonDocument::fromJson(backData.toUtf8(), &error);
            if(error.error == QJsonParseError::NoError)
            {
                if(documet.isObject())
                {
                    QJsonObject jsonObjs = documet.object();
                    if(jsonObjs.contains("data"))
                    {
                        QJsonObject jsonObjdata = jsonObjs.take("data").toObject();
                        if(jsonObjdata.contains("liveRoomDto"))
                        {
                            QJsonObject jsonObj = jsonObjdata.take("liveRoomDto").toObject();
                            QString qqSign = jsonObj.take("qqSign").toString();
                            m_qqSign = qqSign;
                            QString lessonId = QString("%1").arg( jsonObj.take("roomId").toInt() );
                            m_lessonId = lessonId;
                            int socketFlag = jsonObj.take("socketFlag").toInt();
                            if(socketFlag == 1)
                            {
                                m_isTcpProtocol = true;
                            }
                            else if(socketFlag == 2)
                            {
                                m_isTcpProtocol = false;
                            }
                            // 开始时间和结束时间
                            QString startTime = jsonObj.value("startTime").toString();
                            QDateTime startTimeDate = QDateTime::fromString(startTime, "yyyy-MM-dd hh:mm:ss");
                            QString startTimes = startTimeDate.toString("hh:mm");
                            QString endTime = jsonObj.value("endTime").toString();
                            QDateTime endTimeDate = QDateTime::fromString(endTime, "yyyy-MM-dd hh:mm:ss");
                            QString endTimes = endTimeDate.toString("hh:mm");
                            // 课程时长
                            m_classTimeLen = (endTimeDate.toTime_t() - startTimeDate.toTime_t() ) / 60 ;
                            // 开始时间-结束时间
                            m_startToEndTime = startTimes + " - " + endTimes;
                            //
                            QString title_short = jsonObj.take("title_short").toString();
                            QString name_short = title_short.remove(m_lessonId);
                            name_short = name_short.remove(startTimes);
                            name_short = name_short.remove(endTimes);
                            name_short = name_short.remove("-");
                            name_short = name_short.remove(" ");
                            m_sTitle = jsonObj.take("title").toString();
                            m_curriculum =  name_short;

                            // agoraAuth节段
                            QJsonObject agoraAuth = jsonObj.take("agoraAuth").toObject();
                            m_agoraChannelKey = agoraAuth.take("channelKey").toString();
                            m_agoraChannelName = agoraAuth.take("channelName").toString();
                            m_agoraRecordingKey = agoraAuth.take("recordingKey").toString();
                            m_agoraToken = agoraAuth.take("token").toString();
                            m_agoraUid =QString::number( agoraAuth.take("uid").toInt());

                            //当前用户ID和标题、房间号等参数
                            m_currentUserId = jsonObj.take("currentUserId").toString();
                            studentId = m_currentUserId;
                            YMUserBaseInformation::id = m_currentUserId;

                            m_endTime = jsonObj.value("endTime").toDouble();
                            m_startTime = jsonObj.value("startTime").toDouble();
                            m_title = jsonObj.take("title").toString();
                            m_liveRoomId = jsonObj.take("liveroomId").toString();
                            YMUserBaseInformation::liveroomId = m_liveRoomId;
                            m_lessonId = m_liveRoomId;

                            // 教师参数
                            QJsonObject teacher = jsonObj.take("teacher").toObject();
                            QString  headPicture = teacher.take("headImage").toString();
                            m_teacher.m_teacherUrl = headPicture;
                            QString  realName = teacher.take("userName").toString();
                            m_teacher.m_teacherName = realName;
                            QString  teacherId = QString("%1").arg( teacher.take("userId").toString() );
                            m_teacher.m_teacherId = teacherId;
                            QString  mobileNo = teacher.take("phone").toString();
                            m_teacher.m_teachPhone = mobileNo;
                            int  uid = teacher.take("uid").toInt();
                            m_teacher.m_uid = uid;

                            // 遍历学生参数
                            QJsonArray students = jsonObj.take("students").toArray();
                            foreach (QJsonValue student, students)
                            {
                                Student student1;
                                QString  headPictures = student.toObject().take("headImage").toString();
                                student1.m_studentUrl =  headPictures;
                                QString  realNames = student.toObject().take("userName").toString();
                                student1.m_studentName = realNames;
                                QString  ids = student.toObject().take("userId").toString();
                                student1.m_studentId = ids;
                                int uid = student.toObject().take("uid").toInt();
                                student1.m_uid = uid;
                                QString  types = student.toObject().take("type").toString();
                                student1.m_studentType = types;
                                m_allStudentUserInfo.append(student1);
                                if(studentId != ids)
                                {
                                    m_student.append(student1);
                                }
                                else
                                {
                                    m_selfStudent.m_uid = student1.m_uid;
                                    m_selfStudent.m_studentUrl = student1.m_studentUrl;
                                    m_selfStudent.m_studentName = student1.m_studentName;
                                    m_selfStudent.m_studentType = student1.m_studentType;
                                    m_selfStudent.m_studentId = student1.m_studentId;

                                }
                            }
                            qDebug()<<"m_student"<<m_student.size();
                        }
                    }
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

            return status;
        }
        //得到用户话筒状态
        QString getUserPhone(QString userId)
        {
            QMap<QString, QPair<QString, QString> >::iterator it =  m_cameraPhone.begin() ;
            QString status = "1";
            for(; it != m_cameraPhone.end() ; it++)
            {
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

        }

        QList<Student> m_student,m_allStudentUserInfo;
        Teacher m_teacher;
        QString m_lessonId;
        QString m_apiVersion;
        QString m_appVersion;
        QString m_token;
        QString m_curriculum; //课程名称
        bool m_dataInsertion;
        QString m_qqSign;
        QString m_shewangSign;
        QString m_audioName;

        QString m_agoraChannelKey;//声网通道key
        QString m_agoraChannelName;//声网通道name
        QString m_agoraRecordingKey;//recordingKey
        QString m_agoraToken;//声网通道token
        QString m_agoraUid;//声网通道uid
        QString m_currentUserId;//当前用户的 userId
        double m_endTime;//课程结束时间
        double m_startTime;//课程开始
        QString m_title;//课程标题
        QString m_liveRoomId;//房间id

        QString m_logTime;//登录客户端时间
        QString m_userName;//登录时的用户名

        QSet<QString> m_onlineId;

        QString m_address;
        int m_currentServerDelay = 0; //当前服务器的延迟信息
        int m_currentServerLost = 0;//当前服务器的丢包信息
        QString m_startToEndTime;

        int m_port = 5122;
        int m_udpPort = 5120;

        int m_tcpPort;//tcp端口
        int m_httpPort;//http端口

        QString m_sTitle;
        QString m_lessonType;
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
        QMap<QString,QString> m_userUp;//用户上下台权限
        QMap<QString,int> m_reward;//奖励存储

        QString m_lat;//坐标
        QString m_lng;//坐标
        int m_classTimeLen;//一节课的课程时间 分钟显示

        double midHeight; // 中间画板高度
        double midWidth;  // 中间画板宽度

        double fullWidth; // 中间全屏时的画板高度
        double fullHeight;// 中间全屏时的画板宽度

        QString strAppName; //记录当前应用程序的名称
        QString strAppFullPath; //记录当前应用程序的路径 + 名称, 方便加载dll文件的时候, 使用
        QString strAppFullPath_LogFile; //记录当前应用程序日志文件的路径 + 名称, 方便日志上传的服务器
        QString strAgoraFullPath_LogFile; //记录声网SDK的日志文件路径 + 名称, 方便日志上传的服务器

        QJsonObject m_currentQuestionData;//当前显示的 题目数据信息
        QJsonArray lessonCommentConfigInfo;//课程结束时评价的配置

        QString apiUrl = "api.yimifudao.com/v2.4"; //api 全局url 默认值api.yimifudao.com/v2.4
        QString teachingUrl;//教学全局url 默认值 jyhd.yimifudao.com
        bool lessonListIsEmptys = false;//获取课件是否为空 默认为否

#ifdef USE_OSS_AUTHENTICATION
        bool coursewareSignOff = false;//老课件oss验签是否开关
#endif

    private:
        StudentData()
        {
            m_camera = "1";
            m_microphone = "1";
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

};
class AudioVideoPlaySetting
{

    public:
        AudioVideoPlaySetting()
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

        bool isHasSynchronize = false;//标示 是否从同步中解析过数据 如果解析过 在开始上课时不发视频命令

        QString m_camera;
        QString m_microphone;

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
                    if(types == 0) //wireless
                    {
                        m_netWorkMode = netInterface.name();
                        // qDebug()<<netInterface.name()<<netInterface.hardwareAddress()<<"netInterface.name()netInterface.name()";
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
        QString m_supplier; //当前频道
        QString m_videoType; //当前音频
        QString m_timeLens;
        int m_timeTotaltime;


        QString m_userBrushPermissions;//操作权限0为无权限
        QMap<QString, QString> m_userBrushPermissionsId;//每个用户的书写权限
        QString m_userPagePermissions;//翻页权限0为无权限

        bool m_isAlreadyClass; //检测是否已经上过课
        bool m_isStartClass;//是否已经开课

        bool m_techerEnerRoom;//老师有没进入房间

        bool m_teacherIsOnline; //老师是否在线为了B类型学生
        bool m_astudentIsOnline; //A学生是否在线为了B类型学生\


        QString m_uerIds;
        QString m_uerIdsAuthy;

        QMap<QString, QString> m_phoneType; //记录设备的类型, 比如: IOS, key是user id

        //检测声网通道延迟信息
        QMap<QString, QString> m_ipContents;

        QString m_netWorkMode;//判断是无线还是有线
        bool m_selectItem;//判断是否是点击切换频道
        QSet<uint> m_onlineId;//用于存储a通道的数据

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

        //优化Ip列表
        QVariantList goodIpList;
        bool m_isFinishClass = false;

        bool isAutoDisconnectServer = false; //是否是主动从服务器断开
        QMap<QString, QString> deviceVersion; //版本号
        QMap<QString, QString> deviceSysInfo; //连接设备信息

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

        //当前显示的课件类型 1 老课件 2 新课件
        int currentCourwareType = -1;
};


#endif // DATAMODEL

