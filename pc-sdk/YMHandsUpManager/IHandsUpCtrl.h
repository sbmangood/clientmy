#ifndef IHANDSUPCTRL_H
#define IHANDSUPCTRL_H
#include <QObject>
#include <QJsonObject>
#include <QString>

// 老师操作类型
enum TEA_OPERATION
{
    FORCE_UP = 1,// 强制上台
    FORCE_DOWN = 2,// 强制下台
    AGREE = 3,// 同意发言
    REFUSE = 4// 拒绝发言
};

// 学生操作类型
enum STU_OPERATION
{
    REQUEST = 1,// 申请发言
    CANCEL = 2// 取消
};

class IHandsUpCtrl : public QObject
{
    Q_OBJECT
public:
    /**************************************************
     * @function：初始化举手上台组件
     * @param json: 初始化系列参数
     * @return：0成功，-1失败
     **************************************************/
    virtual int initHandsUp(QJsonObject json) = 0;

    /****************** 学生端接口 begin ***************/

    /**************************************************
     * @function：学生举手申请上台
     * @return：0成功，-1失败
     **************************************************/
    virtual int raiseHandForUp(QString userId, QString groupId) = 0;

    /**************************************************
     * @function：学生取消举手申请上台
     * @return：0成功，-1失败
     **************************************************/
    virtual int cancelHandsUp(QString userId, QString groupId) = 0;

    /**************************************************
     * @function：学生处理老师的审批结果
     * @param operation: 0-取消，1-上台
     * @return：0成功，-1失败
     **************************************************/
    virtual int processResponse(QString userId, int operation) = 0;

    /****************** 学生端接口 end *****************/

    /****************** 老师端接口 begin ***************/

    /**************************************************
     * @function：老师处理选择学生处理上台申请
     * @param userId: 选择学生的Id
     * @param groupId: 学生组Id
     * @param operation: FORCE_UP强制上台, FORCE_DOWN强制下台, AGREE同意发言, REFUSE拒绝发言
     * @return：0成功，-1失败
     **************************************************/
    virtual int processHandsUp(QString userId, uint groupId, TEA_OPERATION operation) = 0;

    /**************************************************
     * @function：更新学生全员列表
     * @param userId: 学生Id
     * @param groupId: 学生组Id
     * @param state: 0-离开，1-进入
     * @return：0成功，-1失败
     **************************************************/
    virtual int updateAllStudentList(QString userId, uint groupId, int state) = 0;

    /**************************************************
     * @function：更新申请上台学生列表
     * @param userId: 学生Id
     * @param groupId: 学生组Id
     * @param operation: 0-取消，1-上台
     * @return：0成功，-1失败
     **************************************************/
    virtual int updateUpStudentList(QString userId, uint groupId, int operation) = 0;

    /****************** 老师端接口 end *****************/

signals:
    /****************************************************
     * @function：学生申请上台或取消上台、老师同意或拒绝学生上台
     * @param userId: 学生Id
     * @param operation: 0-取消，1-上台
     ***************************************************/
    void sigHandsUpEvent(QString userId, int operation);

    /****************************************************
     * @function：更新申请上台发言学生列表信号
     * @param userId: 学生Id
     * @param operation: 0-取消，1-上台
     ***************************************************/
    void sigUpdateUpStudentList(QString userId, int operation);

    /****************************************************
     * @function：更新全体学生成员列表信号
     * @param userId: 学生Id
     * @param state: 0-离开，1-进入
     ***************************************************/
    void sigUpdateAllStudentList(QString userId, int state);

    /****************************************************
     * @function：举手消息内容content
     * @param content: content内容
     ***************************************************/
    void sigMsgContent(QJsonObject content);
};
Q_DECLARE_INTERFACE(IHandsUpCtrl,"org.qt-project.Qt.Plugin.IHandsUpCtrl/1.0")
#endif // IHANDSUPCTRL_H
