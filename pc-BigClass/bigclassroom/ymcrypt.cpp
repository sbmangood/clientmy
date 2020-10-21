#include "ymcrypt.h"
#include <QDebug>
#include <QString>
#include <QByteArray>

QString key = "lM1fVBa0";

YMCrypt::YMCrypt()
{

}

QString YMCrypt::encrypt(QString content)
{
    QByteArray bytes = content.toUtf8();
    for (int i = 0; i < key.size(); i++)
    {
        char c = key.toStdString().at(i);
        for (int j = 0; j < bytes.size(); j++)
        {
            bytes[j] = bytes.at(j) ^ c;
        }
    }
    return QString(bytes.toBase64());
}

QString YMCrypt::decrypt(QString content)
{
    QByteArray bytes = QByteArray::fromBase64(content.toUtf8());
    for (int i = key.size() - 1; i >= 0; i--)
    {
        char c = key.toStdString().at(i);
        for (int j = 0; j < bytes.size(); j++)
        {
            bytes[j] = bytes.at(j) ^ c;
        }
    }
    return QString(bytes);
}


