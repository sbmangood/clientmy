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
        Msg(const Msg & mg){
          msg = mg.msg;
          userId = mg.userId;
        }
        Msg &operator=(const Msg &mg){
           if(this !=&mg){
               msg = mg.msg;
               msg = mg.userId;
           }
          return (*this);
        }
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
        MessageModel(int isCourware, QString bgimg, double width, double heigh, int currentCoursewareType, long expiredTime);
#else
        MessageModel(int isCourware, QString bgimg, double width, double heigh, int currentCoursewareType);
#endif

        void addMsg(QString userId, QString msg);
        void undo(QString userId);
        void clear();
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

        //新讲义
        int columnId = -1; //栏目id
        int columnType = -1;//栏目类型
        //int questions = -1;//题目集合
        int pageIndex = 0; //栏目的 索引
        QString questionId = "";//题目id

        QJsonObject resourceContents;

        int currentCoursewareType = -1;//当前的讲义类型 1 为老课件 2 为新课件 0 不用去区分类型

        double offSetX = 0.0;//当前滚动条的X坐标偏移量
        double offSetY = 0.0;//当前滚动条的Y坐标偏移量
        double zoomRate = 1.0;//缩放比例

         bool beShowedAsLongImg = false;//pictureReport 图按照长图显示

};

#endif // MESSAGEMODEL_H
