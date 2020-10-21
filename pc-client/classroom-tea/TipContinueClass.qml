import QtQuick 2.0
import QtQuick.Controls 2.0

/*
*继续上课页面
*/

Item {
    id: continueView

    property double widthRates: fullWidths / 1440;
    property double heightRates: fullHeights / 900;
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    property string userName: "";//用户名称
    property bool disableButton: true;

    signal sigContinue();//继续上课信号

    onVisibleChanged: {
        if(visible){
            disableButton = true;
        }else{
            disableButton = false;
        }
    }

    Rectangle{
        id: backView
        width: 270 * heightRates * 0.8;
        height: 174 * heightRates * 0.8;
        radius:  8 * heightRates
        anchors.centerIn: parent
        color: "#ffffff"

        MouseArea{
            width: 238 * heightRates * 0.8
            height: 34 * heightRates * 0.8
            enabled: disableButton
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10 * heightRates
            anchors.horizontalCenter: parent.horizontalCenter
            cursorShape: Qt.PointingHandCursor

            Image{
                width: parent.width
                height: parent.height
                source: "qrc:/images/btn_jianbian.png"
            }

            Text {
                text: qsTr("继续上课")
                color:  disableButton ? "#ffffff" : "gray"
                font.pixelSize: 12 * heightRates
                font.family: "Microsoft YaHei"
                anchors.centerIn: parent
            }

            onClicked: {
                disableButton = false;
                sigContinue();
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
                font.pixelSize: 15 * heightRates
                font.family: "Microsoft YaHei"
                text: qsTr("学生 ")
                wrapMode: Text.WordWrap
            }

            Text {
                id: userNameTextOne
                font.pixelSize: 15 * heightRates
                font.family: "Microsoft YaHei"
                text: userName
                anchors.left: userNameText.right
                wrapMode: Text.WordWrap
                color: "#FF6633"
            }

            Text {
                id: userNameTextTwo
                font.pixelSize: 15 * heightRates
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
                text: qsTr("当前课程可以接着之前内容继续进行")
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
                text: "现在继续上课？"
            }
        }

    }
    //显示界面
    function showWindow(){
        continueView.visible = true;
    }

    //隐藏界面
    function hideWindow(){
        continueView.visible = false;
    }
}
