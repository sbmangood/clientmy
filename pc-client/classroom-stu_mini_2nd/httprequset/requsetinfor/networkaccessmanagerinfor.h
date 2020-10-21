#ifndef NETWORKACCESSMANAGERINFOR_H
#define NETWORKACCESSMANAGERINFOR_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QDebug>
#include <QByteArray>
#include <QVariant>
#include <QUrl>
#include <QDateTime>
#include <QCryptographicHash>
#include <QMap>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>
#include "./dataconfig/datahandl/datamodel.h"

class NetworkAccessManagerInfor : public QObject
{
        Q_OBJECT
    public:
        explicit NetworkAccessManagerInfor(QObject *parent = 0);
        ~NetworkAccessManagerInfor();

        //图片请求
        Q_INVOKABLE void getGifName(QString names);

        //获得gif的路径
        Q_INVOKABLE QList<QString> getGifUrlPath(int nums);

        Q_INVOKABLE void getCoursewareNameInfor();

        //发送课程信息
        Q_INVOKABLE void sendCoursewareNameInfor(QString names);

        //视频课件获得信息
        Q_INVOKABLE void getVideoNameInfor();


        //设置视频文件名称
        Q_INVOKABLE void  setFileUrlName();

        //获得视频的url
        Q_INVOKABLE QString  getVideoFileUrlName(QString names);

        /*
         * 获得登录信息
         */
        void getLoginInfor(QString name, QString pwd);


        void getCoursewareName(QMap<QString, QString> maps);


        void getVideoName(QMap<QString, QString> maps);

    signals:
        void sendRetInfor(QString infor);
        void sigCoursewareName(QString infor);
        void sigVideoName(QString infor);
        void sigGifUrlPathName(QString infor);

        void sigSenGroundNum(int nums);
        void sigCoursewareNameList(QList<QString> listNames);

        void sigSendCoursewareNameInfor(QString contents);

        void sigSendVideoNameInfor(QStringList listNames);


    public slots:
        void replyFinished(QNetworkReply*);
        void replyVideoFinished(QNetworkReply*);
        void replyGifFinished(QNetworkReply*);
        //处理返回的数据
        void onSigGifUrlPathName(QString contents);

        //处理课件信息
        void onSigCoursewareName(QString infor );

        //处理视频课件
        void onSigVideoName(QString infor );

    private:
        QNetworkAccessManager *m_accessManager;
        QNetworkRequest m_request;
        QNetworkReply *m_reply;


        QNetworkAccessManager *m_accessManagerVideo;
        QNetworkRequest m_requestVideo;
        QNetworkReply *m_replyVideo;


        QNetworkAccessManager *m_accessManagerGif;
        QNetworkRequest m_requestGif;
        QNetworkReply *m_replyGif;

        QMap<QString, QMap<int, QString> > m_gifUrlPath;
        QList<QString> m_gifUrlPathName;

        QMap<QString, QList<QString> > m_coursewareName;
        QMap<QString, QString > m_coursewareNameIndex;
        QList<QString> m_coursewareNameList;


        QMultiMap<QString, QString> m_lessonfileUrl;
        QMultiMap<QString, QPair<QString, QString> > m_docfileUrl;
        QMultiMap<QString, QPair<QString, QPair<QString, QString> > >m_pagefileUrl;
        QMap<QString, QString> m_fileUrlName;

};

#endif // NETWORKACCESSMANAGERINFOR_H
