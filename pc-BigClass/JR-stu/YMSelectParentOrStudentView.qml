import QtQuick 2.0
//身份选择时弹窗  学生身份 家长身份
import "Configuration.js" as Cfg
Rectangle {
    id:mainBackGroundRectangle
    property bool isStudentBeselect: true;

    signal currentRole(var isStudent);// 当用户选择好角色的时候被发出的信号  isStudent 为 true是学生角色 false 为老师

    visible: true
    color:Qt.rgba(0,0,0,0.60)
    //
    Rectangle{//背景
        anchors.centerIn: parent
        width: 380 * heightRate
        height: 380 * heightRate
        color:"#ffffff"
        radius: 12 * widthRate

        MouseArea{//关闭按钮
            id: closeButton
            z: 2
            width: 25*widthRate
            height: 25*widthRate
            hoverEnabled: true
            anchors.top: parent.top
            anchors.topMargin: 10*heightRate
            anchors.right: parent.right
            anchors.rightMargin: 10*heightRate
            cursorShape: Qt.PointingHandCursor
            Text{
                text: "×"
                font.bold: true
                font.pixelSize: 22 * widthRate
                color: parent.containsMouse ? "red" : "#3c3c3e"
                anchors.centerIn: parent
            }

            onClicked: {
                mainBackGroundRectangle.visible=false;
                currentRole(true);
            }
        }

        Text {//选择身边字体
            id:textRectangle
            width: parent.width
            height: 20 * heightRate
            anchors.top:parent.top
            anchors.topMargin: 30* heightRate
            text: qsTr("选择身份")
            font.pixelSize: 18 * widthRate
            color:"#3c3c3e"
            horizontalAlignment: Text.AlignHCenter
            font.family: Cfg.DEFAULT_FONT
        }

        Row {
            id:photoRow
            width: parent.width
            height: parent.height * 0.4
            anchors.top: textRectangle.bottom
            anchors.topMargin: 30 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle {
                height: parent.height * 0.5
                width: parent.width * 0.5
                Image {
                    height: parent.width * 0.4
                    width: parent.width * 0.4
                    anchors.centerIn: parent
                    source:isStudentBeselect ? "qrc:/images/pangting_student_sed@2x.png":"qrc:/images/pangting_student@2x.png"
                }
                Text{
                    text: "学生"
                    width: parent.width
                    font.pixelSize: 16 * widthRate
                    color:isStudentBeselect ? "#ff6633" : "#666666"
                    anchors.top:  parent.bottom
                    anchors.topMargin: 15 * heightRate
                    horizontalAlignment:  Text.AlignHCenter
                    font.family: Cfg.DEFAULT_FONT
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        isStudentBeselect=true;
                    }
                }
            }
            Rectangle  {
                height: parent.height * 0.5
                width: parent.width * 0.5
                Image {
                    height: parent.width * 0.4
                    width: parent.width * 0.4
                    anchors.centerIn: parent
                    source: isStudentBeselect ? "qrc:/images/pangting_family@2x.png": "qrc:/images/pangting_family_sed@2x.png"
                }
                Text{
                    text: "家长"
                    width: parent.width
                    font.pixelSize: 16 * widthRate
                    color:isStudentBeselect==false ? "#ff6633" : "#666666"
                    anchors.top:  parent.bottom
                    anchors.topMargin: 15 * heightRate
                    horizontalAlignment:  Text.AlignHCenter
                    font.family: Cfg.DEFAULT_FONT
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        isStudentBeselect=false;
                    }
                }
            }
        }

        Rectangle{//身份切换 说明字体
            id: descItem
            width:parent.width
            height: 20 * heightRate
            anchors.top: photoRow.bottom
            Text {
                anchors.centerIn: parent
                text: qsTr("选定身份后可在“设置”菜单切换身份")
                color:"#3c3c3e"
                font.pixelSize: 18 * heightRate
                font.family: Cfg.DEFAULT_FONT
            }
        }
        Rectangle{//确定按钮
            width:parent.width * 0.8
            height: 42 * heightRate
            anchors.top: descItem.bottom
            anchors.topMargin: 20 * heightRate
            radius: 5 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            color:"#ff5000"
            Text {
                anchors.centerIn: parent
                text: qsTr("确定")
                color:"#ffffff"
                font.pixelSize: 22 * heightRate
                font.family: Cfg.DEFAULT_FONT
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    currentRole(isStudentBeselect);
                    mainBackGroundRectangle.visible=false;
                }
            }
        }
    }
}

