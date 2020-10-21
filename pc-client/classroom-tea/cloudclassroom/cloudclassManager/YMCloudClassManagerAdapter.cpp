#include "YMCloudClassManagerAdapter.h"
#include "YMEncryption.h"
#include "YMUserBaseInformation.h"
#include <QDir>
#include <QStandardPaths>
#include <QEventLoop>
#include "QCoreApplication"
#include "./dataconfig/datahandl/datamodel.h"

/*
*云教室接口
*/

YMCloudClassManagerAdapter::YMCloudClassManagerAdapter(QObject *parent)
    : QObject(parent)
{
    m_httpClient = YMHttpClient::defaultInstance();
    connect(m_httpClient, SIGNAL(onTimerOut()), this, SIGNAL(requestTimerOut()));
    m_currentIp = m_httpClient->getRunUrl(0);  "stage-jyhd.yimifudao.com";//"47.100.68.102:9026"; //"192.168.3.24";
    tempUrl = m_httpClient->getRunUrl(1);//"stage-api.yimifudao.com/v2.4";
    qDebug() << "*******m_currentIp********" << m_currentIp << tempUrl;
    m_currentNumber = 0;
    m_repeatLessonTime = new QTimer();
    m_repeatLessonTime->setInterval(1000);
    connect(m_repeatLessonTime, SIGNAL(timeout()), this, SLOT(getLessonList()));
    m_errorArray.clear();

    QSettings reg("HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\", QSettings::NativeFormat);
    reg.beginGroup("BIOS");
    QString deviceInfo = reg.value("SystemManufacturer").toString().remove("#").append("|").append(reg.value("SystemSKU").toString().remove("#"));

    deviceInfo.remove("\r").remove("\n").remove("\\").remove("\u0002").remove("/").remove("}").remove("{").remove(";").remove(":").remove(",").remove("\"").remove("]").remove("[");
    YMUserBaseInformation::deviceInfo = QString::fromUtf8(deviceInfo.toUtf8());

}

//获取课程结束时评价的配置
void YMCloudClassManagerAdapter::getLessonCommentConfig()
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap  reqParm;
    reqParm.insert("type", "TEA");
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("apiVersion", "3.0"); //YMUserBaseInformation::apiVersion);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    QString url = "http://" + tempUrl + "/lesson/getLessonCommentConfig";
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();

    if(dataObj.value("result").toString().toLower() == "success")
    {
        QJsonArray lessonDataArray = dataObj.value("data").toArray();
        StudentData::gestance()->lessonCommentConfigInfo = lessonDataArray;
        emit sigLessonCommentConfig(lessonDataArray);
    }
    else
    {
        qDebug() << "YMCloudClassManagerAdapter::getLessonCommentConfig failed" << dataObj;
    }
}

//课堂练习答案单题提交
void YMCloudClassManagerAdapter::saveStudentAnswer(QJsonObject answerParm)
{
    long lessonId = answerParm.value("lessonId").toString().toLong();
    QString prePlanId = answerParm.value("prePlanId").toString();
    long itemId = answerParm.value("itemId").toString().toLong();
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
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    //QString url = m_httpClient->httpUrl\+ "/api/lesson-plan/classwork/saveStudentAnswer";
    QString url = "http://" + m_currentIp + "/api/lesson-plan/classwork/saveStudentAnswer";
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();


    if(dataObj.value("result").toString().toLower() != "success")
    {
        qDebug() << "YMCloudClassManagerAdapter::saveStudentAnswer failed" << dataObj;
    }
}

