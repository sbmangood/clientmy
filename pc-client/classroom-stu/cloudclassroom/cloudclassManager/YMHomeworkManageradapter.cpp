#include "YMHomeWorkManagerAdapter.h"
#include "YMEncryption.h"
#include "YMUserBaseInformation.h"

/*
*课堂练习
*/

YMHomeWorkManagerAdapter::YMHomeWorkManagerAdapter(QObject *parent) : QObject(parent)
{
    m_httpAccessmanger = new QNetworkAccessManager(this);
    m_httpClient = YMHttpClient::defaultInstance();
    connect(m_httpClient, SIGNAL(onTimerOut()), this, SIGNAL(requestTimerOut()));
    //getLessonWorkList("10","-1");
    //this->saveStudentAnswer("19","100010101","2","100","","");
    //this->updateLessonWorkStatus("19");
    //this->getAnswerCard("19");
    //this->updateReaded("19");
    //this->getQuestionStatus("19");
    //getDetailByOne("18",1);
    //getLessonList("786810");
}

//获取作业列表
QJsonObject YMHomeWorkManagerAdapter::getLessonWorkList(QString pageIndex, QString lessonWorkStatus)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("pageIndex", pageIndex.toInt()); //下标从 1 开始
    reqParm.insert("pageSize", 10);
    reqParm.insert("lessonWorkStatus", lessonWorkStatus);
    reqParm.insert("userType", YMUserBaseInformation::type);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    //QString url = m_httpClint->httpUrl + "/homework/getLessonWorkList";//https://
    QString url = "http://192.168.1.108:9026/api/homework/getLessonWorkList";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    qDebug() << "getLessonWorkList( test~~~~~~~~~~~`" << QString::fromUtf8(dataByte);
    return objectData;
}

//作业答案单题提交  学生答案 (客观题上传‘选择项的顺序orderno’，多选题上传如：2,3)
bool YMHomeWorkManagerAdapter::saveStudentAnswer(QString lessonWorkId, QString questionId, QString studentAnswer, QString useTime, QString photos, QString writeImages)
{
    qDebug() << "YMHomeWorkManagerAdapter::saveStudentAnswer(" << lessonWorkId << questionId << studentAnswer << useTime << "photos:" << photos << "writeImages:" << writeImages;
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonWorkId", lessonWorkId.toLongLong());
    reqParm.insert("questionId", questionId);
    //reqParm.insert("childQuestionId","");
    reqParm.insert("studentAnswer", studentAnswer);
    reqParm.insert("useTime", useTime.toInt());
    reqParm.insert("photos", photos);
    reqParm.insert("allImages", photos);
    reqParm.insert("writeImages", writeImages);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    //QString url = m_httpClint->httpUrl + "/homework/saveStudentAnswer";//https://
    QString url = "http://192.168.1.108:9026/api/homework/saveStudentAnswer";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);
    qDebug() << "YMHomeWorkManagerAdapter::saveStudentAnswer reply backdata" << QString::fromUtf8(dataByte);

    if(QString::fromUtf8(dataByte).contains("\"result\":\"success\""))
    {
        return true;
    }
    else
    {
        qDebug() << "YMHomeWorkManagerAdapter::saveStudentAnswer reply backdata" << QString::fromUtf8(dataByte);
    }

    return false;
    //返回的数据格式
    //"{\"message\":\"success\",\"result\":\"success\",\"data\":null,\"code\":0}"
}

//批改完成，更改作业状态
bool YMHomeWorkManagerAdapter::updateLessonWorkStatus(QString lessonWorkId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonWorkId", lessonWorkId.toLongLong());
    //  reqParm.insert("appVersion",YMUserBaseInformation::appVersion);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    //QString url = m_httpClient->httpUrl + "/homework/updateLessonWorkStatus";//https://
    QString url = "http://192.168.1.108:9026/api/homework/updateLessonWorkStatus";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);
    //qDebug() << "YMHomeWorkManagerAdapter::updateLessonWorkStatus reply backdata" <<QString::fromUtf8(dataByte);

    if(QString::fromUtf8(dataByte).contains("\"result\":\"success\""))
    {
        return true;
    }
    else
    {
        qDebug() << "YMHomeWorkManagerAdapter::updateLessonWorkStatus" << QString::fromUtf8(dataByte) << __LINE__;
    }

    return false;
    //{\"message\":\"未批改完成不能修改状态\",\"result\":\"fail\",\"data\":null,\"code\":18001}
}

