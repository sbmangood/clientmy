/**
* FU SDK使用者可以将拿到处理后的frame图像与自己的原有项目对接
* 请FU SDK使用者直接参考示例放至代码至对应位置
*
* FU SDK与camera无耦合，不关心数据的来源，只要图像内容正确且和宽高吻合即可GlobalValue
*
* Created by liujia on 2018/1/3 mybbs2200@gmail.com.
*/
//#include "CameraDS.h"
#include "Nama.h"
#include <fstream>
#include <iostream>
#include <QFile>
#include <tchar.h>

#include "./dataconfig/datahandl/datamodel.h"

#include "GlobalValue.h"        //nama SDK 的资源文件
#include"./include/authpack.h"  //nama SDK 的key文件
#include"./include/funama.h"    //nama SDK 的头文件
#pragma comment(lib, "nama.lib")//nama SDK 的lib文件

//======================= >>>
//初始化OpenGL, 需要使用的库
//参考网址: https://github.com/Faceunity/FULivePC/blob/master/docs/FUNama%20SDK%20%E5%B8%AE%E5%8A%A9%E6%96%87%E6%A1%A3.md
#include <windows.h>
#include <stdio.h>
#pragma comment(lib,"opengl32.lib")
#pragma comment(lib,"glu32.lib")

PIXELFORMATDESCRIPTOR pfd =
{
    sizeof(PIXELFORMATDESCRIPTOR),
    1u,
    PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER | PFD_DRAW_TO_WINDOW,
    PFD_TYPE_RGBA,
    32u,
    0u, 0u, 0u, 0u, 0u, 0u,
    8u,
    0u,
    0u,
    0u, 0u, 0u, 0u,
    24u,
    8u,
    0u,
    PFD_MAIN_PLANE,
    0u,
    0u, 0u
};

void InitOpenGL()
{
    HWND hw = CreateWindowExA(
                0, "EDIT", "", ES_READONLY,
                0, 0, 1, 1,
                NULL, NULL,
                GetModuleHandleA(NULL), NULL);
    HDC hgldc = GetDC(hw);
    int spf = ChoosePixelFormat(hgldc, &pfd);
    int ret = SetPixelFormat(hgldc, spf, &pfd);
    HGLRC hglrc = wglCreateContext(hgldc);
    wglMakeCurrent(hgldc, hglrc);

    //hglrc就是创建出的OpenGL context
    qDebug() << "hw=%08x hgldc=%08x spf=%d ret=%d hglrc=%08x" << hw << hgldc << spf << ret << hglrc;
}

//检查当前的OpenGL环境, 是否可用
bool doCheckOpenGL_Status()
{
    //OpenGL函数的地址，如果4个中任意一个不为空值，则OpenGL环境是可用的
    //此后的所有Nama SDK调用都会基于这个context
    //如果客户端有其他绘制创建了另外的OpenGL context，那么请确保调用Nama接口时一直是同一个context
    if(
            NULL == wglGetProcAddress("glGenFramebuffersARB") && \
            NULL == wglGetProcAddress("glGenFramebuffersOES") && \
            NULL == wglGetProcAddress("glGenFramebuffersEXT") && \
            NULL == wglGetProcAddress("glGenFramebuffers")
            )
    {
        //美颜失败的时候, 减少打印输出
        static int i = 0;
        if((i % 100) == 0)
        {
            qDebug() << "doCheckOpenGL_Status is false. Fail" << __LINE__;
        }
        i++;

        return false;
    }

    return true;
}

// <<<=======================

using namespace NamaExampleNameSpace;
bool Nama::m_hasSetup = false;