//老师提交批注
void YMCloudClassManagerAdapter::saveTeacherComment(long lessonId, QString prePlanId, long itemId, QJsonObject commentParm)
{
    //qDebug() << "===YMCloudClassManagerAdapter::saveTeacherComment===" << commentParm;
    QString questionId = commentParm.value("questionId").toString();
    QString childQuestionId = commentParm.value("childQuestionId").toString();
    QString remarkUrl = commentParm.value("remarkUrl").toString();
    int remarkTime = commentParm.value("remarkTime").toInt();
    int errorType = commentParm.value("errorType").toInt();
    QString errorName = commentParm.value("errorName").toString();
    int questionStatus = commentParm.value("questionStatus").toInt();
    double score = commentParm.value("score").toDouble();

    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonId", lessonId);
    reqParm.insert("planId", prePlanId);
    reqParm.insert("itemId", itemId);
    reqParm.insert("questionId", questionId);
    reqParm.insert("childQuestionId", childQuestionId);
    reqParm.insert("remarkUrl", remarkUrl);
    reqParm.insert("remarkTime", remarkTime);
    reqParm.insert("errorType", errorType); //错因Id
    reqParm.insert("errorName", errorName);
    reqParm.insert("questionStatus", questionStatus);
    reqParm.insert("score", score);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    QString url = "http://" + m_currentIp + "/api/lessonPlan/saveTeacherComment";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();

    qDebug() << "YMCloudClassManagerAdapter::saveTeacherComment"
             << url << lessonId << prePlanId << itemId << questionId
             << childQuestionId << remarkUrl << remarkTime << errorType
             << errorName  << questionStatus << score ;

    //qDebug() << "*************saveTeacherComment::objectData***************" << objectData;

    if(objectData.value("result").toString().toLower() == "success")
    {
        for(auto it = m_itemInfo.begin(); it != m_itemInfo.end(); it++)
        {
            if(it.key() != itemId)
            {
                continue;
            }

            QMap<QString, QJsonObject> mapData = it.value();
            for(auto its = mapData.begin(); its != mapData.end(); its++)
            {
                if(its.key() == questionId)
                {
                    QJsonObject bufferObj = objectData.value("data").toObject();
                    QJsonObject questionObj =  its.value();
                    //qDebug() << "**************questionObj>>>>>>>>>>" << questionObj;
                    int questionTypes = questionObj.value("questionType").toInt();
                    //综合题替换题目
                    if(questionTypes == 6)
                    {
                        QJsonObject addObj;
                        addObj.insert("analyse", questionObj.value("analyse").toString());
                        addObj.insert("answer", questionObj.value("answer").toArray());
                        addObj.insert("baseImage", questionObj.value("baseImage").toObject());
                        addObj.insert("content", questionObj.value("content").toString());
                        addObj.insert("difficulty", questionObj.value("difficulty").toInt());
                        addObj.insert("errorName", questionObj.value("errorName").toString());
                        addObj.insert("errorType", questionObj.value("errorType").toInt());
                        addObj.insert("haschild", questionObj.value("haschild").toBool());
                        addObj.insert("id", questionObj.value("id").toString());
                        addObj.insert("isFavorite", questionObj.value("isFavorite").toInt());
                        addObj.insert("isRight", questionObj.value("isRight").toInt());
                        addObj.insert("knowledges", questionObj.value("knowledges").toArray());
                        addObj.insert("lastUpdatedDate", questionObj.value("lastUpdatedDate").toString());
                        addObj.insert("orderNumber", questionObj.value("orderNumber").toInt());
                        addObj.insert("photos", questionObj.value("photos").toArray());
                        addObj.insert("qtype", questionObj.value("qtype").toString());
                        addObj.insert("questionItems", questionObj.value("questionItems").toArray());
                        addObj.insert("questionType", questionObj.value("questionType").toInt());
                        addObj.insert("remarkTime", questionObj.value("remarkTime").toInt());
                        addObj.insert("remarkUrl", questionObj.value("remarkUrl").toString());
                        addObj.insert("reply", questionObj.value("reply").toString());
                        addObj.insert("score", questionObj.value("score").toInt());
                        addObj.insert("status", questionObj.value("status").toInt());
                        addObj.insert("studentAnswer", questionObj.value("studentAnswer").toString());
                        addObj.insert("studentScore", questionObj.value("studentScore").toInt());
                        addObj.insert("teacherImages", questionObj.value("teacherImages").toArray());
                        addObj.insert("useTime", questionObj.value("useTime").toInt());
                        addObj.insert("writeImages", questionObj.value("writeImages").toArray());

                        QJsonArray questionArray  = questionObj.value("childQuestionInfo").toArray();
                        QString currentQustionId = bufferObj.value("id").toString();
                        QJsonArray addArray;
                        for(int i = 0; i < questionArray.size(); i++)
                        {
                            QJsonObject childQuestionObj = questionArray.at(i).toObject();
                            QString childQuesitonId = childQuestionObj.value("id").toString();

                            if(childQuesitonId == currentQustionId)
                            {
                                addArray.insert(i, bufferObj);
                                continue;
                            }
                            addArray.insert(i, childQuestionObj);
                        }
                        addObj.insert("childQuestionInfo", addArray);

                        m_itemInfo[it.key()][questionId]  = addObj;

                        QJsonArray answerArray;
                        QJsonArray photosArray;
                        QJsonArray childAnswerArray = bufferObj.value("answer").toArray();
                        answerArray.append(childAnswerArray);

                        int questionType = bufferObj.value("questionType").toInt();
                        if(questionType == 4 || questionType == 5)
                        {
                            QJsonArray childPhotosArray = bufferObj.value("allImages").toArray();
                            if(childPhotosArray.size() > 0)
                            {
                                photosArray.append(childPhotosArray);
                            }
                        }
                        //qDebug() << "**************questionObj************" << addObj;
                        //emit sigQuestionInfo(addObj,answerArray,photosArray,false);
                        emit sigCorreSuccess();
                        break;
                    }

                    m_itemInfo[it.key()][questionId] = bufferObj;

                    QJsonArray answerArray;
                    QJsonArray photosArray;
                    QJsonArray childAnswerArray = bufferObj.value("answer").toArray();
                    answerArray.append(childAnswerArray);

                    int questionType = bufferObj.value("questionType").toInt();
                    if(questionType == 4 || questionType == 5)
                    {
                        QJsonArray childPhotosArray = bufferObj.value("allImages").toArray();
                        if(childPhotosArray.size() > 0)
                        {
                            photosArray.append(childPhotosArray);
                        }
                    }
                    //emit sigQuestionInfo(bufferObj,answerArray,photosArray,false);
                    emit sigCorreSuccess();
                    break;
                }
            }
        }
        //qDebug() << "===YMCloudClassManagerAdapter::saveTeacherComment===" << objectData;
    }
    else
    {
        qDebug() << "===YMCloudClassManagerAdapter::saveTeacherComment failed." << objectData;
    }
}

//查询栏目下的所有题目信息
void YMCloudClassManagerAdapter::getLessonPlanQuestionInfo(QString lessonId, QString prePlanId, QString itemId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonId", lessonId);
    reqParm.insert("prePlanId", prePlanId);
    reqParm.insert("itemId", itemId);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    //QString url = m_httpClient->httpUrl + "/api/lesson-plan/classwork/getLessonPlanQuestionInfo";
    QString url = "http://" + m_currentIp + "/api/lesson-plan/classwork/getLessonPlanQuestionInfo";
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    if(dataObj.value("result").toString().toLower() != "success")
    {
        qDebug() << "YMCloudClassManagerAdapter::getLessonPlanQuestionInfo failed." << dataObj;
    }
}

