#include "curriculumdata.h"
#include"../YMCommon/qosManager/YMQosManager.h"

CurriculumData::CurriculumData(QObject *parent) : QObject(parent)
{

}

CurriculumData::~CurriculumData()
{

}
QString CurriculumData::getLessonType()
{
    return StudentData::gestance()->m_lessonType;
}

//得到用户的姓名
QString CurriculumData::getUserName(QString userId)
{
    if(userId == StudentData::gestance()->m_teacher.m_teacherId)
    {

        return StudentData::gestance()->m_teacher.m_teacherName;
    }
    if(userId == "0")
    {

        return StudentData::gestance()->m_selfStudent.m_studentName;
    }
    for(int i = 0 ; i < StudentData::gestance()->m_student.count(); i++)
    {
        if(userId == StudentData::gestance()->m_student[i].m_studentId)
        {
            return StudentData::gestance()->m_student[i].m_studentName;
        }
    }
    return "";

}
//设置视频的所有的id
void CurriculumData::getListAllUserId()
{
    QStringList list;
    list << QString("0"); //代表老师自己
    for(int i = 0 ; i < StudentData::gestance()->m_student.count(); i++)
    {
        list << StudentData::gestance()->m_student[i].m_studentId;
    }
    emit sigListAllUserId(list);
}
//得到用户的url
QString CurriculumData::getUserUrl(QString userId)
{
    if(userId == StudentData::gestance()->m_teacher.m_teacherId)
    {

        return StudentData::gestance()->m_teacher.m_teacherUrl;
    }
    if(userId == "0")
    {

        return StudentData::gestance()->m_selfStudent.m_studentUrl;
    }
    for(int i = 0 ; i < StudentData::gestance()->m_student.count(); i++)
    {
        if(userId == StudentData::gestance()->m_student[i].m_studentId)
        {
            return StudentData::gestance()->m_student[i].m_studentUrl;
        }
    }
    return "";
}
//判断用户是否在线
QString CurriculumData::justUserOnline(QString userId)
{
    //qDebug()<< "StudentData::gestance()->m_onlineId =="<< userId <<StudentData::gestance()->m_onlineId;
    QString userIds = userId;
    if(userId == "0")
    {
        userIds = StudentData::gestance()->m_selfStudent.m_studentId;
        return "1";
    }
    if(StudentData::gestance()->justIdIsExit(userIds ))
    {
        return "1";
    }
    else
    {
        return "0";
    }
}
//得到是否是视频聊天
QString CurriculumData::getIsVideo()
{
    return TemporaryParameter::gestance()->m_videoType;
}

QString CurriculumData::isTeacher(QString userId)
{
    //qDebug() << "CurriculumData::isTeacher:" << userId << StudentData::gestance()->m_teacher.m_teacherId;
    if(userId == "0" ) //StudentData::gestance()->m_teacher.m_teacherId) {
    {

        return QString("1");
    }
    else
    {
        return QString("0");
    }
}

//获得操作权限
QString CurriculumData::getUserBrushPermissions()
{
    return TemporaryParameter::gestance()->m_userBrushPermissions;
}
//获得某个用户的操作权限
QString CurriculumData::getUserIdBrushPermissions(QString userId)
{
    QString userIds = userId;
    if(userId == "0")
    {
        userIds = StudentData::gestance()->m_selfStudent.m_studentId;
    }
    QString str = StudentData::gestance()->m_userAuth.value(userIds, "");
    qDebug() << "===getUserIdBrushPermissions==" << str;
    if(str == "1")
    {
        return QString("1");
    }
    else
    {
        return QString("0");
    }

}

//得到用户的类型
QString CurriculumData::getUserType(QString userId)
{
    if(userId == "0")
    {
        return "TEA";
    }
    if(userId == StudentData::gestance()->m_teacher.m_teacherId)
    {
        return "TEA";
    }
    if(userId == StudentData::gestance()->m_selfStudent.m_studentId )
    {

        return StudentData::gestance()->m_selfStudent.m_studentType;
    }
    for(int i = 0 ; i < StudentData::gestance()->m_student.count(); i++)
    {
        if(userId == StudentData::gestance()->m_student[i].m_studentId)
        {
            return StudentData::gestance()->m_student[i].m_studentType;
        }
    }

}
//得到当前用户的类型
QString CurriculumData::getCurrentUserType()
{
    return "TEA";  //StudentData::gestance()->m_selfStudent.m_studentType;
}

//判断老师是否在线, 控制"结束课程的时候", 是否提示: 结束课程的对话框
bool CurriculumData::justTeacherOnline()
{
    bool bValue = StudentData::gestance()->justIdIsExit(StudentData::gestance()->m_teacher.m_teacherId);;
    qDebug() << "CurriculumData::justTeacherOnline  bValue: " << bValue;

    return bValue;
}

