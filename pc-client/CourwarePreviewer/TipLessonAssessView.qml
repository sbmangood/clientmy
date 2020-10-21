import QtQuick 2.0
import QtQuick.Controls 2.0
import "Configuuration.js" as Cfg

/*
*课程评价界面
*/

Rectangle {
    id: assessView

    width: 300 * widthRate
    height: 550 * heightRate
    radius: 12 * widthRate
    color: "transparent"

    //提交退出信号
    signal continueExit(var contentText1,var contentText2,var contentText3);

    //关闭信号
    signal confirmClose();

    Image{
        id: headImg
        width: parent.width
        height: 110 * heightRate
        source: "qrc:/images/pingjiahead.png"
    }

    //禁止频繁提交结束课程指令
    Timer{
        id: enableBtnTime
        running: false
        interval: 5000
        repeat: false
        onTriggered: {
            continueButton.enabled = true;
        }
    }

    MouseArea{
        id: closeImage
        width:  45 * heightRate
        height: 45 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 10 * heightRate
        anchors.right: parent.right
        anchors.rightMargin: -15 * heightRate
        cursorShape: Qt.PointingHandCursor

        Rectangle{
            anchors.fill: parent
            radius: 100
            color: "white"
        }

        Text {
            font.pixelSize: 18 * heightRate
            font.bold: true
            color: "#ff5000"
            anchors.centerIn: parent
            text: qsTr("×")
        }

//        Image{
//            anchors.fill: parent
//            source: "qrc:/images/cr_btn_quittwo.png"
//        }

        onClicked: {
            confirmClose();
        }
    }


    Rectangle{
        width: parent.width
        height: 40 * heightRate
        anchors.top: headImg.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: "white"
    }

    Rectangle{
        width: parent.width
        height: parent.height - headImg.height
        anchors.top: headImg.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: "white"
        radius:  12 * heightRate
    }

    Column{
        id: column
        width: parent.width - 40 * heightRate
        height: parent.height - headImg.height
        anchors.top: headImg.bottom
        anchors.topMargin: 20 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20 * heightRate

        Item{
            width: parent.width
            height: 40 * heightRate

            Text {
                id: text1
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 16 * heightRate
                text: qsTr("知识掌握情况 :")
                anchors.verticalCenter: parent.verticalCenter
            }
            YMStarsAssessView{
                id: starsAssessView1
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                onSigUpdateAssess: {
                    if(textArea3.length >= 10 && starsAssessView2.starsValue >= 0 && starsAssessView1.starsValue >= 0){
                        continueButton.enabled = true
                    }else{
                        continueButton.enabled = false;
                    }
                }
            }
        }

        Item{
            width: parent.width
            height:  40 * heightRate
            Text {
                id: text2
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 16 * heightRate
                text: qsTr("课堂表现 :")
                anchors.verticalCenter: parent.verticalCenter
            }

            YMStarsAssessView{
                id: starsAssessView2
                anchors.right: parent.right
                onSigUpdateAssess: {
                    if(textArea3.length >= 10 && starsAssessView2.starsValue >= 0 && starsAssessView1.starsValue >= 0){
                        continueButton.enabled = true
                    }else{
                        continueButton.enabled = false;
                    }
                }
            }
        }

        Text {
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * heightRate
            text: qsTr("老师评价 :")
        }

        TextAreaControl{
            id: textArea3
            width: parent.width
            height: 160 * heightRate

            maximumLength: 100
            placeholderText: "请输入评价(10-100字)"
            onTextChanged: {
                if(textArea3.length >= 10 && starsAssessView2.starsValue >= 0 && starsAssessView1.starsValue >= 0){
                    continueButton.enabled = true
                }else{
                    continueButton.enabled = false;
                }
            }
        }

        Text {
            visible: false
            width: parent.width
            height: 50 * heightRate
            text: qsTr("根据课堂练习情况，已为您只能推送了2道课后作业题目，请在作业中心确认后布置给学生")
            font.family: Cfg.font_family
            font.pixelSize: 18 * heightRate
            wrapMode: Text.WordWrap
            color:  "gray"
        }

        MouseArea{
            id: continueButton
            width: parent.width
            height: 45 * heightRate
            cursorShape: Qt.PointingHandCursor
            enabled: false

            Rectangle{
                anchors.fill: parent
                radius: 6 * heightRate
                color: parent.enabled ? "#ff5000" :"#c3c6c9"
            }

            Text {
                text: qsTr("提交并退出")
                font.family: Cfg.font_family
                font.pixelSize: 18 * heightRate
                anchors.centerIn: parent
                color:  "white"
            }

            onClicked: {
                continueButton.enabled = false;
                enableBtnTime.restart();
                //console.log("=====starsAssessView1===",starsAssessView1.starsValue , starsAssessView2.starsValue , textArea3.text)
                continueExit(starsAssessView1.starsValue , starsAssessView2.starsValue , textArea3.text);
            }
        }
    }

    /*
    MouseArea{
        id: closeImage
        width:  20 * heightRate
        height: 20 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 10 * heightRate
        anchors.right: parent.right
        anchors.rightMargin: 10 * heightRate
        cursorShape: Qt.PointingHandCursor

        Image{
            anchors.fill: parent
            source: "qrc:/images/cr_btn_quittwo.png"
        }
        onClicked: {
            confirmClose();
        }
    }



    Text{
        id: assessText
        width: parent.width
        height: 55 * heightRate
        text: "课程评价"
        font.family: Cfg.font_family
        font.pixelSize: 24 * heightRate
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Column{
        id: column
        width: parent.width - 40
        height: parent.height - assessText.height
        anchors.top: assessText.bottom
        anchors.topMargin: 20 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 30 * heightRate

        property int textHeight:  80 * heightRate
        property int columnHeight: 100 * heightRate


        Item{
            width: parent.width
            height: parent.columnHeight
            Text{
                id: text1
                text: "这节课学习了"
                font.pixelSize: 18 * heightRate
                font.family: Cfg.font_family
            }

            TextAreaControl{
                id: textArea1
                width: parent.width
                height: column.textHeight
                maximumLength: 40
                anchors.top: text1.bottom
                anchors.topMargin: 10 * heightRate
                onTextChanged: {
                    if(textArea1.length >= 1 && textArea2.length >= 10 && textArea3.length >= 10){
                        continueButton.enabled = true;
                    }else{
                        continueButton.enabled = false;
                    }
                }
            }
            Text{
                text: "1~40字"
                font.pixelSize: 14 * heightRate
                font.family: Cfg.font_family
                anchors.top: textArea1.bottom
                anchors.right: parent.right
            }
        }

        Item{
            width: parent.width
            height: parent.columnHeight
            Text{
                id: text2
                text: "知识掌握情况"
                font.pixelSize: 18 * heightRate
                font.family: Cfg.font_family
            }

            TextAreaControl{
                id: textArea2
                width: parent.width
                height: column.textHeight
                anchors.top: text2.bottom
                anchors.topMargin: 10 * heightRate
                maximumLength: 50
                onTextChanged: {
                    if(textArea1.length >= 1 && textArea2.length >= 10 && textArea3.length >= 10){
                        continueButton.enabled = true
                    }else{
                        continueButton.enabled = false;
                    }
                }
            }
            Text{
                text: "10~50字"
                font.family: Cfg.font_family
                 font.pixelSize: 14 * heightRate
                anchors.top: textArea2.bottom
                anchors.right: parent.right
            }
        }

        Item{
            width: parent.width
            height: parent.columnHeight
            Text{
                id: text3
                text: "课堂表现"
                font.pixelSize: 18 * heightRate
                font.family: Cfg.font_family
            }

            TextAreaControl{
                id: textArea3
                width: parent.width
                height: column.textHeight
                anchors.top: text3.bottom
                anchors.topMargin: 10 * heightRate
                maximumLength: 50
                onTextChanged: {
                    if(textArea1.length >= 1 && textArea2.length >= 10 && textArea3.length >= 10){
                        continueButton.enabled = true
                    }else{
                        continueButton.enabled = false;
                    }
                }
            }
            Text{
                text: "10~50字"
                font.pixelSize: 14 * heightRate
                font.family: Cfg.font_family
                anchors.top: textArea3.bottom
                anchors.right: parent.right
            }
        }

        Item{
            width: parent.width
            height: parent.columnHeight
            Label{
                id: lable1
                text: "1.请确保作业已经布置"
                font.family: Cfg.font_family
                font.pixelSize: 14 * heightRate
            }

            Label{
                id: lable2
                text: "2.提交后,上述内容会以短信的形式发送给家长"
                font.family: Cfg.font_family
                font.pixelSize: 14 * heightRate
                anchors.top: lable1.bottom
            }

            MouseArea{
                id: continueButton
                width: parent.width
                height: 45 * heightRate
                cursorShape: Qt.PointingHandCursor
                anchors.top: lable2.bottom
                anchors.topMargin: 10
                enabled: false

                Rectangle{
                    anchors.fill: parent
                    radius: 6 * heightRate
                    color: parent.enabled ? "#ff5000" :"#c3c6c9"
                }

                Text {
                    text: qsTr("提交并退出")
                    font.family: Cfg.font_family
                    font.pixelSize: 18 * heightRate
                    anchors.centerIn: parent
                    color:  "white"
                }

                onClicked: {
                    continueButton.enabled = false;
                    enableBtnTime.restart();
                    continueExit(textArea1.text , textArea2.text , textArea3.text);
                }

            }
        }
    }*/

}
