#include <QFile>
#include <QDebug>
#include <QString>
#include <QByteArray>
#include <QDataStream>
#include <QTextStream>
#include "ymcrypt.h"
#include <QCryptographicHash>

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

void YMCrypt::fileEncrypt(QString source, QString target)
{
    QFile file(source);
    if (!file.open(QIODevice::ReadOnly))
    {
        qDebug() << "open file error:file path = " << source;
        return;
    }
    QFile outFile(target);
    if (!outFile.open(QIODevice::WriteOnly))
    {
        qDebug() << "open file error:file path = " << target;
        return;
    }

    QDataStream out(&outFile);
    QTextStream in(&file);
    while (! in.atEnd())
    {
        QString line = in.readLine();
        out << YMCrypt::encrypt(line);
    }
}

QList<QString> YMCrypt::fileDecrypt(QString source)
{
    QFile file(source);
    QList<QString> list;
    if (!file.open(QIODevice::ReadOnly))
    {
        qDebug() << "open file error:file path = " << source;
        return list;
    }
    QDataStream in(&file);
    while (! in.atEnd())
    {
        QString line;
        in >> line;
        list.append(YMCrypt::decrypt(line));
    }
    return list;
}

QList<QString> YMCrypt::analysisFile(QString filePath)
{
    QFile file(filePath);
    QList<QString> list;
    if (!file.open(QIODevice::ReadOnly))
    {
        qDebug() << "open file error:file path = " << filePath;
        return list;
    }

    QTextStream in(&file);
    in.setCodec("utf-8");
    in.setGenerateByteOrderMark(true);
    while (! in.atEnd())
    {
        QString line = in.readLine();
        list.append(line);
    }
    return list;
}

QString YMCrypt::md5(const QString& data)
{
    QCryptographicHash hash(QCryptographicHash::Md5);
    hash.addData(data.toUtf8());
    return QString(hash.result().toHex());
}


QString YMCrypt::signSort(const QMap<QString, QString> &dataMap)
{
    QString sign = "";
    for(auto it = dataMap.begin(); it != dataMap.end(); ++it)
    {
        sign.append(it.key()).append("=").append(it.value());
        if(it != dataMap.end() - 1)
        {
            sign.append("&");
        }
    }
    return sign;
}

QString YMCrypt::signMapSort(const QVariantMap &dataMap)
{
    QString sign = "";
    for(auto it = dataMap.begin(); it != dataMap.end(); ++it)
    {
        sign.append(it.key()).append("=").append(QString::fromUtf8( it.value().toByteArray()));
        if(it != dataMap.end() - 1)
        {
            sign.append("&");
        }
    }
    return sign;
}
