import QtQuick 2.7


//评价
Rectangle {
    id:tipEvaluateWidgetItem

    property double widthRates: tipEvaluateWidgetItem.width /  300.0
    property double heightRates: tipEvaluateWidgetItem.height / 400.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates
    radius: 10 * ratesRates

    color: "#00000000"

    //学生姓名
    property string  studentName: "郭靖"

    //授课内容是否合适
    property int  teachingContentType: 0

    //教学态度是否合适
    property int teachingAttitudeType: 0

    //课后作业是否布置
    property int homeworkType: 0

    //评价
    signal sigEvaluateContents(int content , int attitude , int homework , string contentText);

    //关闭界面
    signal closeTheWidget();

    //背景图片1
    Image {
        id:backGroundImage1
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: 100 * heightRates
        z:1
        source: "qrc:/images/dialog_goodtwo.png"
    }
    //背景图片2
    Image {
        id:backGroundImage2
        anchors.left: parent.left
        anchors.top: backGroundImage1.bottom
        width: parent.width
        height: 300 * heightRates
        z:1
        source: "qrc:/images/frametwo.png"
    }


    //提示姓名信息
    Rectangle{
        id: tagNameBackGround
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: 12 * tipEvaluateWidgetItem.heightRates
        anchors.leftMargin: 0 * tipEvaluateWidgetItem.widthRates
        anchors.topMargin: 100 * tipEvaluateWidgetItem.heightRates
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
            font.pixelSize: 12 * tipEvaluateWidgetItem.heightRates
            color: "#3c3c3e"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            z:2
            text: qsTr("学生 ") +  tipEvaluateWidgetItem.studentName + qsTr(" 结束课程")
        }
    }


    //提示信息
    Text {
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 15 * tipEvaluateWidgetItem.widthRates
        anchors.topMargin: 130 * tipEvaluateWidgetItem.heightRates
        width: 199 * tipEvaluateWidgetItem.widthRates
        height: 18 * tipEvaluateWidgetItem.heightRates
        font.pixelSize: 14 * tipEvaluateWidgetItem.heightRates
        color: "#ff5000"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        z:3
        text: '<font >*</font><font color="#708090">授课内容是否合适</font>'

    }

    Text {
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 15 * tipEvaluateWidgetItem.widthRates
        anchors.topMargin: 171 * tipEvaluateWidgetItem.heightRates
        width: 199 * tipEvaluateWidgetItem.widthRates
        height: 18 * tipEvaluateWidgetItem.heightRates
        font.pixelSize: 14 * tipEvaluateWidgetItem.heightRates
        color: "#ff5000"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        z:3
        text: '<font >*</font><font color="#708090">教学态度是否合适</font>'

    }

    Text {
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 15 * tipEvaluateWidgetItem.widthRates
        anchors.topMargin: 212 * tipEvaluateWidgetItem.heightRates
        width: 199 * tipEvaluateWidgetItem.widthRates
        height: 18 * tipEvaluateWidgetItem.heightRates
        font.pixelSize: 14 * tipEvaluateWidgetItem.heightRates
        color: "#ff5000"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        z:3
        text: '<font >*</font><font color="#708090">课后作业是否布置</font>'
    }


    //授课内容是否合适按钮
    Rectangle{
        id:teachingContentYes
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 236 * tipEvaluateWidgetItem.widthRates
        anchors.topMargin: 127 * tipEvaluateWidgetItem.heightRates
        width: 20 * tipEvaluateWidgetItem.widthRates
        height: 20 * tipEvaluateWidgetItem.heightRates
        color: "#00000000"
        radius: 2
        border.color: teachingContentType == 1 ? "#ff5000" : "#c3c6c9"
        border.width: 1
        z:3
        Text {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            font.family: "Microsoft YaHei"
            font.pixelSize: 12  * tipEvaluateWidgetItem.heightRates
            color: teachingContentType == 1 ? "#ff5000" : "#c3c6c9"
            text: qsTr("是")
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                teachingContentType = 1;
            }
        }
    }

    Rectangle{
        id:teachingContentNo
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 265 * tipEvaluateWidgetItem.widthRates
        anchors.topMargin: 127 * tipEvaluateWidgetItem.heightRates
        width: 20 * tipEvaluateWidgetItem.widthRates
        height: 20 * tipEvaluateWidgetItem.heightRates
        color: "#00000000"
        radius: 2
        border.color: teachingContentType == 2 ? "#ff5000" : "#c3c6c9"
        border.width: 1
        z:3
        Text {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            font.family: "Microsoft YaHei"
            font.pixelSize: 12  * tipEvaluateWidgetItem.heightRates
            color: teachingContentType == 2 ? "#ff5000" : "#c3c6c9"
            text: qsTr("否")
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                teachingContentType = 2;
            }
        }
    }



    //教学态度是否合适
    Rectangle{
        id:teachingAttitudeYes
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 236 * tipEvaluateWidgetItem.widthRates
        anchors.topMargin: 168 * tipEvaluateWidgetItem.heightRates
        width: 20 * tipEvaluateWidgetItem.widthRates
        height: 20 * tipEvaluateWidgetItem.heightRates
        color: "#00000000"
        radius: 2
        border.color: teachingAttitudeType == 1 ? "#ff5000" : "#c3c6c9"
        border.width: 1
        z:3
        Text {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            font.family: "Microsoft YaHei"
            font.pixelSize: 12  * tipEvaluateWidgetItem.heightRates
            color: teachingAttitudeType == 1 ? "#ff5000" : "#c3c6c9"
            text: qsTr("是")
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                teachingAttitudeType = 1;
            }
        }
    }

    Rectangle{
        id:teachingAttitudeNo
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 265 * tipEvaluateWidgetItem.widthRates
        anchors.topMargin: 168 * tipEvaluateWidgetItem.heightRates
        width: 20 * tipEvaluateWidgetItem.widthRates
        height: 20 * tipEvaluateWidgetItem.heightRates
        color: "#00000000"
        radius: 2
        border.color: teachingAttitudeType == 2 ? "#ff5000" : "#c3c6c9"
        border.width: 1
        z:3
        Text {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            font.family: "Microsoft YaHei"
            font.pixelSize: 12  * tipEvaluateWidgetItem.heightRates
            color: teachingAttitudeType == 2 ? "#ff5000" : "#c3c6c9"
            text: qsTr("否")
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                teachingAttitudeType = 2;
            }
        }
    }




    //课后作业是否布置
    Rectangle{
        id:homeworkYes
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 236 * tipEvaluateWidgetItem.widthRates
        anchors.topMargin: 209 * tipEvaluateWidgetItem.heightRates
        width: 20 * tipEvaluateWidgetItem.widthRates
        height: 20 * tipEvaluateWidgetItem.heightRates
        color: "#00000000"
        radius: 2
        border.color: homeworkType == 1 ? "#ff5000" : "#c3c6c9"
        border.width: 1
        z:3
        Text {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            font.family: "Microsoft YaHei"
            font.pixelSize: 12  * tipEvaluateWidgetItem.heightRates
            color: homeworkType == 1 ? "#ff5000" : "#c3c6c9"
            text: qsTr("是")
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                homeworkType = 1;
            }
        }
    }

    Rectangle{
        id:homeworkNo
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 265 * tipEvaluateWidgetItem.widthRates
        anchors.topMargin: 209 * tipEvaluateWidgetItem.heightRates
        width: 20 * tipEvaluateWidgetItem.widthRates
        height: 20 * tipEvaluateWidgetItem.heightRates
        color: "#00000000"
        radius: 2
        border.color: homeworkType == 2 ? "#ff5000" : "#c3c6c9"
        border.width: 1
        z:3
        Text {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            font.family: "Microsoft YaHei"
            font.pixelSize: 12  * tipEvaluateWidgetItem.heightRates
            color: homeworkType == 2 ? "#ff5000" : "#c3c6c9"
            text: qsTr("否")
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                homeworkType = 2;
            }
        }
    }



    //评价内容
    Rectangle{
        id:contentEdit
        anchors.left: parent.left
        anchors.top: parent.top
        color: "#ffffff"
        border.color: "#c3c6c9"
        border.width: 1
        radius: 5 *  tipEvaluateWidgetItem.ratesRates
        anchors.leftMargin:15 * tipEvaluateWidgetItem.widthRates
        anchors.topMargin:  244 * tipEvaluateWidgetItem.heightRates
        width:  270 * tipEvaluateWidgetItem.widthRates
        height:  90 * tipEvaluateWidgetItem.heightRates
        z:3
        TextEdit{
            id:tcontentEditText
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 2
            anchors.topMargin: 2
            width: parent.width - 4
            height: parent.height - 4
            color: "#222222"
            font.family: "Microsoft YaHei"
            selectByMouse:true

            font.pixelSize: 12 *  tipEvaluateWidgetItem.ratesRates
            wrapMode: TextEdit.Wrap
            onLengthChanged:
            {
                if(tcontentEditText.length > 100)
                {
                    var prePosition = cursorPosition;
                    tcontentEditText.text = tcontentEditText.text.substring(0, 100);
                    cursorPosition = Math.min(prePosition, 100);
                }
            }
        }
        Text {
            id: contentEditTip
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 2
            anchors.topMargin: 2
            width: parent.width - 4
            height: parent.height - 4
            color: "#c3c6c9"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            font.pixelSize: 12 *  tipEvaluateWidgetItem.ratesRates
            text: qsTr("请填写评价内容，最多一百个中文字符超过不予填写。")
            opacity:tcontentEditText.length > 0? 0 :1
        }
    }


    //确定按钮
    Rectangle{
        id:okBtn
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 15 *  tipEvaluateWidgetItem.widthRates
        anchors.topMargin:  350 * tipEvaluateWidgetItem.heightRates
        width:  270  *  tipEvaluateWidgetItem.widthRates
        height:  32 * tipEvaluateWidgetItem.heightRates
        enabled:tipEvaluateWidgetItem.teachingContentType > 0 ?(tipEvaluateWidgetItem.teachingAttitudeType > 0 ? ( tipEvaluateWidgetItem.homeworkType > 0 ? ( tcontentEditText.length > 0 ? true : false): false ): false ): false
        color: "#ff5000"
        radius: 5 * tipEvaluateWidgetItem.heightRates
        z:3
        Text {
            id: okBtnName
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14  * tipEvaluateWidgetItem.ratesRates
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            color: "#ffffff"
            text: qsTr("提交并退出")
        }
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            enabled: okBtn.enabled
            onEnabledChanged: {
                if(enabled) {
                    okBtn.color = "#ff5000";

                }else {
                    okBtn.color = "#c3c6c9";

                }

            }

            onPressed: {
                okBtn.color = "#c3c6c9";

            }
            onReleased: {
                okBtn.color = "#ff5000";

                sigEvaluateContents(teachingContentType,teachingAttitudeType ,homeworkType ,tcontentEditText.text );

                tcontentEditText.text = "";
                tipEvaluateWidgetItem.teachingContentType = 0;
                tipEvaluateWidgetItem.teachingAttitudeType = 0;
                tipEvaluateWidgetItem.homeworkType = 0;

            }
        }
    }


    //关闭按钮
    Rectangle{
        id:closeBtn
        width: 22  * tipEvaluateWidgetItem.ratesRates
        height: 22 * tipEvaluateWidgetItem.ratesRates
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 25 * tipEvaluateWidgetItem.ratesRates
        anchors.rightMargin:  5 * tipEvaluateWidgetItem.ratesRates
        color: "#00000000"
        z:3
        Image {
            width: parent.width
            height: parent.height
            source: "qrc:/images/cr_btn_quittwo.png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                tipEvaluateWidgetItem.closeTheWidget();
                tcontentEditText.text = "";
                tipEvaluateWidgetItem.teachingContentType = 0;
                tipEvaluateWidgetItem.teachingAttitudeType = 0;
                tipEvaluateWidgetItem.homeworkType = 0;
            }
        }
    }


}

