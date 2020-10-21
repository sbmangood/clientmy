#ifndef YMHTTPRESPONSEHANDLER_H
#define YMHTTPRESPONSEHANDLER_H

#include "QObject"

class YMHttpResponseHandler
{
    public:
        virtual void onResponse(int reqCode, const QString& data) = 0;
};

#endif // YMHTTPRESPONSEHANDLER_H