//答题卡界面（老师学生都用）
QJsonObject YMHomeWorkManagerAdapter::getAnswerCard(QString lessonWorkId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonWorkId", lessonWorkId.toLongLong());
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    //QString url = m_httpClint->httpUrl + "/homework/getAnswerCard";//https://
    QString url = "http://192.168.1.108:9026/api/homework/getAnswerCard";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    qDebug() << "YMHomeWorkManagerAdapter::getAnswerCard reply back data~~~~~~" << QString::fromUtf8(dataByte);
    return objectData;

    /*
     {\"message\":\"\",\"result\":\"success\",\"data\":{\"create_time\":1516956870000,\"update_time\":1517193979000,\"create_name\":null,\"id\":19,\"lessonWorkName\":\"string\",\"teacherName\":\"天使\",\"studentName\":\"阿拉斯加\",\"endTime\":1516762660000,\"description\":\"string\",\"lessonWorkStatus\":2,\"scoreAvg\":null,\"finishTime\":1517193979000,\"useTime\":2485,\"questionCount\":7,\"wrongCount\":2,\"rightCount\":1,\"subjectiveItemCount\":4,\"halfCount\":0,\"questionStatusDtoList\":[{\"id\":\"00000180-b653-11e6-b4d5-00e04c6f6690\",\"orderNumber\":1,\"questionType\":1,\"status\":4,\"isRight\":1,\"haveRemark\":1},{\"id\":\"0008E9FE-F4FF-ADBA-D012-4538F7DC8C81\",\"orderNumber\":5,\"questionType\":5,\"status\":2,\"isRight\":0,\"haveRemark\":1},{\"id\":\"001bafd1-b5a3-11e6-b6dc-00e04c6f6690\",\"orderNumber\":3,\"questionType\":3,\"status\":2,\"isRight\":0,\"haveRemark\":1},{\"id\":\"1b7226fe-5aa4-4452-be5d-c08690103c3b\",\"orderNumber\":4,\"questionType\":4,\"status\":2,\"isRight\":0,\"haveRemark\":1},{\"id\":\"2b9bbd1f-97b5-490f-9231-1ee4a14649f7\",\"orderNumber\":6,\"questionType\":6,\"status\":2,\"isRight\":0,\"haveRemark\":1},{\"id\":\"3162F6EC-011E-4C19-9FEA-9C0593CFE173\",\"orderNumber\":2,\"questionType\":2,\"status\":2,\"isRight\":0,\"haveRemark\":1},{\"id\":\"33563f6a-c1b2-4e75-8e77-a23c7a85fda2\",\"orderNumber\":7,\"questionType\":6,\"status\":2,\"isRight\":0,\"haveRemark\":1}]},\"code\":0}
    */
}

//更改作业标示为已读
bool YMHomeWorkManagerAdapter::updateReaded(QString lessonWorkId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonWorkId", lessonWorkId.toLongLong());
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("userType", YMUserBaseInformation::type);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    //QString url = m_httpClient->httpUrl + "/homework/updateReaded";//https://
    QString url = "http://192.168.1.108:9026/api/homework/updateReaded";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);

    if(QString::fromUtf8(dataByte).contains("\"result\":\"success\""))
    {
        return true;
    }
    else
    {
        qDebug() << "YMHomeWorkManagerAdapter::updateReaded reply backdata" << QString::fromUtf8(dataByte);
    }

    return false;
    //{\"message\":null,\"result\":\"success\",\"data\":null,\"code\":0}
}

