import QtQuick 2.0
import "./Configuration.js" as Cfg
/*
*上课提醒页面
*/

Item {
    z: 100
    id: lessonTipsView
    anchors.fill: parent

    property bool isDownLesson: false;

    signal sigFinishLesson();//下课
    signal sigHalt();//中途休息
    signal sigStartLesson();//开始继续上课
    signal sigAutoExit();//自动退出

    //离开下课提示窗口
    Item{
        id: exitRoomView
        width: 473 * heightRate
        height: 162 * heightRate
        anchors.centerIn: parent
        visible: false

        Image{
            anchors.fill: parent
            source: "qrc:/lessonMgrImage/lkjs.png"
        }

        MouseArea{
            width: 33 * heightRate
            height: 33 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.top: parent.top
            anchors.topMargin: 4 * heightRate
            anchors.right: parent.right
            anchors.rightMargin: 34 * heightRate

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/lessonMgrImage/tkgb3.png" : "qrc:/lessonMgrImage/tkgb2.png"
            }
            onClicked: {
                exitRoomView.visible = false;
            }
        }

        Row{
            width: parent.width - 25 * heightRate
            height: 45 * heightRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 28 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 28 * heightRate
            spacing: 25 * heightRate

            MouseArea{
                width: 150 * heightRate
                height: parent.height
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                Image {
                    anchors.fill: parent
                    source: parent.containsMouse ? "qrc:/lessonMgrImage/xk3.png" : "qrc:/lessonMgrImage/xk1.png"
                }

                onClicked: {
                    sigFinishLesson();
                }
            }

            MouseArea{
                width: 172 * heightRate
                height: parent.height
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                Image{
                    anchors.fill: parent
                    source: parent.containsMouse ? "qrc:/lessonMgrImage/lkjs3.png" : "qrc:/lessonMgrImage/lkjs1.png"
                }

                onClicked: {
                    sigHalt();
                }
            }

        }
    }

    //开始上课
    Image{
        id: startLesson
        visible: false
        width: 388 * heightRate
        height: 95 * heightRate
        source: "qrc:/lessonMgrImage/kssk.png"
        anchors.centerIn: parent
    }

    //继续上课
    Item{
        id: continueLessonView
        width: 362 * heightRate
        height: 126 * heightRate
        anchors.centerIn: parent
        visible: false

        Image{
            anchors.fill: parent
            source: "qrc:/lessonMgrImage/hdjs.png"
        }

        MouseArea{
            width: 148 * heightRate
            height: 42 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.left: parent.left
            anchors.leftMargin: 24 * heightRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 18 * heightRate

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/lessonMgrImage/jxsk3.png" : "qrc:/lessonMgrImage/jxsk1.png"
            }

            onClicked: {
                sigStartLesson();
                lessonTipsView.visible = false;
            }
        }
    }

    //下课了
    Image{
        id: endImg
        width: 308 * heightRate
        height: 123 * heightRate
        anchors.centerIn: parent
        visible: false
        source: "qrc:/lessonMgrImage/kcjs.png"

        MouseArea{
            width: 149 * heightRate
            height: 42 * heightRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 13 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 17 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Image{
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/lessonMgrImage/exitroomsed.png" : "qrc:/lessonMgrImage/exitroom.png"
            }

            onClicked: {
                sigAutoExit();
            }
        }
    }


    //老师离开
    Image{
        id: tealevaImg
        width: 400 * heightRate
        height: 110 * heightRate
        anchors.centerIn: parent
        visible: false
        source: "qrc:/lessonMgrImage/ztlk.png"
    }

    //注意注意老师开课了
    Image{
        id: warningImg
        width: 447 * heightRate
        height: 95 * heightRate
        anchors.centerIn: parent
        visible: false
        source: "qrc:/lessonMgrImage/lskkl.png"
    }

    //未开课提醒
    Image{
        id: noStartLessonImg
        width: 447 * heightRate
        height: 95 * heightRate
        anchors.centerIn: parent
        visible: false
        source: "qrc:/lessonMgrImage/hmkssk.png"
    }

    //开始上课清屏操作
    Image{
        id: clearScreenImg
        width: 504 * heightRate
        height: 95 * heightRate
        visible: false
        anchors.centerIn: parent
        source: "qrc:/lessonMgrImage/ksskclear.png"
    }

    Timer{
        id: tipsTime
        interval: 3000
        repeat: false
        running: false
        onTriggered: {
            hideView();
        }
    }

    //隐藏所有页面
    function hideView(){
        exitRoomView.visible = false;
        startLesson.visible = false;
        continueLessonView.visible = false;
        tealevaImg.visible = false;
        warningImg.visible = false;
        noStartLessonImg.visible = false;
        clearScreenImg.visible = false;
    }

    //显示开始上课
    function showExitroom(){
        hideView();
        lessonTipsView.visible = true;
        exitRoomView.visible = true;
    }

    //开始上课
    function showStartLesson(){
        hideView();
        lessonTipsView.visible = true;
        startLesson.visible = true;
        tipsTime.restart();
    }

    //继续上课提醒
    function showContinueLessonView(){
        hideView();
        lessonTipsView.visible = true;
        continueLessonView.visible = true;
    }

    //下课了提醒 助教和学生使用
    function showDownLesson(){
        hideView();
        lessonTipsView.visible = true;
        endImg.visible = true;
    }

    //老师离开提醒 助教和学生使用
    function showTealevaImg(){
        hideView();
        lessonTipsView.visible = true;
        tealevaImg.visible = true;
        tipsTime.restart();
    }

    //老师开课提醒 学生助教提醒
    function showTeaStartLesson(){
        hideView();
        warningImg.visible = true;
        lessonTipsView.visible = true;
        tipsTime.restart();
    }

    //未开课提醒
    function showNoStartLesson(){
        hideView();
        noStartLessonImg.visible = true;
        lessonTipsView.visible = true;
        tipsTime.restart();
    }

    //开始上课清屏提醒
    function showClearScreen(){
        hideView();
        clearScreenImg.visible = true;
        lessonTipsView.visible = true;
        tipsTime.restart();
    }

}
