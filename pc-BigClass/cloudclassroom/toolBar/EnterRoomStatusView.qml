import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtWebEngine 1.4
import "./Configuuration.js" as Cfg

Rectangle {
    id: enterRoomStatusView
    color: "#000000"
    opacity: 0.7
    visible: true

    property string errCodeText: "";
    signal sigExitRoom();//退出信号

    Image {
        id: loading
        width: 64 * heightRate
        height: 65 * heightRate
        anchors.centerIn: parent
        source: "qrc:/classImage/1100加载中.png"
    }
    Text {
        id: loadText
        width: 140 * heightRate
        height: 18 * heightRate
        text: "   进入教室中..."
        color: "#FFFFFF"
        anchors.top: loading.bottom
        anchors.topMargin: 22 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 18 * heightRate
    }


    Image {
        z:2
        id: loadErrView
        width: 418 * heightRate
        height: 226 * heightRate
        anchors.centerIn: parent
        visible: false
        source: "qrc:/classImage/bg_pop_mshl.png"

        Text {
            id: errText
            width: 160 * heightRate
            height: 20 * heightRate
            text: errCodeText
            color: "#FFFFFF"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 73 * heightRate
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 20 * heightRate
        }

        Image {
            id: exitImage
            width: 177 * heightRate
            height: 44 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15 * heightRate
            source: exitBut.containsMouse ? "qrc:/classImage/btn_pop_foc.png" : "qrc:/classImage/btn_pop_nor.png"

            MouseArea{
                id: exitBut
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent

                onClicked: {
                    sigExitRoom();
                }
            }

        }
    }

    //通知状态
    function notifyStateCode(stateCode){
        if(stateCode != "0")
        {
            errCodeText = "error code: " + stateCode;
            loadErrView.visible = true;
            loading.visible = false;
            loadText.visible = false;
        }

    }

}