//查看作业答题情况
QJsonObject YMHomeWorkManagerAdapter::getQuestionStatus(QString lessonWorkId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonWorkId", lessonWorkId.toLongLong());
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    //QString url = m_httpClient->httpUrl + "/homework/getQuestionStatus";//https://
    QString url = "http://192.168.1.108:9026/api/homework/getQuestionStatus";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);
    qDebug() << "YMHomeWorkManagerAdapter::getQuestionStatus reply backdata" << QString::fromUtf8(dataByte);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();

    return objectData;
    //{\"message\":\"\",\"result\":\"success\",\"data\":{\"questionStatusDtos\":[{\"id\":\"00000180-b653-11e6-b4d5-00e04c6f6690\",\"orderNumber\":1,\"questionType\":0,\"status\":4,\"isRight\":0,\"haveRemark\":0},{\"id\":\"0008E9FE-F4FF-ADBA-D012-4538F7DC8C81\",\"orderNumber\":5,\"questionType\":0,\"status\":2,\"isRight\":0,\"haveRemark\":0},{\"id\":\"001bafd1-b5a3-11e6-b6dc-00e04c6f6690\",\"orderNumber\":3,\"questionType\":0,\"status\":2,\"isRight\":0,\"haveRemark\":0},{\"id\":\"1b7226fe-5aa4-4452-be5d-c08690103c3b\",\"orderNumber\":4,\"questionType\":0,\"status\":2,\"isRight\":0,\"haveRemark\":0},{\"id\":\"2b9bbd1f-97b5-490f-9231-1ee4a14649f7\",\"orderNumber\":6,\"questionType\":0,\"status\":2,\"isRight\":0,\"haveRemark\":0},{\"id\":\"3162F6EC-011E-4C19-9FEA-9C0593CFE173\",\"orderNumber\":2,\"questionType\":0,\"status\":2,\"isRight\":0,\"haveRemark\":0},{\"id\":\"33563f6a-c1b2-4e75-8e77-a23c7a85fda2\",\"orderNumber\":7,\"questionType\":0,\"status\":2,\"isRight\":0,\"haveRemark\":0}],\"useTime\":2485},\"code\":0}
}

//学生完成作业接口
bool YMHomeWorkManagerAdapter::getFinishLessonWork(QString lessonWorkId)
{
    QDateTime currentTime = QDateTime::currentDateTime();

    QVariantMap reqParm;
    reqParm.insert("lessonWorkId", lessonWorkId);
    reqParm.insert("userType", YMUserBaseInformation::type);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    //QString url = m_httpClient->httpUrl + "/api/homework/finishLessonWork";
    QString url = "http://192.168.1.108:9026/api/homework/finishLessonWork";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    bool isFinish = false;

    if(objectData.value("result").toString().toLower() == "success")
    {
        isFinish = true;
        return isFinish;
    }
    else
    {
        qDebug() << "===YMHomeWorkManagerAdapter::getFinishLessonWork failed===" << objectData << isFinish;
    }

    return isFinish;
}

//老师提交批注接口
bool YMHomeWorkManagerAdapter::saveTeacherComment(
    QString lessonWorkId,/*作业Id*/
    QString questionId,/*题目Id*/
    QString childQuestionId,/*子题目Id*/
    QString remarkUrl,/*评论语音url*/
    int errorType,/*错因（主观题不是全对时必填）*/
    QString teacherImages,/*老师批注照片（主观题才有，多个以英文逗号隔开）*/
    QString originImages,/*老师批注原始照片（主观题才有，多个以英文逗号隔开，顺序和teacherImages保持一致）*/
    int questionStatus,/*题目得分状态（主观题才有：0错，1对，2半对半错）*/
    double score/*得分（主观题才有）*/)
{
    QDateTime currentTime = QDateTime::currentDateTime();

    QVariantMap reqParm;
    reqParm.insert("lessonWorkId", lessonWorkId);
    reqParm.insert("questionId", questionId);

    if(childQuestionId != -1)
    {
        reqParm.insert("childQuestionId", childQuestionId);
    }
    if(remarkUrl != "")
    {
        reqParm.insert("remarkUrl", remarkUrl);
    }
    if(errorType != -1)
    {
        reqParm.insert("errorType", errorType);
    }
    if(teacherImages != "")
    {
        reqParm.insert("teacherImages", teacherImages);
    }
    if(originImages != "")
    {
        reqParm.insert("originImages", originImages);
    }
    if(questionStatus != -1)
    {
        reqParm.insert("questionStatus", questionStatus);
    }
    if(score != -1)
    {
        reqParm.insert("score", score);
    }
    reqParm.insert("userType", YMUserBaseInformation::type);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    //QString url = m_httpClient->httpUrl + "/api/homework/saveTeacherComment";
    QString url = "http://192.168.1.108:9026/api/homework/saveTeacherComment";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    bool isFinish = false;

    if(objectData.value("result").toString().toLower() == "success")
    {
        isFinish = true;
        return isFinish;
    }
    else
    {
        qDebug() << "===YMHomeWorkManagerAdapter::saveTeacherComment===" << objectData << isFinish;
    }

    return isFinish;
}

