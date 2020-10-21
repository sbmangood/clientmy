import QtQuick 2.0
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import YMLessonManagerAdapter 1.0
import "./Configuration.js" as Cfg

Rectangle {

    property double widthRate: Screen.width * 0.8 / 966.0;
    property double heightRate: widthRate / 1.5337;

    anchors.fill: parent
    border.width: 1
    border.color: "#e3e6e9"
    radius:  4 * widthRate

    signal closed();
    signal enterMini();

    property string executionPlanId: "";
    property string uId: "";
    property string envData: "sit01";
    property string groupId: "";
    property string failTips: "";
    property var window: null
    property bool enterConfirm: false;
    property string appType: "roomApp1V1";
    property string appId: "kiFBIeLYvxOuWFgwWOy1XFFFehdA2ovo";
    property string appKey: "L6X0TIPFLQGkwEKM";

    YMLessonManagerAdapter {
        id: lessonMgr
        onSigJoinClassroomFail: {
            failTips = "房间号错误";
        }
    }

    Rectangle {
        width: parent.width
        height: Cfg.TB_HEIGHT
        color: "transparent"
        MouseArea {
            id: dragRegion
            anchors.fill: parent
            property point clickPos: "0,0"
            onPressed: {
                clickPos  = Qt.point(mouse.x,mouse.y)
            }
            onPositionChanged: {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
                window.setX(window.x+delta.x)
                window.setY(window.y+delta.y)
            }
            onDoubleClicked:
            {
                window.visibility = Window.Windowed;
            }
        }
    }

    //关闭按钮
    MouseArea {
        id: closeButton
        width: 35 * widthRate
        height: 35 * widthRate
        anchors.right: parent.right
        anchors.top: parent.top
        hoverEnabled: true
        cursorShape: Qt.pointingHandCursor

        Image {
            id: closeImg
            anchors.fill: parent
            source: "qrc:/images/close.png"
        }

        /*
        Text{
            text: "×"
            font.bold: true
            font.pixelSize: 16 * widthRate
            color: parent.containsMouse ? "red" : "#3c3c3e"
            anchors.centerIn: parent
        }
        */

        onClicked: {
            closed();
        }
    }

    /*
    // 最小化按钮
    MouseArea{
        width: 15 * widthRate
        height: 35 * widthRate
        anchors.right: closeButton.left
        anchors.top: parent.top
        cursorShape: Qt.PointingHandCursor
        Text{
            text: "—"
            font.bold: true
            font.pixelSize: 12 * widthRate
            color: parent.containsMouse ? "#3c3c3e" : "#3c3c3e"
            anchors.centerIn: parent
        }
        onClicked: {
            enterMini();
        }
    }
    */

    // logo
    Item {
        id: logItem
        width: 117 * widthRate
        height: 91 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 50 *widthRate
        Image {
            anchors.fill: parent
            smooth: true
            fillMode: Image.PreserveAspectFit
            source: "qrc:/images/loginlogo.png"
        }
    }

    Item {
        id: inputItm
        width: 0.5 * parent.width
        height: 50 * heightRate
        anchors.top: logItem.bottom
        anchors.topMargin: 10 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter

        TextField {
            id: execId
            width: parent.width
            height: 50 * heightRate
            x: (parent.width - width) * 0.5
            text: executionPlanId
            placeholderText: "请输入房间号："
            font.family: Cfg.LOGIN_FAMILY
            font.pixelSize: Cfg.LOGIN_FONTSIZE * widthRate
            maximumLength: 32
            validator: RegExpValidator{id:regexp ; regExp: /^[0-9]+$/ }
            style: TextFieldStyle {
                background: Rectangle {
                    color: "#F5F8F9"
                    border.color:"#F5F8F9"
                    border.width: 1 * widthRate
                    radius: 22 * widthRate
                }
                textColor: "#222222"
                placeholderTextColor: "#999999"
                padding.left: 10 * widthRate
            }
            menu: null
            onTextChanged: {
                failTips = "";
                if(execId.text !== "")
                {
                    enterConfirm = true;
                }
                else
                {
                    enterConfirm = false;
                }
            }
            Image {
                id: enterImg
                width: 50 * heightRate
                height: 50 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: 5 * heightRate
                source: ((execId.text != "" && usrId.text != "") && (comboBox.currentIndex != 0 ? grpId.text != "" : true))? "qrc:/images/enter_success.png" : "qrc:/images/enter_failed.png"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if(appType == "roomApp" || appType == "roomApp1V1")
                        {
                            executionPlanId = execId.text;
                            uId = usrId.text;
                            envData =envType.text
                            groupId = grpId.text;
                            lessonMgr.getJoinClassRoomInfo(envType.text, executionPlanId, uId, groupId, appType);
                        }
                        else
                        {
                            executionPlanId = execId.text;
                            envData =envType.text
                            if(execId.text != "")
                            {             
                                lessonMgr.startPlayer(appId, appkey, envType.text, executionPlanId);
                            }
                        }


                    }
                }
            }

        }

        TextField {
            id: envType
            width: parent.width
            height: 50 * heightRate
            anchors.top: execId.bottom
            anchors.topMargin: 20 * heightRate
            x: (parent.width - width) * 0.5
            text: envData
            placeholderText: "请输入环境类型："
            font.family: Cfg.LOGIN_FAMILY
            font.pixelSize: Cfg.LOGIN_FONTSIZE * widthRate
            style: TextFieldStyle {
                background: Rectangle {
                    color: "#F5F8F9"
                    border.color:"#F5F8F9"
                    border.width: 1 * widthRate
                    radius: 22 * widthRate
                }
                textColor: "#222222"
                placeholderTextColor: "#999999"
                padding.left: 10 * widthRate
            }
            menu: null
            onTextChanged: {
                failTips = "";
                if(envType.text !== "")
                {
                    enterConfirm = true;
                }
                else
                {
                    enterConfirm = false;
                }
            }
        }


        TextField {
            id: usrId
            width: parent.width
            height: 50 * heightRate
            anchors.top: envType.bottom
            anchors.topMargin: 20 * heightRate
            x: (parent.width - width) * 0.5
            text: uId
            placeholderText: "请输入用户id：整型"
            font.family: Cfg.LOGIN_FAMILY
            font.pixelSize: Cfg.LOGIN_FONTSIZE * widthRate
            maximumLength: 18
            validator: RegExpValidator{id:regexp1 ; regExp: /^[0-9]+$/ }
            style: TextFieldStyle {
                background: Rectangle {
                    color: "#F5F8F9"
                    border.color:"#F5F8F9"
                    border.width: 1 * widthRate
                    radius: 22 * widthRate
                }
                textColor: "#222222"
                placeholderTextColor: "#999999"
                padding.left: 10 * widthRate
            }
            menu: null
            onTextChanged: {
                failTips = "";
                if(usrId.text !== "")
                {
                    enterConfirm = true;
                }
                else
                {
                    enterConfirm = false;
                }
            }
        }

        TextField {
            id: grpId
            width: parent.width
            height: 50 * heightRate
            anchors.top: usrId.bottom
            anchors.topMargin: 20 * heightRate
            x: (parent.width - width) * 0.5
            text: groupId
            visible: comboBox.currentIndex != 0
            placeholderText: "请输入班级id："
            font.family: Cfg.LOGIN_FAMILY
            font.pixelSize: Cfg.LOGIN_FONTSIZE * widthRate
            style: TextFieldStyle {
                background: Rectangle {
                    color: "#F5F8F9"
                    border.color:"#F5F8F9"
                    border.width: 1 * widthRate
                    radius: 22 * widthRate
                }
                textColor: "#222222"
                placeholderTextColor: "#999999"
                padding.left: 10 * widthRate
            }
            menu: null
            onTextChanged: {
                failTips = "";
                if(comboBox.currentIndex != 0){
                    if(grpId.text !== "")
                    {
                        enterConfirm = true;
                    }
                    else
                    {
                        enterConfirm = false;
                    }
                }
            }
        }

        YMComboxControl {
            id: appBox
            width: parent.width/2
            height: 30 * heightRate
            anchors.top: grpId.bottom
            anchors.topMargin: 10 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            model: ListModel {
                id: appItems
                ListElement { text: "云教室1V1" }
                ListElement { text: "教室" }
                ListElement { text: "播放器" }
            }
            currentIndex: 0
            onCurrentTextChanged: {
                if(currentIndex == 2)
                {
                    grpId.visible = false;
                    comboBox.visible = false;
                    usrId.visible = false;
                    appType = "playerApp";
                }
                else if(currentIndex == 1)
                {
                    comboBox.visible = true;
                    usrId.visible = true;
                    appType = "roomApp";
                }
                else if(currentIndex == 0)
                {
                    comboBox.visible = true;
                    usrId.visible = true;
                    appType = "roomApp1V1";
                }
            }
        }


        YMComboxControl {
            id: comboBox
            width: parent.width/2
            height: 30 * heightRate
            anchors.top: appBox.bottom
            anchors.topMargin: 10 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            model: ListModel {
                id: cbItems
                ListElement { text: "老师" }
                ListElement { text: "学生" }
                ListElement { text: "助教" }
            }
            currentIndex: 0
            onCurrentTextChanged: {
                lessonMgr.setUserRole(currentIndex);
                if(currentIndex == 0)
                {
                    grpId.visible = false;
                }
                else
                {
                    grpId.visible = true;
                }
            }
        }
    }


    // 错误提示
    Item {
        id: failTipItem
        width: 0.5 * parent.width
        height: 50 * heightRate
        anchors.top: inputItm.bottom
        anchors.topMargin: 40 * widthRate
        anchors.horizontalCenter: parent.horizontalCenter
        Text {
            id: lbFailText
            anchors.centerIn: parent
            visible: failTips == "" ? false : true
            text: failTips
            color: "#FF6363"
            font.family: Cfg.LOGIN_FAMILY
            font.pixelSize: Cfg.LOGIN_FONTSIZE * widthRate
        }
    }

    // 右下角logo
    Image {
        id: rightLogo
        width: 150 * heightRate
        height: 150 * heightRate
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        source: "qrc:/images/rightLogo.png"
    }

    Keys.onPressed: {
        if(event.key === Qt.Key_Enter || event.key === (Qt.Key_Enter - 1)){
            executionPlanId = execId.text;
            lessonMgr.getJoinClassRoomInfo(executionPlanId);
        }
    }

    //控制当前窗口, 光标的默认位置
    Component.onCompleted: {
        if(execId.text.trim() == "")
        {
            execId.focus = true;
        }
        else if(passwordText.text.trim() == "")
        {
            passwordText.focus = true;
        }
        else
        {
            execId.focus = true;
        }
    }
}
