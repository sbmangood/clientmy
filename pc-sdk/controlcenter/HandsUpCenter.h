#ifndef HANDSUPCENTER_H
#define HANDSUPCENTER_H

#include <QObject>
#include <QJsonObject>
#include "datacenter.h"
#include "controlcenter.h"
#include "../YMHandsUpManager/IHandsUpCtrl.h"

class HandsUpCenter : public QObject
{
    Q_OBJECT
public:
    explicit HandsUpCenter(QObject *parent = 0);
    ~HandsUpCenter();

    int init(const QString &pluginPathName);
    int uninit();

    int initHandsUp(QJsonObject json);

    int raiseHandForUp(QString userId, QString groupId);
    int cancelHandsUp(QString userId, QString groupId);
    int processResponse(QString userId, int operation);

    int processHandsUp(QString userId, uint groupId, TEA_OPERATION operation);// 老师处理学生举手申请
    int parseHandsUpMsg(const QJsonObject& msg);// 解析上台消息

    QObject* loadPlugin(const QString &pluginPath);
    void unloadPlugin(QObject* instance);

private:
    ControlCenter* m_controlCenter;
    IHandsUpCtrl* m_IHandsUpCtrl;

signals:
    void updateStuList(QString userId, uint groupId, int reqOrCancel);// 更新学生发言列表信号,0-cancel,1-req
    void sigHandsUpResponse(QString userId, uint groupId, QString type);// 学生处理老师的回应
public slots:
    void handsUpReqMsg(QJsonObject content);// 生成消息content
};

#endif // HANDSUPCENTER_H
