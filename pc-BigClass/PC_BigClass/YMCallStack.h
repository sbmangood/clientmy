#ifndef YMCALLSTACK_H
#define YMCALLSTACK_H

#include <windows.h>
#include <Dbghelp.h>
#include <vector>
#include <QApplication>

using namespace std;

const int MAX_ADDRESS_LENGTH = 32;
const int MAX_NAME_LENGTH = 1024;

struct CrashInfo
{
    CHAR ErrorCode[MAX_ADDRESS_LENGTH];
    CHAR Address[MAX_ADDRESS_LENGTH];
    CHAR Flags[MAX_ADDRESS_LENGTH];
};

//CallStack信息
struct CallStackInfo
{
    CHAR ModuleName[MAX_NAME_LENGTH];
    CHAR MethodName[MAX_NAME_LENGTH];
    CHAR FileName[MAX_NAME_LENGTH];
    CHAR LineNumber[MAX_NAME_LENGTH];
};

// 安全拷贝字符串函数
void SafeStrCpy(char* szDest, size_t nMaxDestSize, const char* szSrc);

// 得到程序崩溃信息
CrashInfo GetCrashInfo(const EXCEPTION_RECORD *pRecord);

// 得到CallStack信息
vector<CallStackInfo> GetCallStack(const CONTEXT *pContext);

//注册异常捕获函数的入口函数
LONG ApplicationCrashHandler(EXCEPTION_POINTERS *pException);

#endif // YMCALLSTACK_H
