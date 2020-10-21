#include "filecrypt.h"
#include <QFile>
#include <QDebug>
#include <QDataStream>
#include <QTextStream>
#include "./ymcrypt.h"

FileCrypt::FileCrypt()
{

}

void FileCrypt::encrypt(QString source, QString target)
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

QList<QString> FileCrypt::analysisFile(QString filePath)
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


QList<QString> FileCrypt::decrypt(QString source)
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
