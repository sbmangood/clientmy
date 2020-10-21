#ifndef FILECRYPT_H
#define FILECRYPT_H

#include <QObject>

class FileCrypt
{
    public:
        FileCrypt();

        static void encrypt(QString source, QString target);
        static QList<QString> decrypt(QString source);
        static QList<QString> analysisFile(QString filePath);
};

#endif // FILECRYPT_H
