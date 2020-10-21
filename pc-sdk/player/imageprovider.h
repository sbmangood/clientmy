#ifndef IMAGEPROVIDER_H
#define IMAGEPROVIDER_H
#include<QImage>
#include<QPixmap>
#include <QSet>
#include<QQuickImageProvider>

class ImageProvider : public QQuickImageProvider
{
    public:
        ImageProvider(): QQuickImageProvider(QQuickImageProvider::Image)
        {
        }

        QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize)
        {
            return this->image;
        }
    public:
        QImage image;
};

class Student
{

    public:
        Student()
        {
            m_camera = "1";
            m_microphone = "1";
        }
        virtual ~Student()
        {
        }

        QString m_studentId;
        QString m_studentUrl;
        QString m_studentType;
        QString m_studentName;

        QString m_camera;
        QString m_microphone;
};

class Teacher
{

    public:
        Teacher()
        {
            m_camera = "1";
            m_microphone = "1";
        }
        virtual ~Teacher()
        {
        }

        QString m_teacherId;
        QString m_teacherUrl;
        QString m_teacherName;
        QString m_teachPhone;

        QString m_camera;
        QString m_microphone;
    signals:
    protected slots:

};

class StudentData
{

    public:

        virtual ~StudentData()
        {
            m_cameraPhone.clear();
        }

        static StudentData  * gestance()
        {
            static StudentData * m_studentDatash = new StudentData();


            return m_studentDatash;
        }


        void insertIntoOnlineId(QString ids)
        {
            m_onlineId.insert(ids);
        }
        void removeOnlineId(QString ids)
        {
            m_onlineId.remove(ids);
        }
        bool justIdIsExit(QString ids)
        {
            return  m_onlineId.contains(ids);
        }

        QList<Student> m_student;
        Teacher m_teacher;
        QString m_lessonId;
        QString m_apiVersion;
        QString m_appVersion;
        QString m_token;
        QString m_curriculum; //课程名称
        bool m_dataInsertion;
        QString m_qqSign;
        QString m_channelKey;
        QString m_shewangSign;
        QString m_audioName;

        QString m_logTime;//登录客户端时间
        QString m_userName;//登录时的用户名

        QSet<QString> m_onlineId;

        QString m_address;
        QString m_startToEndTime;
        QString m_lessonType;//课程类型
        bool isNewPlay;

        int m_port;
        int m_udpPort = 5120;
        //协议类型 isTcpProtocol  true 为tcp协议   false为 udp协议
        bool m_isTcpProtocol = true;//默认 tcp协议

        Student m_selfStudent;
        QString m_mD5Pwd;
        QString m_sysInfo;
        QString m_phone;
        QString m_deviceInfo;

        QString m_camera;
        QString m_microphone;//本地的摄像头状态
        QString m_selectItemAddress; //选中ip

        QMap<QString, QPair<QString, QString> > m_cameraPhone; //存储所有的摄像头状态

        QString m_lat;//坐标
        QString m_lng;//坐标
        int m_classTimeLen;//一节课的课程时间 分钟显示

        double midHeight; // 中间画板高度
        double midWidth;
        double fullWidth;
        double fullHeight;

        QString strAppName; //记录当前应用程序的名称
        QString strAppFullPath; //记录当前应用程序的路径 + 名称, 方便加载dll文件的时候, 使用
        QString strAppFullPath_LogFile; //记录当前应用程序日志文件的路径 + 名称, 方便日志上传的服务器

        double spacingSize;

    private:
        StudentData()
        {
            m_camera = "1";
            m_microphone = "0";
            m_classTimeLen = 0;
            m_cameraPhone.clear();
            m_selectItemAddress = "";

            m_sysInfo =  QSysInfo::prettyProductName();
            m_deviceInfo = QSysInfo::buildCpuArchitecture();
            m_sysInfo.remove("#");
            m_sysInfo.remove("\n");
            m_deviceInfo.remove("#");
            m_deviceInfo.remove("\n");
        }

};


#endif // IMAGEPROVIDER_H
