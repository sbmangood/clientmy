#ifndef MESSAGEMODEL_H
#define MESSAGEMODEL_H

#include <QObject>
#include <QDebug>
#include <QMap>

class Msg
{
    public:
        Msg(): msg("")
            , userId("")
        {}
        virtual ~Msg() {}

        QString msg;
        QString userId;
};

class MessageModel
{
 public:
#ifdef USE_OSS_AUTHENTICATION
        MessageModel(int isCourware, QString bgimg, double width, double height, QString questionId, QString columnType, double offsetY, bool questionBtnStatus, long expiredTime);
#else
        MessageModel(int isCourware, QString bgimg, double width, double height, QString questionId, QString columnType, double offsetY, bool questionBtnStatus);
#endif
        void addMsg(QString userId, QString msg);
        void undo(QString userId);
        void clear();
        void clear(QString userId);
        void setPage(int totalPage, int curretnPage);
        void setQuestionButStatus(bool questionStatus);
        void setOffsetY(double offsetY);
        void setImageUrl(QString filePath, double width, double height);
        int getCurrentPage();
        int getTotalPage();
        QList<Msg> getMsgs();
        void release();

    public:
        QList<Msg> msgs;
        int isCourware;
        QString bgimg;
        double width, height;
        int totalPage;
        int currentPage;
        QString questionId;//��ĿId
        QString columnType;//��Ŀ����
        double offsetY;//��ǰ���������
        bool questionBtnStatus;//��ʼ��ϰ��ť״̬
#ifdef USE_OSS_AUTHENTICATION
        long expiredTime;
#endif
};

#endif // MESSAGEMODEL_H
