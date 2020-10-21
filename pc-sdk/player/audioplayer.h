#ifndef AUDIOPLAYER_H
#define AUDIOPLAYER_H

#include <QObject>
#include <libzplay.h>

using namespace libZPlay;

class AudioPlayer : public QObject
{
        Q_OBJECT
    public:
        explicit AudioPlayer(QObject *parent = 0);
        void play();
        void setAudio(QString filename);
        void pause();
        void seek(int seconds);
        void stop();
        ~AudioPlayer();

    signals:

    public slots:

    private:
        ZPlay *player;
        QString currentAudio;
};

#endif // AUDIOPLAYER_H