//判断A学生是否在线
bool CurriculumData::justAStundentOnline()
{
    bool status = false;
    for(int i = 0 ; i < StudentData::gestance()->m_student.count(); i++)
    {
        if( "A" == StudentData::gestance()->m_student[i].m_studentType )
        {
            status = StudentData::gestance()->justIdIsExit(StudentData::gestance()->m_student[i].m_studentId );
        }
    }

    return status;

}
//获得开课时间
QString CurriculumData::getStartClassTimelen()
{
    return TemporaryParameter::gestance()->m_timeLens;
}
//判断是否已经开课
bool CurriculumData::justIsStartClass()
{
    return TemporaryParameter::gestance()->m_isStartClass;
}
//查看用户是否有翻页权限
bool CurriculumData::isUserPagePermissions()
{
    if(TemporaryParameter::gestance()->m_userPagePermissions == "1")
    {

        return true;
    }
    else
    {
        return false;
    }

}
//得到用户摄像头状态
QString CurriculumData::getUserCamcera(QString userId)
{
    QString userIds = userId;
    if(userIds == "0")
    {
        userIds = StudentData::gestance()->m_selfStudent.m_studentId;
    }
    //qDebug()<<"StudentData::gestance()->m_cameraPhone =="<<StudentData::gestance()->m_cameraPhone;
    QMap<QString, QPair<QString, QString> >::iterator it =  StudentData::gestance()->m_cameraPhone.begin() ;

    QString status = "1";
    for(; it != StudentData::gestance()->m_cameraPhone.end() ; it++)
    {
        if(it.key() == userIds)
        {
            status = it.value().first;
        }
    }
    //qDebug()<<"StudentData::gestance()->m_cameraPhone status=="<<status;
    return status;
}

//获取用户上下台状态
QString CurriculumData::getUserUpStatus(QString userId)
{
    QString userUpStatus = "1";
    QMap<QString,QString>::iterator it = StudentData::gestance()->m_userUp.begin();
    for(; it != StudentData::gestance()->m_userUp.end(); it++)
    {
        if(it.key() == userId)
        {
            userUpStatus = it.value();
            break;
        }
    }
    return userUpStatus;
}

//得到用户话筒状态
QString CurriculumData::getUserPhone(QString userId)
{
    QString userIds = userId;
    if(userIds == "0")
    {
        userIds = StudentData::gestance()->m_selfStudent.m_studentId;
    }
    QMap<QString, QPair<QString, QString> >::iterator it =  StudentData::gestance()->m_cameraPhone.begin() ;

    QString status = "1";
    for(; it != StudentData::gestance()->m_cameraPhone.end() ; it++)
    {
        if(it.key() == userIds)
        {
            status = it.value().second;
        }
    }
    return status;
}

//得到用户的通道
QString CurriculumData::getUserChanncel()
{
    return TemporaryParameter::gestance()->m_supplier;
}
//得到所有的ip列表
QStringList CurriculumData::getAllIpList()
{
    QStringList list =   SettingFile::gestance()->getAllIpList();
    return list;
}

void CurriculumData::setBeginClassTimeData(int &beginClassTimeData)
{

    TemporaryParameter::gestance()->m_beginClassTimeData = beginClassTimeData;
}
//获得课程名称
QString CurriculumData::curriculumName()
{
    QString str = StudentData::gestance()->m_title;//StudentData::gestance()->m_curriculum;

    return str;
}
//获得课程id
QString CurriculumData::curriculumId()
{
    QString str = StudentData::gestance()->m_lessonId;

    return str;
}
//开始到结束时间
QString CurriculumData::startToEndTime()
{
    QString str = StudentData::gestance()->m_startToEndTime;

    return str;
}
//获得课程时间总长度
int CurriculumData::courseTimeTotalLength()
{
    //qDebug() << "CurriculumData::courseTimeTotalLength" <<StudentData::gestance()->m_classTimeLen;
    return StudentData::gestance()->m_classTimeLen;
}
//开始上课的时间
int CurriculumData::beginClassTimeData()
{
    return  TemporaryParameter::gestance()->m_beginClassTimeData;
}
//学生的姓名
QString CurriculumData::studentName()
{
    QString names;
    for(int i = 0 ; i < StudentData::gestance()->m_student.count() ; i++)
    {
        if(StudentData::gestance()->m_student[i].m_studentType == "A")
        {
            names = StudentData::gestance()->m_student[i].m_studentName;
        }
    }
    return names;
}

