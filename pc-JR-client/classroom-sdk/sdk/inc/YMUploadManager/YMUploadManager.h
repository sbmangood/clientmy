#ifndef YMUPLOADMANAGER_H
#define YMUPLOADMANAGER_H

#include <QtCore/qglobal.h>

#if defined(YMUPLOADMANAGER_LIBRARY)
#  define YMUPLOADMANAGERSHARED_EXPORT Q_DECL_EXPORT
#else
#  define YMUPLOADMANAGERSHARED_EXPORT Q_DECL_IMPORT
#endif
#include <string>
#include "YMUploadCallback.h"

using namespace std;

class YMUPLOADMANAGERSHARED_EXPORT YMUploadManager
{

public:
    YMUploadManager();

    int upLoadFileToOss(const string& userId, const string& envType, const string& filePath, const string& upFileMark = "");// 上传到OSS

    virtual void addUploadCallBack(YMUploadCallback *instantUploadCallBack = NULL);// 添加上传回调

    virtual void delUploadCallBack();// 移除上传回调
};

#endif // YMUPLOADMANAGER_H