//作业题目详情
QJsonObject YMHomeWorkManagerAdapter::getHomeworkDetailList(QString lessonWorkId)
{
    QDateTime currentTime = QDateTime::currentDateTime();

    QVariantMap reqParm;
    reqParm.insert("lessonWorkId", lessonWorkId);
    reqParm.insert("userType", YMUserBaseInformation::type);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    //QString url = m_httpClient->httpUrl + "/api/homework/getHomeworkDetailList";
    QString url = "http://192.168.1.108:9026/api/homework/getHomeworkDetailList";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    QJsonObject data;

    if(objectData.value("result").toString().toLower() == "success")
    {
        data = objectData.value("data").toObject();
        return data;
    }
    else
    {
        qDebug() << "===YMHomeWorkManagerAdapter::getHomeworkDetailList failed===" << objectData;
    }

    return data;
}

//单题题目详情
QJsonObject YMHomeWorkManagerAdapter::getDetailByOne(QString lessonWorkId, int orderNumber)
{
    QDateTime currentTime = QDateTime::currentDateTime();

    QVariantMap reqParm;
    reqParm.insert("lessonWorkId", lessonWorkId);
    reqParm.insert("orderNumber", orderNumber);
    reqParm.insert("userType", YMUserBaseInformation::type);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    //QString url = m_httpClient->httpUrl + "/api/homework/getDetailByOne";
    QString url = "http://192.168.1.108:9026/api/homework/getDetailByOne";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    QJsonObject data;

    if(objectData.value("result").toString().toLower() == "success")
    {
        data = objectData.value("data").toObject();
        return data;
    }
    else
    {
        qDebug() << "===YMHomeWorkManagerAdapter::getDetailByOne failed===" << objectData;
    }

    return data;
}

//返回错因列表
QJsonArray YMHomeWorkManagerAdapter::getErrReason()
{
    QDateTime currentTime = QDateTime::currentDateTime();

    QVariantMap reqParm;
    reqParm.insert("userType", YMUserBaseInformation::type);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    //QString url = m_httpClient->httpUrl + "/api/homework/getErrReason";
    QString url = "http://192.168.1.108:9026/api/homework/getErrReason";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    QJsonArray dataArray;

    if(objectData.value("result").toString().toLower() == "success")
    {
        dataArray = objectData.value("data").toArray();
        return dataArray;
    }
    else
    {
        qDebug() << "===YMHomeWorkManagerAdapter::getErrReason failed===" << objectData;
    }

    return dataArray;
}

//学生是否完成作业接口
bool YMHomeWorkManagerAdapter::getStudentIsFinish(QString lessonWorkId)
{
    QDateTime currentTime = QDateTime::currentDateTime();

    QVariantMap reqParm;
    reqParm.insert("lessonWorkId", lessonWorkId);
    reqParm.insert("userType", YMUserBaseInformation::type);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    //QString url = m_httpClient->httpUrl + "/api/homework/isFinish";
    QString url = "http://192.168.1.108:9026/api/homework/isFinish";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    bool isFinish = false;

    if(objectData.value("result").toString().toLower() == "success")
    {
        isFinish = objectData.value("data").toBool();
        return isFinish;
    }
    else
    {
        qDebug() << "===YMHomeWorkManagerAdapter::getStudentIsFinish failed===" << objectData << isFinish;
    }

    return isFinish;
}

