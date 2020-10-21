#include "onsignalhandler.h"
#include "breakpadhttpUploader.h"
#include <QDateTime>
OnSignalHandler::OnSignalHandler(QObject *parent) : QObject(parent)
{

}
void OnSignalHandler::onRecieve(QString msg){

  printf("onRecieve msg:%s\n",qPrintable(msg));
  QString api_url =msg.section(';', 0, 0);
  QString file_name = msg.section(';', 1, 1);
  //====================参数拼接===================================//
   QDateTime times = QDateTime::currentDateTime();
   QMap<QString, QString> maps;
   maps.insert("token",      msg.section(';', 2,2));
   maps.insert("lessonId",   msg.section(';', 3, 3));
   maps.insert("appVersion", msg.section(';', 4, 4));
   maps.insert("apiVersion", msg.section(';', 5, 5));
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
   QString httpsd = "http://" + api_url + "/log/logUpload?" + QString("%1").arg(urls);
   const QUrl url(httpsd);
   printf("onRecieve url:%s\n",qPrintable(httpsd));
   QBreakpadHttpUploader *sender = new QBreakpadHttpUploader(url);
   sender->uploadLog(file_name);

}