//保存老师轨迹图片
void YMCloudClassManagerAdapter::saveTeacherTrajectory(QString lessonId, QString prePlanId, QString itemId, QString questionId, QString childQuestionId, QString imageArray)
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
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    //QString url = m_httpClient->httpUrl + "/api/lesson-plan/classwork/saveTeacherTrajectory";
    QString url = "http://" + m_currentIp + "/api/lesson-plan/classwork/saveTeacherTrajectory";
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    if(dataObj.value("result").toString().toLower() != "success")
    {
        qDebug() << "YMCloudClassManagerAdapter::saveTeacherTrajectory failed" << dataObj;
    }
}

//课程列表查看是否有课件
void YMCloudClassManagerAdapter::getLessonInfoStatus(QString lessonId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonId", lessonId);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    //QString url = m_httpClient->httpUrl + "/lessonListInfo/getLessonInfoStatus";
    QString url = "http://" + m_currentIp + "/lessonListInfo/getLessonInfoStatus";
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    if(dataObj.value("message").toString().toLower() != "success")
    {
        qDebug() << "YMCloudClassManagerAdapter::getLessonInfoStatus failed" << dataObj;
    }
}

//根据课程ID查询讲义列表
void YMCloudClassManagerAdapter::getLessonList()
{
    m_repeatLessonTime->stop();
    QString lessonId = YMUserBaseInformation::lessonId;
    qDebug() << "YMCloudClassManagerAdapter::getLessonList::" << YMUserBaseInformation::lessonId << YMUserBaseInformation::token;
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonId", YMUserBaseInformation::lessonId);
    reqParm.insert("userType", YMUserBaseInformation::type);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    //QString url = m_httpClient->httpUrl + "/api/lessonPlan/getLessonList";
    QString url = "http://" + tempUrl + "/api/lessonPlan/getLessonList";

    qDebug() << "==YMCloudClassManagerAdapter::getLessonList::url==" << url << reqParm;

    QByteArray byteArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(byteArray).object();

    if(m_currentNumber == 3) //连续三次获取失败则发送退出教室信号
    {
        emit sigLoadLessonFail();

        //信息上报
        QJsonObject obj;
        obj.insert("result","0");
        obj.insert("api_name","getLessonPlanList");

        if(m_httpClient->getCurrentReplyCode() != 200)
        {
            if(m_httpClient->getCurrentReplyCode() == 0)
            {
              obj.insert("errMsg",QStringLiteral("客户端没有连接网络"));
            }else
            {
                obj.insert("errMsg",QStringLiteral("接口服务器系统异常，接口返回") + QString::number(m_httpClient->getCurrentReplyCode()));
            }
        }else if(byteArray.size() == 0)
        {
            obj.insert("errMsg",QStringLiteral("接口返回数据异常，数据获取为空"));
        }else if(dataObj.value("result").toString().toLower() != "success")
        {
            obj.insert("errMsg",QStringLiteral("接口返回数据异常，result字段不为success"));
        }

        YMQosManager::gestance()->addBePushedMsg("lessonBaseInfo",obj);
        return;
    }

    //三次获取课件
    if(byteArray.size() == 0 && m_currentNumber < 3)
    {
        qDebug() << "========m_repeatLessonTime::reStart=========" << byteArray.size() << m_currentNumber;
        m_repeatLessonTime->start();
        m_currentNumber++;
        return;
    }

    //    qDebug() << "YMCloudClassManagerAdapter::getLessonList::dataObj"<< byteArray.size() << dataObj;
    //将访问数据写入文本文件
    //    QString bufferFilePath = QCoreApplication::applicationDirPath();//QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    //    QDir dir(bufferFilePath);
    //    if(!dir.exists()){
    //        dir.mkdir(bufferFilePath);
    //    }
    //    QString saveFilePath = bufferFilePath + "/lesson.text";
    //    qDebug() << "saveUserInfo:" << saveFilePath;
    //    QFile file(saveFilePath);
    //    file.close();
    //    if(file.open(QFile::ReadWrite)){
    //        QTextStream textOut(&file);
    //        textOut << byteArray;
    //        textOut.flush();
    //    }
    //    file.close();


    QJsonArray dataArray;
    if(dataObj.value("result").toString().toLower() == "success")
    {
        dataArray = dataObj.value("data").toArray();
        m_plandInfo.clear();
        m_itemInfo.clear();
        m_courseware.clear();
        //缓存所有栏目信息和题目
        for(int i = 0; i < dataArray.size(); i++)
        {
            QJsonObject dataObj = dataArray.at(i).toObject();
            QJsonObject planInfoObj = dataObj.value("planInfo").toObject();
            int planType = dataObj.value("planType").toInt();

            QJsonArray itemsArray = planInfoObj.value("items").toArray();
            long planId = planInfoObj.value("planId").toInt();
            if(planType == 2 || planType == 100)
            {
                QJsonObject courseObj = planInfoObj.value("lessonDoc").toObject();
                QJsonArray courseArray = courseObj.value("images").toArray();
                m_courseware.insert(planId, courseArray);
                continue;
            }
            this->analyzeItemInfo(planId, itemsArray);
            this->getErrorReasons(lessonId.toLong(), planId);
            //qDebug() << "*******AAA******" << itemsArray;
        }
        m_repeatLessonTime->stop();
        //qDebug() << "YMCloudClassManagerAdapter::getLessonList::" << m_plandInfo.count() << m_itemInfo.count();
    }
    else
    {
        qDebug() << "YMCloudClassManagerAdapter::getLessonList failed::" << dataObj;
    }

    emit sigHandoutInfo(dataArray);
}

