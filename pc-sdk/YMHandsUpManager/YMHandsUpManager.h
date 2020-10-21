#ifndef YMHANDSUPMANAGER_H
#define YMHANDSUPMANAGER_H

#include <QObject>
#include "IHandsUpCtrl.h"

class YMHandsUpManager : public IHandsUpCtrl
{
    Q_OBJECT
#if QT_VERSION >= 0x050000
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.Plugin.IHandsUpCtrl/1.0" FILE "YMHandsUpManager.json")
    Q_INTERFACES(IHandsUpCtrl)
#endif // QT_VERSION >= 0x050000

public:
    explicit YMHandsUpManager();
    virtual ~YMHandsUpManager();

    static YMHandsUpManager* getInstance();

    virtual int initHandsUp(QJsonObject json);

    /****************** 学生端接口 begin *****************/
    virtual int raiseHandForUp(QString userId, QString groupId);
    virtual int cancelHandsUp(QString userId, QString groupId);
    virtual int processResponse(QString userId, int operation);
    /****************** 学生端接口 end *****************/

    /****************** 老师端接口 begin ***************/
    virtual int processHandsUp(QString userId, uint groupId, TEA_OPERATION operation);
    virtual int updateAllStudentList(QString userId, uint groupId, int state);
    virtual int updateUpStudentList(QString userId, uint groupId, int operation);
    /****************** 老师端接口 end *****************/

private:
    static YMHandsUpManager *m_YMHandsUpManager;

    QString m_userId;
    QString m_lessonId;
    QString m_apiVersion;
    QString m_appVersion;
    QString m_token;
    QString executionPlanId;
    uint m_groupId;
};

#endif // YMHANDSUPMANAGER_H
