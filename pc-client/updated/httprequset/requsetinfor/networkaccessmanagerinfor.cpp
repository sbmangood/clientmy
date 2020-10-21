#include "networkaccessmanagerinfor.h"

NetworkAccessManagerInfor::NetworkAccessManagerInfor(QObject *parent) : QObject(parent)
    , m_accessManager(NULL)
    , m_accessManagerVideo(NULL)
    , m_accessManagerGif(NULL)
{

    m_accessManager = new QNetworkAccessManager(this);
    connect(m_accessManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(replyFinished(QNetworkReply*)));

    m_accessManagerVideo = new QNetworkAccessManager(this);
    connect(m_accessManagerVideo, SIGNAL(finished(QNetworkReply*)), this, SLOT(replyVideoFinished(QNetworkReply*)));

    m_accessManagerGif = new QNetworkAccessManager(this);
    connect(m_accessManagerGif, SIGNAL(finished(QNetworkReply*)), this, SLOT(replyGifFinished(QNetworkReply*)));

    connect(this, SIGNAL(sigGifUrlPathName(QString )), this, SLOT(onSigGifUrlPathName(QString ))  );
    connect(this, SIGNAL(sigCoursewareName(QString )), this, SLOT(onSigCoursewareName(QString ))  );
    connect(this, SIGNAL(sigVideoName(QString )), this, SLOT(onSigVideoName(QString ))  );

}

NetworkAccessManagerInfor::~NetworkAccessManagerInfor()
{
    if(m_accessManager != NULL)
    {
        disconnect(m_accessManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(replyFinished(QNetworkReply*)));
        delete m_accessManager;
    }
    if(m_accessManagerVideo != NULL)
    {
        disconnect(m_accessManagerVideo, SIGNAL(finished(QNetworkReply*)), this, SLOT(replyVideoFinished(QNetworkReply*)));
        delete m_accessManagerVideo;
    }
    if(m_accessManagerGif != NULL)
    {
        disconnect(m_accessManagerGif, SIGNAL(finished(QNetworkReply*)), this, SLOT(replyGifFinished(QNetworkReply*)));
        delete m_accessManagerGif;
    }
}

//获得登录信息
void NetworkAccessManagerInfor::getLoginInfor(QString name, QString pwd)
{
    QDateTime times = QDateTime::currentDateTime();

    QMap<QString, QString> maps;
    maps.insert("userId", "105479");
    maps.insert("lessonId", "331255");
    maps.insert("type", "TEA");
    maps.insert("apiVersion", "2.4");
    maps.insert("appVersion", "1.0.0");
    maps.insert("token", "6d499b20858b00790af7b7dd0a3a5fd7");
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
    urls.append("&sign=").append(QCryptographicHash::hash(sign.toLatin1(), QCryptographicHash::Md5).toHex().toUpper());
    QUrl url("http://" + StudentData::gestance()->apiUrl + "/lesson/getStuLessonDocList?");
    QByteArray post_data;//上传的数据可以是QByteArray或者file类型
    QString str = urls;

    post_data.append(str);

    m_request.setHeader(QNetworkRequest::ContentLengthHeader, post_data.length());
    m_request.setUrl(url);
    m_reply = m_accessManager->post(m_request, post_data); //通过发送数据，返回值保存在reply指针里.

}

void NetworkAccessManagerInfor::getCoursewareName(QMap<QString, QString> maps)
{

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
    urls.append("&sign=").append(QCryptographicHash::hash(sign.toLatin1(), QCryptographicHash::Md5).toHex().toUpper());
    QUrl url("http://" + StudentData::gestance()->apiUrl + "/lesson/getStuLessonDocList?");
    QByteArray post_data;//上传的数据可以是QByteArray或者file类型
    QString str = urls;

    post_data.append(str);

    m_request.setHeader(QNetworkRequest::ContentLengthHeader, post_data.length());
    m_request.setUrl(url);
    m_reply = m_accessManager->post(m_request, post_data); //通过发送数据，返回值保存在reply指针里.
}

