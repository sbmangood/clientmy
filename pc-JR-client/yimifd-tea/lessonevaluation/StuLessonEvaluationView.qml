import QtQuick 2.7


//评价
Rectangle {
    id:tipEvaluateWidgetItem

    radius: 4
    width: 710
    height: 510

    color: "#3D3F54"

    //学生姓名
    property string  studentName: "郭靖"

    //授课内容是否合适
    property int  teachingContentType: 0

    //教学态度是否合适
    property int teachingAttitudeType: 0

    //课后作业是否布置
    property int homeworkType: 0

    property string paramTitle1: "是否适应老师的授课内容";
    property string paramTitle2: "是否喜欢老师的授课方式";
    property string paramTitle3: "是否喜欢老师的授课方式";
    property int inputMax: 100;
    property int inputMin: 20;

    //评价
    signal sigEvaluateContents(int content , int attitude , int homework , string contentText);

    //关闭界面
    signal closeTheWidget();

    onVisibleChanged: {
        if(visible){
            console.log("====AssessView1111=====",JSON.stringify(lessonCommentConfigInfo));
            for(var i = 0; i < lessonCommentConfigInfo.length; i++){
                var lessonObj = lessonCommentConfigInfo[i];
                var paramTitle = lessonObj.paramTitle;
                var paramId = lessonObj.paramId;
                var paramValue = lessonObj.paramValue;
                if(i == 0){
                    paramTitle1 = paramTitle;
                }
                if(i == 1){
                    paramTitle2 = paramTitle;
                }
                if(i == 2){
                    paramTitle3 = paramTitle;
                }
            }
        }
    }


    //title
    Rectangle{
        id: tagNameBackGround
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: 42
        color: "#37394C"
        Text {
            id: tagName
            anchors.centerIn: parent
            font.pixelSize: 18
            color: "#FFFFFF"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            text: "本节课程已结束，请填写课堂评价"
        }

        MouseArea{
            id: closeImage
            width:  42
            height: 42
            anchors.top: parent.top
            anchors.right: parent.right
            cursorShape: Qt.PointingHandCursor
            visible: true

            Text {
                font.pixelSize: 25
                font.bold: true
                color: "#6F7596"
                anchors.centerIn: parent
                text: qsTr("×")
            }

            onClicked: {
                tipEvaluateWidgetItem.visible = false;
                closeTheWidget();
            }
        }

    }


    //提示信息
    Text {
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 28
        anchors.topMargin: 72
        width: 184
        height: 16
        font.pixelSize: 16
        color: "#FE4A4A"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        z:3
        text: '<font >*</font><font color="#FFFFFF">'+paramTitle1+'</font>'

    }

    Text {
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 28
        anchors.topMargin: 116
        width: 184
        height: 16
        font.pixelSize: 16
        color: "#FE4A4A"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        z:3
        text: '<font >*</font><font color="#ffffff">'+ paramTitle2 +'</font>'

    }

    Text {
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 28
        anchors.topMargin: 160
        width: 184
        height: 16
        font.pixelSize: 16
        color: "#FE4A4A"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        z:3
        text: '<font >*</font><font color="#FFFFFF">'+ paramTitle3 +'</font>'
    }


    //授课内容是否合适按钮
    Rectangle{
        id:teachingContentYes
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 550
        anchors.topMargin: 67
        width: 60
        height: 26
        color: teachingContentType == 1 ? "#7CA0FF" : "#4B4E6A"
        radius: 4
        z:3
        Text {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.centerIn: parent
            font.family: "Microsoft YaHei"
            font.pixelSize: 16
            color: "#ffffff"
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
        anchors.leftMargin: 622
        anchors.topMargin: 67
        width: 60
        height: 26
        color: teachingContentType == 2 ? "#7CA0FF" : "#4B4E6A"
        radius: 4
        z:3
        Text {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.centerIn: parent
            font.family: "Microsoft YaHei"
            font.pixelSize: 16
            color: "#ffffff"
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
        anchors.leftMargin: 550
        anchors.topMargin: 111
        width: 60
        height: 26
        color: teachingAttitudeType == 1 ? "#7CA0FF" : "#4B4E6A"
        radius: 4
        z:3
        Text {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.centerIn: parent
            font.family: "Microsoft YaHei"
            font.pixelSize: 16
            color: "#ffffff"
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
        anchors.leftMargin: 622
        anchors.topMargin: 111
        width: 60
        height: 26
        color: teachingAttitudeType == 2 ? "#7CA0FF" : "#4B4E6A"
        radius: 4
        z:3
        Text {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.centerIn: parent
            font.family: "Microsoft YaHei"
            font.pixelSize: 16
            color: "#ffffff"
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
        anchors.leftMargin: 550
        anchors.topMargin: 155
        width: 60
        height: 26
        color: homeworkType == 1 ? "#7CA0FF" : "#4B4E6A"
        radius: 4
        z:3
        Text {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.centerIn: parent
            font.family: "Microsoft YaHei"
            font.pixelSize: 16
            color: "#ffffff"
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
        anchors.leftMargin: 622
        anchors.topMargin: 155
        width: 60
        height: 26
        color: homeworkType == 2 ? "#7CA0FF" : "#4B4E6A"
        radius: 4
        z:3
        Text {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.centerIn: parent
            font.family: "Microsoft YaHei"
            font.pixelSize: 16
            color: "#ffffff"
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
        color: "#37394C"
        radius: 4
        anchors.leftMargin:28
        anchors.topMargin:  206
        width:  654
        height:  224
        z:3
        TextEdit{
            id:tcontentEditText
            anchors.centerIn: parent
            width: parent.width - 28
            height: parent.height - 20
            color: "#FFFFFF"
            font.family: "Microsoft YaHei"
            selectByMouse:true

            font.pixelSize: 16
            wrapMode: TextEdit.Wrap
            onLengthChanged:
            {
                if(tcontentEditText.length > inputMax)
                {
                    var prePosition = cursorPosition;
                    tcontentEditText.text = tcontentEditText.text.substring(0, inputMax);
                    cursorPosition = Math.min(prePosition, inputMax);
                }
            }
        }
        Text {
            id: contentEditTip
            anchors.centerIn: parent
            width: parent.width - 28
            height: parent.height - 20
            color: "#8C8FB2"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            font.pixelSize: 16
            text: qsTr("请填写评价内容，不少于20个中文字符")
            opacity:tcontentEditText.length > 0? 0 :1
        }

    }

    Rectangle{
        height: 14
        width: 68
        anchors.right: parent.right
        anchors.top:parent.top
        anchors.rightMargin:  28
        anchors.topMargin: 440
        color: "transparent"

        Text {
            text: tcontentEditText.length
            font.family: "Microsoft YaHei"
            font.pixelSize: 14 * heightRate
            wrapMode: Text.WordWrap
            color:  "#4D90FF"
            anchors.right: midText.left
        }
        Text {
            id:midText
            text: "/"
            font.family: "Microsoft YaHei"
            font.pixelSize: 14 * heightRate
            wrapMode: Text.WordWrap
            color:  "#6E7298"
            anchors.right: totalTextLength.left
        }

        Text {
            id:totalTextLength
            text: "100"
            font.family: "Microsoft YaHei"
            font.pixelSize: 14 * heightRate
            wrapMode: Text.WordWrap
            color:  tcontentEditText.length == 100 ? "#FF5000" : "#6E7298"
            anchors.right: parent.right
            anchors.rightMargin: -5 * widthRate
        }

    }



    //确定按钮
    MouseArea{
        id: okBtn
        width: 250
        height: 36
        cursorShape: Qt.PointingHandCursor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 22
        enabled: (tipEvaluateWidgetItem.teachingContentType>0 && tipEvaluateWidgetItem.teachingAttitudeType > 0 && tipEvaluateWidgetItem.homeworkType > 0)

        Rectangle{
            anchors.fill: parent
            radius: 4 * heightRate
            color: parent.enabled ? "#6186E9" :"#37394C"
        }

        Text {
            text: qsTr("提交课堂评价")
            font.family: "Microsoft YaHei"
            font.pixelSize: 16 * heightRate
            anchors.centerIn: parent
            color: parent.enabled ? "#FFFFFF" :"#7C7F9E"
        }

        onClicked: {
            okBtn.enabled = false;
            sigEvaluateContents(teachingContentType,teachingAttitudeType ,homeworkType ,tcontentEditText.text );

            tcontentEditText.text = "";
            tipEvaluateWidgetItem.teachingContentType = 0;
            tipEvaluateWidgetItem.teachingAttitudeType = 0;
            tipEvaluateWidgetItem.homeworkType = 0;        }
    }


    //关闭按钮
    Rectangle{
        id:closeBtn
        width: 22
        height: 22
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 25
        anchors.rightMargin:  5
        color: "#00000000"
        z:3
        Image {
            width: parent.width
            height: parent.height
//            source: "qrc:/images/cr_btn_quittwo.png"
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

