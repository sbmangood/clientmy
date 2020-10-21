#ifndef YMENCRYPTION_H
#define YMENCRYPTION_H

#include <QObject>
#include <QMap>
#include <QStringList>
#include <QCryptographicHash>
#include <QDebug>
#include <QIODevice>

namespace YMEncryption
{

    static inline
    QString md5(const QString& data)
    {
        QCryptographicHash hash(QCryptographicHash::Md5);
        hash.addData(data.toUtf8());
        return QString(hash.result().toHex());
    }

    static inline
    QString signSort(const QMap<QString, QString> &dataMap)
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
    static inline
    QString signMapSort(const QVariantMap &dataMap)
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
}

#endif // YMENCRYPTION_H
