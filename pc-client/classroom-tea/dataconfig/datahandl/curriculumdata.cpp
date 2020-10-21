#include "curriculumdata.h"

CurriculumData::CurriculumData(QObject *parent) : QObject(parent)
{

}

CurriculumData::~CurriculumData()
{

}

int CurriculumData::getLessonType()
{
    return StudentData::gestance()->m_lessonType;
}

//确认是否是演示课
int CurriculumData::getSubjectId()
{
    return StudentData::gestance()->m_subjectId;
}

//确认是否是标准试听课
int CurriculumData::getApplicationType()
{
    return StudentData::gestance()->m_applicationType;
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
    list << StudentData::gestance()->m_teacher.m_teacherId;//老师旁听
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
    // qDebug()<< "StudentData::gestance()->m_onlineId ==" <<StudentData::gestance()->m_onlineId;
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

bool CurriculumData::justUserIsOnline(QString userId)
{
    if(StudentData::gestance()->justUserIsOnline(userId))
    {
        return true;
    }
    return false;
}

bool CurriculumData::justCCIsOnline()
{
    QString userType = "";
    foreach (const QString &value, StudentData::gestance()->m_onlineId)
    {
        userType = StudentData::gestance()->getUserTypeById(value);
        //qDebug()<<"CurriculumData::justHasTeacherInRoom"<<value<<userType;
        if("assistent" == userType )
        {
            return true;
        }
    }
    return false;
}
QString CurriculumData::getCCId()
{
    QString userType = "";
    foreach (const QString &value, StudentData::gestance()->m_onlineId)
    {
        userType = StudentData::gestance()->getUserTypeById(value);
        if("assistent" == userType )
        {
            StudentData::gestance()->m_ccId = value;
            return value;
        }
    }
    return "";
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
    QString str = TemporaryParameter::gestance()->m_userBrushPermissionsId.value(userIds, "");
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
    bool bValue = StudentData::gestance()->justIdIsExit(StudentData::gestance()->m_teacher.m_teacherId);

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

    //如果是CC账号登录的, 不是持麦者则为1
    //如果是CC账号登录的, 是持麦者则为0
    //如果是老师账号登录的, 则一直都是1
    QString status = StudentData::gestance()->m_StaticPlat == "L" ? (StudentData::gestance()->m_plat =="T" ? "0" : "1") : "1";
    for(; it != StudentData::gestance()->m_cameraPhone.end() ; it++)
    {
        if(it.key() == userIds)
        {
            status = it.value().first;
        }
    }
    qDebug()<<"StudentData::gestance()->m_cameraPhone status=="<< userId << status;
    return status;
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
    QString str = StudentData::gestance()->m_curriculum;

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
    QString isVideo = TemporaryParameter::gestance()->m_videoType;
    QString headPicture;


    if(userId == "0")
    {
        userName = StudentData::gestance()->m_teacher.m_teacherName;
        userOnline = justUserOnline(userId);
        userAuth = getUserIdBrushPermissions(userId);
        userAudio = getUserPhone(userId);
        userVideo = getUserCamcera(userId);
        imagePath = getUserUrl(userId);
        isteacher = isTeacher(userId);
        headPicture = StudentData::gestance()->m_teacher.m_teacherUrl;

        dataObj.insert("userName", userName);
        dataObj.insert("userOnline", userOnline);
        dataObj.insert("userAuth", userAuth);
        dataObj.insert("isVideo", isVideo);
        dataObj.insert("userAudio", userAudio);
        dataObj.insert("userVideo", userVideo);
        dataObj.insert("imagePath", imagePath);
        dataObj.insert("isteacher", isteacher);
        dataObj.insert("supplier", supplier);
        dataObj.insert("headPicture", headPicture);
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
            headPicture = StudentData::gestance()->m_student.at(i).m_studentUrl;

            dataObj.insert("userName", userName);
            dataObj.insert("userOnline", userOnline);
            dataObj.insert("userAuth", userAuth);
            dataObj.insert("isVideo", isVideo);
            dataObj.insert("userAudio", userAudio);
            dataObj.insert("userVideo", userVideo);
            dataObj.insert("imagePath", imagePath);
            dataObj.insert("isteacher", isteacher);
            dataObj.insert("supplier", supplier);
            dataObj.insert("headPicture", headPicture);
            break;
        }
    }

    return dataObj;
}

