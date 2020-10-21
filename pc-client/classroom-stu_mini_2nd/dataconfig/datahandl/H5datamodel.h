#ifndef H5DATAMODEL_H
#define H5DATAMODEL_H

#include <QObject>
#include <QMap>

class H5dataModel
{
public:
    H5dataModel(QString docId,QString courseWareType,QString pageNo,QString url,int currentAnimStep);

public:
    QString m_docId;
    QString m_courseWareType;
    QString m_pageNo;
    QString m_url;
    int m_currentAnimStep;
};

#endif // H5DATAMODEL_H
