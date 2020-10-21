#include "YMStageManagerAdapter.h"
#include "YMEncryption.h"

YMStageManagerAdapter::YMStageManagerAdapter(QObject *parent) : QObject(parent)
{
    m_httpClient = YMHttpClient::defaultInstance();
}

//获取当前网络环境
void YMStageManagerAdapter::getCurrentStage()
{
    int netType = m_httpClient->m_netType;
    QString stageInfo = m_httpClient->m_stage;
    if(stageInfo.trimmed().length() > 0) //如果不是生产环境
    {
        stageInfo += "-";
    }
    qDebug() << "YMStageManagerAdapter::getCurrentStage" << netType << stageInfo << __LINE__;
    emit sigStageInfo(netType, stageInfo);
}

//修改网络配置文件
void YMStageManagerAdapter::updateStage(int netType, QString stageInfo)
{
    qDebug() << "YMStageManagerAdapter::updateStage" << netType << stageInfo << __LINE__;
    m_httpClient->updateNetType(netType, stageInfo);
}

// 获取版本号
QString YMStageManagerAdapter::getAppVersion()
{
    return YMUserBaseInformation::appVersion;
}
