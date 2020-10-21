﻿#pragma once

#include <QGLWidget>
#include <QtOpenGL>
//#include "freeglut.h"
#include "Nama.h"
//for virtual camera
//#include "ipc/filtercommons.h"
//#include "ipc/ipcbridge.h"
#include <uuids.h>
#include<QDebug>
#include<QFile>
class GLWidget : public QGLWidget
{
	Q_OBJECT
private:
    int wndWidth = 1280;
    int wndHeight = 720;
	GLuint textureID = 0;	
	GLuint landmarks_textureID = 0;
	float timeSinceStart;
	float deltaTime;
	int frameRate = 25;
	float xy_aspect;
    //IpcBridge ipcBridge;
    QImage tempImage;
     QImage tempImage2;
public:
	GLWidget(QWidget *parent);
	~GLWidget();
bool hasRender = false;
    //std::tr1::shared_ptr<NamaExampleNameSpace::Nama> nama;
	bool is_need_draw_landmarks;
	bool is_need_ipc_write;
	int fps = 60;
	bool is_frame_null;
 std::tr1::shared_ptr<unsigned char> frame;
 std::tr1::shared_ptr<unsigned char> frame1;
	void initializeGL();
	void resizeGL(int w, int h);
	void drawFrame();
	void drawLandMarks();
	void setTextureData(std::tr1::shared_ptr<unsigned char> frame);
	void setLandMarksTextureData(std::tr1::shared_ptr<unsigned char> frame);
	void paintGL();
};
