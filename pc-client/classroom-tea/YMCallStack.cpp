﻿#include "YMCallStack.h"
#include <qdebug.h>
#include <QMessageBox>
#include"../YMCommon/qosManager/YMQosManager.h"

// 安全拷贝字符串函数
void SafeStrCpy(char* szDest, size_t nMaxDestSize, const char* szSrc)
{
    if (nMaxDestSize <= 0) return;
    if (strlen(szSrc) < nMaxDestSize)
    {
        strcpy_s(szDest, nMaxDestSize, szSrc);
    }
    else
    {
        strncpy_s(szDest, nMaxDestSize, szSrc, nMaxDestSize);
        szDest[nMaxDestSize - 1] = '\0';
    }
}

// 得到程序崩溃信息
CrashInfo GetCrashInfo(const EXCEPTION_RECORD *pRecord)
{
    CrashInfo crashinfo;
    SafeStrCpy(crashinfo.Address, MAX_ADDRESS_LENGTH, "N/A");
    SafeStrCpy(crashinfo.ErrorCode, MAX_ADDRESS_LENGTH, "N/A");
    SafeStrCpy(crashinfo.Flags, MAX_ADDRESS_LENGTH, "N/A");

    sprintf_s(crashinfo.Address, "%08X", pRecord->ExceptionAddress);
    sprintf_s(crashinfo.ErrorCode, "%08X", pRecord->ExceptionCode);
    sprintf_s(crashinfo.Flags, "%08X", pRecord->ExceptionFlags);

    return crashinfo;
}

// 得到CallStack信息
vector<CallStackInfo> GetCallStack(const CONTEXT *pContext)
{
    HANDLE hProcess = GetCurrentProcess();
    SymInitialize(hProcess, NULL, TRUE);

    vector<CallStackInfo> arrCallStackInfo;

    CONTEXT c = *pContext;

    STACKFRAME64 sf;
    memset(&sf, 0, sizeof(STACKFRAME64));
    DWORD dwImageType = IMAGE_FILE_MACHINE_I386;

    // 不同的CPU类型，具体信息可查询MSDN
#ifdef _M_IX86
    sf.AddrPC.Offset = c.Eip;
    sf.AddrPC.Mode = AddrModeFlat;
    sf.AddrStack.Offset = c.Esp;
    sf.AddrStack.Mode = AddrModeFlat;
    sf.AddrFrame.Offset = c.Ebp;
    sf.AddrFrame.Mode = AddrModeFlat;
#elif _M_X64
    dwImageType = IMAGE_FILE_MACHINE_AMD64;
    sf.AddrPC.Offset = c.Rip;
    sf.AddrPC.Mode = AddrModeFlat;
    sf.AddrFrame.Offset = c.Rsp;
    sf.AddrFrame.Mode = AddrModeFlat;
    sf.AddrStack.Offset = c.Rsp;
    sf.AddrStack.Mode = AddrModeFlat;
#elif _M_IA64
    dwImageType = IMAGE_FILE_MACHINE_IA64;
    sf.AddrPC.Offset = c.StIIP;
    sf.AddrPC.Mode = AddrModeFlat;
    sf.AddrFrame.Offset = c.IntSp;
    sf.AddrFrame.Mode = AddrModeFlat;
    sf.AddrBStore.Offset = c.RsBSP;
    sf.AddrBStore.Mode = AddrModeFlat;
    sf.AddrStack.Offset = c.IntSp;
    sf.AddrStack.Mode = AddrModeFlat;
#else
#error "Platform not supported!"
#endif

    HANDLE hThread = GetCurrentThread();

    while (true)
    {
        // 该函数是实现这个功能的最重要的一个函数
        // 函数的用法以及参数和返回值的具体解释可以查询MSDN
        if (!StackWalk64(dwImageType, hProcess, hThread, &sf, &c, NULL, SymFunctionTableAccess64, SymGetModuleBase64, NULL))
        {
            break;
        }

        if (sf.AddrFrame.Offset == 0)
        {
            break;
        }

        //初始化
        CallStackInfo callstackinfo;
        SafeStrCpy(callstackinfo.MethodName, MAX_NAME_LENGTH, "N/A");
        SafeStrCpy(callstackinfo.FileName, MAX_NAME_LENGTH, "N/A");
        SafeStrCpy(callstackinfo.ModuleName, MAX_NAME_LENGTH, "N/A");
        SafeStrCpy(callstackinfo.LineNumber, MAX_NAME_LENGTH, "N/A");

        BYTE symbolBuffer[sizeof(IMAGEHLP_SYMBOL64) + MAX_NAME_LENGTH];
        IMAGEHLP_SYMBOL64 *pSymbol = (IMAGEHLP_SYMBOL64*)symbolBuffer;
        memset(pSymbol, 0, sizeof(IMAGEHLP_SYMBOL64) + MAX_NAME_LENGTH);

        pSymbol->SizeOfStruct = sizeof(symbolBuffer);
        pSymbol->MaxNameLength = MAX_NAME_LENGTH;

        //=============================================
        // 得到函数名
        if (SymGetSymFromAddr64(hProcess, sf.AddrPC.Offset, NULL, pSymbol))
        {
            SafeStrCpy(callstackinfo.MethodName, MAX_NAME_LENGTH, pSymbol->Name);
        }

        IMAGEHLP_LINE64 lineInfo;
        memset(&lineInfo, 0, sizeof(IMAGEHLP_LINE64));
        lineInfo.SizeOfStruct = sizeof(IMAGEHLP_LINE64);

        //=============================================
        // 得到文件名和所在的代码行
        DWORD dwLineDisplacement;
        if (SymGetLineFromAddr64(hProcess, sf.AddrPC.Offset, &dwLineDisplacement, &lineInfo))
        {
            SafeStrCpy(callstackinfo.FileName, MAX_NAME_LENGTH, lineInfo.FileName);
            sprintf_s(callstackinfo.LineNumber, "%d", lineInfo.LineNumber);
        }

        IMAGEHLP_MODULE64 moduleInfo;
        memset(&moduleInfo, 0, sizeof(IMAGEHLP_MODULE64));
        moduleInfo.SizeOfStruct = sizeof(IMAGEHLP_MODULE64);

        //=============================================
        // 得到模块名
        if (SymGetModuleInfo64(hProcess, sf.AddrPC.Offset, &moduleInfo))
        {
            SafeStrCpy(callstackinfo.ModuleName, MAX_NAME_LENGTH, moduleInfo.ModuleName);
        }

        arrCallStackInfo.push_back(callstackinfo);
    }

    SymCleanup(hProcess);
    return arrCallStackInfo;
}

