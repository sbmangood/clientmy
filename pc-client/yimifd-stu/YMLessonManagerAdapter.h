#ifndef YMLESSONMANAGERADAPTER_H
#define YMLESSONMANAGERADAPTER_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include "YMHttpClient.h"
#include <QSsl>
#include <QSslSocket>
#include <openssl/des.h>
#include "ymcrypt.h"
#include <QDataStream>
#include <QTextStream>
#include <QProcess>
#include<QFile>
#include<QDir>
#include<QMessageBox>
#include<QStandardPaths>
#include<QCoreApplication>
#include<QSettings>
#include <QTimer>
#include<QNetworkConfigurationManager>

#include"../YMCommon/qosManager/YMQosManagerForStuM.h"

class YMLessonManagerAdapter
        : public QObject
        , public YMHttpResponseHandler
{
    Q_OBJECT
public:
    YMLessonManagerAdapter(QObject *parent = 0);
    ~YMLessonManagerAdapter();

    Q_INVOKABLE void getStudentLessonInfo(QString dateTime);
    Q_INVOKABLE void getStudentLessonListInfo(QJsonObject data);
    Q_INVOKABLE void getEnterClass(QString lessonId,int interNetGrade);
    Q_INVOKABLE void getLookCourse(QJsonObject lessonInfo);
    Q_INVOKABLE void getRepeatPlayer(QJsonObject lessonInfo);

    Q_PROPERTY(bool isStuUser READ getEnabled WRITE setEnabled)
    Q_INVOKABLE void setUserType(bool isStuUser);
    //设置
    Q_PROPERTY(QString lessonType READ getLessonType WRITE setLessonType)
    Q_PROPERTY(QString lessonPlanStartTime READ getLessonPlanStartTime WRITE setLessonPlanStartTime)
    Q_PROPERTY(QString lessonPlanEndTime READ getLessonPlanEndTime WRITE setLessonPlanEndTime)

    //显示课程详情课后评价信息
    Q_INVOKABLE int getLessonComment(QString lessonId);

    QString tempLessonIds;

public slots:
    void getRecorderresult(QNetworkReply *reply);
    void getEnterClassresult(QNetworkReply *reply);
    void enterClassTimerOut();
    void getCloudServerIpTimeOut();//获取服务端ip超时

public:
    void getCloudServer();//获取课件
    void enterClass();//进入教室
    void downLoadFile(QJsonObject dataObject, QString fileDir);//下载文件
    void getStuVideo(QString videoId, QString fileName, QString fileDir); //获取录播
    void encrypt(QString source, QString target); //加密函数

    QString des_decrypt(const std::string &cipherText);
    QString des_encrypt(const QString &clearText);
    QList<QString> decrypt(QString source);

    //获取录播文件信息进行加密文件
    QVariantList getStuTraila(QString trailId, QString fileName, QString fileDir);

    void setEnabled(bool e)
    {
        isStuUser = e;
    }

    bool getEnabled() const
    {
        return isStuUser;
    }

    bool isStuUser;

    QString lessonType;
    void setLessonType( QString v)
    {
        if(v == "10" || v == "O")
        {
            lessonType = "O";
        }
        else
        {
            lessonType = "A";
        }
    }
    QString getLessonType()
    {
        return lessonType;
    }

    QString lessonPlanStartTime = "";
    QString getLessonPlanStartTime()
    {
        return lessonPlanStartTime;
    }

    void setLessonPlanStartTime(QString time)
    {
        lessonPlanStartTime = time;
    }

    QString lessonPlanEndTime = "";

    QString getLessonPlanEndTime()
    {
        return lessonPlanEndTime;
    }

    void setLessonPlanEndTime(QString time)
    {
        lessonPlanEndTime = time;
    }
    QString currentLessonId = "";

    //重设进入教室的Ip选择 以服务器指定的优先级为最高（ type =1 ）  若服务器未指定则次优先级为 用户自己选择的ip (type = 2)
    void resetSelectIp(int type, QString ip);

    QTimer *m_timer;

protected:
    virtual void onResponse(int reqCode, const QString &data);

private:
    YMHttpClient * m_httpClint;
    QJsonObject m_repeatData; //查看录播信息
    QJsonObject m_classData;
    QString m_domain;
    QString m_ipAddress;
    QString m_port, m_udpPort;
    QString m_httpPort;

    typedef void (YMLessonManagerAdapter::* HttpRespHandler)(const QString& data);
    QMap<int, HttpRespHandler> m_respHandlers;

    bool isdownLoad = true;
    QTimer *m_getIpTimer;//获取serverIp是否超时
signals:
    void studentLessonInfoChanged(QJsonObject lessonInfo);
    void studentLesonListInfoChanged(QJsonObject lessonInfo);
    void lessonlistRenewSignal();
    void setDownValue(int min, int max);
    void downloadChanged(int currentValue);
    void downloadFinished();
    void lodingFinished();//加载数据完成
    void requestTimerOut();
    void showEnterRoomStatusTips(QString statusText);

    void hideEnterClassRoomItem();
    //录播未生成信号
    void sigRepeatPlayer();
    void sigMessageBoxInfo(QString strMsg); //需要提示message box的信号

private:
    void setBufferEnterRoomIp(QString currentIp,QString port);
    QString getBufferEnterRoomIP();
    QString getBufferEnterRoomPort();

};

#endif // YMLESSONMANAGERADAPTER_H
