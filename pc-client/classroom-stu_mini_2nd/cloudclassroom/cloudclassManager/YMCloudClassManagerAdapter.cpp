#include "YMCloudClassManagerAdapter.h"
#include "YMEncryption.h"
#include "YMUserBaseInformation.h"
#include "debuglog.h"
#include "./dataconfig/datahandl/datamodel.h"

/*
 *云教室接口      getLessonList()
 */

YMCloudClassManagerAdapter::YMCloudClassManagerAdapter(QObject *parent)
    : QObject(parent)
{
    m_httpClient = YMHttpClient::defaultInstance();
    connect(m_httpClient, SIGNAL(onTimerOut()), this, SIGNAL(requestTimerOut()));

    QSettings reg("HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\", QSettings::NativeFormat);
    reg.beginGroup("BIOS");
    QString deviceInfo = reg.value("SystemManufacturer").toString().remove("#").append("|").append(reg.value("SystemSKU").toString().remove("#"));

    deviceInfo.remove("\r").remove("\n").remove("\\").remove("\u0002").remove("/").remove("}").remove("{").remove(";").remove(":").remove(",").remove("\"").remove("]").remove("[");
    YMUserBaseInformation::deviceInfo = QString::fromUtf8(deviceInfo.toUtf8());
    qDebug() << " getLessonList(StudentData.gestance()->m_lessonId)" << StudentData::gestance()->m_lessonId;
}

//获取课程结束时评价的配置
void YMCloudClassManagerAdapter::getLessonCommentConfig()
{
    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap  reqParm;
    reqParm.insert("type", "STU");
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("apiVersion", "3.0"); //YMUserBaseInformation::apiVersion);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    QString url = "http://" + apiUrl + "/lesson/getLessonCommentConfig";
    //qDebug() << "YMCloudClassManagerAdapter::getLessonCommentConfig apiUrl: " << qPrintable(apiUrl);

    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();

    if(dataObj.value("result").toString().toLower() == "success")
    {
        QJsonArray lessonDataArray = dataObj.value("data").toArray();
        StudentData::gestance()->lessonCommentConfigInfo = lessonDataArray;
        emit sigLessonCommentConfig(lessonDataArray);
        qDebug() << "YMCloudClassManagerAdapter::getLessonCommentConfig" << StudentData::gestance()->lessonCommentConfigInfo;
    }
    else
    {
        qDebug() << "YMCloudClassManagerAdapter::getLessonCommentConfig failed" << __LINE__;
    }
}

//课堂练习答案单题提交
void YMCloudClassManagerAdapter::saveStudentAnswer(int useTime, QString studentAnswer, QJsonObject answerParm, int isFinished, QString imageAnswerUrl, QString childQId)
{
    qDebug() << "YMCloudClassManagerAdapter::saveStudentAnswer(" << isFinished << useTime << studentAnswer << answerParm << childQId << "photos:" << imageAnswerUrl;
    //    long lessonId = answerParm.value("lessonId").toString().toLong();
    QString prePlanId = answerParm.value("planId").toString();
    long itemId = answerParm.value("columnId").toString().toLong();
    QString questionId = answerParm.value("questionId").toString();
    QString childQuestionId = answerParm.value("childQuestionId").toString();
    //QString studentAnswer = QString::number(orderNumber);
    //int useTime = answerParm.value("useTime").toInt();
    QString photos = answerParm.value("photos").toString();
    QString writeImages = answerParm.value("writeImages").toString();
    QString originImage = answerParm.value("originImage").toString();

    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap  reqParm;
    reqParm.insert("lessonId", StudentData::gestance()->m_lessonId.toLong());
    reqParm.insert("planId", answerParm.value("planId").toString().toInt());
    reqParm.insert("itemId", answerParm.value("columnId").toString().toInt());
    reqParm.insert("questionId", answerParm.value("questionId").toString());

    if(answerParm.value("questionId").toString() != childQId && childQId != "")
    {
        reqParm.insert("childQuestionId", childQId);
    }

    reqParm.insert("studentAnswer", studentAnswer);
    reqParm.insert("useTime", useTime);
    reqParm.insert("isFinish", isFinished);
    reqParm.insert("photos", imageAnswerUrl);
    reqParm.insert("allImages", imageAnswerUrl);
    reqParm.insert("writeImages", writeImages);
    reqParm.insert("originImage", originImage);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    //QString url = m_httpClient->httpUrl\+ "/api/lesson-plan/classwork/saveStudentAnswer";
    QString url = "http://" + tempIp + "/api/lessonPlan/saveStudentAnswer";
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();

    qDebug() << "YMCloudClassManagerAdapter::saveStudentAnswer" << QString::fromUtf8(dataArray) << reqParm;
    if(dataObj.value("result").toString().toLower() == "success")
    {
        uploadStudentAnswerBackData(true, answerParm, isFinished);
        return;
    }
    else
    {
        qDebug() << "YMCloudClassManagerAdapter::saveStudentAnswer failed" << dataObj << url << reqParm << __LINE__;
    }

    uploadStudentAnswerBackData(false, answerParm, isFinished);
}

//老师提交批注
void YMCloudClassManagerAdapter::saveTeacherComment(QJsonObject commentParm)
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
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    //QString url = m_httpClient->httpUrl +"/api/lesson-plan/classwork/saveTeacherComment";
    QString url = "http://" + tempIp + "/api/lesson-plan/classwork/saveTeacherComment";
    QByteArray dataByte = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject objectData = QJsonDocument::fromJson(dataByte).object();

    if(objectData.value("result").toString().toLower() != "success")
    {
        qDebug() << "YMCloudClassManagerAdapter::saveTeacherComment failed" << objectData << __LINE__;
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
    QString url = "http://" + tempIp + "/api/lesson-plan/classwork/getLessonPlanQuestionInfo";
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    if(dataObj.value("result").toString().toLower() != "success")
    {
        qDebug() << "YMCloudClassManagerAdapter::getLessonPlanQuestionInfo failed" << dataObj << __LINE__;
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
    QString url = "http://" + tempIp + "/api/lesson-plan/classwork/saveTeacherTrajectory";
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    if(dataObj.value("result").toString().toLower() != "success")
    {
        qDebug() << "YMCloudClassManagerAdapter::saveTeacherTrajectory failed" << dataObj << __LINE__;
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
    QString url = "http://" + tempIp + "/lessonListInfo/getLessonInfoStatus";
    QByteArray dataArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(dataArray).object();
    if(dataObj.value("message").toString().toLower() != "success")
    {
        qDebug() << "YMCloudClassManagerAdapter::getLessonInfoStatus failed" << dataObj << __LINE__;
    }
}

//根据课程ID查询讲义列表
void YMCloudClassManagerAdapter::getLessonList()
{
    allNewCoursewarwList.clear();
    qDebug() << "YMCloudClassManagerAdapter::getLessonList::" << StudentData::gestance()->m_lessonId << YMUserBaseInformation::token;

    QDateTime currentTime = QDateTime::currentDateTime();
    QVariantMap reqParm;
    reqParm.insert("lessonId", StudentData::gestance()->m_lessonId);
    reqParm.insert("userType", YMUserBaseInformation::type);
    reqParm.insert("token", YMUserBaseInformation::token);
    reqParm.insert("appVersion", YMUserBaseInformation::appVersion);
    reqParm.insert("apiVersion", YMUserBaseInformation::apiVersion);
    reqParm.insert("timestamp", currentTime.toString("yyyyMMddhhmmss"));

    QString signSort = YMEncryption::signMapSort(reqParm);
    QString sign = YMEncryption::md5(signSort).toUpper();
    reqParm.insert("sign", sign);

    //QString url = m_httpClient->httpUrl + "/api/lessonPlan/getLessonList";
    QString url = "http://"  + apiUrl +  "/api/lessonPlan/getLessonList";
    QByteArray byteArray = m_httpClient->httpPostForm(url, reqParm);
    QJsonObject dataObj = QJsonDocument::fromJson(byteArray).object();

//    qDebug() << "YMCloudClassManagerAdapter::getLessonList::dataObj  11"<<StudentData::gestance()->lessonListIsEmptys<<dataObj ;

    QJsonArray dataArray;
    if(dataObj.value("success").toBool())
    {
        dataArray = dataObj.value("data").toArray();
        qDebug() << "YMCloudClassManagerAdapter::getLessonList::" << dataArray.size();
        for(int a = 0 ; a < dataArray.size(); a++)
        {
            QJsonObject obj = dataArray.at(a).toObject();
            //判断是否是新课件
            if(obj.take("planType").toInt() == 1)
            {
                allNewCoursewarwList.append(obj.take("planInfo").toObject());
            }
        }
        StudentData::gestance()->lessonListIsEmptys = false;
        qDebug() << "YMCloudClassManagerAdapter::getLessonList size: " << allNewCoursewarwList.size();

#if 0
        QFile file("11111out.txt");
        if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
            return;
        file.write(byteArray);
        file.flush();
        file.close();
#endif
    }
    else
    {
        qDebug() << ("YMCloudClassManagerAdapter::getLessonList fail byteArray: ") << QString::fromUtf8(byteArray) << dataObj;
        StudentData::gestance()->lessonListIsEmptys = true;
    }

    // emit sigHandoutInfo(dataArray);
}

bool YMCloudClassManagerAdapter::lessonListIsEmpty()
{
    //    if(allNewCoursewarwList.size() > 0)
    //    {
    //        // qDebug()<<"allNewCoursewarwList.size() qq> 0)";
    //        return false;
    //    }
    return StudentData::gestance()->lessonListIsEmptys;
}

//根据讲义Id给出所有的栏目具体信息 meiyong
void YMCloudClassManagerAdapter::getIdByColumnInfo(long lessonId, long planId, int type, QString handoutName)
{

}

//根据栏目id给出具体的题目信息
void YMCloudClassManagerAdapter::findItemById(long lessonId, long planId, long itemId, QString questionId)
{

}

//上一题
void YMCloudClassManagerAdapter::preTopic()
{
    if( m_currentQuestionIndex > 0)
    {
        --m_currentQuestionIndex;
        isResetPageNumber = false;
        getColumnPageData(QString::number( currentPlanIds), QString::number( currentItemIds ), QString::number( m_currentQuestionIndex + 1 ));
        isResetPageNumber = true;
    }
}

//下一题
void YMCloudClassManagerAdapter::nextTopic()
{
    if(m_currentQuestionIndex < m_totalQuestion )
    {
        ++m_currentQuestionIndex;
        isResetPageNumber = false;//
        //查找的时候索引里需要 - 1  m_currentQuestionIndex +1 传入
        getColumnPageData(QString::number(currentPlanIds), QString::number( currentItemIds ), QString::number( m_currentQuestionIndex + 1 ));
        isResetPageNumber = true;
    }

}

//跳转到某一题
void YMCloudClassManagerAdapter::jumpTopic(int page)
{
    if( page >= 0 && page <= m_totalQuestion  )
    {
        m_currentQuestionIndex = page;
        isResetPageNumber = false;
        getColumnPageData(QString::number(currentPlanIds), QString::number( currentItemIds ), QString::number( m_currentQuestionIndex + 1 ));
        isResetPageNumber = true;
    }
}

void YMCloudClassManagerAdapter::getColumnPageData(QString planId, QString columnId, QString index)
{
    //qDebug()<<"YMCloudClassManagerAdapter::getColumnPageData(QString planId, QString columnId)"<<planId<<columnId<<index;
    for(int a = 0 ; a < allNewCoursewarwList.size(); a++)
    {
        QJsonObject obj = allNewCoursewarwList.at(a);

        QString tempPlanId = QString::number( obj.value("planId").toInt());
        //  qDebug()<<"YMCloudClassManagerAdapter::getColumnPageData for"<<obj.value("planId") <<tempPlanId<<obj.value("planId").toInt();

        //判断课件ID是否相同
        if( planId == tempPlanId )
        {
            //qDebug()<<"YMCloudClassManagerAdapter::getColumnPageData planid";
            //判断栏目ID是否相同
            QJsonArray itemArray = obj.take("items").toArray();

            for(int a = 0 ; a < itemArray.size(); a++)
            {
                QString tempItemId = QString::number( itemArray.at(a).toObject().value("itemId").toInt());
                int tempItemType = itemArray.at(a).toObject().value("itemType").toInt();

                if(columnId == tempItemId)
                {
                    //                    //重置分页数据
                    //                    if(isResetPageNumber == true)
                    //                    {
                    //                        resetPageView(planId.toLong(),columnId.toLong(),itemArray.at(a).toObject());
                    //                    }

                    //      qDebug()<<tempItemType<<tempItemId<<"YMCloudClassManagerAdapter::getColumnPageData(";
                    //判断发送那种信号
                    if(tempItemType == 0)
                    {
                        QJsonArray itemArrays = itemArray.at(a).toObject().take("resourceContents").toArray();
                        //                        for(int a = 0; a<itemArrays.size(); a++)
                        //                        {

                        //                        }

                        //     qDebug()<<"YMCloudClassManagerAdapter::getColumnPageData si 00"<<itemArrays<<itemArrays.size()<<index<<itemArrays.at(index.toInt() - 1).toObject();
                        //获取课件页的数据 并传出去
                        if(itemArrays.size() > index.toInt())
                        {
                            //emit sigLearningTarget(itemArrays.at(index.toInt() - 1).toObject());
                            emit sigLearningTarget(itemArrays.at(index.toInt()).toObject());
                        }

                    }

                    //                    if(tempItemType == 1)
                    //                    {
                    //                        emit sigKnowledgeComb(itemArray.at(a).toObject());
                    //                    }

                    if(tempItemType == 1)
                    {
                        QJsonArray itemArrays = itemArray.at(a).toObject().take("questionInfos").toArray();
                        // qDebug()<<"YMCloudClassManagerAdapter::getColumnPageData  1 sig"<<itemArrays.size() <<index.toInt()<<index;

                        if(itemArrays.size() > index.toInt())
                        {
                            emit sigTypicalExample(itemArrays.at(index.toInt()).toObject());
                        }
                    }

                    if(tempItemType == 2)
                    {
                        QJsonArray itemArrays = itemArray.at(a).toObject().take("questionInfos").toArray();
                        // qDebug()<<"YMCloudClassManagerAdapter::getColumnPageData 2 sig"<<itemArrays.size() <<index.toInt()<<itemArrays.at(index.toInt()).toObject();

                        if(itemArrays.size() > index.toInt())
                        {
                            emit sigClassroomPractice(itemArrays.at(index.toInt()).toObject());
                        }
                    }

                }
            }

        }
    }
}

void YMCloudClassManagerAdapter::getQuestionDataById(QJsonObject objData, int sigType)
{
    QJsonObject tempobjs = objData;

    //    tempobjs.take("planId");
    //    qDebug()<<"tempobjs.take("<<tempobjs;
    //    tempobjs.insert("planId","testplanid");
    //    qDebug()<<"tempobjs.take("<<tempobjs;

    qDebug() << "YMCloudClassManagerAdapter::getQuestionDataById(" << sigType << objData;
    QString planId = objData.value("planId").toString();//QString ::number( objData.take("planId").toInt());
    if(planId == "")
    {
        planId = QString::number(objData.value("planId").toInt());
    }
    QString columnId = objData.value("columnId").toString();//QString ::number( objData.take("columnId").toInt());
    if(columnId == "")
    {
        columnId = QString ::number( objData.take("columnId").toInt());
    }

    QString questionId = objData.take("questionId").toString();


    qDebug() << "YMCloudClassManagerAdapter::getQuestionDataById(" << planId << columnId << questionId;
    for(int a = 0 ; a < allNewCoursewarwList.size(); a++)
    {
        QJsonObject obj = allNewCoursewarwList.at(a);

        QString tempPlanId = QString::number( obj.take("planId").toInt());
        //判断课件ID是否相同
        if( planId == tempPlanId )
        {
            qDebug() << "YMCloudClassManagerAdapter::getQuestionDataById(  planId == tempPlanId ";
            //判断栏目ID是否相同
            QJsonArray itemArray = obj.take("items").toArray();

            for(int a = 0 ; a < itemArray.size(); a++)
            {
                QString tempItemId = QString::number( itemArray.at(a).toObject().value("itemId").toInt());
                //qDebug()<<"YMCloudClassManagerAdapter::getQuestionDataById( tempItemId "<<columnId<<tempItemId;

                if(columnId == tempItemId)
                {

                    //根据 题目id查找题目所在的位置
                    QJsonArray itemArrays = itemArray.at(a).toObject().take("questionInfos").toArray();

                    for(int b = 0; b < itemArrays.size(); b++)
                    {
                        QJsonObject obj = itemArrays.at(b).toObject();
                        QJsonObject backObj = itemArrays.at(b).toObject(); //题目的数据信息
                        QString temps = obj.take("id").toString();

                        //qDebug()<<"YMCloudClassManagerAdapter::getQuestionDataById( temps == questionId "<<temps<<questionId;
                        if( temps == questionId )
                        {
                            //qDebug()<<"YMCloudClassManagerAdapter::getQuestionDataById(temps == questionId sig"<<objData<<"222222222222222222222222222"<<itemArrays.at(b).toObject();
                            //发送查到的题目信息

                            //做题数据信号
                            if(sigType == 1)
                            {
                                sigTeacherSendQuestionData(tempobjs, itemArrays.at(b).toObject());
                                return;
                            }
                            //答案解析数据信号
                            if(sigType == 2)
                            {
                                sigShowAnswerAnalyseView(tempobjs, itemArrays.at(b).toObject());
                                return;
                            }
                            //批改界面
                            if(sigType == 3)
                            {
                                sigShowCorrectView(tempobjs, itemArrays.at(b).toObject());
                                return;
                            }

                        }
                        else if(itemArrays.at(b).toObject().value("haschild").toBool())
                        {
                            //遍历子题是否存在 该题目id
                            QJsonArray childQuestionArray = itemArrays.at(b).toObject().value("childQuestionInfo").toArray();
                            // qDebug()<<" false cccccccc  has child childQuestionArray"<<childQuestionArray;
                            for(int c = 0 ; c < childQuestionArray.size(); c++)
                            {
                                QJsonObject objs = childQuestionArray.at(c).toObject();
                                QString temps = objs.value("id").toString();
                                qDebug() << "YMClou false cccccccc  has child" << temps << questionId;
                                if(temps == questionId)
                                {
                                    //重整数据
                                    backObj.take("childQuestionInfo");
                                    QJsonArray arrys ;
                                    arrys.append(childQuestionArray.at(c).toObject());
                                    backObj.insert("childQuestionInfo", arrys);

                                    //做题数据信号
                                    if(sigType == 1)
                                    {
                                        sigTeacherSendQuestionData(tempobjs, backObj);
                                        return;
                                    }
                                    //答案解析数据信号
                                    if(sigType == 2)
                                    {
                                        sigShowAnswerAnalyseView(tempobjs, backObj);
                                        return;
                                    }
                                    //批改界面
                                    if(sigType == 3)
                                    {
                                        sigShowCorrectView(tempobjs, backObj);
                                        return;
                                    }
                                }
                            }
                        }
                    }
                    //还没找到

                    break;
                }
            }

        }
    }
}

void YMCloudClassManagerAdapter::resetPageView(long planId, long itemId, QJsonObject m_AllQuestionInfo)
{
    qDebug() << "YMCloudClassManagerAdapter::resetPageView(" << planId << itemId;
    //QJsonArray itemsArray  = m_AllQuestionInfo.value("items").toArray();

    int planIds = m_AllQuestionInfo.value("planId").toInt();
    int types = m_AllQuestionInfo.value("type").toInt();

    currentPlanIds = planId;
    currentItemIds = itemId;

    //返回相应数据
    //    for(int i = 0; i < itemsArray.size(); i++)
    //    {
    //QJsonObject itemsObject  =  itemsArray.at(i).toObject();
    int itemType =  m_AllQuestionInfo.value("itemType").toInt();
    int itemIds = m_AllQuestionInfo.value("itemId").toInt();
    m_menuType = itemType;

    if(itemType == 0)
    {
        if(itemId == itemIds)
        {
            m_resourceContentArray = m_AllQuestionInfo.value("resourceContents").toArray();
            m_totalQuestion = m_resourceContentArray.size();
            m_currentQuestionIndex = 0;
            // m_currentQuestionIndex++;
            if(m_resourceContentArray.size() > 1)
            {
                qDebug() << "emit sigShowPage(m_menuCurrentIndex,m_menuTotal); 1" << m_currentQuestionIndex;
                emit sigShowPage(1, m_totalQuestion);
            }
            // emit sigLearningTarget(resourceContentObj);
            return;
        }
    }
    if(itemId == itemIds)
    {
        m_QuestionInfo = m_AllQuestionInfo.value("questionInfos").toArray();
        qDebug() << "********m_QuestionInfo*********" << m_QuestionInfo;

        m_totalQuestion = m_QuestionInfo.size();
        m_currentQuestionIndex = 0;

        qDebug() << "======m_totalQuestion=======" << m_totalQuestion;
        //emit sigQuestionInfo(questionInfoObj);
        //m_currentQuestionIndex++;
        if(m_QuestionInfo.size() > 1)
        {
            qDebug() << "emit sigShowPage(m_menuCurrentIndex,m_menuTotal); 2";
            emit sigShowPage(1, m_totalQuestion);
        }
        //QString questionIds = questionInfoObj.value("id").toString();
        //emit sigTopicId(questionIds);
        return;
    }
    //}
}

QJsonArray YMCloudClassManagerAdapter::getColumnItemNumber(QString planId, QString columnId)
{
    QJsonArray itemArrays;
    for(int a = 0 ; a < allNewCoursewarwList.size(); a++)
    {
        QJsonObject obj = allNewCoursewarwList.at(a);

        QString tempPlanId = QString::number( obj.take("planId").toInt());
        //判断课件ID是否相同
        if( planId == tempPlanId )
        {
            // qDebug()<<"YMCloudClassManagerAdapter::getColumnItemNumber planid";
            //判断栏目ID是否相同
            QJsonArray itemArray = obj.take("items").toArray();

            for(int a = 0 ; a < itemArray.size(); a++)
            {
                QString tempItemId = QString::number( itemArray.at(a).toObject().value("itemId").toInt());
                int tempItemType = itemArray.at(a).toObject().value("itemType").toInt();
                if(columnId == tempItemId)
                {
                    //qDebug()<<tempItemType<<tempItemId<<"YMCloudClassManagerAdapter::getColumnPageData(";
                    //判断发送那种信号
                    if(tempItemType == 0)
                    {
                        itemArrays = itemArray.at(a).toObject().take("resourceContents").toArray();
                        //qDebug()<<"YMCloudClassManagerAdapter::getColumnItemNumber  tempItemType == 0 "<<itemArrays<<itemArrays.size();
                        return  itemArrays;
                    }
                    if(tempItemType == 1)
                    {
                        itemArrays = itemArray.at(a).toObject().take("questionInfos").toArray();
                        return  itemArrays;
                    }
                    if(tempItemType == 2)
                    {
                        itemArrays = itemArray.at(a).toObject().take("questionInfos").toArray();
                        return  itemArrays;
                    }
                }
            }

        }
    }
    return  itemArrays;
}

QJsonObject YMCloudClassManagerAdapter::getCurrentItemBaseImage(QJsonObject dataObjecte, int index)
{
    /* dataObjecte 的数据
    "content": {
        "pageIndex": "5",//页索引
        "planId": 34343,//讲义ID
        "columnId": 1//栏目ID
    }
    */

    qDebug() << "YMCloudClassManagerAdapter::getCurrentItemBaseImagessssssssss" << dataObjecte << allNewCoursewarwList.size() << index;
    QJsonArray itemArrays;
    QString planId ;
    QString columnId;
    QString pageIndex;

    planId = dataObjecte.value("planId").toString();
    if(!dataObjecte.value("planId").isString())
    {
        planId = QString::number(dataObjecte.value("planId").toInt());
    }

    columnId = dataObjecte.value("columnId").toString();
    if(!dataObjecte.value("columnId").isString())
    {
        columnId = QString::number(dataObjecte.value("columnId").toInt());
    }

    //    pageIndex = dataObjecte.value("pageIndex").toString();
    //    if(!dataObjecte.value("pageIndex").isString())
    //    {
    //        pageIndex = QString::number(dataObjecte.value("pageIndex").toInt());
    //    }

    pageIndex = QString::number(index);

    for(int a = 0 ; a < allNewCoursewarwList.size(); a++)
    {
        QJsonObject obj = allNewCoursewarwList.at(a);

        QString tempPlanId = QString::number( obj.take("planId").toInt());
        //判断课件ID是否相同
        if( planId == tempPlanId )
        {

            //判断栏目ID是否相同
            QJsonArray itemArray = obj.take("items").toArray();

            for(int a = 0 ; a < itemArray.size(); a++)
            {
                QString tempItemId = QString::number( itemArray.at(a).toObject().value("itemId").toInt());
                int tempItemType = itemArray.at(a).toObject().value("itemType").toInt();
                if(columnId == tempItemId)
                {
                    qDebug() << planId << tempItemType << tempItemId << "YMCloudClassManagerAdapter::getCurrentItemBaseImage(sssssss";
                    //判断发送那种信号
                    if(tempItemType == 0)
                    {
                        itemArrays = itemArray.at(a).toObject().take("resourceContents").toArray();
                        if(itemArrays.size() - 1  >= pageIndex.toInt())
                        {
                            if(itemArrays.at(pageIndex.toInt()).toObject().value("baseImage").isNull() == false)
                            {
                                return itemArrays.at(pageIndex.toInt()).toObject().value("baseImage").toObject();
                            }
                        }

                    }
                    else if(tempItemType == 1 || tempItemType == 2 )
                    {
                        itemArrays = itemArray.at(a).toObject().take("questionInfos").toArray();
                        // qDebug()<<"YMCloudClassManagerAdapter::getCurrentItemBaseImage("<<itemArrays.size()<<pageIndex.toInt()<<itemArrays.at(pageIndex.toInt()).toObject().value("baseImage")<<itemArrays.at(pageIndex.toInt()).toObject().value("baseImage").isNull();
                        if(itemArrays.size() - 1  >= pageIndex.toInt())
                        {
                            if(itemArrays.at(pageIndex.toInt()).toObject().value("baseImage").isNull() == false)
                            {
                                StudentData::gestance()->m_currentQuestionData = itemArrays.at(pageIndex.toInt()).toObject();
                                return itemArrays.at(pageIndex.toInt()).toObject().value("baseImage").toObject();
                            }
                        }
                    }
                }
            }
        }
    }
    qDebug() << "wqwwwwwwwwwwwwwww1111111111";
    QJsonObject obj;
    return  obj;
}