void NetworkAccessManagerInfor::getVideoName(QMap<QString, QString> maps)
{
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
    urls.append("&sign=").append(QCryptographicHash::hash(sign.toLatin1(), QCryptographicHash::Md5).toHex().toUpper());
    QUrl url("http://" + StudentData::gestance()->apiUrl + "/lesson/getMediaList?");
    QByteArray post_data;//上传的数据可以是QByteArray或者file类型
    QString str = urls;

    post_data.append(str);

    m_requestVideo.setHeader(QNetworkRequest::ContentLengthHeader, post_data.length());
    m_requestVideo.setUrl(url);
    m_replyVideo = m_accessManagerVideo->post(m_requestVideo, post_data); //通过发送数据，返回值保存在reply指针里.

}

void NetworkAccessManagerInfor::getGifName(QString names)
{
    QUrl url("http://" + StudentData::gestance()->apiUrl + "/version/getEmotion?");
    QByteArray post_data;//上传的数据可以是QByteArray或者file类型
    QString str = names;

    post_data.append(str);

    m_requestGif.setHeader(QNetworkRequest::ContentLengthHeader, post_data.length());
    m_requestGif.setUrl(url);
    m_replyGif = m_accessManagerGif->post(m_requestGif, post_data); //通过发送数据，返回值保存在reply指针里.

}
//获得gif的路径
QList<QString> NetworkAccessManagerInfor::getGifUrlPath(int nums)
{
    QString str = QString("%1").arg(nums + 1 );

    QList<QString>  list;
    QMap<int, QString> listMNap = m_gifUrlPath.value(str, QMap<int, QString> ());
    QMap<int, QString>::iterator it =  listMNap.begin();
    for( ; it != listMNap.end() ; it++)
    {
        list.append(it.value() );
    }

    return list;

}

void NetworkAccessManagerInfor::getCoursewareNameInfor()
{
    QDateTime times = QDateTime::currentDateTime();
    QMap<QString, QString> maps;
    maps.insert("userId", StudentData::gestance()->m_teacher.m_teacherId);
    maps.insert("lessonId", StudentData::gestance()->m_lessonId);
    maps.insert("type", "TEA");
    maps.insert("apiVersion", StudentData::gestance()->m_apiVersion);
    maps.insert("appVersion", StudentData::gestance()->m_appVersion);
    maps.insert("token", StudentData::gestance()->m_token);
    maps.insert("timestamp", times.toString("yyyyMMddhhmmss"));
    getCoursewareName(maps);


}
//发送课程信息
void NetworkAccessManagerInfor::sendCoursewareNameInfor(QString names)
{
    QList<QString> lists =  m_coursewareName.value(names);
    QString strName =  m_coursewareNameIndex.value(names);

    QJsonObject json;
    json.insert("command", QString("courware"));
    json.insert("domain", QString("draw"));

    QJsonObject json1;
    json1.insert("docId", strName);
    json1.insert("pageIndex", QString("%1").arg( TemporaryParameter::gestance()->m_pageSave.value(strName, 1) ));

    QJsonArray json2;
    for(int jk = 0 ; jk < lists.count() ; jk++)
    {
        json2.append(QString("http://" + StudentData::gestance()->apiUrl + "/lesson/viewStuLessonDoc?userId=%1&docId=%2").arg(StudentData::gestance()->m_teacher.m_teacherId).arg(lists[jk]));
    }
    json1.insert("urls", json2);
    json.insert("content", json1);
    //QJsonObject json3;


    QJsonDocument documents;
    documents.setObject(json);
    QString str(documents.toJson(QJsonDocument::Compact));

    emit sigSendCoursewareNameInfor(str);
}
//视频课件获得信息
void NetworkAccessManagerInfor::getVideoNameInfor()
{
    QDateTime times = QDateTime::currentDateTime();
    QMap<QString, QString> maps;
    maps.insert("userId", StudentData::gestance()->m_teacher.m_teacherId);
    maps.insert("lessonId", StudentData::gestance()->m_lessonId);
    maps.insert("type", "TEA");
    maps.insert("apiVersion", StudentData::gestance()->m_apiVersion);
    maps.insert("appVersion", StudentData::gestance()->m_appVersion);
    maps.insert("token", StudentData::gestance()->m_token);
    maps.insert("timestamp", times.toString("yyyyMMddhhmmss"));
    getVideoName(maps);

}
//设置视频文件名称
void NetworkAccessManagerInfor::setFileUrlName()
{
    m_fileUrlName.clear();

    QStringList userLists;


    QMultiMap<QString, QString>::iterator ita = m_lessonfileUrl.begin();

    for(; ita != m_lessonfileUrl.end() ; ita++)
    {
        m_fileUrlName.insert(ita.key(), ita.value() ) ;
        userLists << ita.key();
    }

    QMultiMap<QString, QPair<QString, QString> >::iterator itb = m_docfileUrl.begin();
    for(; itb != m_docfileUrl.end() ; itb++)
    {
        if(TemporaryParameter::gestance()->m_currentCourse == itb.key())
        {
            m_fileUrlName.insert(itb.value().first, itb.value().second);
            userLists << itb.value().first;
        }
    }
    QMultiMap<QString, QPair<QString, QPair<QString, QString> > >::iterator itc = m_pagefileUrl.begin();
    for(; itc != m_pagefileUrl.end() ; itc++)
    {
        if(TemporaryParameter::gestance()->m_currentCourse == itc.key())
        {
            if(TemporaryParameter::gestance()->m_pageNo == itc.value().first.toInt() )
            {
                m_fileUrlName.insert(itc.value().second.first, itc.value().second.second);
                userLists << itc.value().second.first;
            }
        }
    }

    emit sigSendVideoNameInfor(userLists);


}
//获得视频的url
QString NetworkAccessManagerInfor::getVideoFileUrlName(QString names)
{
    QString str = m_fileUrlName.value(names, "");
    return str;

}



