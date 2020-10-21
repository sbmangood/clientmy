﻿#include "resetipsettingfile.h"
#include "./miniClass/YMEncryption.h"


ResetIpSettingFile::ResetIpSettingFile(QObject *parent) : QObject(parent)
{
    m_httpClint = YMHttpClient::defaultInstance();
}
ResetIpSettingFile::~ResetIpSettingFile()
{

}

//请求云服务器的ip地址
void ResetIpSettingFile::resetIpFile(QString backData)
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
    if(QFile::exists(fileName) == false)
    {
        return;
    }

    QString selectIp;
    QSettings * m_settings = new QSettings (fileName, QSettings ::IniFormat);

    m_settings->beginGroup("SelectItem");
    selectIp = m_settings->value("ipitem").toString();
    m_settings->endGroup();

    if(selectIp == "")
    {
        QFile::remove(fileName);
        return;
    }


    QStringList listIndor = backData.split("###");
    QString backDataOne;

    if(listIndor.size() == 2)
    {
        backDataOne = listIndor[1];
    }

    QJsonParseError errors;
    QJsonDocument documets = QJsonDocument::fromJson(backDataOne.toUtf8(), &errors);
    if(errors.error == QJsonParseError::NoError)
    {
        if(documets.isObject())
        {
            QJsonObject jsonObjsa = documets.object();

            m_httpAccessmanger = new QNetworkAccessManager(this);
            QEventLoop loop;
            QTimer::singleShot(5000, &loop, SLOT(quit()));
            connect(m_httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));
            QNetworkRequest httpRequest;

            QUrl url("http://" + StudentData::gestance()->apiUrl + "/server/getCloudServerList?");

            QDateTime times = QDateTime::currentDateTime();
            QMap<QString, QString> maps;
            maps.insert("userId", jsonObjsa.take("id").toString()); //"900000386"
            maps.insert("apiVersion", jsonObjsa.take("apiVersion").toString());
            maps.insert("appVersion", jsonObjsa.take("appVersion").toString());
            maps.insert("token", jsonObjsa.take("token").toString());
            maps.insert("timestamp", times.toString("token"));

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

            httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
            httpRequest.setUrl(url);
            QNetworkReply *reply =  m_httpAccessmanger->post(httpRequest, urls.toUtf8()); //通过发送数据，返回值保存在reply指针里.
            loop.exec();
            QString data = reply->readAll();
            QStringList m_addressList;
            if(data.contains(selectIp))
            {
                //重设 文件
                QJsonParseError error;
                QJsonDocument documet = QJsonDocument::fromJson(data.toUtf8(), &error);
                if(error.error == QJsonParseError::NoError)
                {
                    if(documet.isObject())
                    {
                        QJsonObject jsonObj = documet.object();
                        if(jsonObj.contains("data"))
                        {
                            QJsonObject datas = jsonObj.take("data").toObject();
                            if(datas.contains("serverList"))
                            {
                                QJsonArray  emotions = datas.take("serverList").toArray();
                                foreach(QJsonValue emotion, emotions )
                                {
                                    QString address  =  emotion.toString();
                                    m_addressList.append(address);
                                }
                            }
                        }
                    }
                }
                m_settings->clear();
                for(int i = 0 ; i < m_addressList.count() ; i++ )
                {
                    //qDebug()<<m_addressList.at(i);
                    m_settings->beginGroup("ItemLost");
                    m_settings->setValue(m_addressList.at(i), "");
                    m_settings->endGroup();
                    m_settings->beginGroup("ItemDelay");
                    m_settings->setValue(m_addressList.at(i), "");
                    m_settings->endGroup();
                }
                m_settings->beginGroup("SelectItem");
                m_settings->setValue("ipitem", selectIp);
                m_settings->endGroup();
            }
            else
            {
                QFile::remove(fileName);
            }

        }
    }
}
//手动线路切换 改为自动ip切换
void ResetIpSettingFile::getGoodIplist(QString backData)
{
    //删除ip配置文件  为了其他ip的延迟信息
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

    //修改自动切换IP之后添加的代码******
    QFile::remove(fileName);

    //获取并存储优选Ip列表
    QStringList listIndor = backData.split("###");
    QString backDataOne;

    if(listIndor.size() == 2)
    {
        backDataOne = listIndor[1];
    }

    QJsonParseError errors;
    QJsonDocument documets = QJsonDocument::fromJson(backDataOne.toUtf8(), &errors);
    QJsonObject jsonObjsa = documets.object();
    QString url = YMUserBaseInformation::miniUrl + QString("/marketing/app/api/s/agora/ip/list?");
    m_httpAccessmanger = new QNetworkAccessManager(this);
    QEventLoop loop;
    QTimer::singleShot(5000, &loop, SLOT(quit()));
    connect(m_httpAccessmanger, SIGNAL(finished(QNetworkReply*)), &loop, SLOT(quit()));
    QNetworkRequest httpRequest;
    httpRequest.setHeader(QNetworkRequest::ContentTypeHeader, "Content-Type:application/x-www-form-urlencoded");
    httpRequest.setRawHeader("X-AUTH-TOKEN",jsonObjsa.take("token").toString().toLocal8Bit());
    httpRequest.setUrl(QUrl(url));
    QNetworkReply *reply =  m_httpAccessmanger->get(httpRequest);//通过发送数据，返回值保存在reply指针里.
    loop.exec();
    QString data = reply->readAll();

     QJsonDocument documet = QJsonDocument::fromJson(data.toUtf8());
     if(!documet.isEmpty() && !documet.isNull()){
        QJsonObject jsonObj = documet.object();
        QJsonObject childObj = jsonObj.value("data").toObject();
        QJsonArray  dataArray = childObj.value("ipList").toArray();
        TemporaryParameter::gestance()->m_ipList =  dataArray;
     }

}