//老师是否完成批注接口
bool YMHomeWorkManagerAdapter::getIsCommented(QString lessonWorkId)
{
    QDateTime currentTime = QDateTime::currentDateTime();

    QVariantMap reqParm;
    reqParm.insert("lessonWorkId", lessonWorkId);
    reqParm.insert("userType", YMUserBaseInformation::type);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    //QString url = m_httpClient->httpUrl + "/api/homework/isCommented";
    QString url = "http://192.168.1.108:9026/api/homework/isCommented";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    bool isCommented = false;
    if(objectData.value("result").toString().toLower() == "success")
    {
        isCommented = objectData.value("data").toBool();
        return isCommented;
    }
    else
    {
        qDebug() << "===YMHomeWorkManagerAdapter::getIsCommented failed===" << isCommented << objectData;
    }

    return isCommented;
}

/***********************云教室接口***********************/
//课堂练习答案单题提交
void YMHomeWorkManagerAdapter::saveStudentAnswer(QJsonObject answerParm)
{
    qlonglong lessonId = answerParm.value("lessonId").toString().toLongLong();
    QString prePlanId = answerParm.value("prePlanId").toString();
    qlonglong itemId = answerParm.value("itemId").toString().toLongLong();
    QString questionId = answerParm.value("questionId").toString();
    QString childQuestionId = answerParm.value("childQuestionId").toString();
    QString studentAnswer = answerParm.value("studentAnswer").toString();
    int useTime = answerParm.value("useTime").toInt();
    QString photos = answerParm.value("photos").toString();
    QString writeImages = answerParm.value("writeImages").toString();
    QString originImage = answerParm.value("originImage").toString();

    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap  reqParm;
    reqParm.insert("lessonId", lessonId);
    reqParm.insert("prePlanId", prePlanId);
    reqParm.insert("itemId", itemId);
    reqParm.insert("questionId", questionId);
    reqParm.insert("childQuestionId", childQuestionId);
    reqParm.insert("studentAnswer", studentAnswer);
    reqParm.insert("useTime", useTime);
    reqParm.insert("photos", photos);
    reqParm.insert("writeImages", writeImages);
    reqParm.insert("originImage", originImage);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime);

    //QString url = m_httpClient->httpUrl\+ "/api/lesson-plan/classwork/saveStudentAnswer";
    QString url = "http://192.168.1.108:9026/api/lesson-plan/classwork/saveStudentAnswer";
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();

    if(dataObj.value("result").toString().toLower() != "success")
    {
        qDebug() << "YMHomeWorkManagerAdapter::saveStudentAnswer failed" << dataObj;
    }
}

//老师提交批注
void YMHomeWorkManagerAdapter::saveTeacherComment(QJsonObject commentParm)
{
    long lessonId = commentParm.value("lessonId").toString().toLong();
    QString prePlanId = commentParm.value("prePlanId").toString();
    long itemId = commentParm.value("itemId").toString().toLong();
    QString questionId = commentParm.value("questionId").toString();
    QString childQuestionId = commentParm.value("childQuestionId").toString();
    QString remarkUrl = commentParm.value("remarkUrl").toString();
    int remarkTime = commentParm.value("remarkTime").toInt();
    int errorType = commentParm.value("errorType").toInt();
    QString teacherImages = commentParm.value("teacherImages").toString();
    QString originImages = commentParm.value("originImages").toString();
    int questionStatus = commentParm.value("questionStatus").toInt();
    double score = commentParm.value("score").toDouble();

    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonId", lessonId);
    reqParm.insert("prePlanId", prePlanId);
    reqParm.insert("itemId", itemId);
    reqParm.insert("questionId", questionId);
    reqParm.insert("childQuestionId", childQuestionId);
    reqParm.insert("remarkUrl", remarkUrl);
    reqParm.insert("remarkTime", remarkTime);
    reqParm.insert("errorType", errorType);
    reqParm.insert("teacherImages", teacherImages);
    reqParm.insert("originImages", originImages);
    reqParm.insert("questionStatus", questionStatus);
    reqParm.insert("score", score);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime);

    //QString url = m_httpClient->httpUrl +"/api/lesson-plan/classwork/saveTeacherComment";
    QString url = "http://192.168.1.108:9026/api/lesson-plan/classwork/saveTeacherComment";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();

    if(objectData.value("result").toString().toLower() != "success")
    {
        qDebug() << "===YMHomeWorkManagerAdapter::saveTeacherComment failed===" << objectData;
    }
}