void NetworkAccessManagerInfor::replyFinished(QNetworkReply *)
{
    QVariant status_code = m_reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);

    //无错误返回
    if(m_reply->error() == QNetworkReply::NoError)
    {

        QByteArray bytes = m_reply->readAll();
        QString result(bytes);  //转化为字符串
        emit sigCoursewareName(result);

    }
    else
    {
        //处理错误
        // download_Btn->setText("failed");
    }

    m_reply->deleteLater();//要删除reply，但是不能在repyfinished里直接delete，要调用deletelater;


}

void NetworkAccessManagerInfor::replyVideoFinished(QNetworkReply *)
{
    QVariant status_code = m_replyVideo->attribute(QNetworkRequest::HttpStatusCodeAttribute);

    //无错误返回
    if(m_replyVideo->error() == QNetworkReply::NoError)
    {

        QByteArray bytes = m_replyVideo->readAll();
        QString result(bytes);  //转化为字符串
        emit sigVideoName(result);

    }
    else
    {
        //处理错误
        // download_Btn->setText("failed");
    }

    m_replyVideo->deleteLater();//要删除reply，但是不能在repyfinished里直接delete，要调用deletelater;


}

void NetworkAccessManagerInfor::replyGifFinished(QNetworkReply *)
{
    if(m_replyGif->error() == QNetworkReply::NoError)
    {

        QByteArray bytes = m_replyGif->readAll();
        QString result(bytes);  //转化为字符串
        emit sigGifUrlPathName(result);

    }
    else
    {
        //处理错误
        // download_Btn->setText("failed");
    }

    m_replyGif->deleteLater();//要删除reply，但是不能在repyfinished里直接delete，要调用deletelater;

}
//处理返回的数据
void NetworkAccessManagerInfor::onSigGifUrlPathName(QString contents)
{
    QMap<QString, QMap<int, QString> >::iterator it = m_gifUrlPath.begin();
    for( ; it != m_gifUrlPath.end() ; it++)
    {
        it.value().clear();
    }
    m_gifUrlPath.clear();
    m_gifUrlPathName.clear();

    QJsonParseError error;
    QJsonDocument documet = QJsonDocument::fromJson(contents.toUtf8(), &error);
    if(error.error == QJsonParseError::NoError)
    {
        if(documet.isObject())
        {
            QJsonObject jsonObj = documet.object();
            if(jsonObj.contains("data"))
            {
                QJsonObject datas = jsonObj.take("data").toObject();
                if(datas.contains("emotions"))
                {
                    QJsonArray  emotions = datas.take("emotions").toArray();
                    foreach(QJsonValue emotion, emotions )
                    {
                        QString groupId  =  emotion.toObject().take("groupId").toString();
                        QJsonArray ets = emotion.toObject().take("ets").toArray();
                        QMap<int, QString> idurl;
                        foreach (QJsonValue et, ets)
                        {
                            int id = et.toObject().take("id").toInt();
                            QString url =  et.toObject().take("url").toString();
                            idurl.insert(id, url);
                            m_gifUrlPathName.append(url + "_pad.gif");
                            m_gifUrlPathName.append(url + ".png");
                        }
                        m_gifUrlPath.insert(groupId, idurl);
                    }
                }
            }

        }
    }
    emit sigSenGroundNum(m_gifUrlPath.count() );

}
//处理课件信息
void NetworkAccessManagerInfor::onSigCoursewareName(QString infor)
{
    QMap<QString, QList<QString> >::iterator it =  m_coursewareName.begin();
    for(; it != m_coursewareName.end(); it++)
    {
        it.value().clear();
    }
    m_coursewareName.clear();
    m_coursewareNameList.clear();
    m_coursewareNameIndex.clear();
    QJsonParseError error;
    QJsonDocument documet = QJsonDocument::fromJson(infor.toUtf8(), &error);
    if(error.error == QJsonParseError::NoError)
    {
        if(documet.isObject())
        {
            QJsonObject jsonObj = documet.object();
            if(jsonObj.contains("data"))
            {
                QJsonArray datas = jsonObj.take("data").toArray();
                foreach (QJsonValue data, datas)
                {
                    QList<QString> listStr;
                    listStr.clear();
                    QString strName;
                    QString strContent;
                    strName =  data.toObject().take("docName").toString();
                    strContent = QString("%1").arg( data.toObject().take("docId").toInt());
                    QJsonArray childDocs = data.toObject().take("childDocs").toArray();

                    m_coursewareNameIndex.insert(strName, strContent);
                    foreach (QJsonValue childDoc, childDocs)
                    {
                        QString childDocName;
                        childDocName =  QString("%1").arg( childDoc.toObject().take("docId").toInt() );
                        listStr.append(childDocName);
                    }
                    m_coursewareName.insert(strName, listStr);
                    m_coursewareNameList.append(strName);

                }
            }

        }

    }
    TemporaryParameter::gestance()->m_coursewareName = m_coursewareName;

    emit sigCoursewareNameList(m_coursewareNameList);
}
//处理视频课件
void NetworkAccessManagerInfor::onSigVideoName(QString infor)
{
    m_lessonfileUrl.clear();

    m_docfileUrl.clear();
    m_pagefileUrl.clear();

    QJsonParseError error;
    QJsonDocument documet = QJsonDocument::fromJson(infor.toUtf8(), &error);
    if(error.error == QJsonParseError::NoError)
    {
        if(documet.isObject())
        {
            QJsonObject jsonObj = documet.object();
            if(jsonObj.contains("data"))
            {
                QJsonArray datas = jsonObj.take("data").toArray();
                foreach (QJsonValue data, datas)
                {
                    QString mediaType  =  data.toObject().take("mediaType").toString();
                    QString fileUrl  =  data.toObject().take("fileUrl").toString();
                    QString docFid  = QString("%1").arg( data.toObject().take("docFid").toInt() );
                    QString pageNo  =  QString("%1").arg(data.toObject().take("pageNo").toInt() );
                    QString docId  = QString("%1").arg( data.toObject().take("docId").toInt() );
                    QString docName  =  data.toObject().take("docName").toString();

                    if(mediaType.contains("LESSON"))
                    {
                        m_lessonfileUrl.insert(docName, fileUrl);
                    }
                    if(mediaType.contains("DOC"))
                    {
                        QPair<QString, QString> pair;
                        pair.first = docName;
                        pair.second =  fileUrl;
                        m_docfileUrl.insert(docFid, pair);
                    }
                    if(mediaType.contains("PAGE"))
                    {
                        QPair<QString, QString> pair;
                        pair.first = docName;
                        pair.second =  fileUrl;
                        QPair<QString, QPair<QString, QString> > pairs;
                        pairs.first = pageNo;
                        pairs.second = pair;
                        m_pagefileUrl.insert(docFid, pairs);
                    }

                }
            }

        }

    }

    setFileUrlName();

}

