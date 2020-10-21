#ifndef BEAUTYMANAGER_H
#define BEAUTYMANAGER_H
/*
  管理美颜功能的类 待封装 待完善
*/
#include <QObject>
#include "renderWayA/Nama.h"
#include"renderWayA/GLWidget.h"
#include<QImage>
#include"../dataconfig/datahandl/datamodel.h"

class BeautyManager : public QObject
{
        Q_OBJECT
    public:
        explicit BeautyManager(QObject *parent = 0);
        ~BeautyManager();

        //for renderWay A
        QImage tempImage;
        std::tr1::shared_ptr<unsigned char> ImgFrames;
        GLWidget * initGlw;

        bool canUseBeautySdk = true;


        int currentRenderWay = 1;//当前的美颜的渲染线路 1 为xiangxin科技的SDK 渲染
        bool hasInitSdk = false;

    public:
        //renderWay A
        std::tr1::shared_ptr<NamaExampleNameSpace::Nama> nama;
        std::tr1::shared_ptr<unsigned char>  curretnImageFrame ;
    public:
    private:
        bool initBeautySDKSUccess = true;//初始化美颜sdk是否成功  默认 true

    signals:
        void hideBeautyButton();

    public slots:
        //开启美颜功能
        void setBeautyOn(bool isBeautyOn);//设置美颜的开关 isbeautyon false 为关  true 为开

        // renderWay A
        //磨皮 0 到  5.68
        void setCurBlurLevel(float level);
        //美白  0 到 1
        void setCurColorLevel(float level);
        //红润 0 - 1
        void setRedLevel(float level);
        //美颜
        uchar * beautyImage(uchar * img);

        bool checkHideBeautyButton();

public:
        void doHideBeautyButton();
};

#endif // BEAUTYMANAGER_H
