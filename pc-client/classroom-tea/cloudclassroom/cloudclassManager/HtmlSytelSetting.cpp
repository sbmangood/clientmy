#include "HtmlSytelSetting.h"
#include "debuglog.h"

HtmlSytelSetting::HtmlSytelSetting(QObject *parent)
    : QObject(parent)
{

}

void HtmlSytelSetting::updateHtml(QString content)
{
    QString docPath = DebugLog::getDocumentDir();//QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);

    QString filePath = docPath + "/YiMi/";
    QDir dir(filePath);
    if(!dir.exists())
    {
        dir.mkdir(filePath);
    }

    QFile file(filePath + "htmlStyle.html"); //":/contentStyle.html");//

    //qDebug() << "==HtmlSytelSetting::updateHtml==" << filePath << "htmlStyle.html";

    QString htmlBody = "<html>";
    htmlBody += "<head>";
    htmlBody += "<title>题目样式处理页面</title>";
    htmlBody += "<meta http-equiv=\"Content-Type\" content=\"text/html\"; charset=\"utf-8\" />";
    htmlBody += "<style type=\"text/css\">";
    htmlBody += ".FEBox{display: inline;width: 80px;height: 25px;line-height: 25px;border: none;border-bottom: 1px solid #30b4f2;font-size: 14px;padding: 0 20px;}";
    htmlBody += "img{vertical-align:middle;}";
    htmlBody += ".MathJye{ border: 0 none;direction: ltr;line-height: normal; display:inline-block;float: none; font-family:'Microsoft YaHei'; font-size:15px; font-style: normal;font-weight: normal; letter-spacing:1px; line-height: normal;margin: 0;padding: 0;text-align: left; text-indent: 0; text-transform: none; white-space: nowrap;word-spacing: normal; word-wrap: normal; -webkit-text-size-adjust:none;}";
    htmlBody += ".MathJye div,";
    htmlBody += ".MathJye span{border: 0 none;margin: 0;padding: 0;line-height: normal;text-align: left;height:auto;_height:auto;white-space:normal}";
    htmlBody += ".MathJye table{border-collapse:collapse;margin: 0;padding: 0;text-align: center;vertical-align: middle;line-height: normal;font-size: inherit;*font-size: 100%;_font-size: 100%;font-style: normal;font-weight: normal;border: 0;float: none;display: inline-block;display: inline;zoom: 0;}";
    htmlBody += ".MathJye table td{padding:0;font-size:inherit;line-height:normal;white-space: nowrap; border:0 none;width:auto;_height:auto}";
    htmlBody += "*{font-family:\"微软雅黑\";font-size: 18px;}";
    htmlBody += "</style>";
    htmlBody += "<script type=\"text/javascript\">";
    htmlBody += "var result = 0;";
    htmlBody += "function getbodyHeight(){ result = document.body.scrollHeight; alert(a);  return result; }";
    htmlBody += "</script>";
    htmlBody += "</head>";

    htmlBody += "<body>";
    htmlBody += content;
    htmlBody += "</body>";
    htmlBody += "</html>";

    if(file.open(QFile::WriteOnly | QIODevice::Truncate))
    {
        QTextStream textOut(&file);
        textOut << htmlBody ;
        textOut.flush();
    }
    file.close();
    emit sigUpdateSuccess(filePath + "htmlStyle.html");
}
