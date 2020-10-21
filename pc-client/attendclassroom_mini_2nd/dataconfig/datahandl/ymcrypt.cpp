#include "ymcrypt.h"

#include <QString>
#include <QByteArray>
#include "./datamodel.h"

QString key = "lM1fVBa0";

YMCrypt::YMCrypt()
{

}

//加密数据包
QByteArray YMCrypt::encrypt(QString content)
{
    //数据包结构  包头+userID+lessonID+消息体+包尾
    //包头两字节 为整个数据包的大小
    //userId 6字节 lessonId 6字节
    //包尾 一个字节 '\n'
    qulonglong userId = StudentData::gestance()->m_selfStudent.m_studentId.toULongLong();
    qulonglong lessonId = StudentData::gestance()->m_lessonId.toULongLong();
    QByteArray b;
    b.append('0');
    b.append('0');
    //处理userId Little Endian对齐
    for (int i = 0; i < 6; i++)
    {
        b.append(userId & 255);
        userId = userId >> 8;
    }
    //处理lessonId Little Endian对齐
    for (int i = 0; i < 6; i++)
    {
        b.append(lessonId & 255);
        lessonId = lessonId >> 8;
    }
    b.append(content.toUtf8());
    for (int i = 0; i < key.size(); i++)
    {
        char c = key.toStdString().at(i);
        for (int j = 0; j < b.size(); j++)
        {
            b[j] = b.at(j) ^ c;
        }
    }
    b.append('\n');
    //处理包大小 Little Endian对齐
    quint32  dataSize = b.size();
    for (int i = 0; i < 2; i++)
    {
        b[i] = dataSize & 255;
        dataSize = dataSize >> 8;
    }
    return b;
}

//解密数据包
QString YMCrypt::decrypt(QByteArray bytes)
{
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

QString YMCrypt::tcpencrypt(QString content)
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

QString YMCrypt::tcpdecrypt(QString content)
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