//获取新讲义老课件列表
void YMCloudClassManagerAdapter::getCoursewareList(long planId)
{
    QJsonArray coursewareArray;
    QString planIds;
    for(auto it = m_courseware.begin(); it != m_courseware.end(); it++)
    {
        if(it.key() == planId)
        {
            planIds = QString::number(it.key());
            coursewareArray = it.value();
            break;
        }
    }
    QJsonObject coursewareObj;
    QJsonObject contentObj;

    contentObj.insert("docId", planIds);
    contentObj.insert("pageIndex", "1");
    contentObj.insert("urls", coursewareArray);

    coursewareObj.insert("command", "courware");
    coursewareObj.insert("domain", "draw");
    coursewareObj.insert("content", contentObj);
    if(coursewareArray.size() > 0 && planIds != "")
    {
        QJsonDocument documents;
        documents.setObject(coursewareObj);
        QString str(documents.toJson(QJsonDocument::Compact));
        emit sigCourseware(str);
        //qDebug()<< "*********coursewareObj*********" << coursewareObj;
    }
}

//根据讲义Id解析数据进行缓存
void YMCloudClassManagerAdapter::analyzeItemInfo(long planId, QJsonArray itemsArrays)
{
    m_plandInfo.insert(planId, itemsArrays);
    for(int i = 0; i < itemsArrays.size(); i++)
    {
        QJsonObject obj = itemsArrays.at(i).toObject();
        QString questionId;
        QJsonArray questionIdArray;

        //添加讲义数据存储
        int itemId = obj.value("itemId").toInt();
        QJsonArray questionInfosArray = obj.value("questionInfos").toArray();
        //qDebug()<< "=====questionInfosArray=====" << questionInfosArray;
        if(questionInfosArray.size() > 0)
        {
            QMap<QString, QJsonObject> m_questionInfoList;
            for(int k = 0; k < questionInfosArray.size(); k++)
            {
                QJsonObject questionInfosObj = questionInfosArray.at(k).toObject();
                questionId = questionInfosObj.value("id").toString();
                questionIdArray.append(questionId);
                m_questionInfoList.insert(questionId, questionInfosObj);
            }
            m_itemInfo.insert(itemId, m_questionInfoList);
        }

        QJsonArray resourceContentsArray = obj.value("resourceContents").toArray();
        //qDebug() << "=====resourceContentsArray======" << resourceContentsArray.size() << resourceContentsArray;

        if(resourceContentsArray.size() > 0)
        {
            QMap<QString, QJsonObject> m_questionInfoList;
            for(int i = 0; i < resourceContentsArray.size(); i++)
            {
                QJsonObject resourceContentsObj = resourceContentsArray.at(i).toObject();
                questionId = resourceContentsObj.value("resourceId").toString();
                questionIdArray.append(questionId);
                //qDebug() << "======resourceContentsObj=======" << questionId << resourceContentsObj;
                m_questionInfoList.insert(questionId, resourceContentsObj);
            }
            m_itemInfo.insert(itemId, m_questionInfoList);
        }
    }

   StudentData::gestance()->allCoursewareData = m_itemInfo;
}

//根据讲义Id给出所有的栏目具体信息
void YMCloudClassManagerAdapter::getIdByColumnInfo(long lessonId, long planId, int type, QString handoutName)
{
    //qDebug() << "YMCloudClassManagerAdapter::getIdByColumnInfo::data"<<lessonId << planId << type ;

    QJsonArray itemsArrays;

    for(auto it = m_plandInfo.begin(); it != m_plandInfo.end();  it++)
    {
        itemsArrays =  it.value();
        if(it.key() == planId)
        {
            break;
        }
    }

    QJsonArray handoutArray;
    QJsonArray itemsArray;

    for(int i = 0; i < itemsArrays.size(); i++)
    {
        QJsonObject obj = itemsArrays.at(i).toObject();
        QString questionId;
        QJsonArray questionIdArray;
        QJsonObject handoutObjChild;
        QJsonObject itemsObjecte;

        //添加讲义数据存储
        QJsonArray questionInfosArray = obj.value("questionInfos").toArray();
        //qDebug()<< "=====questionInfosArray=====" << questionInfosArray;
        if(questionInfosArray.size() > 0)
        {
            QMap<QString, QJsonObject> m_questionInfoList;
            for(int k = 0; k < questionInfosArray.size(); k++)
            {
                QJsonObject questionInfosObj = questionInfosArray.at(k).toObject();
                questionId = questionInfosObj.value("id").toString();
                questionIdArray.append(questionId);
                m_questionInfoList.insert(questionId, questionInfosObj);
            }
        }

        QJsonArray resourceContentsArray = obj.value("resourceContents").toArray();
        //qDebug() << "=====resourceContentsArray======" << resourceContentsArray.size() << resourceContentsArray;

        if(resourceContentsArray.size() > 0)
        {
            QMap<QString, QJsonObject> m_questionInfoList;
            for(int i = 0; i < resourceContentsArray.size(); i++)
            {
                QJsonObject resourceContentsObj = resourceContentsArray.at(i).toObject();
                questionId = resourceContentsObj.value("resourceId").toString();
                questionIdArray.append(questionId);
                //qDebug() << "======resourceContentsObj=======" << questionId << resourceContentsObj;
                m_questionInfoList.insert(questionId, resourceContentsObj);
            }
        }

        itemsObjecte.insert("itemId", obj.value("itemId").toInt());
        itemsObjecte.insert("itemName", obj.value("itemName").toString());
        itemsObjecte.insert("itemType", obj.value("itemType").toInt());
        itemsObjecte.insert("orderNo", obj.value("orderNo").toInt());
        itemsObjecte.insert("lessonId", lessonId);
        itemsObjecte.insert("planId", planId);
        itemsObjecte.insert("questionId", questionId);
        itemsArray.append(itemsObjecte);

        //发送当前讲义信息
        handoutObjChild.insert("columnId", QString::number(obj.value("itemId").toInt()));
        handoutObjChild.insert("columnName", obj.value("itemName").toString());
        handoutObjChild.insert("columnType", QString::number(obj.value("itemType").toInt()));
        handoutObjChild.insert("questions", questionIdArray);
        handoutArray.append(handoutObjChild);
    }
    //发送当前讲义信息
    QJsonObject handoutObj;
    handoutObj.insert("planId", QString::number(planId));
    handoutObj.insert("planName", handoutName);
    handoutObj.insert("columns", handoutArray);

    emit sigSendHandoutInfo(handoutObj);
    emit sigHandoutMenuInfo(itemsArray);
    //qDebug() << "YMCloudClassManagerAdapter::getIdByColumnInfo::handoutObj" << handoutObj;
}

