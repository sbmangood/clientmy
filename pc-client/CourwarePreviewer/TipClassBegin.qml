import QtQuick 2.0
import "./Configuuration.js" as Cfg
/*
*开始上课页面
*/

Item {
    id: lessonView

    property double widthRates: fullWidths / 1440;
    property double heightRates: fullHeights / 900;
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    property string userName: "";//用户名称
    property bool disableButton: true;
    property string currentTips: "注:当前教室内如有操作将被清空";//

    signal sigStartLesson();//开始上课信号

    onVisibleChanged: {
        if(visible){
            disableButton = true;
        }else{
            disableButton = false;
        }
    }

    Rectangle{
        id: backView
        width: 280 * widthRates;
        height: 220 * heightRates;
        radius:  6 * heightRates
        anchors.centerIn: parent
        color: "#ffffff"

        MouseArea{
            width: parent.width * 0.8
            height: 40 * heightRate
            enabled: disableButton
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20 * heightRates
            anchors.horizontalCenter: parent.horizontalCenter
            cursorShape: Qt.PointingHandCursor

            Image{
                width: parent.width
                height: parent.height
                source: "qrc:/images/btn_jianbian.png"
            }

            Text {
                text: qsTr("开始上课")
                color:  disableButton ? "#ffffff" : "gray"
                font.pixelSize: 14 * heightRates
                font.family: "Microsoft YaHei"
                anchors.centerIn: parent
            }

            onClicked: {
                disableButton = false;
                sigStartLesson();
            }
        }
    }

    Column{
        width: backView.width * 0.8
        height: backView.height
        anchors.top: backView.top
        anchors.topMargin: 25 * heightRates
        anchors.horizontalCenter: backView.horizontalCenter
        spacing: 22 * widthRates

        Text {
            id: userNameText
            height: 45
            width: parent.width
            font.pixelSize: 20 * heightRates
            font.family: Cfg.font_family
            text: qsTr("学生 ") + userName + " 进入教室"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
        Rectangle{
            width: parent.width
            height: 35 * heightRates
            Text {
                id: tipText
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                height: parent.height * 0.5
                text: qsTr("现在开始上课?")
                font.family: "Microsoft YaHei"
                font.pixelSize: 12 * heightRates
                color: "#666666"
            }
            Text{
                width: parent.width
                height: parent.height * 0.5
                anchors.top: tipText.bottom
                font.family: "Microsoft YaHei"
                font.pixelSize: 12 * heightRates
                color: "#666666"
                horizontalAlignment:  Text.AlignHCenter
                text: currentTips//"当前课程可以接着之前内容继续进行"//
            }
        }

    }
    //显示界面
    function showWindow(){
        lessonView.visible = true;
    }

    //隐藏界面
    function hideWindow(){
        lessonView.visible = false;
    }
}

