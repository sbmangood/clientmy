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
    property string currentTips: "开始上课后教室如有内容将被清空！";//

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
        width: 270 * heightRates
        height: 174 * heightRates
        radius:  8 * heightRates
        anchors.centerIn: parent
        color: "#ffffff"

        MouseArea{
            width: 238 * heightRates * 0.9
            height: 34 * heightRates * 0.9
            enabled: disableButton
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15 * heightRates
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
                font.pixelSize: 13 * heightRates
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
        anchors.topMargin: 18 * heightRates
        anchors.horizontalCenter: backView.horizontalCenter
        spacing: 8 * widthRates
        Rectangle
        {
            width: userNameTextOne.width + userNameText.width + userNameTextTwo.width
            height: userNameText.height
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                id: userNameText
                font.pixelSize: 16 * heightRates
                font.family: "Microsoft YaHei"
                text: qsTr("学生 ")
                wrapMode: Text.WordWrap
            }

            Text {
                id: userNameTextOne
                font.pixelSize: 16 * heightRates
                font.family: "Microsoft YaHei"
                text: userName
                anchors.left: userNameText.right
                wrapMode: Text.WordWrap
                color: "#FF6633"
            }

            Text {
                id: userNameTextTwo
                font.pixelSize: 16 * heightRates
                font.family: "Microsoft YaHei"
                text: " 进入教室"
                anchors.left: userNameTextOne.right
                wrapMode: Text.WordWrap
            }
        }
        Rectangle{
            width: parent.width
            height: 35 * heightRates
            Text {
                id: tipText
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                height: parent.height * 0.5
                text: currentTips//"当前课程可以接着之前内容继续进行"//
                font.family: "Microsoft YaHei"
                font.pixelSize: 15 * heightRates
                color: "#666666"
            }
            Text{
                width: parent.width
                height: parent.height * 0.5
                anchors.top: tipText.bottom
                anchors.topMargin: 5 * heightRate
                font.family: "Microsoft YaHei"
                font.pixelSize: 15 * heightRates
                color: "#666666"
                horizontalAlignment:  Text.AlignHCenter
                text: qsTr("现在开始上课?")
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