namespace NamaExampleNameSpace
{
size_t FileSize(std::ifstream& file)
{
    std::streampos oldPos = file.tellg();

    file.seekg(0, std::ios::beg);
    std::streampos beg = file.tellg();
    file.seekg(0, std::ios::end);
    std::streampos end = file.tellg();

    file.seekg(oldPos, std::ios::beg);

    return static_cast<size_t>(end - beg);
}

bool LoadBundle(const std::string& filepath, std::vector<char>& data)
{
    //============================
    //判断文件, 是否存在
    if(!QFile::exists(QString::fromStdString(filepath)))
    {
        qDebug() << "!QFile::exists(filepath)" << __LINE__;
        return false;
    }
    qDebug() << "QFile::exists(filepath) = true." << filepath.c_str() << __LINE__;

    //============================
    std::ifstream fin(filepath, std::ios::binary);
//    std::ifstream fin(_TEXT(filepath), std::ios::binary);
    if (false == fin.good())
    {
        fin.close();
        qDebug() << "LoadBundle fin.good() false" << "eof" << fin.eof() << "fail" << fin.fail() << "bad" << fin.bad() << filepath.c_str() << __LINE__;

//        if(fin.fail())
//        {

//        }

        return false;
    }

    //============================
    size_t size = FileSize(fin);
    if (0 == size)
    {
        fin.close();
        qDebug() << "LoadBundle size == 0" << __LINE__;
        return false;
    }
    data.resize(size);
    fin.read(reinterpret_cast<char*>(&data[0]), size);

    fin.close();
    return true;
}
}

std::string Nama::_filters[6] = { "origin", "delta", "electric", "slowlived", "tokyo", "warm" };

Nama::Nama()
    : m_frameID(0),
      m_curBundleIdx(0),
      m_mode(PROP),
      m_isBeautyOn(false),
      m_isDrawProp(1),
      m_frameWidth(0),
      m_frameHeight(0),
      m_curFilterIdx(0),
      m_beautyHandles(0),
      m_gestureHandles(0),
      m_propHandles(0),
      m_curColorLevel(0.0f),
      m_curBlurLevel(0.0f),
      m_curCheekThinning(0.0f),
      m_curEyeEnlarging(0.0f),
      m_face_shape(3),
      m_redLevel(0.6f),
      m_faceShapeLevel(0.0f)
{
    m_curCameraIdx = 0;
    qDebug() << "Nama::Nama" << fuGetVersion() << __LINE__;

    //m_cap = std::tr1::shared_ptr<CCameraDS>(new CCameraDS);
}

Nama::~Nama()
{
    if (true == m_hasSetup)
    {
        fuDestroyAllItems();//Note: 切忌使用一个已经destroy的item
        fuOnDeviceLost();//Note: 这个调用销毁nama创建的OpenGL资源
    }
    //fuSetup整个程序只需要运行一次，销毁某个子窗口时只需要调用上述两个函数。
    //Tips:如果其他窗口还会用这些资源，那么资源创建应该在父窗口。程序运行期间一直持有这些资源.
}



