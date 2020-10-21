#pragma once
#include <stdint.h>
#include <string>
#include "FileInfoUtils.h"

class  YMUploadCallback
{
public:
    virtual void ProgressCallback(size_t increment, int64_t transfered, int64_t total, UpLoadFileInfo* fileInfoData) = 0;
    virtual void upLoadSuccess(std::string fileUrl, long fileSize, std::string upFileMark) = 0;
    virtual void upLoadFailed(std::string errCode, std::string upFileMark) = 0;

private:

};


