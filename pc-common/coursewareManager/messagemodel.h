#ifndef MESSAGEMODEL_H
#define MESSAGEMODEL_H

#include <QObject>
#include <QDebug>
#include <QMap>
#include <QJsonObject>

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
    void setOffsetY(double offsetY);
    void setImageUrl(QString filePath, double width, double height);
    int getCurrentPage();
    int getTotalPage();
    QList<Msg> getMsgs();
    void release();
    void setNewCourseware(int columnId, QString columnType, int pageIndex, QString questionId, QJsonObject resourceContents);
    void setQuestionButStatus(bool questionStatus);

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
    double zoomRate; //缩放值
    bool questionBtnStatus;//开始练习按钮状态
#ifdef USE_OSS_AUTHENTICATION
    long expiredTime;
#endif
    QJsonObject resourceContents;
    int columnId = -1;//栏目Id
    int currentCoursewareType = -1;//当前的讲义类型 1 为老课件 2 为新课件 0 不用去区分类型
    int pageIndex;
    bool beShowedAsLongImg = false;
};

#endif // MESSAGEMODEL_H