LONG ApplicationCrashHandler(EXCEPTION_POINTERS *pException)
{
    // 确保有足够的栈空间
#ifdef _M_IX86
    if (pException->ExceptionRecord->ExceptionCode == EXCEPTION_STACK_OVERFLOW)
    {
        static char TempStack[1024 * 128];
        __asm mov eax, offset TempStack[1024 * 128];
        __asm mov esp, eax;
    }
#endif

    CrashInfo crashinfo = GetCrashInfo(pException->ExceptionRecord);

    // 输出Crash信息
    QString strCarsh = QString("ErrorCode: %1, Address: %2, Flags: %3") .arg(crashinfo.ErrorCode) .arg(crashinfo.Address) .arg(crashinfo.Flags);
    qDebug() << strCarsh;
    vector<CallStackInfo> arrCallStackInfo = GetCallStack(pException->ContextRecord);

    // 输出CallStack
    qDebug() << "CallStack:";
    QJsonObject crashObj;
    crashObj.insert("crashTime",QDateTime::currentMSecsSinceEpoch());
    for (vector<CallStackInfo>::iterator i = arrCallStackInfo.begin(); i != arrCallStackInfo.end(); ++i)
    {
        CallStackInfo callstackinfo = (*i);
        qDebug() << callstackinfo.MethodName << "() : [" << callstackinfo.ModuleName << "] (File: " << callstackinfo.FileName << ", Line " << callstackinfo.LineNumber << ")" << endl;

        QString msg = callstackinfo.ModuleName;
        msg.append(" FileName ").append(callstackinfo.FileName);
        msg.append(" MethodName ").append(callstackinfo.MethodName);
        msg.append(" LineNumber ").append(callstackinfo.LineNumber);
        crashObj.insert("crashMsg", msg);
        crashObj.insert("crashType","1");
    }
    YMQosManager::gestance()->writeMsgToLocalBuffer("crash",crashObj);

    //在这里, 弹出一个错误对话框, 并退出程序
//    QMessageBox::question(NULL, "Title", "Error occured!", QMessageBox::Ok);
    return EXCEPTION_EXECUTE_HANDLER;
}