//翻页学生的名字
QString CurriculumData::flipStudentName()
{
    QString names = "";
    for(int i = 0 ; i < StudentData::gestance()->m_student.count() ; i++)
    {
        if(StudentData::gestance()->m_student[i].m_studentId == TemporaryParameter::gestance()->m_userId )
        {
            names = StudentData::gestance()->m_student[i].m_studentName;
            return names;
        }

    }
    return names;

}
//退出教室的学生名称
QString CurriculumData::exitStudentName()
{
    QString names = "  ";
    for(int i = 0 ; i < StudentData::gestance()->m_student.count() ; i++)
    {
        if(StudentData::gestance()->m_student[i].m_studentId == TemporaryParameter::gestance()->m_exitRoomId )
        {
            if(StudentData::gestance()->m_student[i].m_studentType.contains("A"))
            {
                names = StudentData::gestance()->m_student[i].m_studentName;
                return names;
            }
        }
    }
    names.clear();
    return names;
}
//申请退出教室
QString CurriculumData::applyExitStudentName()
{
    QString names = "  ";
    for(int i = 0 ; i < StudentData::gestance()->m_student.count() ; i++)
    {
        if(StudentData::gestance()->m_student[i].m_studentId == TemporaryParameter::gestance()->m_exitRequestId )
        {
            names = StudentData::gestance()->m_student[i].m_studentName;
            return names;

        }
    }
    names.clear();
    return names;
}
//b学生进入房间
QString CurriculumData::enterRoomRequestName()
{
    QString names = "  ";
    for(int i = 0 ; i < StudentData::gestance()->m_student.count() ; i++)
    {
        if(StudentData::gestance()->m_student[i].m_studentId == TemporaryParameter::gestance()->m_enterRoomRequest  )
        {
            names = StudentData::gestance()->m_student[i].m_studentName;
            return names;

        }
    }
    names.clear();
    return names;
}

QString CurriculumData::droppedRoomName()
{
    QString names = "  ";
    for(int i = 0 ; i < StudentData::gestance()->m_student.count() ; i++ )
    {
        if(TemporaryParameter::gestance()->m_droppedRoomIds == StudentData::gestance()->m_student[i].m_studentId)
        {
            names = StudentData::gestance()->m_student[i].m_studentName;
            return names;
        }
    }
    names.clear();
    return names;
}
//摄像头状态跟话筒的状态的姓名
QString CurriculumData::cameraStatusName()
{
    return TemporaryParameter::gestance()->m_cameraNames;
}
//返回所有用户的id
QStringList CurriculumData::listAllUserId()
{
    QStringList list;
    // list<<StudentData::gestance()->m_teacher.m_teacherId;
    list << QString("0"); //

    for(int i = 0 ; i < StudentData::gestance()->m_student.count(); i++)
    {
        list << StudentData::gestance()->m_student[i].m_studentId;
    }
    qDebug() << "list aha ==" << list;

    return list;
}

//获取用户所有信息
QJsonObject CurriculumData::getUserInfo(QString userId)
{
    QJsonObject dataObj;

    QString userName;
    QString userOnline;
    QString userAuth;
    QString userAudio;
    QString userVideo;
    QString imagePath;
    QString isteacher;
    QString supplier = getUserChanncel();
    QString isVideo = "0";
    QString headPicture;
    QString userUp;
    QString rewardNum = "0";
    int uid;


    if(userId == "0")
    {
        userName = StudentData::gestance()->m_teacher.m_teacherName;
        userOnline = justUserOnline(userId);
        userAuth = getUserIdBrushPermissions(userId);
        userAudio = getUserPhone(userId);
        userVideo = getUserCamcera(userId);
        imagePath = getUserUrl(userId);
        isteacher = isTeacher(userId);
        userUp = getUserUpStatus(userId);
        headPicture = StudentData::gestance()->m_teacher.m_teacherUrl;
        dataObj.insert("uid", 0);
        dataObj.insert("userName", userName);
        dataObj.insert("userOnline", userOnline);
        dataObj.insert("userAuth", userAuth);
        dataObj.insert("isVideo", "1");
        dataObj.insert("userAudio", userAudio);
        dataObj.insert("userVideo", userVideo);
        dataObj.insert("userUp",userUp);
        dataObj.insert("imagePath", imagePath);
        dataObj.insert("isteacher", isteacher);
        dataObj.insert("supplier", supplier);
        dataObj.insert("headPicture", headPicture);
        dataObj.insert("rewardNum",rewardNum);
        return dataObj;
    }

    for(int i = 0; i < StudentData::gestance()->m_student.count(); i++)
    {
        if(userId == StudentData::gestance()->m_student.at(i).m_studentId)
        {
            userName = StudentData::gestance()->m_student.at(i).m_studentName;
            userOnline = justUserOnline(userId);
            userAuth = getUserIdBrushPermissions(userId);
            userAudio = getUserPhone(userId);
            userVideo = getUserCamcera(userId);
            imagePath = getUserUrl(userId);
            isteacher = isTeacher(userId);
            userUp = getUserUpStatus(userId);
            headPicture = StudentData::gestance()->m_student.at(i).m_studentUrl;

            if(StudentData::gestance()->m_reward.contains(userId))
            {
                rewardNum = QString::number(StudentData::gestance()->m_reward.find(userId).value());
            }

            dataObj.insert("uid",StudentData::gestance()->m_student.at(i).m_uid);
            dataObj.insert("userName", userName);
            dataObj.insert("userOnline", userOnline);
            dataObj.insert("userAuth", userAuth);
            dataObj.insert("isVideo", StudentData::gestance()->m_student.at(i).m_isVideo);
            dataObj.insert("userAudio", userAudio);
            dataObj.insert("userVideo", userVideo);
            dataObj.insert("userUp",userUp);
            dataObj.insert("imagePath", imagePath);
            dataObj.insert("isteacher", isteacher);
            dataObj.insert("supplier", supplier);
            dataObj.insert("headPicture", headPicture);            
            dataObj.insert("rewardNum",rewardNum);
            break;
        }
    }

    return dataObj;
}

