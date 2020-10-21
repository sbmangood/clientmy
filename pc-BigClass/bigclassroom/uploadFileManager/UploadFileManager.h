#include <QObject>
#include <QThread>
#include <QMutex>
#include <QJsonObject>

// 上传文件线程
class UploadFileThread : public QThread
{
    Q_OBJECT
public:
    explicit UploadFileThread();
    virtual ~UploadFileThread();

    void setBasicParams(QJsonObject basicParamsObj);
    QJsonObject getBasicParams();

protected:
    void run();

private:
    QMutex m_basicMutex;
    QJsonObject m_basicParamsObj;

signals:
    void sigUploadSuccess(QString fileUrl, long fileSize);
    void sigUploadFailed();
};

// 上传文件类
class UploadFileManager : public QObject
{
    Q_OBJECT
public:
    explicit UploadFileManager();
    virtual ~UploadFileManager();

    // 上传文件接口
    Q_INVOKABLE int upLoadFileToServer(QString filePath, QString lessonId, QString userId, QString token, QString enType="",
                                       int time_out=10000, QString httpUrl="api.yimifudao.com/v2.4",
                                       QString appVersion="2.4.001", QString apiVersion="2.5");
private:
    UploadFileThread* m_uploadFileThread;

signals:
    void sigUploadSuccess(QString fileUrl, long fileSize);// 文件上传成功信号
    void sigUploadFailed(); // 文件上传失败信号
};
