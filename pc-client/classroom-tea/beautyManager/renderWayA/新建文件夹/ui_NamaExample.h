/********************************************************************************
** Form generated from reading UI file 'NamaExample.ui'
**
** Created by: Qt User Interface Compiler version 5.8.0
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_NAMAEXAMPLE_H
#define UI_NAMAEXAMPLE_H

#include <QtCore/QVariant>
#include <QtWidgets/QAction>
#include <QtWidgets/QApplication>
#include <QtWidgets/QButtonGroup>
#include <QtWidgets/QCheckBox>
#include <QtWidgets/QComboBox>
#include <QtWidgets/QGridLayout>
#include <QtWidgets/QGroupBox>
#include <QtWidgets/QHBoxLayout>
#include <QtWidgets/QHeaderView>
#include <QtWidgets/QLabel>
#include <QtWidgets/QMainWindow>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QRadioButton>
#include <QtWidgets/QSlider>
#include <QtWidgets/QStatusBar>
#include <QtWidgets/QVBoxLayout>
#include <QtWidgets/QWidget>
#include "glwidget.h"

QT_BEGIN_NAMESPACE

class Ui_NamaExampleClass
{
public:
    QWidget *centralWidget;
    QGridLayout *gridLayout;
    QVBoxLayout *verticalLayout_4;
    GLWidget *glwidget;
    QLabel *poplabel_0;
    QLabel *official_website_label;
    QLabel *label_fps;
    QHBoxLayout *horizontalLayout_10;
    QGroupBox *groupBox_leftbottom;
    QGroupBox *group0;
    QWidget *layoutWidget;
    QHBoxLayout *horizontalLayout;
    QRadioButton *radioButton0_tiezhi;
    QPushButton *itemButton0_0;
    QPushButton *itemButton0_1;
    QPushButton *itemButton0_2;
    QPushButton *itemButton0_3;
    QPushButton *itemButton0_4;
    QPushButton *itemButton0_5;
    QPushButton *itemButton0_6;
    QPushButton *itemButton0_7;
    QPushButton *itemButton0_8;
    QWidget *layoutWidget1;
    QHBoxLayout *horizontalLayout_9;
    QRadioButton *radioButton0_meiyan;
    QGroupBox *group0_3;
    QWidget *layoutWidget2;
    QHBoxLayout *horizontalLayout_5;
    QLabel *label_3;
    QSlider *horizontalSlider0_0;
    QGroupBox *group0_4;
    QWidget *layoutWidget3;
    QHBoxLayout *horizontalLayout_6;
    QLabel *label_5;
    QSlider *horizontalSlider0_1;
    QGroupBox *group0_5;
    QWidget *layoutWidget4;
    QHBoxLayout *horizontalLayout_7;
    QLabel *label_6;
    QSlider *horizontalSlider0_2;
    QGroupBox *group0_2;
    QWidget *layoutWidget5;
    QHBoxLayout *horizontalLayout_2;
    QLabel *label;
    QPushButton *itemButton0_9;
    QPushButton *itemButton0_10;
    QPushButton *itemButton0_11;
    QPushButton *itemButton0_12;
    QPushButton *itemButton0_13;
    QPushButton *itemButton0_14;
    QWidget *layoutWidget6;
    QHBoxLayout *horizontalLayout_8;
    QComboBox *comboBox;
    QCheckBox *virtual_camera_checkBox;
    QGroupBox *groupBox_rightbottom;
    QWidget *layoutWidget7;
    QHBoxLayout *horizontalLayout_3;
    QRadioButton *radioButton0_0;
    QRadioButton *radioButton0_1;
    QRadioButton *radioButton0_2;
    QRadioButton *radioButton0_3;
    QWidget *layoutWidget8;
    QHBoxLayout *horizontalLayout_4;
    QVBoxLayout *verticalLayout;
    QLabel *label_7;
    QSlider *verticalSlider0_0;
    QVBoxLayout *verticalLayout_2;
    QLabel *label_8;
    QSlider *verticalSlider0_1;
    QVBoxLayout *verticalLayout_3;
    QLabel *label_9;
    QSlider *verticalSlider0_2;
    QStatusBar *statusBar;
    QButtonGroup *buttonGroup0_1;
    QButtonGroup *buttonGroup0_2;

    void setupUi(QMainWindow *NamaExampleClass)
    {
        if (NamaExampleClass->objectName().isEmpty())
            NamaExampleClass->setObjectName(QStringLiteral("NamaExampleClass"));
        NamaExampleClass->resize(1280, 878);
        NamaExampleClass->setMinimumSize(QSize(720, 500));
        NamaExampleClass->setMaximumSize(QSize(1280, 878));
        QIcon icon;
        icon.addFile(QStringLiteral(":/buttonImages/NamaExample.png"), QSize(), QIcon::Normal, QIcon::Off);
        NamaExampleClass->setWindowIcon(icon);
        centralWidget = new QWidget(NamaExampleClass);
        centralWidget->setObjectName(QStringLiteral("centralWidget"));
        gridLayout = new QGridLayout(centralWidget);
        gridLayout->setSpacing(6);
        gridLayout->setContentsMargins(11, 11, 11, 11);
        gridLayout->setObjectName(QStringLiteral("gridLayout"));
        verticalLayout_4 = new QVBoxLayout();
        verticalLayout_4->setSpacing(6);
        verticalLayout_4->setObjectName(QStringLiteral("verticalLayout_4"));
        glwidget = new GLWidget(centralWidget);
        glwidget->setObjectName(QStringLiteral("glwidget"));
        poplabel_0 = new QLabel(glwidget);
        poplabel_0->setObjectName(QStringLiteral("poplabel_0"));
        poplabel_0->setGeometry(QRect(530, 550, 101, 41));
        QFont font;
        font.setFamily(QString::fromUtf8("\345\276\256\350\275\257\351\233\205\351\273\221"));
        font.setPointSize(24);
        poplabel_0->setFont(font);
        official_website_label = new QLabel(glwidget);
        official_website_label->setObjectName(QStringLiteral("official_website_label"));
        official_website_label->setGeometry(QRect(1210, 700, 61, 21));
        official_website_label->setOpenExternalLinks(true);
        label_fps = new QLabel(glwidget);
        label_fps->setObjectName(QStringLiteral("label_fps"));
        label_fps->setGeometry(QRect(1220, 10, 21, 16));

        verticalLayout_4->addWidget(glwidget);

        horizontalLayout_10 = new QHBoxLayout();
        horizontalLayout_10->setSpacing(6);
        horizontalLayout_10->setObjectName(QStringLiteral("horizontalLayout_10"));
        groupBox_leftbottom = new QGroupBox(centralWidget);
        groupBox_leftbottom->setObjectName(QStringLiteral("groupBox_leftbottom"));
        group0 = new QGroupBox(groupBox_leftbottom);
        group0->setObjectName(QStringLiteral("group0"));
        group0->setGeometry(QRect(10, 0, 611, 71));
        layoutWidget = new QWidget(group0);
        layoutWidget->setObjectName(QStringLiteral("layoutWidget"));
        layoutWidget->setGeometry(QRect(0, 0, 601, 71));
        horizontalLayout = new QHBoxLayout(layoutWidget);
        horizontalLayout->setSpacing(6);
        horizontalLayout->setContentsMargins(11, 11, 11, 11);
        horizontalLayout->setObjectName(QStringLiteral("horizontalLayout"));
        horizontalLayout->setContentsMargins(0, 0, 0, 0);
        radioButton0_tiezhi = new QRadioButton(layoutWidget);
        radioButton0_tiezhi->setObjectName(QStringLiteral("radioButton0_tiezhi"));
        radioButton0_tiezhi->setIconSize(QSize(16, 16));
        radioButton0_tiezhi->setChecked(true);

        horizontalLayout->addWidget(radioButton0_tiezhi);

        itemButton0_0 = new QPushButton(layoutWidget);
        itemButton0_0->setObjectName(QStringLiteral("itemButton0_0"));
        itemButton0_0->setCursor(QCursor(Qt::PointingHandCursor));
        QIcon icon1;
        icon1.addFile(QStringLiteral(":/buttonImages/buttonImages/item0204.png"), QSize(), QIcon::Normal, QIcon::Off);
        itemButton0_0->setIcon(icon1);
        itemButton0_0->setIconSize(QSize(50, 50));
        itemButton0_0->setFlat(false);

        horizontalLayout->addWidget(itemButton0_0);

        itemButton0_1 = new QPushButton(layoutWidget);
        itemButton0_1->setObjectName(QStringLiteral("itemButton0_1"));
        itemButton0_1->setCursor(QCursor(Qt::PointingHandCursor));
        QIcon icon2;
        icon2.addFile(QStringLiteral(":/buttonImages/buttonImages/bgseg.png"), QSize(), QIcon::Normal, QIcon::Off);
        itemButton0_1->setIcon(icon2);
        itemButton0_1->setIconSize(QSize(50, 50));
        itemButton0_1->setFlat(false);

        horizontalLayout->addWidget(itemButton0_1);

        itemButton0_2 = new QPushButton(layoutWidget);
        itemButton0_2->setObjectName(QStringLiteral("itemButton0_2"));
        itemButton0_2->setCursor(QCursor(Qt::PointingHandCursor));
        QIcon icon3;
        icon3.addFile(QStringLiteral(":/buttonImages/buttonImages/fu_zh_duzui.png"), QSize(), QIcon::Normal, QIcon::Off);
        itemButton0_2->setIcon(icon3);
        itemButton0_2->setIconSize(QSize(50, 50));
        itemButton0_2->setFlat(false);

        horizontalLayout->addWidget(itemButton0_2);

        itemButton0_3 = new QPushButton(layoutWidget);
        itemButton0_3->setObjectName(QStringLiteral("itemButton0_3"));
        itemButton0_3->setCursor(QCursor(Qt::PointingHandCursor));
        QIcon icon4;
        icon4.addFile(QStringLiteral(":/buttonImages/buttonImages/yazui.png"), QSize(), QIcon::Normal, QIcon::Off);
        itemButton0_3->setIcon(icon4);
        itemButton0_3->setIconSize(QSize(50, 50));
        itemButton0_3->setFlat(false);

        horizontalLayout->addWidget(itemButton0_3);

        itemButton0_4 = new QPushButton(layoutWidget);
        itemButton0_4->setObjectName(QStringLiteral("itemButton0_4"));
        itemButton0_4->setCursor(QCursor(Qt::PointingHandCursor));
        QIcon icon5;
        icon5.addFile(QStringLiteral(":/buttonImages/buttonImages/matianyu.png"), QSize(), QIcon::Normal, QIcon::Off);
        itemButton0_4->setIcon(icon5);
        itemButton0_4->setIconSize(QSize(50, 50));
        itemButton0_4->setFlat(false);

        horizontalLayout->addWidget(itemButton0_4);

        itemButton0_5 = new QPushButton(layoutWidget);
        itemButton0_5->setObjectName(QStringLiteral("itemButton0_5"));
        itemButton0_5->setCursor(QCursor(Qt::PointingHandCursor));
        QIcon icon6;
        icon6.addFile(QStringLiteral(":/buttonImages/buttonImages/houzi.png"), QSize(), QIcon::Normal, QIcon::Off);
        itemButton0_5->setIcon(icon6);
        itemButton0_5->setIconSize(QSize(50, 50));
        itemButton0_5->setFlat(false);

        horizontalLayout->addWidget(itemButton0_5);

        itemButton0_6 = new QPushButton(layoutWidget);
        itemButton0_6->setObjectName(QStringLiteral("itemButton0_6"));
        itemButton0_6->setCursor(QCursor(Qt::PointingHandCursor));
        QIcon icon7;
        icon7.addFile(QStringLiteral(":/buttonImages/buttonImages/mood.png"), QSize(), QIcon::Normal, QIcon::Off);
        itemButton0_6->setIcon(icon7);
        itemButton0_6->setIconSize(QSize(50, 50));
        itemButton0_6->setFlat(false);

        horizontalLayout->addWidget(itemButton0_6);

        itemButton0_7 = new QPushButton(layoutWidget);
        itemButton0_7->setObjectName(QStringLiteral("itemButton0_7"));
        itemButton0_7->setCursor(QCursor(Qt::PointingHandCursor));
        QIcon icon8;
        icon8.addFile(QStringLiteral(":/buttonImages/buttonImages/gradient.png"), QSize(), QIcon::Normal, QIcon::Off);
        itemButton0_7->setIcon(icon8);
        itemButton0_7->setIconSize(QSize(50, 50));
        itemButton0_7->setFlat(false);

        horizontalLayout->addWidget(itemButton0_7);

        itemButton0_8 = new QPushButton(layoutWidget);
        itemButton0_8->setObjectName(QStringLiteral("itemButton0_8"));
        itemButton0_8->setCursor(QCursor(Qt::PointingHandCursor));
        QIcon icon9;
        icon9.addFile(QStringLiteral(":/buttonImages/buttonImages/yuguan.png"), QSize(), QIcon::Normal, QIcon::Off);
        itemButton0_8->setIcon(icon9);
        itemButton0_8->setIconSize(QSize(50, 50));
        itemButton0_8->setFlat(false);

        horizontalLayout->addWidget(itemButton0_8);

        layoutWidget1 = new QWidget(groupBox_leftbottom);
        layoutWidget1->setObjectName(QStringLiteral("layoutWidget1"));
        layoutWidget1->setGeometry(QRect(10, 70, 691, 51));
        horizontalLayout_9 = new QHBoxLayout(layoutWidget1);
        horizontalLayout_9->setSpacing(6);
        horizontalLayout_9->setContentsMargins(11, 11, 11, 11);
        horizontalLayout_9->setObjectName(QStringLiteral("horizontalLayout_9"));
        horizontalLayout_9->setContentsMargins(0, 0, 0, 0);
        radioButton0_meiyan = new QRadioButton(layoutWidget1);
        radioButton0_meiyan->setObjectName(QStringLiteral("radioButton0_meiyan"));
        radioButton0_meiyan->setChecked(true);

        horizontalLayout_9->addWidget(radioButton0_meiyan);

        group0_3 = new QGroupBox(layoutWidget1);
        group0_3->setObjectName(QStringLiteral("group0_3"));
        layoutWidget2 = new QWidget(group0_3);
        layoutWidget2->setObjectName(QStringLiteral("layoutWidget2"));
        layoutWidget2->setGeometry(QRect(10, 10, 201, 24));
        horizontalLayout_5 = new QHBoxLayout(layoutWidget2);
        horizontalLayout_5->setSpacing(6);
        horizontalLayout_5->setContentsMargins(11, 11, 11, 11);
        horizontalLayout_5->setObjectName(QStringLiteral("horizontalLayout_5"));
        horizontalLayout_5->setContentsMargins(0, 0, 0, 0);
        label_3 = new QLabel(layoutWidget2);
        label_3->setObjectName(QStringLiteral("label_3"));

        horizontalLayout_5->addWidget(label_3);

        horizontalSlider0_0 = new QSlider(layoutWidget2);
        horizontalSlider0_0->setObjectName(QStringLiteral("horizontalSlider0_0"));
        horizontalSlider0_0->setCursor(QCursor(Qt::SizeHorCursor));
        horizontalSlider0_0->setMaximum(599);
        horizontalSlider0_0->setOrientation(Qt::Horizontal);

        horizontalLayout_5->addWidget(horizontalSlider0_0);


        horizontalLayout_9->addWidget(group0_3);

        group0_4 = new QGroupBox(layoutWidget1);
        group0_4->setObjectName(QStringLiteral("group0_4"));
        layoutWidget3 = new QWidget(group0_4);
        layoutWidget3->setObjectName(QStringLiteral("layoutWidget3"));
        layoutWidget3->setGeometry(QRect(10, 10, 201, 24));
        horizontalLayout_6 = new QHBoxLayout(layoutWidget3);
        horizontalLayout_6->setSpacing(6);
        horizontalLayout_6->setContentsMargins(11, 11, 11, 11);
        horizontalLayout_6->setObjectName(QStringLiteral("horizontalLayout_6"));
        horizontalLayout_6->setContentsMargins(0, 0, 0, 0);
        label_5 = new QLabel(layoutWidget3);
        label_5->setObjectName(QStringLiteral("label_5"));

        horizontalLayout_6->addWidget(label_5);

        horizontalSlider0_1 = new QSlider(layoutWidget3);
        horizontalSlider0_1->setObjectName(QStringLiteral("horizontalSlider0_1"));
        horizontalSlider0_1->setCursor(QCursor(Qt::SizeHorCursor));
        horizontalSlider0_1->setMaximum(99);
        horizontalSlider0_1->setOrientation(Qt::Horizontal);

        horizontalLayout_6->addWidget(horizontalSlider0_1);


        horizontalLayout_9->addWidget(group0_4);

        group0_5 = new QGroupBox(layoutWidget1);
        group0_5->setObjectName(QStringLiteral("group0_5"));
        layoutWidget4 = new QWidget(group0_5);
        layoutWidget4->setObjectName(QStringLiteral("layoutWidget4"));
        layoutWidget4->setGeometry(QRect(10, 10, 201, 24));
        horizontalLayout_7 = new QHBoxLayout(layoutWidget4);
        horizontalLayout_7->setSpacing(6);
        horizontalLayout_7->setContentsMargins(11, 11, 11, 11);
        horizontalLayout_7->setObjectName(QStringLiteral("horizontalLayout_7"));
        horizontalLayout_7->setContentsMargins(0, 0, 0, 0);
        label_6 = new QLabel(layoutWidget4);
        label_6->setObjectName(QStringLiteral("label_6"));

        horizontalLayout_7->addWidget(label_6);

        horizontalSlider0_2 = new QSlider(layoutWidget4);
        horizontalSlider0_2->setObjectName(QStringLiteral("horizontalSlider0_2"));
        horizontalSlider0_2->setCursor(QCursor(Qt::SizeHorCursor));
        horizontalSlider0_2->setMaximum(99);
        horizontalSlider0_2->setOrientation(Qt::Horizontal);

        horizontalLayout_7->addWidget(horizontalSlider0_2);


        horizontalLayout_9->addWidget(group0_5);

        horizontalLayout_9->setStretch(0, 1);
        horizontalLayout_9->setStretch(1, 5);
        horizontalLayout_9->setStretch(2, 5);
        horizontalLayout_9->setStretch(3, 5);
        group0_2 = new QGroupBox(groupBox_leftbottom);
        group0_2->setObjectName(QStringLiteral("group0_2"));
        group0_2->setGeometry(QRect(640, 0, 401, 71));
        layoutWidget5 = new QWidget(group0_2);
        layoutWidget5->setObjectName(QStringLiteral("layoutWidget5"));
        layoutWidget5->setGeometry(QRect(0, 0, 391, 71));
        horizontalLayout_2 = new QHBoxLayout(layoutWidget5);
        horizontalLayout_2->setSpacing(6);
        horizontalLayout_2->setContentsMargins(11, 11, 11, 11);
        horizontalLayout_2->setObjectName(QStringLiteral("horizontalLayout_2"));
        horizontalLayout_2->setContentsMargins(0, 0, 0, 0);
        label = new QLabel(layoutWidget5);
        label->setObjectName(QStringLiteral("label"));

        horizontalLayout_2->addWidget(label);

        itemButton0_9 = new QPushButton(layoutWidget5);
        buttonGroup0_1 = new QButtonGroup(NamaExampleClass);
        buttonGroup0_1->setObjectName(QStringLiteral("buttonGroup0_1"));
        buttonGroup0_1->addButton(itemButton0_9);
        itemButton0_9->setObjectName(QStringLiteral("itemButton0_9"));
        itemButton0_9->setCursor(QCursor(Qt::PointingHandCursor));
        QIcon icon10;
        icon10.addFile(QStringLiteral(":/buttonImages/buttonImages/nature.png"), QSize(), QIcon::Normal, QIcon::Off);
        itemButton0_9->setIcon(icon10);
        itemButton0_9->setIconSize(QSize(50, 50));
        itemButton0_9->setFlat(false);

        horizontalLayout_2->addWidget(itemButton0_9);

        itemButton0_10 = new QPushButton(layoutWidget5);
        buttonGroup0_1->addButton(itemButton0_10);
        itemButton0_10->setObjectName(QStringLiteral("itemButton0_10"));
        itemButton0_10->setCursor(QCursor(Qt::PointingHandCursor));
        QIcon icon11;
        icon11.addFile(QStringLiteral(":/buttonImages/buttonImages/delta.png"), QSize(), QIcon::Normal, QIcon::Off);
        itemButton0_10->setIcon(icon11);
        itemButton0_10->setIconSize(QSize(50, 50));
        itemButton0_10->setFlat(false);

        horizontalLayout_2->addWidget(itemButton0_10);

        itemButton0_11 = new QPushButton(layoutWidget5);
        buttonGroup0_1->addButton(itemButton0_11);
        itemButton0_11->setObjectName(QStringLiteral("itemButton0_11"));
        itemButton0_11->setCursor(QCursor(Qt::PointingHandCursor));
        QIcon icon12;
        icon12.addFile(QStringLiteral(":/buttonImages/buttonImages/electric.png"), QSize(), QIcon::Normal, QIcon::Off);
        itemButton0_11->setIcon(icon12);
        itemButton0_11->setIconSize(QSize(50, 50));
        itemButton0_11->setFlat(false);

        horizontalLayout_2->addWidget(itemButton0_11);

        itemButton0_12 = new QPushButton(layoutWidget5);
        buttonGroup0_1->addButton(itemButton0_12);
        itemButton0_12->setObjectName(QStringLiteral("itemButton0_12"));
        itemButton0_12->setCursor(QCursor(Qt::PointingHandCursor));
        QIcon icon13;
        icon13.addFile(QStringLiteral(":/buttonImages/buttonImages/slowlived.png"), QSize(), QIcon::Normal, QIcon::Off);
        itemButton0_12->setIcon(icon13);
        itemButton0_12->setIconSize(QSize(50, 50));
        itemButton0_12->setFlat(false);

        horizontalLayout_2->addWidget(itemButton0_12);

        itemButton0_13 = new QPushButton(layoutWidget5);
        buttonGroup0_1->addButton(itemButton0_13);
        itemButton0_13->setObjectName(QStringLiteral("itemButton0_13"));
        itemButton0_13->setCursor(QCursor(Qt::PointingHandCursor));
        QIcon icon14;
        icon14.addFile(QStringLiteral(":/buttonImages/buttonImages/tokyo.png"), QSize(), QIcon::Normal, QIcon::Off);
        itemButton0_13->setIcon(icon14);
        itemButton0_13->setIconSize(QSize(50, 50));
        itemButton0_13->setFlat(false);

        horizontalLayout_2->addWidget(itemButton0_13);

        itemButton0_14 = new QPushButton(layoutWidget5);
        buttonGroup0_1->addButton(itemButton0_14);
        itemButton0_14->setObjectName(QStringLiteral("itemButton0_14"));
        itemButton0_14->setCursor(QCursor(Qt::PointingHandCursor));
        QIcon icon15;
        icon15.addFile(QStringLiteral(":/buttonImages/buttonImages/warm.png"), QSize(), QIcon::Normal, QIcon::Off);
        itemButton0_14->setIcon(icon15);
        itemButton0_14->setIconSize(QSize(50, 50));
        itemButton0_14->setFlat(false);

        horizontalLayout_2->addWidget(itemButton0_14);

        horizontalLayout_2->setStretch(0, 1);
        horizontalLayout_2->setStretch(1, 4);
        horizontalLayout_2->setStretch(2, 4);
        horizontalLayout_2->setStretch(3, 4);
        horizontalLayout_2->setStretch(4, 4);
        horizontalLayout_2->setStretch(5, 4);
        horizontalLayout_2->setStretch(6, 4);
        layoutWidget6 = new QWidget(groupBox_leftbottom);
        layoutWidget6->setObjectName(QStringLiteral("layoutWidget6"));
        layoutWidget6->setGeometry(QRect(710, 80, 321, 31));
        horizontalLayout_8 = new QHBoxLayout(layoutWidget6);
        horizontalLayout_8->setSpacing(6);
        horizontalLayout_8->setContentsMargins(11, 11, 11, 11);
        horizontalLayout_8->setObjectName(QStringLiteral("horizontalLayout_8"));
        horizontalLayout_8->setContentsMargins(0, 0, 0, 0);
        comboBox = new QComboBox(layoutWidget6);
        comboBox->setObjectName(QStringLiteral("comboBox"));

        horizontalLayout_8->addWidget(comboBox);

        virtual_camera_checkBox = new QCheckBox(layoutWidget6);
        virtual_camera_checkBox->setObjectName(QStringLiteral("virtual_camera_checkBox"));

        horizontalLayout_8->addWidget(virtual_camera_checkBox);

        horizontalLayout_8->setStretch(0, 3);
        horizontalLayout_8->setStretch(1, 1);

        horizontalLayout_10->addWidget(groupBox_leftbottom);

        groupBox_rightbottom = new QGroupBox(centralWidget);
        groupBox_rightbottom->setObjectName(QStringLiteral("groupBox_rightbottom"));
        layoutWidget7 = new QWidget(groupBox_rightbottom);
        layoutWidget7->setObjectName(QStringLiteral("layoutWidget7"));
        layoutWidget7->setGeometry(QRect(0, 10, 208, 20));
        horizontalLayout_3 = new QHBoxLayout(layoutWidget7);
        horizontalLayout_3->setSpacing(6);
        horizontalLayout_3->setContentsMargins(11, 11, 11, 11);
        horizontalLayout_3->setObjectName(QStringLiteral("horizontalLayout_3"));
        horizontalLayout_3->setContentsMargins(0, 0, 0, 0);
        radioButton0_0 = new QRadioButton(layoutWidget7);
        buttonGroup0_2 = new QButtonGroup(NamaExampleClass);
        buttonGroup0_2->setObjectName(QStringLiteral("buttonGroup0_2"));
        buttonGroup0_2->addButton(radioButton0_0);
        radioButton0_0->setObjectName(QStringLiteral("radioButton0_0"));

        horizontalLayout_3->addWidget(radioButton0_0);

        radioButton0_1 = new QRadioButton(layoutWidget7);
        buttonGroup0_2->addButton(radioButton0_1);
        radioButton0_1->setObjectName(QStringLiteral("radioButton0_1"));

        horizontalLayout_3->addWidget(radioButton0_1);

        radioButton0_2 = new QRadioButton(layoutWidget7);
        buttonGroup0_2->addButton(radioButton0_2);
        radioButton0_2->setObjectName(QStringLiteral("radioButton0_2"));

        horizontalLayout_3->addWidget(radioButton0_2);

        radioButton0_3 = new QRadioButton(layoutWidget7);
        buttonGroup0_2->addButton(radioButton0_3);
        radioButton0_3->setObjectName(QStringLiteral("radioButton0_3"));
        radioButton0_3->setChecked(true);

        horizontalLayout_3->addWidget(radioButton0_3);

        layoutWidget8 = new QWidget(groupBox_rightbottom);
        layoutWidget8->setObjectName(QStringLiteral("layoutWidget8"));
        layoutWidget8->setGeometry(QRect(10, 30, 191, 106));
        horizontalLayout_4 = new QHBoxLayout(layoutWidget8);
        horizontalLayout_4->setSpacing(6);
        horizontalLayout_4->setContentsMargins(11, 11, 11, 11);
        horizontalLayout_4->setObjectName(QStringLiteral("horizontalLayout_4"));
        horizontalLayout_4->setContentsMargins(0, 0, 0, 0);
        verticalLayout = new QVBoxLayout();
        verticalLayout->setSpacing(6);
        verticalLayout->setObjectName(QStringLiteral("verticalLayout"));
        label_7 = new QLabel(layoutWidget8);
        label_7->setObjectName(QStringLiteral("label_7"));

        verticalLayout->addWidget(label_7);

        verticalSlider0_0 = new QSlider(layoutWidget8);
        verticalSlider0_0->setObjectName(QStringLiteral("verticalSlider0_0"));
        verticalSlider0_0->setCursor(QCursor(Qt::SizeVerCursor));
        verticalSlider0_0->setMaximum(99);
        verticalSlider0_0->setOrientation(Qt::Vertical);

        verticalLayout->addWidget(verticalSlider0_0);


        horizontalLayout_4->addLayout(verticalLayout);

        verticalLayout_2 = new QVBoxLayout();
        verticalLayout_2->setSpacing(6);
        verticalLayout_2->setObjectName(QStringLiteral("verticalLayout_2"));
        label_8 = new QLabel(layoutWidget8);
        label_8->setObjectName(QStringLiteral("label_8"));

        verticalLayout_2->addWidget(label_8);

        verticalSlider0_1 = new QSlider(layoutWidget8);
        verticalSlider0_1->setObjectName(QStringLiteral("verticalSlider0_1"));
        verticalSlider0_1->setCursor(QCursor(Qt::SizeVerCursor));
        verticalSlider0_1->setMaximum(99);
        verticalSlider0_1->setOrientation(Qt::Vertical);

        verticalLayout_2->addWidget(verticalSlider0_1);


        horizontalLayout_4->addLayout(verticalLayout_2);

        verticalLayout_3 = new QVBoxLayout();
        verticalLayout_3->setSpacing(6);
        verticalLayout_3->setObjectName(QStringLiteral("verticalLayout_3"));
        label_9 = new QLabel(layoutWidget8);
        label_9->setObjectName(QStringLiteral("label_9"));

        verticalLayout_3->addWidget(label_9);

        verticalSlider0_2 = new QSlider(layoutWidget8);
        verticalSlider0_2->setObjectName(QStringLiteral("verticalSlider0_2"));
        verticalSlider0_2->setCursor(QCursor(Qt::SizeVerCursor));
        verticalSlider0_2->setMaximum(99);
        verticalSlider0_2->setOrientation(Qt::Vertical);

        verticalLayout_3->addWidget(verticalSlider0_2);


        horizontalLayout_4->addLayout(verticalLayout_3);


        horizontalLayout_10->addWidget(groupBox_rightbottom);

        horizontalLayout_10->setStretch(0, 5);
        horizontalLayout_10->setStretch(1, 1);

        verticalLayout_4->addLayout(horizontalLayout_10);

        verticalLayout_4->setStretch(0, 5);
        verticalLayout_4->setStretch(1, 1);

        gridLayout->addLayout(verticalLayout_4, 0, 0, 1, 1);

        NamaExampleClass->setCentralWidget(centralWidget);
        statusBar = new QStatusBar(NamaExampleClass);
        statusBar->setObjectName(QStringLiteral("statusBar"));
        NamaExampleClass->setStatusBar(statusBar);

        retranslateUi(NamaExampleClass);
        QObject::connect(itemButton0_0, SIGNAL(clicked()), NamaExampleClass, SLOT(on_pushButtonConnect_clicked0()));
        QObject::connect(itemButton0_1, SIGNAL(clicked()), NamaExampleClass, SLOT(on_pushButtonConnect_clicked1()));
        QObject::connect(itemButton0_3, SIGNAL(clicked()), NamaExampleClass, SLOT(on_pushButtonConnect_clicked3()));
        QObject::connect(itemButton0_2, SIGNAL(clicked()), NamaExampleClass, SLOT(on_pushButtonConnect_clicked2()));
        QObject::connect(itemButton0_4, SIGNAL(clicked()), NamaExampleClass, SLOT(on_pushButtonConnect_clicked4()));
        QObject::connect(itemButton0_5, SIGNAL(clicked()), NamaExampleClass, SLOT(on_pushButtonConnect_clicked5()));
        QObject::connect(itemButton0_6, SIGNAL(clicked()), NamaExampleClass, SLOT(on_pushButtonConnect_clicked6()));
        QObject::connect(itemButton0_7, SIGNAL(clicked()), NamaExampleClass, SLOT(on_pushButtonConnect_clicked7()));
        QObject::connect(itemButton0_8, SIGNAL(clicked()), NamaExampleClass, SLOT(on_pushButtonConnect_clicked8()));
        QObject::connect(itemButton0_9, SIGNAL(clicked()), NamaExampleClass, SLOT(on_filterButtonConnect_clicked()));
        QObject::connect(itemButton0_10, SIGNAL(clicked()), NamaExampleClass, SLOT(on_filterButtonConnect_clicked()));
        QObject::connect(itemButton0_11, SIGNAL(clicked()), NamaExampleClass, SLOT(on_filterButtonConnect_clicked()));
        QObject::connect(itemButton0_12, SIGNAL(clicked()), NamaExampleClass, SLOT(on_filterButtonConnect_clicked()));
        QObject::connect(itemButton0_13, SIGNAL(clicked()), NamaExampleClass, SLOT(on_filterButtonConnect_clicked()));
        QObject::connect(itemButton0_14, SIGNAL(clicked()), NamaExampleClass, SLOT(on_filterButtonConnect_clicked()));
        QObject::connect(radioButton0_0, SIGNAL(toggled(bool)), NamaExampleClass, SLOT(on_shapeButtonConnect_clicked()));
        QObject::connect(radioButton0_1, SIGNAL(toggled(bool)), NamaExampleClass, SLOT(on_shapeButtonConnect_clicked()));
        QObject::connect(radioButton0_2, SIGNAL(toggled(bool)), NamaExampleClass, SLOT(on_shapeButtonConnect_clicked()));
        QObject::connect(radioButton0_3, SIGNAL(toggled(bool)), NamaExampleClass, SLOT(on_shapeButtonConnect_clicked()));
        QObject::connect(verticalSlider0_0, SIGNAL(sliderMoved(int)), NamaExampleClass, SLOT(on_shapeSliderConnect_moved()));
        QObject::connect(verticalSlider0_1, SIGNAL(sliderMoved(int)), NamaExampleClass, SLOT(on_shapeSliderConnect_moved()));
        QObject::connect(verticalSlider0_2, SIGNAL(sliderMoved(int)), NamaExampleClass, SLOT(on_shapeSliderConnect_moved()));
        QObject::connect(comboBox, SIGNAL(currentIndexChanged(int)), NamaExampleClass, SLOT(on_comboBoxCurrentIndexChanged()));
        QObject::connect(horizontalSlider0_1, SIGNAL(sliderMoved(int)), NamaExampleClass, SLOT(on_SliderConnect_moved0()));
        QObject::connect(horizontalSlider0_2, SIGNAL(sliderMoved(int)), NamaExampleClass, SLOT(on_SliderConnect_moved0()));
        QObject::connect(virtual_camera_checkBox, SIGNAL(stateChanged(int)), NamaExampleClass, SLOT(on_virtualCameraCheckStateChanged()));
        QObject::connect(horizontalSlider0_0, SIGNAL(sliderMoved(int)), NamaExampleClass, SLOT(on_SliderConnect_moved0()));
        QObject::connect(radioButton0_tiezhi, SIGNAL(clicked()), NamaExampleClass, SLOT(on_chooseCheckStateChanged()));
        QObject::connect(radioButton0_meiyan, SIGNAL(clicked()), NamaExampleClass, SLOT(on_chooseCheckStateChanged()));

        QMetaObject::connectSlotsByName(NamaExampleClass);
    } // setupUi

    void retranslateUi(QMainWindow *NamaExampleClass)
    {
        NamaExampleClass->setWindowTitle(QApplication::translate("NamaExampleClass", "NamaExample", Q_NULLPTR));
        poplabel_0->setText(QApplication::translate("NamaExampleClass", "\350\257\267\345\230\237\345\230\264", Q_NULLPTR));
        official_website_label->setText(QApplication::translate("NamaExampleClass", "<style> a {text-decoration: none} </style><a href=\"http://www.faceunity.com/\">\346\211\223\345\274\200\345\256\230\347\275\221", Q_NULLPTR));
        label_fps->setText(QApplication::translate("NamaExampleClass", "60", Q_NULLPTR));
        groupBox_leftbottom->setTitle(QString());
        group0->setTitle(QString());
        radioButton0_tiezhi->setText(QApplication::translate("NamaExampleClass", "\350\264\264\347\272\270", Q_NULLPTR));
        itemButton0_0->setText(QString());
        itemButton0_1->setText(QString());
        itemButton0_2->setText(QString());
        itemButton0_3->setText(QString());
        itemButton0_4->setText(QString());
        itemButton0_5->setText(QString());
        itemButton0_6->setText(QString());
        itemButton0_7->setText(QString());
        itemButton0_8->setText(QString());
        radioButton0_meiyan->setText(QApplication::translate("NamaExampleClass", "\347\276\216\351\242\234", Q_NULLPTR));
        group0_3->setTitle(QString());
        label_3->setText(QApplication::translate("NamaExampleClass", "\347\243\250\347\232\256", Q_NULLPTR));
        group0_4->setTitle(QString());
        label_5->setText(QApplication::translate("NamaExampleClass", "\347\276\216\347\231\275", Q_NULLPTR));
        group0_5->setTitle(QString());
        label_6->setText(QApplication::translate("NamaExampleClass", "\347\272\242\346\266\246", Q_NULLPTR));
        group0_2->setTitle(QString());
        label->setText(QApplication::translate("NamaExampleClass", "\346\273\244\351\225\234", Q_NULLPTR));
        itemButton0_9->setText(QString());
        itemButton0_10->setText(QString());
        itemButton0_11->setText(QString());
        itemButton0_12->setText(QString());
        itemButton0_13->setText(QString());
        itemButton0_14->setText(QString());
        virtual_camera_checkBox->setText(QApplication::translate("NamaExampleClass", "\350\231\232\346\213\237\345\214\226", Q_NULLPTR));
        groupBox_rightbottom->setTitle(QString());
        radioButton0_0->setText(QApplication::translate("NamaExampleClass", "\345\245\263\347\245\236", Q_NULLPTR));
        radioButton0_1->setText(QApplication::translate("NamaExampleClass", "\347\275\221\347\272\242", Q_NULLPTR));
        radioButton0_2->setText(QApplication::translate("NamaExampleClass", "\350\207\252\347\204\266", Q_NULLPTR));
        radioButton0_3->setText(QApplication::translate("NamaExampleClass", "\346\216\250\350\215\220", Q_NULLPTR));
        label_7->setText(QApplication::translate("NamaExampleClass", "\347\250\213\345\272\246", Q_NULLPTR));
        label_8->setText(QApplication::translate("NamaExampleClass", "\345\244\247\347\234\274", Q_NULLPTR));
        label_9->setText(QApplication::translate("NamaExampleClass", "\347\230\246\350\204\270", Q_NULLPTR));
    } // retranslateUi

};

namespace Ui {
    class NamaExampleClass: public Ui_NamaExampleClass {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_NAMAEXAMPLE_H
