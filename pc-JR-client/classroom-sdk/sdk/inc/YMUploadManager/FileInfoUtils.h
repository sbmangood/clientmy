#pragma once
struct UpLoadFileInfo
{
    const char* fileurl;
    const char* fileMark;
    void* mark;
    UpLoadFileInfo() : fileurl(nullptr), fileMark(nullptr), mark(nullptr) {}
};
