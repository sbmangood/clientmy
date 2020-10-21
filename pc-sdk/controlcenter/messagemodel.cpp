#include "messagemodel.h"

#ifdef USE_OSS_AUTHENTICATION
MessageModel::MessageModel(int isCourware, QString bgimg, double width, double height, QString questionId, QString columnType, double offsetY, bool questionButStatus, long expiredTime) :
    isCourware(isCourware),
    bgimg(bgimg),
    width(width),
    height(height),
    questionId(questionId),
    columnType(columnType),
    offsetY(offsetY),
    questionBtnStatus(questionButStatus),
    expiredTime(expiredTime)
{

}
#else
MessageModel::MessageModel(int isCourware, QString bgimg, double width, double height, QString questionId, QString columnType, double offsetY, bool questionButStatus) :
    isCourware(isCourware),
    bgimg(bgimg),
    width(width),
    height(height),
    questionId(questionId),
    columnType(columnType),
    offsetY(offsetY),
    questionBtnStatus(questionButStatus)
{
}
#endif

void MessageModel::setImageUrl(QString filePath, double width, double height)
{
    this->bgimg = filePath;
    this->width = width;
    this->height = height;
}

//向信息容器内添加数据
void MessageModel::addMsg(QString userId, QString msg)
{
    Msg m;
    m.msg = msg;
    m.userId = userId;
//    qDebug() << "===addMsg==" << userId;
    msgs.append(m);
}

//从容器内删除某个点
void MessageModel::undo(QString userid)
{
//    qDebug() << "===undo===" << userid;
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

//根据用户Id清除轨迹
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
//设置坐标
void MessageModel::setOffsetY(double offsetY)
{
    this->offsetY = offsetY;
}
//设置开始按钮状态
void MessageModel::setQuestionButStatus(bool questionStatus)
{
    this->questionBtnStatus = questionStatus;
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

