#ifndef YMSEEK_H
#define YMSEEK_H

#include "./ymaudiodecoder.h"
class YMSeek
{
    public:
        YMSeek();
        static void doSeek(PlayerState *ps, double increase);
        static void seeking(PlayerState *ps);
};
#endif // YMSEEK_H
