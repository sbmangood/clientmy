#ifndef MESSAGEMODEL_H
#define MESSAGEMODEL_H

#include <QObject>
#include <QDebug>
#include<QJsonObject>
#include<QJsonArray>
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
        void clear(QString userId);
        void setPage(int totalPage, int curretnPage);
        int getCurrentPage();
        int getTotalPage();
        QList<Msg> getMsgs();
        void release();

        void setNewCourseware(int columnId, int columnType, int pageIndex, QString questionId, QJsonObject resourceContents);

#ifdef USE_OSS_AUTHENTICATION
        long expiredTime;//重新验签
#endif

    public:
        QList<Msg> msgs;
        int isCourware;
        QString bgimg;
        double width, height;
        int totalPage;
        int currentPage;
        bool questionBtnStatus;
        //新讲义
        int columnId = -1; //栏目id
        QString columnType = "-1";//栏目类型
        //int questions = -1;//题目集合
        int pageIndex = 0; //栏目的 索引
        QString questionId = "";//题目id

        QJsonObject resourceContents;

        QString currentCoursewareType =" -1";//当前的讲义类型 1 为老课件 2 为新课件 0 不用去区分类型

        double offsetX = 0.0;//当前滚动条的X坐标偏移量
        double offsetY = 0.0;//当前滚动条的Y坐标偏移量
        double zoomRate = 1.0;//缩放比例

};

#endif // MESSAGEMODEL_H
