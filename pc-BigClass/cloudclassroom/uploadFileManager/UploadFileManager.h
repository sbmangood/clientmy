#include <QObject>
#include <QString>
#include <QThread>
#include <QJsonObject>
#include <QMutex>
#include <YMUploadManager.h>

class YMUpLoadFileManager : public QThread, public YMUploadManager, public YMUploadCallback
{
    Q_OBJECT
public:
    YMUpLoadFileManager();

    virtual void ProgressCallback(size_t increment, int64_t transfered, int64_t total, void* userData);

    virtual void upLoadSuccess(std::string fileUrl, long fileSize, std::string upFileMark);

    virtual void upLoadFailed(std::string errCode, std::string upFileMark);


    void setBasicParams(QJsonObject basicParamsObj);

    QJsonObject getBasicParams();

    void stop()// 结束线程
    {
        is_runnable = false;
    }

protected:
    void run();// 线程运行

private:
    QMutex m_mutex;
    QJsonObject m_basicParamsObj;
    bool is_runnable = true;// 是否可运行

signals:
    void sigUploadSuccess(QString fileUrl, long fileSize, QString upFileMark);// 文件上传成功信号
    void sigUploadFailed(QString errCode, QString upFileMark); // 文件上传失败信号
};

// 上传文件类
class UploadFileManager : public QObject
{
    Q_OBJECT
public:
    explicit UploadFileManager();
    virtual ~UploadFileManager();

    // 上传文件接口(老接口))
    Q_INVOKABLE int upLoadFileToServer(QString upFileMark, QString filePath, QString lessonId, QString userId, QString token, QString enType="",
                                       int time_out=600000, QString httpUrl="api.yimifudao.com/v2.4",
                                       QString appVersion="2.4.001", QString apiVersion="2.5");

    // 新上传接口(已兼容老接口)
    Q_INVOKABLE int YMUpLoadFileToOss(const QString& userId, const QString& envType, const QString& filePath, const QString& upFileMark = "");

signals:
    void sigUploadSuccess(QString fileUrl, long fileSize, QString upFileMark);// 文件上传成功信号

    void sigUploadFailed(QString errCode, QString upFileMark); // 文件上传失败信号
};
