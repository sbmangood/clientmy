import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import "./Configuuration.js" as Cfg

/*
 * 橡皮擦
 */
Item {
    id:bakcGround

    property double eraserSize: 0.025;

    //清屏、撤销信号
    signal sigClearsCreeon(var types);

    //橡皮擦
    signal sigSendEraserInfor(int types);

    Image {
        id: bakcGroundImage
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        source: "qrc:/miniClassImage/huabi.png"
    }


    Rectangle{
        id: roundView
        width: 44 * heightRate
        height: 44 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 22 * heightRate

        Image{
            anchors.fill: parent
            source: "qrc:/miniClassImage/xb_gongju_huabi_huan.png"
        }

        Rectangle{
            id: round
            width: 6 * heightRate
            height: 6 * heightRate
            radius: 100
            color: "#ffffff"
            border.width: 2 * heightRate
            border.color: "#ff6633"
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
            round.width = 7.0 * value * 6 * heightRate;
            round.height = 7.0 * value * 6 * heightRate;
            var currentPenValue = value / 10 * 0.5 ;
            eraserSize = currentPenValue.toFixed(7);
            //console.log("====colorSlider=====",value,eraserSize,currentPenValue.toFixed(7))
        }

        style: SliderStyle{
            groove:  Image{
                width: colorSlider.width
                height: colorSlider.height
                source: "qrc:/miniClassImage/xb_lashentiao.png"
            }

            handle: Rectangle{
                width: 10 * heightRate
                height: 14 * heightRate
                color: "#bababa"
                radius: 2 * heightRate
            }
        }
    }

    //撤销
    MouseArea{
        id: undoButton
        width: parent.width - 50 * heightRate
        height: 33  * heightRate
        anchors.top: colorSlider.bottom
        anchors.topMargin: 10 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: (parent.width - width) * 0.5 - 4 * heightRate
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle{
            anchors.fill: parent
            radius: 4 * heightRate
            color: parent.containsMouse ? "#fff9f6" : "#eeeeee"
            border.width: 1 * heightRate
            border.color: parent.containsMouse ? "#ffa182" : "#fff9f6"
        }

        Image {
            id: undoImg
            width: 18 * heightRate
            height: 19 * heightRate
            source: parent.containsMouse ? "qrc:/miniClassImage/xb_gongju_xiangpi_chexiao_dianji.png" : "qrc:/miniClassImage/xb_gongju_xiangpi_chexiao_changtai.png"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 45 * heightRate
        }

        Text {
            text: qsTr("撤销")
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * heightRate
            color: parent.containsMouse ? "#ff6633" : "black"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: undoImg.right
            anchors.leftMargin: 5 * heightRate
        }
        onClicked: {
            sigClearsCreeon(2);
        }
    }

    //清屏
    MouseArea{
        width: parent.width - 50 * heightRate
        height: 33  * heightRate
        anchors.top: undoButton.bottom
        anchors.topMargin: 10 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: (parent.width - width) * 0.5 - 4 * heightRate
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        Rectangle{
            anchors.fill: parent
            radius: 4 * heightRate
            color: parent.containsMouse ? "#fff9f6" : "#eeeeee"
            border.width: 1 * heightRate
            border.color: parent.containsMouse ? "#ffa182" : "#fff9f6"
        }

        Image {
            id: removeImg
            width: 21 * heightRate
            height: 19 * heightRate
            source: parent.containsMouse ? "qrc:/miniClassImage/xb_gongju_xiangpi_qingchu_dianji.png" : "qrc:/miniClassImage/xb_gongju_xiangpi_qingchu_changtai.png"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 35 * heightRate
        }

        Text {
            id: text2
            text: qsTr("清除所有")
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * heightRate
            color: parent.containsMouse ? "#ff6633" : "black"
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            anchors.left: removeImg.right
            anchors.leftMargin: 5 * heightRate
        }

        onClicked: {            
            bakcGround.visible = false;
            sigClearsCreeon(1);
        }
    }

}