//查询栏目下的所有题目信息
void YMHomeWorkManagerAdapter::getLessonPlanQuestionInfo(QString lessonId, QString prePlanId, QString itemId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonId", lessonId);
    reqParm.insert("prePlanId", prePlanId);
    reqParm.insert("itemId", itemId);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime);

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    //QString url = m_httpClient->httpUrl + "/api/lesson-plan/classwork/getLessonPlanQuestionInfo";
    QString url = "http://192.168.1.108:9026/api/lesson-plan/classwork/getLessonPlanQuestionInfo";
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    if(dataObj.value("result").toString().toLower() != "success")
    {
        qDebug() << "YMHomeWorkManagerAdapter::getLessonPlanQuestionInfo failed" << dataObj;
    }
}

//保存老师轨迹图片
void YMHomeWorkManagerAdapter::saveTeacherTrajectory(QString lessonId, QString prePlanId, QString itemId, QString questionId, QString childQuestionId, QString imageArray)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonId", lessonId);
    reqParm.insert("prePlanId", prePlanId);
    reqParm.insert("itemId", itemId);
    reqParm.insert("questionId", questionId);
    reqParm.insert("childQuestionId", childQuestionId);
    reqParm.insert("image", imageArray);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime);

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    //QString url = m_httpClient->httpUrl + "/api/lesson-plan/classwork/saveTeacherTrajectory";
    QString url = "http://192.168.1.108:9026/api/lesson-plan/classwork/saveTeacherTrajectory";
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    if(dataObj.value("result").toString().toLower() != "success")
    {
        qDebug() << "YMHomeWorkManagerAdapter::saveTeacherTrajectory failed." << dataObj;
    }
}

//课程列表查看是否有课件
void YMHomeWorkManagerAdapter::getLessonInfoStatus(QString lessonId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonId", lessonId);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime);

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    //QString url = m_httpClient->httpUrl + "/lessonListInfo/getLessonInfoStatus";
    QString url = "http://192.168.1.108:9026/lessonListInfo/getLessonInfoStatus";
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    if(dataObj.value("message").toString().toLower() != "success")
    {
        qDebug() << "YMHomeWorkManagerAdapter::getLessonInfoStatus failed." << dataObj;
    }
}

//根据课程ID查询讲义列表
void YMHomeWorkManagerAdapter::getLessonList(QString lessonId)
{
    qDebug() << "YMHomeWorkManagerAdapter::getLessonList::" << lessonId;
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonId", lessonId);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime);

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    //QString url = m_httpClient->httpUrl + "/lessonListInfo/getLessonList";
    QString url = "http://192.168.1.108:9026/lessonListInfo/getLessonList";
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();

    qDebug() << "YMHomeWorkManagerAdapter::getLessonList::data" << dataObj;

    if(dataObj.value("message").toString().toLower() != "success")
    {
        qDebug() << "YMHomeWorkManagerAdapter::getLessonList failed" << dataObj;
    }
}

//根据讲义Id给出所有的栏目具体信息
void YMHomeWorkManagerAdapter::getRgister()
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("username", YMUserBaseInformation::userName);
    reqParm.insert("password", YMUserBaseInformation::passWord);
    reqParm.insert("name", YMUserBaseInformation::nickName);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime);

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    QString url = m_httpClient->httpUrl + "/api/user/register";
    //QString url = "http://192.168.1.108:9026/api/user/register";
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();

    if(dataObj.value("message").toString().toLower() != "success")
    {
        qDebug() << "YMHomeWorkManagerAdapter::getRgister failed" << dataObj;
    }
}