//根据栏目id给出具体的题目信息
void YMCloudClassManagerAdapter::findItemById(long lessonId, long planId, long itemId, QString questionId)
{
    qDebug() << "===YMCloudClassManagerAdapter::findItemById===" << planId << itemId << questionId << m_plandInfo.size();

    if(questionId == "")
    {
        qDebug() << "==YMCloudClassManagerAdapter::findItemById::null::quesitonId==";
        return ;
    }
    int itemType =  0;
    m_currentItemId = 0;

    bool make = false;
    for(auto it = m_plandInfo.begin(); it != m_plandInfo.end();  it++)
    {
        QJsonArray plandArray =  it.value();

        for(int i = 0; i < plandArray.size(); i++)
        {
            QJsonObject plandObj = plandArray.at(i).toObject();
            int currentItemsId = plandObj.value("itemId").toInt();
            if(itemId == currentItemsId)
            {
                m_currentItemId = itemId;
                itemType =  plandObj.value("itemType").toInt();
                make = true;
                break;
            }
        }

        if(make)
        {
            break;
        }
    }

    for(auto it = m_itemInfo.begin(); it != m_itemInfo.end(); ++it)
    {
        if(it.key() == itemId)
        {
            QMap<QString, QJsonObject> arrayData = it.value();
            for(auto its = arrayData.begin(); its != arrayData.end(); its++)
            {
                QJsonObject  itemsObject = its.value();
                m_menuType = itemType;

                if(itemType == 0)
                {
                    if(itemId == m_currentItemId)
                    {
                        m_resourceContentArray = itemsObject.value("resourceContents").toArray();
                        m_menuTotal = m_resourceContentArray.size();
                        m_menuCurrentIndex = 0;
                        QJsonObject resourceContentObj;
                        for(int i = 0; i < m_resourceContentArray.size(); i++)
                        {
                            QJsonObject resouceObj = m_resourceContentArray.at(i).toObject();
                            resourceContentObj.insert("itemType", itemType);
                            resourceContentObj.insert("content", resouceObj.value("content").toString());
                            break;
                        }
                        m_menuCurrentIndex++;
                        if(m_resourceContentArray.size() > 1)
                        {
                            emit sigShowPage(m_menuCurrentIndex, m_menuTotal + 1);
                        }
                        emit sigLearningTarget(resourceContentObj);
                        break;
                    }
                }

                if(itemId == m_currentItemId)
                {
                    //qDebug() << "********YMCloudClassManagerAdapter::findItemById::itemsObject*********" << arrayData.size() << itemsObject;
                    m_totalQuestion = arrayData.size();
                    m_currentQuestionIndex = 0;

                    QJsonArray childQuestionInfoArray = itemsObject.value("childQuestionInfo").toArray();
                    //qDebug() << "======childQuestionInfoArray=====" << childQuestionInfoArray.size() << childQuestionInfoArray;

                    if(m_totalQuestion > 1)
                    {
                        emit sigIsMenuMultiTopic(true);
                    }
                    else
                    {
                        emit sigIsMenuMultiTopic(false);
                    }

                    if(childQuestionInfoArray.size() > 1)
                    {
                        emit sigIsChildTopic(true);
                    }
                    else
                    {
                        emit sigIsChildTopic(false);
                    }
                    QJsonArray answerArray;
                    QJsonArray photosArray;
                    int questinType = itemsObject.value("questionType").toInt();
                    if(questinType < 6)
                    {
                        QJsonArray answerArrayData =   itemsObject.value("answer").toArray();
                        answerArray.append(answerArrayData);
                    }
                    for(int k = 0; k < childQuestionInfoArray.size(); k++)
                    {
                        QJsonObject answerObj = childQuestionInfoArray.at(k).toObject();
                        QJsonArray childAnswerArray = answerObj.value("answer").toArray();
                        answerArray.append(childAnswerArray);

                        int questionType = answerObj.value("questionType").toInt();
                        if(questionType == 4 || questionType == 5)
                        {
                            QJsonArray childPhotosArray = answerObj.value("allImages").toArray();
                            if(childPhotosArray.size() > 0)
                            {
                                photosArray.append(childPhotosArray);
                            }
                        }
                    }

                    //qDebug() << "**************answerArray******************" << answerArray << answerArray.at(1);
                    emit sigQuestionInfo(itemsObject, answerArray, photosArray, false);
                    m_currentQuestionIndex++;
                    if(arrayData.size() > 1)
                    {
                        emit sigShowPage(m_currentQuestionIndex, m_totalQuestion + 1);
                    }
                    //QString questionIds = itemsObject.value("id").toString();
                    //qDebug() << "=======questionIds=========" << questionIds << questionId;
                    //emit sigTopicId(questionId);
                    break;
                }
            }
            //qDebug() << "YMCloudClassManagerAdapter::findItemById" << it.key() << it.value();
            break;
        }
    }
}

