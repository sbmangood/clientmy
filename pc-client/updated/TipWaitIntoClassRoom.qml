import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

/*
 *等待进入教室画面
 */
Rectangle {
    id:tipWaitIntoClassRoom

    color: "white"
    property double widthRates: tipWaitIntoClassRoom.width / 240.0
    property double heightRates: tipWaitIntoClassRoom.height / 153.0
    property double ratesRates: tipWaitIntoClassRoom.widthRates > tipWaitIntoClassRoom.heightRates? tipWaitIntoClassRoom.heightRates : tipWaitIntoClassRoom.widthRates

    property string tagNameContent: "进入教室中…"
    border.width: 1
    border.color: "#f3f3f3"

    radius: 10 * ratesRates
    clip: true

    //关闭界面
    signal sigCloseAllWidget();

    Image {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 97 * tipWaitIntoClassRoom.widthRates
        anchors.topMargin:  33 * tipWaitIntoClassRoom.heightRates
        width: 48 * tipWaitIntoClassRoom.ratesRates
        height: 48 * tipWaitIntoClassRoom.ratesRates
        fillMode: Image.PreserveAspectFit
        source: "qrc:/images/jinrujiaoshiwai logo.png"
    }
    Text {
        id: tagName
        width: 180 * tipWaitIntoClassRoom.widthRates
        height: 22 * tipWaitIntoClassRoom.heightRates
        anchors.left: parent.left
        anchors.top: parent.top
        font.pixelSize: 17 * tipWaitIntoClassRoom.heightRates
        anchors.leftMargin: 30 * tipWaitIntoClassRoom.widthRates
        anchors.topMargin: 113 * tipWaitIntoClassRoom.heightRates
        horizontalAlignment: Text.AlignHCenter
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        color: "#030303"
        text: tagNameContent
    }

    //关闭按钮
    Rectangle{
        id:closeBtn
        width: 13  * tipWaitIntoClassRoom.ratesRates
        height: 13 * tipWaitIntoClassRoom.ratesRates
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin:5 * tipWaitIntoClassRoom.ratesRates
        anchors.rightMargin:  5 * tipWaitIntoClassRoom.ratesRates
        color: "#00000000"
        Image {
            width: parent.width
            height: parent.height
            source: "qrc:/images/cr_btn_quittwo.png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                sigCloseAllWidget();
            }
        }
    }

    Rectangle{
        id: progressBars
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20  * fullWidths / 1440
        anchors.topMargin: 89 * tipWaitIntoClassRoom.heightRates
        width: 200  * fullWidths / 1440
        height: 4 * tipWaitIntoClassRoom.heightRates
        color: "#ff5000"
       //  color: "yellow"
        clip: true
        z:2

        Rectangle{
            id: progressBarb
            width: 100  * fullWidths / 1440
            height: parent.height
            y:0
            x:0
            z:3
            LinearGradient{
                anchors.fill: parent;
                z:4

                gradient: Gradient{
                    GradientStop{
                        position: 0.0;
                        color:  "#ff5000";

                    }
                    GradientStop{
                        position: 0.5;
                        color:"#FFEA4E";

                    }
                    GradientStop{
                        position: 1.0;
                        color: "#ff5000";
                    }
                }
                start:Qt.point(0, 0);
                end: Qt.point(parent.width, 0);
            }
        }
    }


    SequentialAnimation {
        id: playbanner
        running: false
        loops:  Animation.Infinite
        NumberAnimation { target: progressBarb; property: "x";from: -100  * fullWidths / 1440; to: 200 *fullWidths / 1440; duration: 3000}

    }

    Rectangle{
        anchors.left: parent.left
        anchors.top: progressBars.top
        anchors.right: progressBars.left
        anchors.bottom: progressBars.bottom
        color: "white"
        z:5

    }
    Rectangle{
        anchors.left: progressBars.right
        anchors.top: progressBars.top
        anchors.right:parent.right
        anchors.bottom: progressBars.bottom
        color: "white"
        z:5

    }

    //    //等待进度条
    //    ProgressBar{
    //        id: progressBar
    //        width: 200 * tipWaitIntoClassRoom.widthRates
    //        height: 4 * tipWaitIntoClassRoom.heightRates
    //        minimumValue: 0
    //        maximumValue: 0
    //        indeterminate: true
    //        anchors.left: parent.left
    //        anchors.top: parent.top
    //        anchors.leftMargin: 20 * tipWaitIntoClassRoom.widthRates
    //        anchors.topMargin: 89 * tipWaitIntoClassRoom.heightRates
    //        visible: false

    //    }
    Component.onCompleted: {
        playbanner.start();
    }

}
