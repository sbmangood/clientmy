#ifndef YMCRYPT_H
#define YMCRYPT_H

#include <QObject>

class YMCrypt
{
    public:
        static QString encrypt(QString content);
        static QString decrypt(QString content);

    private:
        YMCrypt();
};

#endif // YMCRYPT_H