//根据讲义Id、栏目Id、题目Id查询题目
void YMCloudClassManagerAdapter::filterQuestionInfo(QString planId, QString columnId, QString questionId)
{
    qDebug() << "==YMCloudClassManagerAdapter::filterQuestionInfo==" << m_plandInfo.size() << m_itemInfo.size() << planId << columnId << questionId;
    int itemType =  0;
    long itemId = columnId.toLong();
    long planIds = planId.toLong();
    if(planId == "" && columnId == "")
    {
        return;
    }
    //qDebug() << "====itemId::planIds===" << itemId <<planIds;

    for(auto it = m_plandInfo.begin(); it != m_plandInfo.end();  it++)
    {
        if(it.key() != planIds)
        {
            continue;
        }
        QJsonArray plandArray =  it.value();
        for(int i = 0; i < plandArray.size(); i++)
        {
            QJsonObject plandObj = plandArray.at(i).toObject();
            int currentItemsId = plandObj.value("itemId").toInt();
            if(itemId == currentItemsId)
            {
                itemType =  plandObj.value("itemType").toInt();
                break;
            }
        }
    }

    for(auto it = m_itemInfo.begin(); it != m_itemInfo.end(); ++it)
    {
        //qDebug() << "***************it::key**************" << it.key();
        if(it.key() == itemId)
        {
            QMap<QString, QJsonObject> arrayData = it.value();
            //qDebug() << "=======itemsObject::itemId::planId=========" << itemId << planId << questionId;
            for(auto its = arrayData.begin(); its != arrayData.end(); its++)
            {
                QJsonObject  itemsObject = its.value();
                QString questionIds = itemsObject.value("id").toString();
                QString resourceId = itemsObject.value("resourceId").toString();
                int questinType = itemsObject.value("questionType").toInt();
                if(questionIds == "")
                {
                    if(resourceId != questionId)
                    {
                        continue;
                    }
                }
                else
                {
                    if(questionIds != questionId)
                    {
                        continue;
                    }
                }

                //qDebug() << "=======itemsObject=========" << questionId << itemType << itemsObject;
                if(itemType == 0)
                {
                    emit sigLearningTarget(itemsObject);
                    break;
                }

                //qDebug() << "********m_QuestionInfo*********" << arrayData.size() << itemsObject;
                QJsonArray childQuestionInfoArray = itemsObject.value("childQuestionInfo").toArray();
                //qDebug() << "======childQuestionInfoArray=====" << childQuestionInfoArray.size() << childQuestionInfoArray;

                if(arrayData.size() > 1)
                {
                    emit sigIsMenuMultiTopic(true);
                }
                else
                {
                    emit sigIsMenuMultiTopic(false);
                }

                if(childQuestionInfoArray.size() > 1)
                {
                    emit sigIsChildTopic(true);
                }
                else
                {
                    emit sigIsChildTopic(false);
                }
                QJsonArray answerArray;
                QJsonArray photosArray;

                if(questinType < 6)
                {
                    QJsonArray answerArrayData =   itemsObject.value("answer").toArray();
                    answerArray.append(answerArrayData);
                }

                for(int k = 0; k < childQuestionInfoArray.size(); k++)
                {
                    QJsonObject answerObj = childQuestionInfoArray.at(k).toObject();
                    QJsonArray childAnswerArray = answerObj.value("answer").toArray();
                    answerArray.append(childAnswerArray);

                    int questionType = answerObj.value("questionType").toInt();
                    if(questionType == 4 || questionType == 5)
                    {
                        QJsonArray childPhotosArray = answerObj.value("allImages").toArray();
                        if(childPhotosArray.size() > 0)
                        {
                            photosArray.append(childPhotosArray);
                        }
                    }
                }

                emit sigQuestionInfo(itemsObject, answerArray, photosArray, false);
                emit sigTopicId(questionId);
                break;
            }
            break;
        }
    }
}

//获取音视频函数
void YMCloudClassManagerAdapter::getLessonPlanUrl()
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonId", YMUserBaseInformation::lessonId);
    reqParm.insert("type", 3);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);
    //QString url = m_httpClient->httpUrl + "/api/lessonPlan/getLessonPlanUrl";
    QString url = "http://" + m_currentIp + "/api/lessonPlan/getLessonPlanUrl";
    QByteArray byteArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(byteArray).object();

    if(dataObj.value("result").toString().toLower() == "success")
    {
        QJsonArray dataArray = dataObj.value("data").toArray();
        //qDebug() << "***YMCloudClassManagerAdapter::getLessonPlanUrl***" << dataArray;
        emit sigGetMeidiaInfo(dataArray);
    }
    else
    {
        qDebug() << "***YMCloudClassManagerAdapter::getLessonPlanUrl failed" << dataObj;
    }
}