bool Nama::Init(const int width, const int height)
{
    int value = -1;

    m_frameWidth = width;
    m_frameHeight = height;

    //    if (false == m_cap->OpenCamera(m_curCameraIdx, false, m_frameWidth, m_frameHeight))
    //    {
    //        qDebug() << "缺少摄像头，推荐使用 Logitech C920，然后安装官方驱动。\n Error: Missing camera! " << std::endl ;
    //    }

//#if 0
    //=======================
    //使用exe文件的绝对路径
    static bool bOnlyOnce = false;
    QString strBundleFolder = "";
    if(!bOnlyOnce)
    {
        strBundleFolder = StudentData::gestance()->strAppFullPath;
        strBundleFolder = strBundleFolder.replace(StudentData::gestance()->strAppName, "assets");
        if(strBundleFolder.length() <= 0)
        {
            qDebug() << "Nama::Init return false." <<  __LINE__;
            return false;
        }
        strBundleFolder.replace("\\","/");
        strBundleFolder = strBundleFolder.append("/");
        strBundleFolder = strBundleFolder.toUtf8();
        g_fuDataDir_Absolute = strBundleFolder.toStdString(); //得到绝对路径
        bOnlyOnce = true;
    }
//#endif

    //=======================
    if (false == m_hasSetup)
    {
        //读取nama数据库，初始化nama
        qDebug() << "Nama::Init" << g_fuDataDir_Absolute.c_str() << g_fuDataDir.c_str() << __LINE__;
        std::vector<char> v3data;
        if (false == LoadBundle(g_fuDataDir + g_v3Data, v3data)) //相对路径
        {
            qDebug() << QStringLiteral("Nama::Init Error: 缺少数据文件") << g_fuDataDir_Absolute.c_str() << g_fuDataDir.c_str() <<g_v3Data.c_str() << __LINE__;

            //相对路径失败了, 再次尝试绝对路径
            if(false == LoadBundle(g_fuDataDir_Absolute + g_v3Data, v3data))     //绝对路径
            {
                qDebug() << QStringLiteral("Nama::Init Error: 缺少数据文件") << g_fuDataDir_Absolute.c_str() << g_fuDataDir.c_str() <<g_v3Data.c_str() << __LINE__;
                return false;
            }
        }

        //InitOpenGL, 需要在fuSetup之前, 因为在这个时候, OpenGL, 可能就不能使用了, 可以通过下面的函数返回值, 判断OpenGL, 是否可用
        //OpenGL环境, 不能使用的时候, 重新InitOpenGL
        if(!doCheckOpenGL_Status())
        {
            //            return false;
            InitOpenGL();
        }

        value = fuSetup(reinterpret_cast<float*>(&v3data[0]), NULL, g_auth_package, sizeof(g_auth_package));
        qDebug() << "Nama::Init" << value << __LINE__;

        std::vector<char> anim_model_data;
        if (false == LoadBundle(g_fuDataDir + g_anim_model, anim_model_data))
        {
            qDebug() << QStringLiteral("Nama::Init Error: 缺少数据文件") << g_fuDataDir_Absolute.c_str() << g_fuDataDir.c_str() <<g_anim_model.c_str() << __LINE__;

            //相对路径失败了, 再次尝试绝对路径
            if(false == LoadBundle(g_fuDataDir_Absolute + g_anim_model, anim_model_data))     //绝对路径
            {
                qDebug() << QStringLiteral("Nama::Init Error: 缺少数据文件") << g_fuDataDir_Absolute.c_str() << g_fuDataDir.c_str() <<g_anim_model.c_str() << __LINE__;
                return false;
            }
        }

        value = fuLoadAnimModel(reinterpret_cast<float*>(&anim_model_data[0]), anim_model_data.size());
        qDebug() << "Nama::Init" << value << __LINE__;

        fuSetExpressionCalibration(1);
        m_hasSetup = true;
    }
    else
    {
        fuOnDeviceLost();
        m_hasSetup = false;
    }

    {
        std::vector<char> propData;
        if (false == LoadBundle(g_fuDataDir + g_faceBeautification, propData))
        {
            qDebug() << QStringLiteral("Nama::Init Error: 缺少数据文件") << g_fuDataDir_Absolute.c_str() << g_fuDataDir.c_str() <<g_faceBeautification.c_str() << __LINE__;

            //相对路径失败了, 再次尝试绝对路径
            if(false == LoadBundle(g_fuDataDir_Absolute + g_faceBeautification, propData))     //绝对路径
            {
                qDebug() << QStringLiteral("Nama::Init Error: 缺少数据文件") << g_fuDataDir_Absolute.c_str() << g_fuDataDir.c_str() <<g_faceBeautification.c_str() << __LINE__;
                return false;
            }
        }

        m_beautyHandles = fuCreateItemFromPackage(&propData[0], propData.size());

        //"origin", "delta", "electric", "slowlived", "tokyo", "warm"等参数的设置
        fuItemSetParams(m_beautyHandles, QString("filter_name").toLatin1().data(), &_filters[m_curFilterIdx][0]);
        fuItemSetParamd(m_beautyHandles, QString("is_opengl_es").toLatin1().data(), 0);
        fuItemSetParamd(m_beautyHandles, QString("color_level").toLatin1().data(), m_curColorLevel);
        fuItemSetParamd(m_beautyHandles, QString("blur_level").toLatin1().data(), m_curBlurLevel);
        fuItemSetParamd(m_beautyHandles, QString("cheek_thinning").toLatin1().data(), m_curCheekThinning);
        fuItemSetParamd(m_beautyHandles, QString("eye_enlarging").toLatin1().data(), m_curEyeEnlarging);
        fuItemSetParamd(m_beautyHandles, QString("face_shape_level").toLatin1().data(), m_faceShapeLevel);
        fuItemSetParamd(m_beautyHandles, QString("red_level").toLatin1().data(), m_redLevel);
        fuItemSetParamd(m_beautyHandles, QString("face_shape").toLatin1().data(), m_face_shape);
    }

    //读取手势识别道具
    {
        std::vector<char> gestureData;
        if (false == LoadBundle(g_fuDataDir + g_gestureRecongnition, gestureData))
        {
            qDebug() << QStringLiteral("Nama::Init Error: 缺少数据文件") << g_fuDataDir_Absolute.c_str() << g_fuDataDir.c_str() <<g_gestureRecongnition.c_str() << __LINE__;

            //相对路径失败了, 再次尝试绝对路径
            if(false == LoadBundle(g_fuDataDir_Absolute + g_gestureRecongnition, gestureData))     //绝对路径
            {
                qDebug() << QStringLiteral("Nama::Init Error: 缺少数据文件") << g_fuDataDir_Absolute.c_str() << g_fuDataDir.c_str() <<g_gestureRecongnition.c_str() << __LINE__;
                return false;
            }
        }

        m_gestureHandles = fuCreateItemFromPackage(&gestureData[0], gestureData.size());
    }
    m_propHandles.resize(g_propCount);
    //加载一个bundle
    m_curBundleIdx = -1;
    NextBundle();

    fuSetDefaultOrientation(0);

    return true;
}

