#include "yimibreakpad.h"
#include <tchar.h>
#include <QDateTime>
#include<QFile>
#include<QDir>
#include<QStandardPaths>
#include<QCoreApplication>
#include<QSettings>
#include<QNetworkReply>
#include<QNetworkRequest>
#include<QNetworkInterface>
#include<QTextCodec>
#include <QJsonObject>
#include <QJsonDocument>
#include "client/windows/crash_generation/crash_generation_server.h"
#include "client/windows/handler/exception_handler.h"
#include "client/windows/crash_generation/client_info.h"
#include "HttpUploader.h"
using namespace google_breakpad;
namespace  yimi_fudao_breakpad{
const wchar_t kPipeName[] = L"\\\\.\\pipe\\BreakpadCrashServices\\TestServer";
static google_breakpad::ExceptionHandler* handler_client = NULL;
static google_breakpad::CrashGenerationServer* crash_server = NULL;
static HttpClient* http_client = NULL;
static QString push_url = "https://galaxy.yimifudao.com/client";
static const int kMaxLength = 256;

void ShowClientConnected(void* context,const ClientInfo* client_info){

    google_breakpad::ClientInfo* temp = const_cast<google_breakpad::ClientInfo*>(client_info);
    if(!temp->PopulateCustomInfo())
        qDebug()<<"PopulateCustomInfo failed";
    qDebug()<<"onClientConnected";
    //取自定用户信息
    google_breakpad::CustomClientInfo custom_info = client_info->GetCustomInfo();
    QStringList nameList;
    QStringList valueList;
    QJsonObject msgData;
    QJsonObject baseData;
    for(uint i =0; i<custom_info.count;i++){
        nameList<<QString::fromWCharArray(custom_info.entries[i].name);
        valueList<<QString::fromWCharArray(custom_info.entries[i].value);
        qDebug()<<QString::fromWCharArray(custom_info.entries[i].name)<<QString::fromWCharArray(custom_info.entries[i].value);
    }

    for(int i =0;i < nameList.count();i++){
        if(nameList.at(i)== "token" || nameList.at(i)== "apiVersion" || nameList.at(i)== "ptime"){
            if( nameList.at(i)== "ptime"){
                continue;
            }else{
                ((Yimibreakpad*)context)->para_map_.insert(nameList.at(i),valueList.at(i));
            }

        } else {
            baseData.insert(nameList.at(i),valueList.at(i));
        }

    }
    QString user_name = "_" + baseData.value("userName").toString();
    ((Yimibreakpad*)context)->para_map_.insert("lessonId",baseData.value("lessonId").toString() + user_name);
    ((Yimibreakpad*)context)->para_map_.insert("appVersion",baseData.value("appVersion").toString());

    baseData.insert("crashTime",QDateTime::currentMSecsSinceEpoch());
    baseData.insert("actionTime",QDateTime::currentMSecsSinceEpoch());
    ((Yimibreakpad*)context)->post_data_.insert("msgType","crash");
    ((Yimibreakpad*)context)->post_data_.insert("data",baseData);
    qDebug()<<"ShowClientConnected"<<((Yimibreakpad*)context)->post_data_;


}
void ShowClientCrashed(void* context,const ClientInfo* client_info,const std:: wstring* dump_path){
    qDebug()<<"ShowClientCrashed";
    ((Yimibreakpad*)context)->dump_path_ = dump_path->c_str();
    ((Yimibreakpad*)context)->is_crash_ = true;


}
void ShowClientExited(void* context,const ClientInfo* client_info){

    if(((Yimibreakpad*)context)->is_crash_){

        QJsonDocument tempDoc ;
        tempDoc.setObject(((Yimibreakpad*)context)->post_data_);
        QString  post_data =  tempDoc.toJson(QJsonDocument::Compact);
        emit ((Yimibreakpad*)context)->sigPingback(push_url,post_data.toUtf8());
        emit ((Yimibreakpad*)context)->sigUploadDump();
        ((Yimibreakpad*)context)->is_crash_ = false;

    }


}
HttpClient::HttpClient(QObject *parent) : QObject(parent){
    m_accessManager = new QNetworkAccessManager(this);
    QObject::connect(m_accessManager, SIGNAL(finished(QNetworkReply *)), this, SLOT(onFinished(QNetworkReply *)));

}

void HttpClient::requestPost(const QString &url, const QByteArray &data){
    qDebug()<<"UrlRequestPost"<<data;
    const QUrl aurl(url);
    QNetworkRequest qnr(aurl);
    qnr.setRawHeader("Content-Type","application/json");
    QSslConfiguration conf = qnr.sslConfiguration();
    conf.setPeerVerifyMode(QSslSocket::VerifyNone);
    conf.setProtocol(QSsl::TlsV1SslV3);
    qnr.setSslConfiguration(conf);
    m_accessManager->post(qnr,data);
   // qDebug()<<"requestPost"<<url;

}

void HttpClient::onFinished(QNetworkReply *reply){
    QString  replydata ="Error";
    //无错误返回
    if(reply->error() == QNetworkReply::NoError){
        QTextCodec *codec = QTextCodec::codecForName("utf8");
        if(NULL!=codec)
           replydata = codec->toUnicode(reply->readAll());
        qDebug()<<"QNetworkReply::NoError"<<replydata;

    } else {
        qDebug()<<"QNetworkReply::Error"<<replydata;

    }
    reply->deleteLater();

}

Yimibreakpad::Yimibreakpad(QObject *parent) : QObject(parent){
     http_client =  new  HttpClient();
     push_url  =GetPushUrl();
     is_crash_ = false;
     QObject::connect(this, SIGNAL(sigPingback(const QString , const QByteArray)), this, SLOT(onSigPingback(const QString , const QByteArray)));
     QObject::connect(this, SIGNAL(sigUploadDump()), this, SLOT(onSigUploadDump()));
}
void Yimibreakpad::onSigPingback(const QString &url, const QByteArray &data){
     http_client->requestPost(url,data);
}

void Yimibreakpad::onSigUploadDump(){

    QDateTime times = QDateTime::currentDateTime();
    para_map_.insert("timestamp", times.toString("yyyyMMddhhmmss"));
    QString sign;
    QString urls;
    QMap<QString, QString>::iterator it =para_map_.begin();
    for(int i = 0; it != para_map_.end();it++,i++){
        if(i == 0){
            sign.append(it.key());
            sign.append("=" + it.value());
        } else {
            sign.append("&" + it.key());
            sign.append("=" + it.value());
        }
    }
    urls.append(sign);
    urls.append("&sign=").append(QCryptographicHash::hash(sign.toUtf8(), QCryptographicHash::Md5).toHex().toUpper());
    QString httpsd = "http://" + api_url_ + "/log/logUpload?" + QString("%1").arg(urls);
    const QUrl url(httpsd);
    std::wstring dump_path = dump_path_;
    dump_path = dump_path.substr(0,dump_path.find_last_of(L"\\"));
    QString tmp_dump_path = QString::fromStdWString(dump_path);
    qDebug()<<"ShowClientExited"<<tmp_dump_path;
    if(!tmp_dump_path.isNull() && !tmp_dump_path.isEmpty()) {
        QDir dumpDir(tmp_dump_path);
        dumpDir.setNameFilters(QStringList()<<"*.dmp");
        QStringList dumpFiles = dumpDir.entryList();
        qDebug()<<"#####dumpFiles#####"<<dumpFiles;

        foreach(QString itDmpFileName, dumpFiles) {
            qDebug() << "Sending " << QString(itDmpFileName);
            HttpUploader *sender = new HttpUploader(url);
            sender->uploadDump(tmp_dump_path + "\\" + itDmpFileName);
        }
    }

}

QString Yimibreakpad::GetPushUrl(){

    QString  pushurl = "https://galaxy.yimifudao.com/client";
    if(!QFile::exists("Qtyer.dll")){
        pushurl = "https://galaxy.yimifudao.com/client";
    }
    QSettings * m_setting = new QSettings("Qtyer.dll", QSettings::IniFormat);
    // 环境类型  测试环境:0  正式环境:1 手动配置
    m_setting->beginGroup("EnvironmentType");
    int environmentType = m_setting->value("type").toInt();
    m_setting->endGroup();
    m_setting->beginGroup("V2.4");
    m_setting->endGroup();
    if(environmentType == 1){
        pushurl = "https://galaxy.yimifudao.com/client";
        m_setting->beginGroup("V2.4");
        api_url_ = m_setting->value("formal").toString();//, "api.yimifudao.com/v2.4"
        m_setting->endGroup();

    }else{
        pushurl = "https://galaxy-test.yimifudao.com/client";
        m_setting->beginGroup("V2.4");
        api_url_ = m_setting->value("stage").toString();//stage-api.yimifudao.com/v2.4
        m_setting->endGroup();
    }
    qDebug()<<"###########GetPushUrl()################"<<pushurl;
    return pushurl;
}

void Yimibreakpad::monitorProcessServer(){
    if (crash_server) {
        return;
    }
    std::wstring dump_path = L"C:\\Dumps\\";
    CreateDirectory(dump_path.c_str(),NULL);
    QDateTime current_date_time =QDateTime::currentDateTime();
    QString current_date =current_date_time.toString("yyyy-MM-dd");
    dump_path+=current_date.toStdWString();

    if (_wmkdir(dump_path.c_str()) && (errno != EEXIST)) {
        return;
    }
    crash_server = new CrashGenerationServer(kPipeName,
            NULL,
            ShowClientConnected,
            this,
            ShowClientCrashed,
            this,
            ShowClientExited,
            this,
            NULL,
            NULL,
            true,
            &dump_path);
        if (!crash_server->Start()){
            delete crash_server;
            crash_server = NULL;
        }

}

void Yimibreakpad::monitorProcessClient(const std::map<std::wstring,std::wstring> &base_info){
    std::list<CustomInfoEntry> list_cumtom;
    std::map<std::wstring,std::wstring>::const_iterator iter = base_info.begin();
    for(;iter !=base_info.end();iter++){
        CustomInfoEntry custom_info_entry;
        custom_info_entry.set_name((iter->first).c_str());
        custom_info_entry.set_value((iter->second).c_str());
        list_cumtom.push_back(custom_info_entry);

    }
    auto  count = list_cumtom.size();
    CustomInfoEntry custom_info_entries[kMaxLength];
    auto i=0;
    for(std::list<CustomInfoEntry>::const_iterator iter = list_cumtom.begin();iter != list_cumtom.end();iter++){
        custom_info_entries[i++]= *iter;
    }

    CustomClientInfo custom_info = {custom_info_entries,count};
    handler_client = new ExceptionHandler(L"",
               NULL,
               NULL,
               NULL,
               ExceptionHandler::HANDLER_ALL,
               MiniDumpNormal,
               kPipeName,
               &custom_info);

}

void Yimibreakpad::cleanUp(){
    if (handler_client){
        delete handler_client;
    }
    if (crash_server){
        delete crash_server;
    }
    if (http_client){
        delete http_client;
    }
}
}