//根据题目Id给出题目详情
void YMCloudClassManagerAdapter::findQuestionDetailById(long lessonId, long planId, long itemId, QString questionId)
{
    //    qDebug()<< "YMCloudClassManagerAdapter::findQuestionDetailById::" << lessonId << planId << itemId << questionId;
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonId", lessonId);
    reqParm.insert("planId", planId);
    reqParm.insert("itemId", itemId);
    reqParm.insert("questionId", questionId);
    reqParm.insert("userType", YMUserBaseInformation::type);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    //QString url = m_httpClient->httpUrl + "/api/lessonPlan/findQuestionDetailById";
    QString url = "http://" + m_currentIp + "/api/lessonPlan/findQuestionDetailById?";

    QString sign = "";
    QString urls = "";
    for(auto it = reqParm.begin(); it != reqParm.end(); ++it)
    {
        sign.append(it.key()).append("=").append(QString::fromUtf8( it.value().toByteArray()));
        if(it != reqParm.end() - 1)
        {
            sign.append("&");
        }
    }
    urls.append(sign);
    urls.append("&sign=").append(QCryptographicHash::hash(sign.toUtf8(), QCryptographicHash::Md5).toHex().toUpper());

    QByteArray post_data;
    post_data.append(urls);

    QEventLoop httploop;
    QTimer::singleShot(10000, &httploop, SLOT(quit()));
    QNetworkAccessManager *httpAccessMgr = new QNetworkAccessManager();
    QNetworkRequest netRequest;
    netRequest.setUrl(url);
    netRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    QNetworkReply *net_reply;
    net_reply = httpAccessMgr->post(netRequest, post_data); //通过发送数据，返回值保存在reply指针里.

    connect(net_reply, SIGNAL(finished()), &httploop, SLOT(quit()));
    httploop.exec();

    QByteArray byteArray = net_reply->readAll();
    QJsonObject dataObj = QJsonDocument::fromJson(byteArray).object();
    QString str_arr;
    str_arr.prepend(byteArray);

    //    qDebug() << "YMCloudClassManagerAdapter::findQuestionDetailById::dataObj" << url << reqParm << str_arr << byteArray.size();

    if(dataObj.value("result").toString().toLower() == "success")
    {
        QJsonObject dataObject = dataObj.value("data").toObject();
        //        qDebug() << "YMCloudClassManagerAdapter::findQuestionDetailById::dataObject" << dataObject;
        QJsonArray answerArray;
        QJsonArray photosArray;
        QJsonArray answerData = dataObject.value("answer").toArray();

        int questionType = dataObject.value("questionType").toInt();
        if(questionType < 6)
        {
            answerArray.append(answerData);
        }
        if(questionType == 6)
        {
            QJsonArray childQuestionArray  = dataObject.value("childQuestionInfo").toArray();
            for(int i = 0; i < childQuestionArray.size(); i++)
            {
                QJsonObject childQuestionObj = childQuestionArray.at(i).toObject();
                QJsonArray childPhotosArray = childQuestionObj.value("allImages").toArray();

                QJsonArray childAnswerArray = childQuestionObj.value("answer").toArray();
                answerArray.append(childAnswerArray);
                //             qDebug() << "***YMCloudClassManagerAdapter::findQuestionDetailById***" << childPhotosArray;

                if(childPhotosArray.size() > 0)
                {
                    photosArray.append(childPhotosArray);
                }
            }
        }

        if(questionType == 4 || questionType == 5)
        {
            QJsonArray childPhotosArray = dataObject.value("allImages").toArray();
            if(childPhotosArray.size() > 0)
            {
                photosArray.append(childPhotosArray);
            }
        }

        for(auto it = m_itemInfo.begin(); it != m_itemInfo.end(); it++)
        {
            if(it.key() != itemId)
            {
                continue;
            }

            QMap<QString, QJsonObject> mapData = it.value();
            for(auto its = mapData.begin(); its != mapData.end(); its++)
            {
                if(its.key() == questionId)
                {
                    //                    qDebug() << "=======old::data======" << mapData[its.key()];
                    mapData.value(its.key(), dataObject);
                    //                    qDebug() << "====YMCloudClassManagerAdapter::findQuestionDetailById===" << dataObject;
                    m_itemInfo[it.key()][questionId] = dataObject;
                    break;
                }
            }
        }
        emit sigQuestionInfo(dataObject, answerArray, photosArray, true);
    }
    else
    {
        QString msg;
        msg.prepend(byteArray);
        DebugLog::gestance()->log("YMCloudClassManagerAdapter::findQuestionDetailById::" + msg);
        qDebug() << "YMCloudClassManagerAdapter::findQuestionDetailById failed" << lessonId << planId << itemId << questionId << msg << dataObj;

        //emit sigGetQuestionFail();
        findQuestionDetailById(lessonId, planId, itemId, questionId);
    }
}

