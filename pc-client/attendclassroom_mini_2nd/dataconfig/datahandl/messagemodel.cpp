#include "messagemodel.h"

#ifdef USE_OSS_AUTHENTICATION
MessageModel::MessageModel(int isCourware, QString bgimg, double width, double height, int currentCoursewareType, long expiredTime) :
    isCourware(isCourware), bgimg(bgimg), width(width), height(height), currentCoursewareType(currentCoursewareType), expiredTime(expiredTime)
#else
MessageModel::MessageModel(int isCourware, QString bgimg, double width, double height, int currentCoursewareType) :
    isCourware(isCourware), bgimg(bgimg), width(width), height(height), currentCoursewareType(currentCoursewareType)
#endif
{
}
//向信息容器内添加数据
void MessageModel::addMsg(QString userId, QString msg)
{
    Msg m;
    m.msg = msg;
    m.userId = userId;
    msgs.append(m);
}

//从容器内删除某个点
void MessageModel::undo(QString userid)
{
    int lastIndex = -1;
    for (int i = 0; i < msgs.size(); ++i)
    {
        if (msgs.at(i).userId == userid)
            lastIndex = i;
    }
    if (lastIndex > -1)
        msgs.removeAt(lastIndex);
}

//清空容器
void MessageModel::clear()
{
    msgs.clear();
}

//清空容器
void MessageModel::clear(QString userId)
{
    for (int i = 0; i < msgs.size(); ++i)
    {
        if (msgs.at(i).userId == userId)
        {
           msgs.removeAt(i);
           i = 0;
        }
    }
}


//设置当前的页面跟全部页面的数据
void MessageModel::setPage(int totalPage, int currentPage)
{
    this->totalPage = totalPage;
    this->currentPage = currentPage;
}

//获得当前的页面
int MessageModel::getCurrentPage()
{
    return this->currentPage;
}

//获得全部的页面
int MessageModel::getTotalPage()
{
    return this->totalPage;
}

//获得所有存储数据的容器
QList<Msg> MessageModel::getMsgs()
{
    return this->msgs;
}

//释放当前的内存
void MessageModel::release()
{
    msgs.clear();
    //    delete this;
}

void MessageModel::setNewCourseware(int columnId, int columnType, int pageIndex, QString questionId, QJsonObject resourceContents)
{
    this->columnId = columnId;
    this->columnType = columnType;
    //this->questions = questions;
    this->pageIndex = pageIndex;
    this->questionId = questionId;
    this->currentCoursewareType = 2;//新课件标示
    this-> resourceContents =  resourceContents;
}