void Nama::SwitchRenderMode()
{
    static MODE nextMode[] = { LANDMARK, PROP };
    m_mode = nextMode[m_mode];
}

void Nama::SwitchBeauty()
{
    m_isBeautyOn = !m_isBeautyOn;
}

void Nama::PreBundle()
{
    if (!m_isDrawProp)return;

    --m_curBundleIdx;
    if (m_curBundleIdx < 0)
    {
        m_curBundleIdx += m_propHandles.size();
    }

    CreateBundle(m_curBundleIdx);
}

void Nama::NextBundle()
{
    if (!m_isDrawProp)return;

    ++m_curBundleIdx;
    m_curBundleIdx %= m_propHandles.size();

    CreateBundle(m_curBundleIdx);
}

void Nama::SetCurrentBundle(int index)
{
    if (!m_isDrawProp)return;
    if (0 <= index <= g_propCount)
    {
        m_curBundleIdx = index;
        CreateBundle(m_curBundleIdx);
    }
}

void Nama::SetCurrentShape(int index)
{
    if (false == m_isBeautyOn)return;
    if (0 <= index <= 3)
    {
        m_face_shape = index;
        int res = fuItemSetParamd(m_beautyHandles, QString("face_shape").toLatin1().data(), m_face_shape);
    }
}

void Nama::NextShape()
{
    if (false == m_isBeautyOn)
    {
        return;
    }
    ++m_face_shape;
    m_face_shape %= 3;
    int res = fuItemSetParamd(m_beautyHandles, QString("face_shape").toLatin1().data(), m_face_shape);
    qDebug() << "Nama::NextShape: " << m_face_shape << __LINE__;
}

void Nama::UpdateFilter()
{
    if (false == m_isBeautyOn)return;

    fuItemSetParams(m_beautyHandles, QString("filter_name").toLatin1().data(), &_filters[m_curFilterIdx][0]);
}

void Nama::UpdateBeauty()
{
    if (false == m_isBeautyOn)return;

    fuItemSetParamd(m_beautyHandles,  QString("color_level").toLatin1().data(), m_curColorLevel);
    fuItemSetParamd(m_beautyHandles,  QString("blur_level").toLatin1().data(), m_curBlurLevel);
    fuItemSetParamd(m_beautyHandles,  QString("cheek_thinning").toLatin1().data(), m_curCheekThinning);
    fuItemSetParamd(m_beautyHandles,  QString("eye_enlarging").toLatin1().data(), m_curEyeEnlarging);
    fuItemSetParamd(m_beautyHandles,  QString("face_shape_level").toLatin1().data(), m_faceShapeLevel);
    fuItemSetParamd(m_beautyHandles,  QString("red_level").toLatin1().data(), m_redLevel);
}

