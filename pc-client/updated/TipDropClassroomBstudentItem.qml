import QtQuick 2.7
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4


//课程暂时中断，请退出 学生 某某某某 退出教室 用于b学生
Rectangle {
    id:tipClassOverWidgetItem

    property double widthRates: tipClassOverWidgetItem.width /  240.0
    property double heightRates: tipClassOverWidgetItem.height / 137.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates
    radius: 10 * ratesRates
    color: "white"

    //退出教室
    signal sigExitRoom();

    //退出教室的名字
    property string  exitName: "郭靖"

    property string  exitTip: qsTr("课程暂时中断，请退出")
    //提示姓名信息
    Rectangle{
        id: tagNameBackGround
        anchors.left: parent.left
        anchors.top: parent.top
        width: 212 * tipClassOverWidgetItem.widthRates
        height: 40 * tipClassOverWidgetItem.heightRates
        anchors.leftMargin: 25 * tipClassOverWidgetItem.widthRates
        anchors.topMargin: 16 * tipClassOverWidgetItem.heightRates
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#00000000"
        z:2
        Text {
            id: tagName
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height:parent.height
            font.bold: true
            font.pixelSize: 18 * tipClassOverWidgetItem.heightRates
            color: "#222222"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            z:2
            text:  tipClassOverWidgetItem.exitName + qsTr("退出教室")
        }
    }

    //提示信息
    Rectangle{
        id: contentNameBackGround
        anchors.left: parent.left
        anchors.top: parent.top
        width: 200 * tipClassOverWidgetItem.widthRates
        height: 17 * tipClassOverWidgetItem.heightRates
        anchors.leftMargin: 20 * tipClassOverWidgetItem.widthRates
        anchors.topMargin: 60 * tipClassOverWidgetItem.heightRates
        color: "#00000000"
        z:2
        Text {
            id: contentName
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height:parent.height
            //font.bold: true
            font.pixelSize: 12 * tipClassOverWidgetItem.heightRates
            color: "#3c3c3e"
            //wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            z:2
            text: exitTip
        }
    }


    //ok按钮
    Rectangle{
        id: okBtnBackGround
        anchors.left: parent.left
        anchors.top: parent.top
        width: 200 * tipClassOverWidgetItem.widthRates
        height: 32 * tipClassOverWidgetItem.heightRates
        anchors.leftMargin: 20 * tipClassOverWidgetItem.widthRates
        anchors.topMargin: 90 * tipClassOverWidgetItem.heightRates
        z:2
        radius: 5 //* ratesRates
        color: "#ff5000"
        Text {
            id: okBtn
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height:parent.height
            font.bold: true
            font.pixelSize: 14 * tipClassOverWidgetItem.heightRates
            color: "#ffffff"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            z:2
            text: qsTr("确定")
        }


        //        Rectangle{
        //            anchors.left: parent.left
        //            anchors.top: parent.top
        //            anchors.leftMargin: 5
        //            width: parent.width - 10
        //            height: parent.height
        //            LinearGradient{
        //                anchors.fill: parent;

        //                gradient: Gradient{
        //                    GradientStop{
        //                        position: 0.0;
        //                        color:  "#ff8000";

        //                    }
        //                    GradientStop{
        //                        position: 0.5;
        //                        color:"#ff5000";

        //                    }
        //                    GradientStop{
        //                        position: 1.0;
        //                        color: "#ff5000";
        //                    }
        //                }
        //                start:Qt.point(0, 0);
        //                end: Qt.point(parent.width, parent.width  );
        //            }
        //  }

        MouseArea{
            anchors.fill: parent
            cursorShape :Qt.PointingHandCursor
            z:5
            onClicked: {
                sigExitRoom();
            }
        }
    }




}

