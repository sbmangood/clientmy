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

/*
 *存储数据的类
*/
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
        QString questionId;//题目Id
        QString columnType;//栏目类型
        double offsetY;//当前题滚动坐标
        bool questionBtnStatus;//开始练习按钮状态
#ifdef USE_OSS_AUTHENTICATION
        long expiredTime;
#endif

        bool beShowedAsLongImg = false;
};

#endif // MESSAGEMODEL_H
