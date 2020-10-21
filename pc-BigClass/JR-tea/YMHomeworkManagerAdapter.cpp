#include "YMHomeWorkManagerAdapter.h"
#include "YMEncryption.h"

/*
*课堂练习
*/

YMHomeWorkManagerAdapter::YMHomeWorkManagerAdapter(QObject *parent) : QObject(parent)
{
    m_httpClient = YMHttpClient::defaultInstance();
    connect(m_httpClient, SIGNAL(onTimerOut()), this, SIGNAL(requestTimerOut()));
    //getLessonWorkList("10","-1");
    //this->saveStudentAnswer("19","100010101","2","100","","");
    //this->updateLessonWorkStatus("19");
    //this->getAnswerCard("19");
    //this->updateReaded("19");
    //this->getQuestionStatus("19");
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
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonWorkId", lessonWorkId.toLong());
    reqParm.insert("questionId", questionId);
    //reqParm.insert("childQuestionId","");
    reqParm.insert("studentAnswer", studentAnswer);
    reqParm.insert("useTime", useTime.toInt());
    reqParm.insert("photos", photos);
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

    if(QString::fromUtf8(dataByte).contains("\"result\":\"success\""))
    {
        return true;
    }

    qDebug() << "YMHomeWorkManagerAdapter::saveStudentAnswer::Fail" << QString::fromUtf8(dataByte);
    return false;
    //返回的数据格式
    //"{\"message\":\"success\",\"result\":\"success\",\"data\":null,\"code\":0}"
}

//批改完成，更改作业状态
bool YMHomeWorkManagerAdapter::updateLessonWorkStatus(QString lessonWorkId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonWorkId", lessonWorkId.toLong());
    //  reqParm.insert("appVersion",YMUserBaseInformation::appVersion);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    //QString url = m_httpClient->httpUrl + "/homework/updateLessonWorkStatus";//https://
    QString url = "http://192.168.1.108:9026/api/homework/updateLessonWorkStatus";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);

    if(QString::fromUtf8(dataByte).contains("\"result\":\"success\""))
    {
        return true;
    }

    qDebug() << "YMHomeWorkManagerAdapter::updateLessonWorkStatus::Fail" << QString::fromUtf8(dataByte);
    return false;
    //{\"message\":\"未批改完成不能修改状态\",\"result\":\"fail\",\"data\":null,\"code\":18001}
}

//答题卡界面（老师学生都用）
QJsonObject YMHomeWorkManagerAdapter::getAnswerCard(QString lessonWorkId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonWorkId", lessonWorkId.toLong());
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    //QString url = m_httpClint->httpUrl + "/homework/getAnswerCard";//https://
    QString url = "http://192.168.1.108:9026/api/homework/getAnswerCard";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    qDebug() << "YMHomeWorkManagerAdapter::getAnswerCard::dataObj" << QString::fromUtf8(dataByte);
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
    reqParm.insert("lessonWorkId", lessonWorkId.toLong());
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

    qDebug() << "YMHomeWorkManagerAdapter::updateReaded::dataObj" << QString::fromUtf8(dataByte);
    return false;
    //{\"message\":null,\"result\":\"success\",\"data\":null,\"code\":0}
}

//查看作业答题情况
QJsonObject YMHomeWorkManagerAdapter::getQuestionStatus(QString lessonWorkId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonWorkId", lessonWorkId.toLong());
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    QString sign = YMEncryption::signMapSort(reqParm);
    QString md5Sign = YMEncryption::md5(sign);
    reqParm.insert("sign", md5Sign.toUpper());

    //QString url = m_httpClient->httpUrl + "/homework/getQuestionStatus";//https://
    QString url = "http://192.168.1.108:9026/api/homework/getQuestionStatus";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();
    QString result = objectData.value("result").toString().toLower();
    if(!result.contains("success"))
    {
        QString strMsg = objectData.value("message").toString();
        emit sigMessageBoxInfo(strMsg);

        qDebug() << "YMHomeWorkManagerAdapter::getQuestionStatus::dataObject failed." << objectData;
    }
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
    qDebug() << "YMHomeWorkManagerAdapter::getFinishLessonWork::dataObj" << objectData << isFinish;
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
        qDebug() << "YMHomeWorkManagerAdapter::saveTeacherComment" << objectData;
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
    qDebug() << "===YMHomeWorkManagerAdapter::getHomeworkDetailList::Fail" << objectData;
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
    qDebug() << "YMHomeWorkManagerAdapter::getDetailByOne::Fail" << objectData;
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
    qDebug() << "YMHomeWorkManagerAdapter::getErrReason::" << objectData;
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

    qDebug() << "===YMHomeWorkManagerAdapter::getStudentIsFinish::Fail" << objectData << isFinish;
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

    qDebug() << "===YMHomeWorkManagerAdapter::getIsCommented::Fail" << isCommented << objectData;
    return isCommented;
}

//获取当前网络环境
void YMHomeWorkManagerAdapter::getCurrentStage()
{
    int netType = m_httpClient->m_netType;
    QString stageInfo = m_httpClient->m_stage;
    emit sigStageInfo(netType,stageInfo);
}

//修改网络配置文件
void YMHomeWorkManagerAdapter::updateStage(int netType, QString stageInfo)
{
    m_httpClient->updateNetType(netType,stageInfo);
}