QString YMHomeWorkManagerAdapter::uploadImage(QString pathss, QString orderNumber, QString froms)
{
    pathss.remove("file:///");

    QString planId = "temp";
    QString itemId = "temp";

    if(froms == "select")
    {
        froms = "photo";
    }
    else
    {
        froms = "image";
    }

    QString filename;
    if(pathss .split("/").size() > 0)
    {
        filename =  pathss .split("/").at( pathss .split("/").size() - 1 );
    }

    if(TemporaryParameter::gestance()->m_currentCourse.split("yxt").size() == 2)
    {
        planId = TemporaryParameter::gestance()->m_currentCourse.split("yxt").at(0);
        itemId = TemporaryParameter::gestance()->m_currentCourse.split("yxt").at(1);
    }
    QString key = QString("lessonPlan/%1/student/%2/%3/%4/%5/%6").arg(StudentData::gestance()->m_lessonId).arg(planId).arg(itemId).arg(orderNumber).arg(froms).arg(filename);
    //qDebug() << "LoadInforMation::uploadQuestionImgOSS" << key << filename<<pathss;

    QString paths = QUrl::fromPercentEncoding(pathss.toUtf8());
    QEventLoop loop;
    QTimer::singleShot(15000, &loop, SLOT(quit()));
    connect(m_httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));

    m_imageFiles = new QFile(paths);
    if( !m_imageFiles->open(QIODevice::ReadOnly) )
    {
        qDebug() << "YMHomeWorkManagerAdapter::uploadImage failed." << pathss << __LINE__;
        return "" ;
    }
    QString jpegs = QString("image/jpeg");
    int iPos = paths.lastIndexOf(".");
    QString strFileExetenion = paths.mid(iPos + 1).toLower();
    if(strFileExetenion == "jpg")
    {
        jpegs = QString("image/jpeg");;
    }
    else
    {
        jpegs = QString("image/%1").arg(strFileExetenion);
    }

    QDateTime times = QDateTime::currentDateTime();

    QMap<QString, QString> maps;
    maps.insert("key", key);
    maps.insert("token", StudentData::gestance()->m_token); //"6d499b20858b00790af7b7dd0a3a5fd7"
    maps.insert("timestamp", times.toString("yyyyMMddhhmmss"));

    QString sign;
    QString urls;
    QMap<QString, QString>::iterator it =  maps.begin();
    for(int i = 0; it != maps.end() ; it++, i++)
    {
        if(i == 0)
        {
            sign.append(it.key());
            sign.append("=" + it.value());
        }
        else
        {
            sign.append("&" + it.key());
            sign.append("=" + it.value());
        }
    }
    urls.append(sign);
    urls.append("&sign=").append(QCryptographicHash::hash(sign.toUtf8(), QCryptographicHash::Md5).toHex().toUpper());

    m_multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    QHttpPart imagePart;
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant(jpegs.toLower()));
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"file\"; filename=\"file\""));

    imagePart.setBodyDevice(m_imageFiles);
    m_imageFiles->setParent(m_multiPart);
    m_multiPart->append(imagePart);

    QString httpsd = "http://" + StudentData::gestance()->teachingUrl + "/api/lesson/upload/image?" + QString("%1").arg(urls);
    QUrl url(httpsd);
    QNetworkRequest request(url);
    // qDebug() << "===========loadinformation::url============" << url;
    QNetworkReply *imageReply = m_httpAccessmanger->post(request, m_multiPart);

    loop.exec();
    QByteArray replyData = imageReply->readAll();
    QJsonObject dataObject = QJsonDocument::fromJson(replyData).object();
    //qDebug() << "=======loadinFormation===========" << replyData.length() <<dataObject;

    if(dataObject.value("result").toString().toLower() == "success")
    {
        QString s_url =  dataObject.value("data").toString();
        //qDebug() << "=======loadinFormation===========" <<s_url;
        return s_url;
    }
    else
    {
        qDebug() << "YMHomeWorkManagerAdapter::uploadImage" << dataObject;
    }

    return "";

}