bool CurriculumData::getIsStandardLesson()
{
    if(YMUserBaseInformation::applicationType == 0)
    {
        return false;
    }
    if(YMUserBaseInformation::applicationType == 1)
    {
        return true;
    }
    return false;
}


bool CurriculumData::getLessonReportStatus()
{
    if(YMUserBaseInformation::reportFlag == 0)
    {
        return false;
    }
    if(YMUserBaseInformation::reportFlag == 1)
    {
        return true;
    }
    return false;
}

int CurriculumData::getCurrentRoleType()
{// m_selfStudent.m_studentId  为自己的ID
    if(StudentData::gestance()->m_selfStudent.m_studentId == StudentData::gestance()->m_teacher.m_teacherId)
    {
        return 1;
    }
    return 2;
}



bool CurriculumData::getCurrentIsAttend()
{
    qDebug() << "CurriculumData::getCurrentIsAttend" << StudentData::gestance()->m_plat << __LINE__;
    if(StudentData::gestance()->m_plat == "T")
    {
        return false;
    }

    if(StudentData::gestance()->m_plat == "L")
    {
        return true;
    }
}

QString CurriculumData::getTeacherId()
{
    return StudentData::gestance()->m_teacher.m_teacherId;
}

QString CurriculumData::getCurrentUserId()
{
    return StudentData::gestance()->m_selfStudent.m_studentId;
}

//返回持麦者的user id
QString CurriculumData::getJoinMicId()
{
    qDebug()<<StudentData::gestance()->m_JoinMicId<<":getJoinMicId()";
    return StudentData::gestance()->m_JoinMicId;
}

QString CurriculumData::getListenId()
{
    return StudentData::gestance()->m_selfStudent.m_listenId;
}

QString CurriculumData::getCurrentCcCameraStatus()
{

    QMap<QString, QPair<QString, QString> >::iterator it =  StudentData::gestance()->m_cameraPhone.begin() ;

    QString status = "0";
    for(; it != StudentData::gestance()->m_cameraPhone.end() ; it++)
    {
        if(it.key() == StudentData::gestance()->m_JoinMicId)
        {
            status = it.value().first;
        }
    }
    return status  ;
}

QString CurriculumData::getCurrentOrderId()
{
    qDebug() << "CurriculumData::getCurrentOrderId" << StudentData::gestance()->m_JoinMicId << __LINE__;
    return  StudentData::gestance()->m_JoinMicId;
}


//判断userId, 是否是学生
bool CurriculumData::doCheck_ID_Is_Student(QString userId)
{
    //StudentData::gestance()->m_selfStudent.m_studentAId 是通过temp.ini文件中, 获取的
    //比如, 搜索代码: m_selfStudent.m_studentAId = ids;
    if(userId == StudentData::gestance()->m_selfStudent.m_studentAId)
    {
        return true;
    }

    return  false;
}

void CurriculumData::setCouldDirectExit( bool couldDirectExit)
{
    StudentData::gestance()->couldDirectExit = couldDirectExit;
}

bool CurriculumData::getIsReportStatus()
{
    QString bufferFilePath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QString saveFilePath = bufferFilePath + "/closeReport.dll";

    bool bResut = true;
    QFile file(saveFilePath);
    if(!file.exists())//如果不存在则显示报告
    {
        return bResut;
    }

    if(file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        QTextStream textStream(&file);
        QString readText = textStream.readAll();
        if(readText.contains(YMUserBaseInformation::lessonId))
        {
            bResut = false;
        }
        else
        {
            bResut = true;
        }
    }

    file.close();
    return bResut;
}

void CurriculumData::writeReport(QString lessonId)
{
    QString bufferFilePath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QString saveFilePath = bufferFilePath + "/closeReport.dll";

    QFile file(saveFilePath);
    if(file.open(QFile::ReadWrite))
    {
        QTextStream textOut(&file);
        textOut << lessonId;
        textOut.flush();
    }

    file.close();
}

bool CurriculumData::justStudentIsOnline()
{
    bool status = false;
    for(int i = 0 ; i < StudentData::gestance()->m_student.count(); i++)
    {
        if( "A" == StudentData::gestance()->m_student[i].m_studentType )
        {
            status = StudentData::gestance()->justUserIsOnline(StudentData::gestance()->m_student[i].m_studentId );
        }
    }

    return status;

}

QString CurriculumData::getAStudentName()
{
    return YMUserBaseInformation::aStudentName;
}
