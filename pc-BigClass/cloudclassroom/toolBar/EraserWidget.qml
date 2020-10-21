import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import "./Configuration.js" as Cfg

/*
 * 橡皮擦
 */
Item {
    id:bakcGround

    property double eraserSize: 0.025;

    signal sigClearsCreeon(var types); //0:清黑板，1:清屏、2:撤销信号
    signal sigSendEraserInfor(int types);    //橡皮擦

    MouseArea{
        anchors.fill: parent
        onClicked: {

        }
    }

    Image {
        id: bakcGroundImage
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.fill: parent
        source: "qrc:/images/huabi.png"
    }


    Rectangle{
        id: roundView
        width: 44 * heightRate
        height: 44 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 22 * heightRate
        radius: 100
        color: "#00000000"

        Image{
            anchors.fill: parent
            source: "qrc:/images/xb_gongju_huabi_huan.png"
        }

        Rectangle{
            id: round
            width: 6 * heightRate
            height: 6 * heightRate
            radius: 100
            color: "#00000000"
            border.width: 2 * heightRate
            border.color: "#35D0B0"
            anchors.centerIn: parent
        }
    }

    Slider{
        z: 5
        id: colorSlider
        width: parent.width - 50 * heightRate
        height: 18  * heightRate
        anchors.top: roundView.bottom
        anchors.topMargin: 12 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: (parent.width - width) * 0.5 - 4 * heightRate
        value: 0.5
        onPressedChanged: {
            bakcGround.visible = true;
            if(pressed == false){
                sigSendEraserInfor(2);
            }
        }

        onValueChanged: {
            if(value <= 0.18){
                round.width = 6 * heightRate
                round.height = 6 * heightRate
                eraserSize = 0.02;
                return
            }
            round.width = 8.0 * value * 6 * heightRate;
            round.height = 8.0 * value * 6 * heightRate;
            var currentPenValue = value / 10 * 0.5 ;
            eraserSize = currentPenValue.toFixed(7);
            //console.log("====colorSlider=====",value,eraserSize,currentPenValue.toFixed(7))
        }

        style: SliderStyle{
            groove:  Image{
                width: colorSlider.width
                height: colorSlider.height
                source: "qrc:/images/xb_lashentiao.png"
            }

            handle: Rectangle{
                width: 10 * heightRate
                height: 18 * heightRate
                color: "#A7ACDA"
                radius: 2 * heightRate
            }
        }
    }

//    //撤销
//    MouseArea{
//        id: undoButton
//        width: parent.width - 50 * heightRate
//        height: 33  * heightRate
//        anchors.top: colorSlider.bottom
//        anchors.topMargin: 10 * heightRate
//        anchors.left: parent.left
//        anchors.leftMargin: (parent.width - width) * 0.5 - 4 * heightRate
//        hoverEnabled: true
//        cursorShape: Qt.PointingHandCursor

//        Rectangle{
//            anchors.fill: parent
//            radius: 4 * heightRate
//            color: "#609BFD"
//        }

//        Image {
//            id: undoImg
//            width: 18 * heightRate
//            height: 19 * heightRate
//            source: parent.containsMouse ? "qrc:/images/xb_gongju_xiangpi_chexiao_dianji.png" : "qrc:/images/xb_gongju_xiangpi_chexiao_changtai.png"
//            anchors.verticalCenter: parent.verticalCenter
//            anchors.left: parent.left
//            anchors.leftMargin: 45 * heightRate
//        }

//        Text {
//            text: qsTr("撤销")
//            font.family: Cfg.DEFAULT_FONT
//            font.pixelSize: 16 * heightRate
//            color: parent.containsMouse ? "#4CF8D4" : "#ffffff"
//            anchors.verticalCenter: parent.verticalCenter
//            anchors.left: undoImg.right
//            anchors.leftMargin: 5 * heightRate
//        }
//        onClicked: {
//            sigClearsCreeon(2);
//        }
//    }

    //清屏
    MouseArea{
        id: clearCourse
        width: parent.width - 50 * heightRate
        height: 33  * heightRate
        anchors.top: colorSlider.bottom
        anchors.topMargin: 19 * widthRate
        anchors.left: parent.left
        anchors.leftMargin: (parent.width - width) * 0.5 - 4 * heightRate
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle{
            anchors.fill: parent
            radius: 2 * heightRate
            color: "#505370"
        }

//        Image {
//            id: removeImg
//            width: 21 * heightRate
//            height: 19 * heightRate
//            source: parent.containsMouse ? "qrc:/images/xb_gongju_xiangpi_qingchu_dianji.png" : "qrc:/images/xb_gongju_xiangpi_qingchu_changtai.png"
//            anchors.verticalCenter: parent.verticalCenter
//            anchors.left: parent.left
//            anchors.leftMargin: 35 * heightRate
//        }

        Text {
            id: text2
            text: qsTr("清除课件")
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * heightRate
            color: parent.containsMouse ? "#E2E5FF" : "#ffffff"
            anchors.centerIn: parent
        }

        onClicked: {
            sigClearsCreeon(1);
        }
    }

    //清屏
    MouseArea{
        width: parent.width - 50 * heightRate
        height: 33  * heightRate
        anchors.top: clearCourse.bottom
        anchors.topMargin: 10 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: (parent.width - width) * 0.5 - 4 * heightRate
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle{
            anchors.fill: parent
            radius: 2 * heightRate
            color: "#505370"
        }

//        Image {
//            id: removeImg1
//            width: 21 * heightRate
//            height: 19 * heightRate
//            source: parent.containsMouse ? "qrc:/images/xb_gongju_xiangpi_qingchu_dianji.png" : "qrc:/images/xb_gongju_xiangpi_qingchu_changtai.png"
//            anchors.verticalCenter: parent.verticalCenter
//            anchors.left: parent.left
//            anchors.leftMargin: 35 * heightRate
//        }

        Text {
            id: clearText
            text: qsTr("清除黑板")
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * heightRate
            color: parent.containsMouse ? "#E2E5FF" : "#ffffff"
            anchors.centerIn: parent
        }

        onClicked: {
            sigClearsCreeon(0);
        }
    }

}

