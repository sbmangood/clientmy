#pragma once

#include <vector>
#include <memory>
#include <string>
#include <sstream>
#include<QString>
#include<QDebug>
#include<QImage>
//class CCameraDS;
namespace NamaExampleNameSpace
{
class Nama
{
    enum MODE
    {
        PROP,
        LANDMARK
    };
public:
    int m_frameID;
    int m_curCameraIdx;
    Nama();
    ~Nama();
    bool Init(const int width = 1280, const int height = 720);
    void SwitchRenderMode();
    void SwitchBeauty();
    void PreBundle();
    void NextBundle();
    void SetCurrentBundle(int index);
    void SetCurrentShape(int index);
    void NextShape();
    void UpdateFilter();
    void UpdateBeauty();
    void ScissorFrameBuffer(std::tr1::shared_ptr<unsigned char> frame);
    std::tr1::shared_ptr<unsigned char> ConvertBetweenBGRAandRGBA(std::tr1::shared_ptr<unsigned char> frame);
    uchar * RenderItems(uchar * frame);
    std::tr1::shared_ptr<unsigned char> RenderEx();
    void DrawLandmarks(uchar *frame);

    int getErrorCode();
private:
    void CreateBundle();
    void CreateBundle(const int idx);
    void DrawPoint(uchar *frame, int x, int y, unsigned char r = 255, unsigned char g = 240, unsigned char b = 33);

private:
    static std::tr1::shared_ptr<Nama> m_pInstance;
    //std::tr1::shared_ptr<CCameraDS> m_cap;
    int m_curBundleIdx;

    int m_face_shape;//0 女神 1 网红 2 自然 3 推荐
    MODE m_mode;
    std::vector<int> m_propHandles;
    int m_beautyHandles;
    int m_gestureHandles;
    int m_frameWidth, m_frameHeight;
    static bool m_hasSetup;
public:
    int m_isBeautyOn;//美颜 滤镜使用是 此属性也需要为true
    int m_isDrawProp;//贴纸

    int m_isDrawPoints;//
    int m_isDrawWireFram;
    int m_isDrawSplines;

    int m_curFilterIdx;//滤镜的index
    float m_curColorLevel;//美白 0 - 1
    float m_curBlurLevel;//磨皮 0 -  5.68
    float m_curCheekThinning;//瘦脸 0 - 1
    float m_curEyeEnlarging;//大眼 0 - 1
    float m_faceShapeLevel;//程度 0 - 1
    float m_redLevel;//红润 0 - 1
    std::string m_curTranslation;
    std::string m_curRotation;

    static std::string _filters[6];
};
}

template < class T>
std::string ConvertToString(T value) {
    std::stringstream ss;
    ss << value;
    return ss.str();
}
