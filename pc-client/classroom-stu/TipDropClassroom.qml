import QtQuick 2.7

/*
 *主动退出教室课程结束
 */

Rectangle {
    id:tipDropClassroom

    color: "white"
    property double widthRates: tipDropClassroom.width / 240.0
    property double heightRates: tipDropClassroom.height / 226.0
    property double ratesRates: tipDropClassroom.widthRates > tipDropClassroom.heightRates? tipDropClassroom.heightRates : tipDropClassroom.widthRates
    property string tagNameContent: qsTr("")

    property int selectBtnBakcground: 1


    radius: 10 * ratesRates
    clip: true

    signal selectWidgetType(int types);
    signal closeWidget();

    onSelectBtnBakcgroundChanged: {
        if(selectBtnBakcground == 1){
            temporarilyExit.border.color =  "#ff5000"
            temporarilyExitName.color =  "#ff5000"
            courseEnd.border.color =  "#666666"
            courseEnd.color = "#ffffff"
            courseEndName.color =  "#666666"
            contentName.text = qsTr("课程尚未结束，确认退出？")

        }

        if(selectBtnBakcground == 2){
            temporarilyExit.border.color =  "#666666"
            temporarilyExitName.color =  "#666666"
            courseEnd.border.color =  "#ff5000"
            courseEnd.color = "#FFF3E9"
            courseEndName.color =  "#ff5000"
            contentName.text = qsTr("课程结束后无法再次回到教室，确认退出？")
        }

    }

    Text {
        id: tagName
        width: 84 * tipDropClassroom.widthRates
        height: 20 * tipDropClassroom.heightRates
        anchors.left: parent.left
        anchors.top: parent.top
        font.pixelSize: 18 * tipDropClassroom.ratesRates
        anchors.leftMargin: 73 * tipDropClassroom.widthRates
        anchors.topMargin: 18 * tipDropClassroom.heightRates
        color:  "#222222"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        text: qsTr("退出教室")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }


    //临时退出
    Rectangle{
        id:temporarilyExit
        width: 198 * tipDropClassroom.widthRates
        height: 30 * tipDropClassroom.heightRates
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20 * tipDropClassroom.widthRates
        //根据"课程结束"按钮的visible, 来决定"临时退出"按钮的布局
        anchors.topMargin: courseEnd.visible ? 93 * tipDropClassroom.heightRates : 135 * tipDropClassroom.heightRates
        color: selectBtnBakcground == 1 ? "#FFF3E9" : "#ffffff"
        border.color: selectBtnBakcground == 1 ? "#ff5000": "#666666"
        border.width: 1
        radius: 5 * tipDropClassroom.heightRates
        Text {
            id: temporarilyExitName
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 13  * tipDropClassroom.heightRates
            color:  selectBtnBakcground == 1 ? "#ff5000": "#666666"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            text: qsTr("临时退出")
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                console.log("==========Rectangle1============", applicationType, lessonType);
                tipDropClassroom.selectBtnBakcground = 1;
            }
        }
    }

    //课程结束
    Rectangle{
        id:courseEnd
        width: 198 * tipDropClassroom.widthRates
        height: 30 * tipDropClassroom.heightRates
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20 * tipDropClassroom.widthRates
        anchors.topMargin: 135 * tipDropClassroom.heightRates
        color: "#ffffff"
        border.color: "#666666"
        border.width: 1
        radius: 5 * tipDropClassroom.heightRates
        //如果是标准试听课的时候, 即: applicationType = 1, lessonType = 0 的时候, "课程结束"按钮, 隐藏掉, 演示课, 订单课, 则继续显示
        visible: ((applicationType == 1) && lessonType == 0) ? false : true

        Text {
            id: courseEndName
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 13  * tipDropClassroom.heightRates
            color: "#666666"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            text: qsTr("课程结束")
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                console.log("==========Rectangle2============", applicationType, lessonType);
                tipDropClassroom.selectBtnBakcground = 2;
            }
        }
    }

    Text {
        id: contentName
        width: 198 * tipDropClassroom.widthRates
        height: 28 * tipDropClassroom.heightRates
        anchors.left: parent.left
        anchors.top: parent.top
        font.pixelSize: 11.5 * tipDropClassroom.ratesRates
        anchors.leftMargin: 20 * tipDropClassroom.widthRates
        anchors.topMargin: 45 * tipDropClassroom.heightRates
        color: "#333333"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        text: qsTr("课程尚未结束，确认退出？")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }


    //确定按钮
    Rectangle{
        id:okBtn
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20 *  tipDropClassroom.widthRates
        anchors.topMargin:  184 * tipDropClassroom.heightRates
        width:  200  *  tipDropClassroom.widthRates
        height:  32 * tipDropClassroom.heightRates
        color: "#ff5000"
        radius: 5 * tipDropClassroom.heightRates
        Text {
            id: okBtnName
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14  * tipDropClassroom.ratesRates
            color: "#ffffff"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            text: qsTr("确定")
        }
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                selectWidgetType(tipDropClassroom.selectBtnBakcground);
                tipDropClassroom.selectBtnBakcground = 1;
                tipDropClassroom.visible = false;
            }
        }
    }


    //关闭按钮
    Rectangle{
        id:closeBtn
        width: 20  * tipDropClassroom.ratesRates
        height: 20 * tipDropClassroom.ratesRates
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin:10 * tipDropClassroom.ratesRates
        anchors.rightMargin:  10 * tipDropClassroom.ratesRates
        color: "#00000000"
        Image {
            width: parent.width
            height: parent.height
            source: "qrc:/images/cr_btn_quittwo.png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                closeWidget();
                tipDropClassroom.selectBtnBakcground = 1;

            }
        }
    }



}