//加载全部道具，初始化稍慢
void Nama::CreateBundle()
{
    for (int i(0); i != g_propCount; ++i)
    {
        CreateBundle(i);
    }
}

//按需加载道具，但是在切换的时候会卡顿一下
void Nama::CreateBundle(const int idx)
{
    if (0 == m_propHandles[idx])
    {
        std::vector<char> propData;
        if (false == LoadBundle(g_fuDataDir + g_propName[idx], propData))
        {
            qDebug() << QStringLiteral("Nama::CreateBundle Error: 缺少数据文件") << g_fuDataDir_Absolute.c_str() << g_fuDataDir.c_str() <<g_propName[idx].c_str() << __LINE__;

            //相对路径失败了, 再次尝试绝对路径
            if(false == LoadBundle(g_fuDataDir_Absolute + g_propName[idx], propData))     //绝对路径
            {
                qDebug() << QStringLiteral("Nama::CreateBundle Error: 缺少数据文件") << g_fuDataDir_Absolute.c_str() << g_fuDataDir.c_str() <<g_propName[idx].c_str() << __LINE__;
                //return false;
            }
        }

        m_propHandles[idx] = fuCreateItemFromPackage(&propData[0], propData.size());
    }

//    return true;
}

//左右翻转图像内容
void Nama::ScissorFrameBuffer(std::tr1::shared_ptr<unsigned char> frame)
{
    int size = m_frameWidth * m_frameHeight * 4;
    for (int i = 0; i < m_frameHeight; i++)
    {
        auto ptr = frame.get() + i * m_frameWidth * 4 + m_frameWidth * 4;
        auto qptr = frame.get() + i * m_frameWidth * 4;
        for (int j = 0; j < m_frameWidth * 0.31640625f; j++)
        {
            qptr[0] = 0;
            qptr[1] = 0;
            qptr[2] = 0;
            qptr[3] = 0;
            qptr += 4;
            ptr[0] = 0;
            ptr[1] = 0;
            ptr[2] = 0;
            ptr[3] = 0;
            ptr -= 4;
        }
    }
}

std::tr1::shared_ptr<unsigned char> Nama::ConvertBetweenBGRAandRGBA(std::tr1::shared_ptr<unsigned char> frame)
{
    int size = m_frameWidth * m_frameHeight * 4;
    auto temp_frame = std::tr1::shared_ptr<unsigned char>(new unsigned char[size]);
    int offset = 0;
    //    if (IsBadReadPtr(frame.get(), 4))//can't debug run
    //    {
    //        printf("The camera is usered by other programs!\n");
    //        return temp_frame;
    //    }
    auto output = temp_frame.get();
    auto input = frame.get();
    for (int i = 0; i < m_frameHeight; i++)
    {
        for (int j = 0; j < m_frameWidth; j++)
        {
            output[offset] = input[offset + 2];
            output[offset + 1] = input[offset + 1];
            output[offset + 2] = input[offset];
            output[offset + 3] = input[offset + 3];

            offset += 4;
        }
    }

    return temp_frame;
}
int Nama::getErrorCode()
{
    return fuGetSystemError();
}