//返回错因列表
void YMCloudClassManagerAdapter::getErrorReasons(long lessonId, int planId)
{
    qDebug() << "YMCloudClassManagerAdapter::getErrorReasons::" << lessonId << planId;

    for(auto it = m_errorArray.begin(); it != m_errorArray.end(); it++)
    {
        if(it.key() == planId)
        {
            QJsonArray errorArray = it.value();
            qDebug() << "YMCloudClassManagerAdapter::getErrorReasons::errorData" << planId << errorArray;
            emit sigErrorList(errorArray);
            return;
        }
    }

    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonId", lessonId);
    reqParm.insert("planId", planId);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);
    //QString url = m_httpClient->httpUrl + "/api/lessonPlan/getErrorReasons";
    QString url = "http://" + m_currentIp + "/api/lessonPlan/getErrorReasons";
    QByteArray byteArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(byteArray).object();

    qDebug() << "******YMCloudClassManagerAdapter::getErrorReasons******" << url << reqParm;

    if(dataObj.value("result").toString().toLower() == "success")
    {
        QJsonArray errorArray = dataObj.value("data").toArray();
        emit sigErrorList(errorArray);
        m_errorArray.insert(planId, errorArray);
        //        qDebug() << "YMCloudClassManagerAdapter::getErrorReasons::errorArray" << byteArray.size()<< errorArray << dataObj;
    }
    else
    {
        qDebug() << "YMCloudClassManagerAdapter::getErrorReasons failed." << dataObj;
    }
}

//保存题目或者资源生成的底图
void YMCloudClassManagerAdapter::saveBaseImage(long lessonId, long planId, long itemId, QString questionId, QString resourceId, QString baseImageUrl, int width, int height)
{
    qDebug() << "YMCloudClassManagerAdapter::saveBaseImage";
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonId", lessonId);
    reqParm.insert("planId", planId);
    reqParm.insert("itemId", itemId);
    reqParm.insert("questionId", questionId);
    reqParm.insert("resourceId", resourceId);
    reqParm.insert("baseImageUrl", baseImageUrl);
    reqParm.insert("width", width);
    reqParm.insert("height", height);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);
    //QString url = m_httpClient->httpUrl + "/api/lessonPlan/saveBaseImage";
    QString url = "http://" + m_currentIp + "/api/lessonPlan/saveBaseImage";
    QByteArray byteArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(byteArray).object();

    if(dataObj.value("result").toString().toLower() != "success")
    {
        qDebug() << "YMCloudClassManagerAdapter::saveBaseImage failed:" << dataObj;
    }
}

//教室内改变讲义栏目接口
void YMCloudClassManagerAdapter::changeItem(long planId, long itemId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonId", YMUserBaseInformation::lessonId);
    reqParm.insert("planId", planId);
    reqParm.insert("itemId", itemId);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);
    QString url = "http://" + m_currentIp + "/api/lesson/changeItem";
    QByteArray byteArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(byteArray).object();
    if(dataObj.value("result").toString().toLower() != "success")
    {
        qDebug() << "==YMCloudClassManagerAdapter::changeItem failed" << dataObj;
    }
}

void YMCloudClassManagerAdapter::spliceImage(QString imageList, QString key)
{
    qDebug() << "YMCloudClassManagerAdapter::spliceImage" << imageList << key;
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("imageList", imageList);
    reqParm.insert("key", key);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);
    //QString url = m_httpClient->httpUrl + "/api/lesson/montage/image";
    QString url = "http://" + m_currentIp + "/api/lesson/montage/image";
    QByteArray byteArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(byteArray).object();

    if(dataObj.value("result").toString().toLower() != "success")
    {
        qDebug() << "YMCloudClassManagerAdapter::spliceImage failed" << dataObj;
    }
}

//判断是否是第一次开始练习题目
bool YMCloudClassManagerAdapter::getIsOneQuestion()
{
    QString bufferFilePath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QString saveFilePath = bufferFilePath + "/oneStartLesson.dll";
    qDebug() << "saveUserInfo:" << saveFilePath;
    QFile file(saveFilePath);
    if(file.exists())
    {
        qDebug() << "saveUserInfo::true" << saveFilePath;
        return false;
    }
    if(file.open(QFile::WriteOnly | QFile::Append))
    {
        QTextStream textOut(&file);
        textOut << "open";
        textOut.flush();
        return true;
    }
}


QJsonObject YMCloudClassManagerAdapter::getStuHomeWorkData(int pageIndex)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("pageIndex", pageIndex);
    reqParm.insert("pageSize", "2000");
    reqParm.insert("lessonWorkStatus", "-1");
    reqParm.insert("userType", YMUserBaseInformation::type);
    reqParm.insert("token", YMUserBaseInformation::token);
    //reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    //reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));
    reqParm.insert("lessonId", YMUserBaseInformation::lessonId.toInt());
    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    QString url = "http://" + m_currentIp + "/api/homework/getLessonWorkList";

    QByteArray byteArray = m_httpClient->httpPostForm(url,reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(byteArray).object();

    if(dataObj.value("success").toBool())
    {
        emit sigHomeWorkList(dataObj);
    }

    //qDebug() << "==YMCloudClassManagerAdapter::getStuHomeWorkData::url=="<< reqParm << url << dataObj << __LINE__;
    //qDebug() << "==YMCloudClassManagerAdapter::getStuHomeWorkData::url=="<< m_currentIp << YMUserBaseInformation::type;

    return dataObj;

}

QJsonObject YMCloudClassManagerAdapter::getStuHomeWorkDetailData(QString lessonWorkId)
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonWorkId", lessonWorkId);
    reqParm.insert("token", YMUserBaseInformation::token);
    //reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    //reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    QString url = "http://" + m_currentIp + "/api/homework/getHomeworkDetailList";

    QByteArray byteArray = m_httpClient->httpPostForm(url,reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(byteArray).object();

    if(dataObj.value("success").toBool())
    {
        emit sigHomeWorkDetail(dataObj);
    }

    //qDebug() << "==YMCloudClassManagerAdapter::getStuHomeWorkData::url=="<< reqParm << url <<dataObj;
    return dataObj;
}
