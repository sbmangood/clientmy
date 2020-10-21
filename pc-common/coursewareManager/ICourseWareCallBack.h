#ifndef ICOURSEWARECALLBACK_H
#define ICOURSEWARECALLBACK_H
#include <QString>

class ICourseWareCallBack
{
public:
    ICourseWareCallBack();

    void onViewUpdate();//	View 更新的时候回调

    void onViewLoadSuccess();//	View 加载成功

    void onViewLoadFailed(int errorCode, QString errorMsg);// View加载失败
};

#endif // ICOURSEWARECALLBACK_H
