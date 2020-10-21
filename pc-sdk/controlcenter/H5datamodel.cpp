#include "H5datamodel.h"

H5dataModel::H5dataModel(QString docId,QString courseWareType,QString pageNo,QString url,int currentAnimStep) :
    m_docId(docId),
    m_courseWareType(courseWareType),
    m_pageNo(pageNo),
    m_url(url),
    m_currentAnimStep(currentAnimStep)
{

}
