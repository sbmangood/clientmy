#ifndef YMCRYPT_H
#define YMCRYPT_H

#include <QObject>

class YMCrypt
{
    public:
        static QString encrypt(QString content);
        static QString decrypt(QString content);

        static void fileEncrypt(QString source, QString target);
        static QList<QString> fileDecrypt(QString source);
        static QList<QString> analysisFile(QString filePath);

        static QString md5(const QString& data);

        static QString signSort(const QMap<QString, QString> &dataMap);

        static QString signMapSort(const QVariantMap &dataMap);

    private:
        YMCrypt();
};

#endif // YMCRYPT_H