//渲染函数
uchar * Nama::RenderItems(uchar *frame)
{
    //std::tr1::shared_ptr<unsigned char> m_frame = std::tr1::shared_ptr<unsigned char>(new unsigned char[3686400]);
    //ConvertBetweenBGRAandRGBA(frame);
    switch (m_mode)
    {
    case PROP:
        if (1 == m_isBeautyOn && 1 == m_isDrawProp)
        {
            int handle[2] = { m_beautyHandles, m_propHandles[m_curBundleIdx] };
            //如果输入的数据不是BGRA的，可以调用fuRenderItemsEx替换调用fuRenderItems。 支持的格式有FU_FORMAT_BGRA_BUFFER 、 FU_FORMAT_NV21_BUFFER 、FU_FORMAT_I420_BUFFER 、FU_FORMAT_RGBA_BUFFER
            fuRenderItemsEx2(FU_FORMAT_RGBA_BUFFER, reinterpret_cast<int*>(frame), FU_FORMAT_BGRA_BUFFER, reinterpret_cast<int*>(frame),
                             m_frameWidth, m_frameHeight, m_frameID, handle, 2, NAMA_RENDER_FEATURE_FULL | NAMA_RENDER_OPTION_FLIP_X, NULL);
        }
        else if (1 == m_isDrawProp && 0 == m_isBeautyOn)
        {
            fuRenderItemsEx2(FU_FORMAT_RGBA_BUFFER, reinterpret_cast<int*>(frame), FU_FORMAT_BGRA_BUFFER, reinterpret_cast<int*>(frame),
                             m_frameWidth, m_frameHeight, m_frameID, &m_propHandles[m_curBundleIdx], 1, NAMA_RENDER_FEATURE_FULL | NAMA_RENDER_OPTION_FLIP_X, NULL);
        }
        else if (1 == m_isBeautyOn && 0 == m_isDrawProp)
        {
            //            qDebug() << "Nama::RenderItems" << __LINE__;
            //            qDebug() << "gl ver test \n"<<wglGetProcAddress("glGenFramebuffersARB")<<wglGetProcAddress("glGenFramebuffersOES")<<wglGetProcAddress("glGenFramebuffersEXT")<< wglGetProcAddress("glGenFramebuffers");

            fuRenderItemsEx2(FU_FORMAT_RGBA_BUFFER, reinterpret_cast<int*>(frame), FU_FORMAT_BGRA_BUFFER, reinterpret_cast<int*>(frame),
                             m_frameWidth, m_frameHeight, m_frameID, &m_beautyHandles, 1, NAMA_RENDER_FEATURE_FULL | NAMA_RENDER_OPTION_FLIP_X, NULL);
            //            qDebug() << "Nama::RenderItems" << __LINE__;
        }
        break;
    case LANDMARK:
        DrawLandmarks(frame);
        break;
    default:
        break;
    }//FU_FORMAT_BGRA_BUFFER Format_RGB32
    //QImage tex1 = QImage(frame,1280,720, QImage::Format_ARGB32);//Format_ARGB32
    //tex1.save("2e323231111eeeeee0000000000006666.jpg","jpg");
    ++m_frameID;
    return frame;
}

//只调用nama里的美颜模块
std::tr1::shared_ptr<unsigned char> Nama::RenderEx()
{
    std::tr1::shared_ptr<unsigned char> frame ;//= m_cap->QueryFrame();

    fuBeautifyImage(FU_FORMAT_BGRA_BUFFER, reinterpret_cast<int*>(frame.get()),
                    FU_FORMAT_BGRA_BUFFER, reinterpret_cast<int*>(frame.get()),
                    m_frameWidth, m_frameHeight, m_frameID, &m_beautyHandles, 1);

    ++m_frameID;

    return frame;
}

//绘制人脸特征点
void Nama::DrawLandmarks(uchar *frame)
{
    float landmarks[150];
    float trans[3];
    float rotat[4];
    int ret = 0;

    ret = fuGetFaceInfo(0, QString("landmarks").toLatin1().data(), landmarks, sizeof(landmarks) / sizeof(landmarks[0]));
    for (int i(0); i != 75; ++i)
    {
        DrawPoint(frame, static_cast<int>(landmarks[2 * i]), static_cast<int>(landmarks[2 * i + 1]));
    }

}

void Nama::DrawPoint(uchar *frame, int x, int y, unsigned char r, unsigned char g, unsigned char b)
{
    const int offsetX[] = { -1, 0, 1, -1, 0, 1, -1, 0, 1 };
    const int offsetY[] = { -1, -1, -1, 0, 0, 0, 1, 1, 1 };
    const int count = sizeof(offsetX) / sizeof(offsetX[0]);

    unsigned char* data = frame;
    for (int i(0); i != count; ++i)
    {
        int xx = x + offsetX[i];
        int yy = y + offsetY[i];
        if (0 > xx || xx >= m_frameWidth || 0 > yy || yy >= m_frameHeight)
        {
            continue;
        }

        data[yy * 4 * m_frameWidth + xx * 4 + 0] = b;
        data[yy * 4 * m_frameWidth + xx * 4 + 1] = g;
        data[yy * 4 * m_frameWidth + xx * 4 + 2] = r;
    }

}