//获取花名册所有信息
QJsonArray CurriculumData::getRosterInfo()
{
    QJsonArray dataArray;
    QJsonObject contentData;
    QString userId;

    for(int i = 0; i < StudentData::gestance()->m_student.size(); i++)
    {
        userId = StudentData::gestance()->m_student.at(i).m_studentId;

        int userReward = 0;
        QString userUp = "1";
        QString userAuth = "0";
        QString userVideo = "1";
        QString userAudio = "1";

        //如果是老师自己则不添加到花名册信息中
        if(userId == StudentData::gestance()->m_teacher.m_teacherId)
        {
            continue;
        }

        //授权缓存
        qDebug()<< "===userAuth===" << userId << StudentData::gestance()->m_userAuth;
        if(StudentData::gestance()->m_userAuth.contains(userId))
        {
            QMap<QString, QString>::iterator authIt = StudentData::gestance()->m_userAuth.find(userId);
            qDebug() << "==aaaaaaaaa==" << authIt.value();
            userAuth = authIt.value();
        }
        qDebug() << "==bbbb==" << StudentData::gestance()->m_userUp;
        //上台缓存
        if(StudentData::gestance()->m_userUp.contains(userId))
        {
            QMap<QString, QString>::iterator userUpIt  = StudentData::gestance()->m_userUp.find(userId);
            userUp = userUpIt.value();
        }

        QString userName = this->getUserName(userId);

        //摄像头，麦克风状态
        if(StudentData::gestance()->m_cameraPhone.contains(userId))
        {
            QMap<QString, QPair<QString, QString> >::iterator it =  StudentData::gestance()->m_cameraPhone.find(userId);
            userAudio = it.value().second;
            userVideo = it.value().first;
        }

        //奖励状态
        if(StudentData::gestance()->m_reward.contains(userId))
        {
            QMap<QString,int>::iterator rewardIt = StudentData::gestance()->m_reward.find(userId);
            userReward = rewardIt.value();
        }

        contentData.insert("userId",userId);
        contentData.insert("userName",userName);
        contentData.insert("userAuth", userAuth);
        contentData.insert("userAudio", userAudio);
        contentData.insert("userVideo", userVideo);
        contentData.insert("userUp", userUp);
        contentData.insert("userReward",userReward);
        contentData.insert("userOnline", justUserOnline(userId));
        contentData.insert("teacherName",StudentData::gestance()->m_teacher.m_teacherName);
        dataArray.append(contentData);
    }
    return dataArray;
}

//获取本节课开课时间
qlonglong CurriculumData::getCurrentStartTime()
{
    return StudentData::gestance()->m_startTime;
}

bool CurriculumData::isAttend(QString userId)
{
    for(int i = 0; i < StudentData::gestance()->m_student.count(); i++)
    {
        if(StudentData::gestance()->m_student.at(i).m_studentId.contains(userId))
        {
            return true;
        }
    }
    return false;
}

QString CurriculumData::getCurrentIp()
{
    return StudentData::gestance()->m_address;
}

void CurriculumData::addFeedbackInfo(QString feedbackTest)
{
    QString msgType = "XBKCloudClassroom_teacher_click_feedback";
    QJsonObject jsonObj;
    jsonObj.insert("lessonId",StudentData::gestance()->m_lessonId);
    jsonObj.insert("socketIp",StudentData::gestance()->m_address);
    jsonObj.insert("className",StudentData::gestance()->m_title);
    jsonObj.insert("help_user",StudentData::gestance()->m_userName);
    QByteArray byteArray = feedbackTest.toUtf8();
    jsonObj.insert("help_content",QString::fromUtf8(byteArray));
    YMQosManager::gestance()->addBePushedMsg(msgType,jsonObj);
}

QString CurriculumData::getCurrentToken()
{
    return StudentData::gestance()->m_token;
}
