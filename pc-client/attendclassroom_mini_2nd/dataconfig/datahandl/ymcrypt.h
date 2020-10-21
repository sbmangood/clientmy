#ifndef YMCRYPT_H
#define YMCRYPT_H

#include <QObject>
#include <QDebug>
class YMCrypt
{
    public:
        static QByteArray encrypt(QString content);
        static QString decrypt(QByteArray bytes);
        static QString YMCrypt::tcpencrypt(QString content);
        static QString YMCrypt::tcpdecrypt(QString content);

    private:
        YMCrypt();
};

#endif // YMCRYPT_H
