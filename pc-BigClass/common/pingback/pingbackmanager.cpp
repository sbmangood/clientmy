#include "PingbackManager.h"
#include "galaxy_message.pb.h"
#include<QFile>
#include<QDir>
#include<QStandardPaths>
#include<QCoreApplication>
#include<QSettings>
#include<QNetworkReply>
#include<QNetworkRequest>
#include<QNetworkInterface>
#include<QSysInfo>
#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
#include <QTextCodec>
#include <QUuid>
#include <QTimer>
#include <QJsonDocument>
using namespace std;
namespace yimipingback {


PingbackManager::PingbackManager(QObject *parent) : QObject(parent){

   company_ = "";
   business_="";
   appversion_="";
   uid_="";
   user_type_="";
   pushurl_ = GetPushUrl();
   session_id_ =GetSessionId();
   uuid_ = GetUuid();
   os_version_=GetOsVersion();
   net_type_ = GetCurrentNetWorkType();
   device_info_ = GetDeviceInfo();
   operator_type_ = GetOperatorType();
   m_accessManager = new QNetworkAccessManager(this);
   connect(m_accessManager, SIGNAL(finished(QNetworkReply *)), this, SLOT(replyFinished(QNetworkReply *)));
   connect(this, SIGNAL(sinalFail()), this, SLOT(onAgainPostData()));

}
void PingbackManager::InitSDK(const QString &company, const QString &business,const QString  &appversion){
    company_ = company;
    business_= business;
    appversion_ = appversion;
}
void PingbackManager::SetUserInfo(const QString &uid, const QString &user_type){

     uid_ = uid;
     user_type_ = user_type;
}
void PingbackManager::ClearUserInfo(){
     uid_ = "";
     user_type_ = "";

}
void PingbackManager::RegisterRoomEventList(const QList<QString> &eventid_list){
     eventid_list_ = eventid_list;
}
void PingbackManager::RegisterRoomEventParams(const QJsonObject &liveinfo){
     liveinfo_ = liveinfo;
}
void PingbackManager::UnregisterRoomEventParams(){
    for(int i=0;i<liveinfo_.size();i++)
        liveinfo_.remove(QString::number(i));
}
bool PingbackManager::JudgeEventId(const QString &cureventid){
    auto bfind = false;
     QList<QString>::ConstIterator ci;
     for(ci=eventid_list_.constBegin();ci!=eventid_list_.constEnd();++ci){
         if(*ci ==cureventid){
             bfind = true;
             break;
         }
     }

    return bfind;
}
void PingbackManager::SendEvent(const QString &eventId, YimiLogType logtype, const QMap<QString,QString> &extrainfos ){
       LogEntry  _logentry{};
       auto baseinfo =  _logentry.mutable_baseinfo();
       QDateTime time = QDateTime::currentDateTime();   //获取当前时间
       QString timeT = time.toString("yyyyMMddhhmmsszzz"); //将当前时间转为时间戳
       baseinfo->set_time(timeT.toLongLong());
       baseinfo->set_sessionid(session_id_.toStdString());
       baseinfo->set_uuid(uuid_.toStdString());
       if(company_ =="YIMI"){
            baseinfo->set_company(LogEntry_Company_YIMI);
       }else if(company_ =="JUREN"){
            baseinfo->set_company(LogEntry_Company_JUREN);
       }

       baseinfo->set_sdkversion(LogEntry_SDKVersion_V100);
       baseinfo->set_userid(uid_.toStdString());

       if(user_type_=="STU"){
            baseinfo->set_usertype(LogEntry_UserType_STU);
       }else if (user_type_=="TEA"){
            baseinfo->set_usertype(LogEntry_UserType_TEA);
       }else if (user_type_=="CC"){
            baseinfo->set_usertype(LogEntry_UserType_CC);
       }else if (user_type_=="CR"){
            baseinfo->set_usertype(LogEntry_UserType_CR);
       }else if (user_type_=="AUDIT")
       {
            baseinfo->set_usertype(LogEntry_UserType_AUDIT);
       }

       if(logtype==CLICK){
           baseinfo->set_type(LogEntry_LogType_CLICK);
       }else if(logtype==PV){
           baseinfo->set_type(LogEntry_LogType_PV);
       }else if(logtype==HEARTBEAT){
           baseinfo->set_type(LogEntry_LogType_HEARTBEAT);
       }else if(logtype==OPEN){
           baseinfo->set_type(LogEntry_LogType_APP);
       }else if(logtype==CRASH){
           baseinfo->set_type(LogEntry_LogType_APP);
       }else if(logtype==EXIT){
           baseinfo->set_type(LogEntry_LogType_APP);
       }else if(logtype==REFRESH){
           baseinfo->set_type(LogEntry_LogType_REFRESH);
       }else if(logtype==SEARCH){
           baseinfo->set_type(LogEntry_LogType_SEARCH);
       }

       if(!eventId.isEmpty()){
          baseinfo->set_eventid(eventId.toStdString());
       }
       if(net_type_ =="G2"){
            baseinfo->set_nettype(LogEntry_NetType_G2);
       }else if (net_type_=="G3"){
            baseinfo->set_nettype(LogEntry_NetType_G3);
       }else if (net_type_=="G4"){
            baseinfo->set_nettype(LogEntry_NetType_G4);
       }else if (net_type_=="G5"){
            baseinfo->set_nettype(LogEntry_NetType_G5);
       }else if (net_type_=="wifi"){
            baseinfo->set_nettype(LogEntry_NetType_WIFI);
       }else if (net_type_=="cable"){
            baseinfo->set_nettype(LogEntry_NetType_CABLE);
       }else {
            baseinfo->set_nettype(LogEntry_NetType_NETTYPE_DEFAULT);

       }

        baseinfo->set_operatortype(LogEntry_OperatorType_UNICOM);
        baseinfo->set_requestcnt(1);
        baseinfo->set_business(business_.toStdString());
        baseinfo->set_os(LogEntry_Os_PC);
        baseinfo->set_appversion(appversion_.toStdString());
        baseinfo->set_apptype(kAppType.toStdString());
        baseinfo->set_deviceinfo(device_info_.toStdString());
        baseinfo->set_osversion(os_version_.toStdString());
       if(!eventId.isEmpty() && JudgeEventId(eventId)){
            auto live  = _logentry.mutable_liveinfo();
             if(!liveinfo_.isEmpty()){
                if(liveinfo_.contains("lessonId")){
                    QString  lessonid = liveinfo_.value("lessonId").toString();
                    live->set_lessonid(lessonid.toStdString());
                }
                if(liveinfo_.contains("lessonType")){
                    auto lessontype = liveinfo_.value("lessonType").toString();
                     if(lessontype=="AUDITION"){
                         live->set_lessontype(LogEntry_LessonType_AUDITION);
                     }else if(lessontype=="ORDER"){
                         live->set_lessontype(LogEntry_LessonType_ORDER);
                     }else if(lessontype=="AUDITION_U"){
                         live->set_lessontype(LogEntry_LessonType_AUDITION_U);
                     }else if (lessontype=="AUDITION_N"){
                         live->set_lessontype(LogEntry_LessonType_AUDITION_N);
                     }else{
                         live->set_lessontype(LogEntry_LessonType_LESSONTYPE_DEFAULT);
                     }

                 }
                 if(liveinfo_.contains("serverip")){
                    QString  serverip = liveinfo_.value("serverip").toString();
                    live->set_serverip(serverip.toStdString());
                 }


             }
       }

       QMap<QString,QString>::const_iterator it;//遍历qmap
       for(it=extrainfos.begin(); it!= extrainfos.end();++it ) {
             auto  extrinfo = _logentry.add_extrainfo();
             extrinfo->set_key(it.key().toStdString());
             extrinfo->set_value(it.value().toStdString());
       }

       auto len = _logentry.ByteSize();
       qDebug("len %d",len);
       char *buffer = new char[len];
       if(!_logentry.SerializeToArray(buffer,len)){
           qDebug()<<"SerializeToArray"<<"fail";
       }
       QByteArray data = QByteArray(buffer,len);
       UrlRequestPost(pushurl_,data);
       if (buffer!=NULL){
           delete buffer;
           buffer = NULL;
       }

}
QString PingbackManager::GetPushUrl(){
       QString  pushurl = "https://galaxy-burypoint-pb.yimifudao.com/buryPoint/pc";
       if(!QFile::exists("Qtyer.dll")){
              pushurl = "https://galaxy-bp-prod.yimifudao.com/buryPoint/pc";
       }
         QSettings * m_setting = new QSettings("Qtyer.dll", QSettings::IniFormat);
           // 环境类型  测试环境:0  正式环境:1 手动配置
         m_setting->beginGroup("EnvironmentType");
         int environmentType = m_setting->value("type").toInt();
         m_setting->endGroup();
         m_setting->beginGroup("V2.4");
         m_setting->endGroup();

         if(environmentType == 1){

               pushurl = "https://galaxy-bp-prod.yimifudao.com/buryPoint/pc";
          }else{
               pushurl = "https://galaxy-burypoint-pb.yimifudao.com/buryPoint/pc";
          }
         qDebug()<<"GetPushUrl"<<pushurl;
        return pushurl;
 }
QString PingbackManager::GetCurrentNetWorkType(){
        int types = 0;
        QString netWorkType = "";
        QList<QNetworkInterface> list = QNetworkInterface::allInterfaces();
        foreach (QNetworkInterface netInterface, list)
        {
            if (!netInterface.isValid())
            {
                continue;
            }

            QNetworkInterface::InterfaceFlags flags = netInterface.flags();
            if (flags.testFlag(QNetworkInterface::IsRunning)
                    && !flags.testFlag(QNetworkInterface::IsLoopBack))
            {
                if(types == 0)
                {
                    netWorkType = netInterface.name();
                }
                types++;
            }
        }

        if(netWorkType.contains(QStringLiteral("wireless")))
        {
            return "wifi";
        }
        return "cable";
}
QString PingbackManager::GetOsVersion(){

       QString osversion = QSysInfo::prettyProductName();
       osversion.remove("\r").remove("\n").remove("\\").remove("\u0002").remove("/").remove("}").remove("{").remove(";").remove(":").remove(",").remove("\"").remove("]").remove("[");
       return osversion;

}
QString PingbackManager::GetOperatorType(){

    return "";
}
QString PingbackManager::GetDeviceInfo(){

        QSettings reg("HKEY_LOCAL_MACHINE\\HARDWARE\\DESCRIPTION\\System\\", QSettings::NativeFormat);
        reg.beginGroup("BIOS");
        QString deviceinfo = reg.value("SystemManufacturer").toString().remove("#").append("|").append(reg.value("SystemSKU").toString().remove("#"));
        deviceinfo.remove("\r").remove("\n").remove("\\").remove("\u0002").remove("/").remove("}").remove("{").remove(";").remove(":").remove(",").remove("\"").remove("]").remove("[");
        reg.endGroup();
        return deviceinfo;

}
QString PingbackManager::GetUuid(){
        QString  strMac;
        QList<QNetworkInterface> ifaces = QNetworkInterface::allInterfaces();
        for (int i = 0; i < ifaces.count(); i++)
        {
            QNetworkInterface iface = ifaces.at(i);
            if ( iface.flags().testFlag(QNetworkInterface::IsUp) && iface.flags().testFlag(QNetworkInterface::IsRunning) && !iface.flags().testFlag(QNetworkInterface::IsLoopBack))
            {
                for (int j=0; j<iface.addressEntries().count(); j++)
                {
                    strMac = iface.hardwareAddress();
                    i = ifaces.count();
                    break;
                }
            }
        }
        if(strMac.isEmpty()) {
            foreach(QNetworkInterface iface,ifaces)
            {
                if(!iface.flags().testFlag(QNetworkInterface::IsLoopBack)) {
                    strMac = iface.hardwareAddress();
                    break;
                }
            }
        }
        qDebug()<<"YMQosManager::getMacString()"<<strMac;
        return strMac;
}
QString PingbackManager::GetSessionId(){

    QUuid uid = QUuid::createUuid();
    QString hexStr = uid.toString().replace("{","").replace("-","").replace("}","").mid(0,16);
    int timeSpan = QDateTime::currentDateTime().toTime_t();
    QString sessionId = hexStr + QString::number(timeSpan) + "001";
    return sessionId;

}
void PingbackManager::UrlRequestPost( const QString &url, const QByteArray &data)
{

        qDebug()<<"UrlRequestPost"<<data;
        const QUrl aurl(url);
        QNetworkRequest qnr(aurl);
        qnr.setRawHeader("Content-Type","application/octet-stream");
        QSslConfiguration conf = qnr.sslConfiguration();
        conf.setPeerVerifyMode(QSslSocket::VerifyNone);
        conf.setProtocol(QSsl::TlsV1SslV3);
        qnr.setSslConfiguration(conf);
        m_accessManager->post(qnr,data);


}
void PingbackManager::replyFinished(QNetworkReply *reply){

        QString  replydata ="";
        //无错误返回
        if(reply->error() == QNetworkReply::NoError)
        {
            QTextCodec *codec = QTextCodec::codecForName("utf8");
            if(NULL!=codec)
               replydata = codec->toUnicode(reply->readAll());
             qDebug()<<"QNetworkReply::NoError"<<replydata;

        }
        else
        {
            //
           emit sinalFail();
        }

        reply->deleteLater();
}
void PingbackManager::onAgainPostData(){
    //UrlRequestPost(pushurl_,cur_bytearray_);
    //cur_bytearray_.clear();
}
}
