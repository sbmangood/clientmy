import QtQuick 2.7
import QtQuick.Controls 2.0
import "Configuuration.js" as Cfg

/*
*课程评价界面  星级计算
*/

Rectangle {
    id: assessView
    width: 710 * widthRate * 0.7
    height: 636 * widthRate * 0.7
    radius: 6 * widthRate
    color: "#FFFFFF"

    property string paramTitle1: "知识掌握情况";
    property string paramTitle2:  "课堂表现";
    property string paramTitle3: "老师评价";
    property int inputMax: 400;
    property int inputMin: 10;
    property string aStudentName: curriculumData.getAStudentName();

    property bool couldDirectExit: false;//是否可以直接退出 默认false
    //提交退出信号
    signal continueExit(var contentText1,var contentText2,var contentText3);

    //关闭信号
    signal confirmClose();

    //评价之前发送退出教室信号
    signal sigSendFinishClass();

    ListModel
    {
        id:showTextModel
    }

    onVisibleChanged: {
        if(visible){
            console.log("====AssessView1111=====",JSON.stringify(lessonCommentConfigInfo));
            for(var i = 0; i < lessonCommentConfigInfo.length; i++){
                var lessonObj = lessonCommentConfigInfo[i];
                var paramTitle = lessonObj.paramTitle;
                var paramId = lessonObj.paramId;
                var paramValue = lessonObj.paramValue;
                console.log("====AssessView=====",JSON.stringify(lessonObj));
                if(i == 0){
                    paramTitle1 = paramTitle;
                }
                if(i == 1){
                    paramTitle2 = paramTitle;
                }
                if(i == 2){
                    paramTitle3 = paramTitle;
                    var paramList = paramValue.split("^");
                    inputMin = paramList[0];
                    inputMax = paramList[1];
                }
            }
        }
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
        width:  20 * heightRate
        height: 20 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 28 * heightRate
        anchors.right: parent.right
        anchors.rightMargin: 10 * heightRate
        cursorShape: Qt.PointingHandCursor
        visible: false
        Rectangle{
            anchors.fill: parent
            radius: 100
            color: "white"
        }

        Text {
            font.pixelSize: 15 * heightRate
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
            if(couldDirectExit)//已经发过finish命令了
            {
                confirmClose();
            }
            assessView.visible = false;
        }
    }

    Text {
        height: 20 * widthRates
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 17 * heightRate
        text: "课堂评价"
        color: "#111111"
        anchors.top: parent.top
        anchors.topMargin: 21 * widthRates
        anchors.horizontalCenter: parent.horizontalCenter

    }


    Rectangle{
        width: 238 * widthRate * 0.7
        height: 196 * widthRate * 0.7
        anchors.top: parent.top
        anchors.topMargin: 72 * widthRate * 0.7
        anchors.left: parent.left
        anchors.leftMargin: 32 * widthRates * 0.7
        color: "white"
        border.width: 1
        border.color: "#c0c0c0"
        radius: 3 * widthRate
        z:5

        Rectangle
        {
            anchors.left: parent.left
            anchors.leftMargin: 10 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 1 * widthRate
            height: 27 * widthRate
            width: parent.width
            color: "transparent"
            Rectangle
            {
                height: 11 * widthRate
                width: 1.5 * widthRate
                anchors.left: parent.left
                color: "#FF5500"
                radius: 1
                anchors.top: parent.top
                anchors.topMargin: 8.6 * widthRate
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 15 * heightRate
                text: "选择评价等级"
                color: "#111111"
                anchors.left: parent.left
                anchors.leftMargin: 9 * widthRate
                anchors.verticalCenter: parent.verticalCenter

            }
        }


        Row
        {
            id:rowOne
            spacing: 13 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 42 * widthRate * 0.7
            anchors.left: parent.left
            anchors.leftMargin: 15 * widthRates * 0.7
            property int currentSelectIndex: -1;

            onCurrentSelectIndexChanged: {
                if(textArea3.length >= inputMin && rowOne.currentSelectIndex != -1 && rowTwo.currentSelectIndex != -1 && rowThree.currentSelectIndex != -1 && rowFour.currentSelectIndex != -1){
                    continueButton.enabled = true
                }else{
                    continueButton.enabled = false;
                }
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: "课堂表现：  "
                color: "#737373"
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: "优秀"
                color: rowOne.currentSelectIndex == 1 ? "#FF6300" : "#CBCBCB"
                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        rowOne.currentSelectIndex = 1;
                        resetViewModel(1,1);
                    }
                }
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: "良好"
                color: rowOne.currentSelectIndex == 2 ? "#FF6300" : "#CBCBCB"
                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        rowOne.currentSelectIndex = 2;
                        resetViewModel(1,2);
                    }
                }
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: "一般"
                color: rowOne.currentSelectIndex == 3 ? "#FF6300" : "#CBCBCB"
                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        rowOne.currentSelectIndex = 3;
                        resetViewModel(1,3);
                    }
                }
            }

        }

        Row
        {
            id:rowTwo
            spacing: 13 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 72 * widthRate * 0.7
            anchors.left: parent.left
            anchors.leftMargin: 15 * widthRates * 0.7
            property int currentSelectIndex: -1;

            onCurrentSelectIndexChanged: {
                if(textArea3.length >= inputMin && rowOne.currentSelectIndex != -1 && rowTwo.currentSelectIndex != -1 && rowThree.currentSelectIndex != -1 && rowFour.currentSelectIndex != -1){
                    continueButton.enabled = true
                }else{
                    continueButton.enabled = false;
                }
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: "课堂互动：  "
                color: "#737373"
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: "优秀"
                color: rowTwo.currentSelectIndex == 1 ? "#FF6300" : "#CBCBCB"
                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        rowTwo.currentSelectIndex = 1;
                        resetViewModel(2,1);
                    }
                }
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: "良好"
                color: rowTwo.currentSelectIndex == 2 ? "#FF6300" : "#CBCBCB"
                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        rowTwo.currentSelectIndex = 2;
                        resetViewModel(2,2);
                    }
                }
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: "一般"
                color: rowTwo.currentSelectIndex == 3 ? "#FF6300" : "#CBCBCB"
                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        rowTwo.currentSelectIndex = 3;
                        resetViewModel(2,3);
                    }
                }
            }

        }

        Row
        {
            id:rowThree
            spacing: 13 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 102 * widthRate * 0.7
            anchors.left: parent.left
            anchors.leftMargin: 15 * widthRates * 0.7
            property int currentSelectIndex: -1;

            onCurrentSelectIndexChanged: {
                if(textArea3.length >= inputMin && rowOne.currentSelectIndex != -1 && rowTwo.currentSelectIndex != -1 && rowThree.currentSelectIndex != -1 && rowFour.currentSelectIndex != -1){
                    continueButton.enabled = true
                }else{
                    continueButton.enabled = false;
                }
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: "知识点掌握："
                width: 52 * widthRate
                color: "#737373"
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: "优秀"
                color: rowThree.currentSelectIndex == 1 ? "#FF6300" : "#CBCBCB"
                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        rowThree.currentSelectIndex = 1;
                        resetViewModel(3,1);
                    }
                }
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: "良好"
                color: rowThree.currentSelectIndex == 2 ? "#FF6300" : "#CBCBCB"
                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        rowThree.currentSelectIndex = 2;
                        resetViewModel(3,2);
                    }
                }
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: "一般"
                color: rowThree.currentSelectIndex == 3 ? "#FF6300" : "#CBCBCB"
                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        rowThree.currentSelectIndex = 3;
                        resetViewModel(3,3);
                    }
                }
            }

        }

        Row
        {
            id:rowFour
            spacing: 13 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 132 * widthRate * 0.7
            anchors.left: parent.left
            anchors.leftMargin: 15 * widthRates * 0.7
            property int currentSelectIndex: -1;

            onCurrentSelectIndexChanged: {
                if(textArea3.length >= inputMin && rowOne.currentSelectIndex != -1 && rowTwo.currentSelectIndex != -1 && rowThree.currentSelectIndex != -1 && rowFour.currentSelectIndex != -1){
                    continueButton.enabled = true
                }else{
                    continueButton.enabled = false;
                }
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: "个人能力：  "
                color: "#737373"
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: "优秀"
                color: rowFour.currentSelectIndex == 1 ? "#FF6300" : "#CBCBCB"
                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        rowFour.currentSelectIndex = 1;
                        resetViewModel(4,1);
                    }
                }
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: "良好"
                color: rowFour.currentSelectIndex == 2 ? "#FF6300" : "#CBCBCB"
                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        rowFour.currentSelectIndex = 2;
                        resetViewModel(4,2);
                    }
                }
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: "一般"
                color: rowFour.currentSelectIndex == 3 ? "#FF6300" : "#CBCBCB"
                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        rowFour.currentSelectIndex = 3;
                        resetViewModel(4,3);
                    }
                }
            }

        }


    }

    Rectangle{
        width: 400 * widthRate * 0.7
        height: 196 * widthRate * 0.7
        anchors.top: parent.top
        anchors.topMargin: 72 * widthRate * 0.7
        anchors.left: parent.left
        anchors.leftMargin: 282 * widthRate * 0.7
        color: "white"
        border.width: 1
        border.color: "#c0c0c0"
        z:5
        radius: 3 * widthRate
        clip: true

        Text {
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 15 * heightRate
            text: "添加全部"
            color: "#FF6300"
            anchors.right: parent.right
            anchors.rightMargin: 12 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 7 * widthRate
            font.underline: true

            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked:
                {
                    var tempText = "";
                    for(var a = 0; a < showTextModel.count; a++)
                    {
                        tempText = tempText + showTextModel.get(a).showText
                    }

                    var tmepStrig = aStudentName + "同学，继续加油哦！";
                    if(textArea3.text.indexOf(tmepStrig) != -1)
                    {
                        var allstring = textArea3.text;
                        allstring = allstring.replace(tmepStrig,tempText);
                        textArea3.text = allstring + tmepStrig
                    }else
                    {
                        textArea3.text = textArea3.text + tempText;
                    }

                }
            }

        }

        Rectangle
        {
            anchors.left: parent.left
            anchors.leftMargin: 10 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 1 * widthRate
            height: 27 * widthRate
            width: parent.width
            color: "transparent"
            Rectangle
            {
                height: 11 * widthRate
                width: 1.5 * widthRate
                anchors.left: parent.left
                color: "#FF5500"
                radius: 1
                anchors.top: parent.top
                anchors.topMargin: 8.6 * widthRate
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 15 * heightRate
                text: "选择评价描述"
                color: "#111111"
                anchors.left: parent.left
                anchors.leftMargin: 9 * widthRate
                anchors.verticalCenter: parent.verticalCenter

            }
        }

        ListView{
            id:indexListView
            height: 156 * widthRate * 0.7
            width: 350 * widthRate * 0.7
            model: showTextModel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 36 * heightRates
            delegate: Item{
                width:indexListView.width
                height: showTextId.height + 13 * widthRate

                Rectangle {
                    width: showTextId.width + 15 * heightRate
                    height: showTextId.height + 10 * heightRate
                    radius: 18 * heightRates
                    color: indexMouse.containsMouse ? "#FFFFFF" : "#F8F8F8"
                    border.width: 1
                    border.color: indexMouse.containsMouse ? "#FF6300" : "#F8F8F8"
                    Text {
                        id:showTextId
                        text: showText
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 14 * heightRate
                        color: indexMouse.containsMouse ? "#FF6300" : "#A1A1A1"
                        anchors.centerIn: parent
                        wrapMode: Text.WordWrap

                        onWidthChanged:
                        {
                            showTextId.width = showTextId.width > indexListView.width ? indexListView.width - 10 * widthRate : showTextId.width

                        }
                    }

                    MouseArea
                    {
                        id:indexMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked:
                        {
                            var tmepStrig = aStudentName + "同学，继续加油哦！";
                            if(textArea3.text.indexOf(tmepStrig) != -1)
                            {
                                var allstring = textArea3.text;
                                allstring = allstring.replace(tmepStrig,showText);
                                textArea3.text = allstring + tmepStrig
                            }else
                            {
                                textArea3.text = textArea3.text + showText;
                            }

                        }
                    }

                }

            }
        }
    }

    Rectangle
    {
        width: 654 * widthRate * 0.7
        height: 286 * widthRate * 0.7
        color: "white"
        border.width: 1
        border.color: "#c0c0c0"
        radius: 3 * widthRate
        anchors.top: parent.top
        anchors.topMargin: 284 * widthRate * 0.7
        anchors.horizontalCenter: parent.horizontalCenter
        TextAreaControl{
            id: textArea3
            width: parent.width - 10 * widthRate
            height: parent.height - 25 * widthRate
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 24 * widthRate
            font.pixelSize: 11 * heightRates
            color: "#989898"
            maximumLength: 400

            text: aStudentName + "同学                  " + aStudentName + "同学，继续加油哦！"
            placeholderText: "请输入内容..."//+ inputMin.toString() + "-" + inputMax.toString()+"字)"

            onTextChanged: {
                if(textArea3.length >= inputMin && rowOne.currentSelectIndex != -1 && rowTwo.currentSelectIndex != -1 && rowThree.currentSelectIndex != -1 && rowFour.currentSelectIndex != -1){
                    continueButton.enabled = true
                }else{
                    continueButton.enabled = false;
                }
            }
        }

        Rectangle
        {
            anchors.left: parent.left
            anchors.leftMargin: 10 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 1 * widthRate
            height: 27 * widthRate
            width: parent.width
            color: "transparent"
            Rectangle
            {
                height: 11 * widthRate
                width: 1.5 * widthRate
                anchors.left: parent.left
                color: "#FF5500"
                radius: 1
                anchors.top: parent.top
                anchors.topMargin: 8.6 * widthRate
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 15 * heightRate
                text: "评价总览"
                color: "#111111"
                anchors.left: parent.left
                anchors.leftMargin: 9 * widthRate
                anchors.verticalCenter: parent.verticalCenter

            }
        }


        Rectangle
        {
            height: 10 * widthRates
            width: 20 * widthRates
            anchors.right: parent.right
            anchors.top:textArea3.bottom
            anchors.rightMargin:  5 * widthRates
            anchors.topMargin: 6 * widthRates

            Text {
                text: textArea3.length
                font.family: Cfg.font_family
                font.pixelSize: 12 * heightRate
                wrapMode: Text.WordWrap
                color:  "#FF5000"
                anchors.right: midText.left
            }
            Text {
                id:midText
                text: "/"
                font.family: Cfg.font_family
                font.pixelSize: 12 * heightRate
                wrapMode: Text.WordWrap
                color:  "#D2D2D2"
                anchors.right: totalTextLength.left
            }

            Text {
                id:totalTextLength
                text: "400"
                font.family: Cfg.font_family
                font.pixelSize: 12 * heightRate
                wrapMode: Text.WordWrap
                color:  textArea3.length == 400 ? "#FF5000" : "#D2D2D2"
                anchors.right: parent.right
                anchors.rightMargin: -5 * widthRates
            }

        }
    }

    MouseArea{
        width: 158 * widthRate * 0.7
        height: 34 * widthRate * 0.7
        cursorShape: Qt.PointingHandCursor
        anchors.left: parent.left
        anchors.leftMargin: 191 * widthRate * 0.7
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 17 * widthRate * 0.7
        Rectangle{
            anchors.fill: parent
            radius: 6 * heightRate
            color: "white"
            border.width: 1
            border.color: "#999999"
        }

        Text {
            text: qsTr("取消")
            font.family: Cfg.font_family
            font.pixelSize: 12 * heightRate
            anchors.centerIn: parent
            color: "#333333"
        }

        onClicked: {
            if(couldDirectExit)//已经发过finish命令了
            {
                confirmClose();
            }
            assessView.visible = false;
        }
    }

    MouseArea{
        id: continueButton
        width: 158 * widthRate * 0.7
        height: 34 * widthRate * 0.7
        cursorShape: Qt.PointingHandCursor
        anchors.left: parent.left
        anchors.leftMargin: 361 * widthRate * 0.7
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 17 * widthRate * 0.7
        enabled: false

        Rectangle{
            anchors.fill: parent
            radius: 6 * heightRate
            color: parent.enabled ? "#ff5000" :"#c3c6c9"
        }

        Text {
            text: qsTr("提交并结束课程")//!couldDirectExit ? qsTr("提交") : qsTr("提交并退出")
            font.family: Cfg.font_family
            font.pixelSize: 12 * heightRate
            anchors.centerIn: parent
            color:  "white"
        }

        onClicked: {
            continueButton.enabled = false;
            enableBtnTime.restart();
            if(!couldDirectExit)
            {
                sigSendFinishClass();
                couldDirectExit = true;
            }
            console.log("=====starsAssessView1===",starsAssessView1.starsValue , starsAssessView2.starsValue , textArea3.text)
            continueExit(getParamValue(rowThree.currentSelectIndex,rowFour.currentSelectIndex) , getParamValue(rowOne.currentSelectIndex,rowTwo.currentSelectIndex) , textArea3.text);
        }
    }

    Column{
        id: column
        width: parent.width - 40 * heightRate
        height: parent.height
        anchors.top: parent.top
        anchors.topMargin: 270 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20 * heightRate

        Item{
            width: parent.width
            height: 50 * heightRate
            z:2
            visible: false
            Text {
                id: text1
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text:  paramTitle1
                color: "#666666"
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

            Rectangle
            {
                height: 1 * widthRates
                width: parent.width
                color: "#EEEEEE"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -5 * widthRates
            }
        }

        Item{
            visible: false
            width: parent.width
            height:  30 * heightRate
            Text {
                id: text2
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: paramTitle2
                color: "#666666"
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

            Rectangle
            {
                height: 1 * widthRates
                width: parent.width
                color: "#EEEEEE"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -10 * widthRates
            }
        }

    }

    function resetViewModel(rowKey,rowValue)
    {
        showTextModel.clear();
        if(rowKey == 1)
        {
            if(rowValue == 1)
            {
                showTextModel.append({
                                         "showText":"课堂注意力集中；"
                                     })
                showTextModel.append({
                                         "showText":"能认真记笔记，考虑问题全面；"
                                     })
                showTextModel.append({
                                         "showText":"解题思路清晰，解题能力优秀；"
                                     })
                showTextModel.append({
                                         "showText":"解题有耐心，非常注意细节。"
                                     })
            }else if(rowValue == 2)
            {
                showTextModel.append({
                                         "showText":"课堂注意力较集中；"
                                     })
                showTextModel.append({
                                         "showText":"基本能做到认真记笔记，考虑问题比较全面；"
                                     })
                showTextModel.append({
                                         "showText":"解题思路较清晰，解题能力良好；"
                                     })
                showTextModel.append({
                                         "showText":"解题较有耐心，比较注意细节。"
                                     })
            }else if(rowValue == 3)
            {
                showTextModel.append({
                                         "showText":"课堂注意力稍有分心；"
                                     })
                showTextModel.append({
                                         "showText":"未能做到认真记笔记，考虑问题不够全面；"
                                     })
                showTextModel.append({
                                         "showText":"解题思路不够清晰，解题能力一般；"
                                     })
                showTextModel.append({
                                         "showText":"解题较较急躁，不够注意细节。"
                                     })
            }

        }else if(rowKey == 2)
        {
            if(rowValue == 1)
            {
                showTextModel.append({
                                         "showText":"乐于向老师提出自己的疑问；"
                                     })
                showTextModel.append({
                                         "showText":"愿意思考，表达自己观点及想法非常清晰，与老师互动活跃。"
                                     })
            }else if (rowValue == 2)
            {
                showTextModel.append({
                                         "showText":"比较乐意向老师提出自己的疑问；"
                                     })
                showTextModel.append({
                                         "showText":"较愿意思考，表达自己观点及想法比较清晰，与老师互动较活跃。"
                                     })
            }else if (rowValue == 3)
            {
                showTextModel.append({
                                         "showText":"较少向老师提出自己的疑问；"
                                     })
                showTextModel.append({
                                         "showText":"希望多思考，表达自己观点及想法不够清晰，与老师互动较少。"
                                     })
            }

        }if(rowKey == 3)
        {

            if(rowValue == 1)
            {
                showTextModel.append({
                                         "showText":"课堂中知识点中的细节部分掌握全面；"
                                     })
                showTextModel.append({
                                         "showText":"课外知识储备丰富，能熟练用于课堂。"
                                     })
            }else if(rowValue == 2)
            {
                showTextModel.append({
                                         "showText":"课堂中知识点中的细节部分掌握较全面；"
                                     })
                showTextModel.append({
                                         "showText":"课外知识储备较丰富，基本可以熟练用于课堂。"
                                     })
            }else if(rowValue == 3)
            {
                showTextModel.append({
                                         "showText":"课堂中知识点中的细节部分掌握未达预期；"
                                     })
                showTextModel.append({
                                         "showText":"课外知识储备较少，未能熟练用于课堂。"
                                     })
            }

        }if(rowKey == 4)
        {
            if(rowValue == 1)
            {
                showTextModel.append({
                                         "showText":"思路创新；"
                                     })
                showTextModel.append({
                                         "showText":"爱动脑筋，有钻研精神；"
                                     })
                showTextModel.append({
                                         "showText":"碰到困难不会退缩，乐于接受挑战，不惧难题。"
                                     })
            }else if(rowValue == 2)
            {
                showTextModel.append({
                                         "showText":"较有创新性；"
                                     })
                showTextModel.append({
                                         "showText":"比较愿意动脑筋，比较有钻研精神；"
                                     })
                showTextModel.append({
                                         "showText":"碰到困难几乎不会退缩，乐于比较愿意接受挑战，基本不害怕难题。"
                                     })
            }else if(rowValue == 3)
            {
                showTextModel.append({
                                         "showText":"希望更具创造力；"
                                     })
                showTextModel.append({
                                         "showText":"希望多动脑筋，更具钻研精神；"
                                     })
                showTextModel.append({
                                         "showText":"碰到困难偶尔会退缩，不愿意挑战，害怕难题。"
                                     })
            }
        }

    }

    function getParamValue(valueOne,valueTwo)
    {
        var rowOneValue = valueOne == 1 ? 3 : (valueOne == 3 ? 1 : 2)
        var rowTwoValue = valueTwo == 1 ? 3 : (valueTwo == 3 ? 1 : 2)

        var addValue = (rowOneValue + rowTwoValue) / 2;
        if(1 == addValue)
        {
            return 1;
        }else if(1.5 == addValue)
        {
            return 2
        }else if(1.5 == addValue)
        {
            return 2
        }else if(2 == addValue)
        {
            return 3
        }else if(2.5 == addValue)
        {
            return 4
        }else if(3 == addValue)
        {
            return 5
        }
        return 3;
    }

}


/* 保留原代码

import QtQuick 2.0
import QtQuick.Controls 2.0
import "Configuuration.js" as Cfg

Rectangle {
    id: assessView

    width: 360 * widthRate * 0.7
    height: 494 * widthRate * 0.7
    radius: 12 * widthRate
    color: "transparent"

    property string paramTitle1: "知识掌握情况";
    property string paramTitle2:  "课堂表现";
    property string paramTitle3: "老师评价";
    property int inputMax: 100;
    property int inputMin: 10;

    property bool couldDirectExit: false;//是否可以直接退出 默认false
    //提交退出信号
    signal continueExit(var contentText1,var contentText2,var contentText3);

    //关闭信号
    signal confirmClose();

    //评价之前发送退出教室信号
    signal sigSendFinishClass();

    onVisibleChanged: {
        if(visible){
            console.log("====AssessView1111=====",JSON.stringify(lessonCommentConfigInfo));
            for(var i = 0; i < lessonCommentConfigInfo.length; i++){
                var lessonObj = lessonCommentConfigInfo[i];
                var paramTitle = lessonObj.paramTitle;
                var paramId = lessonObj.paramId;
                var paramValue = lessonObj.paramValue;
                console.log("====AssessView=====",JSON.stringify(lessonObj));
                if(i == 0){
                    paramTitle1 = paramTitle;
                }
                if(i == 1){
                    paramTitle2 = paramTitle;
                }
                if(i == 2){
                    paramTitle3 = paramTitle;
                    var paramList = paramValue.split("^");
                    inputMin = paramList[0];
                    inputMax = paramList[1];
                }
            }
        }
    }

    Image{
        id: headImg
        width: parent.width
        height: 110 * heightRate
        source: "qrc:/newStyleImg/popwindow_head@2x.png"
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
        width:  20 * heightRate
        height: 20 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 28 * heightRate
        anchors.right: parent.right
        anchors.rightMargin: 10 * heightRate
        cursorShape: Qt.PointingHandCursor

        Rectangle{
            anchors.fill: parent
            radius:           s
            color: "white"
        }

        Text {
            font.pixelSize: 15 * heightRate
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
            if(couldDirectExit)//已经发过finish命令了
            {
                confirmClose();
            }
            assessView.visible = false;
        }
    }


    Rectangle{
        width: parent.width
        height: 40 * heightRate
        anchors.top: headImg.bottom
        anchors.topMargin: -2 * widthRates
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
            height: 50 * heightRate
            z:2

            Text {
                id: text1
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text:  paramTitle1
                color: "#666666"
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

            Rectangle
            {
                height: 1 * widthRates
                width: parent.width
                color: "#EEEEEE"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -5 * widthRates
            }
        }

        Item{
            width: parent.width
            height:  30 * heightRate
            Text {
                id: text2
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: paramTitle2
                color: "#666666"
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

            Rectangle
            {
                height: 1 * widthRates
                width: parent.width
                color: "#EEEEEE"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -10 * widthRates
            }
        }

        Rectangle
        {
            width: parent.width
            height: 15 * widthRates

            Text {
                height: 20 * widthRates
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: paramTitle3
                color: "#666666"
                anchors.top: parent.top
                anchors.topMargin: 8 * widthRates
            }
        }

        Rectangle
        {
            width: 328 * widthRates * 0.825
            height: 130 * widthRates
            TextAreaControl{
                id: textArea3
                width: 328 * widthRates * 0.825
                height: 120 * widthRates * 0.84
                font.pixelSize: 11 * heightRates

                maximumLength: inputMax
                placeholderText: "请输入内容..."//+ inputMin.toString() + "-" + inputMax.toString()+"字)"
                onTextChanged: {
                    if(textArea3.length >= inputMin && starsAssessView2.starsValue >= 0 && starsAssessView1.starsValue >= 0){
                        continueButton.enabled = true
                    }else{
                        continueButton.enabled = false;
                    }
                }
            }

            Rectangle
            {
                height: 10 * widthRates
                width: 20 * widthRates
                anchors.right: parent.right
                anchors.top:textArea3.bottom
                anchors.rightMargin:  5 * widthRates
                anchors.topMargin: 6 * widthRates

                Text {
                    text: textArea3.length
                    font.family: Cfg.font_family
                    font.pixelSize: 12 * heightRate
                    wrapMode: Text.WordWrap
                    color:  "#FF5000"
                    anchors.right: midText.left
                }
                Text {
                    id:midText
                    text: "/"
                    font.family: Cfg.font_family
                    font.pixelSize: 12 * heightRate
                    wrapMode: Text.WordWrap
                    color:  "#D2D2D2"
                    anchors.right: totalTextLength.left
                }

                Text {
                    id:totalTextLength
                    text: "100"
                    font.family: Cfg.font_family
                    font.pixelSize: 12 * heightRate
                    wrapMode: Text.WordWrap
                    color:  textArea3.length == 100 ? "#FF5000" : "#D2D2D2"
                    anchors.right: parent.right
                    anchors.rightMargin: -5 * widthRates
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
        Rectangle
        {
            width: parent.width
            height: 45 * heightRate
            z:10
            MouseArea{
                width: 158 * widthRates * 0.8
                height: 34 * widthRates * 0.8
                cursorShape: Qt.PointingHandCursor
                anchors.left: parent.left

                Rectangle{
                    anchors.fill: parent
                    radius: 6 * heightRate
                    color: "white"
                    border.width: 1
                    border.color: "#999999"
                }

                Text {
                    text: qsTr("取消")
                    font.family: Cfg.font_family
                    font.pixelSize: 12 * heightRate
                    anchors.centerIn: parent
                }

                onClicked: {
                    if(couldDirectExit)//已经发过finish命令了
                    {
                        confirmClose();
                    }
                    assessView.visible = false;
                }
            }


            MouseArea{
                id: continueButton
                width: 158 * widthRates * 0.8
                height: 34 * widthRates * 0.8
                cursorShape: Qt.PointingHandCursor
                enabled: false
                anchors.right: parent.right

                Rectangle{
                    anchors.fill: parent
                    radius: 6 * heightRate
                    color: parent.enabled ? "#ff5000" :"#c3c6c9"
                }

                Text {
                    text: qsTr("提交并结束课程")//!couldDirectExit ? qsTr("提交") : qsTr("提交并退出")
                    font.family: Cfg.font_family
                    font.pixelSize: 12 * heightRate
                    anchors.centerIn: parent
                    color:  "white"
                }

                onClicked: {
                    continueButton.enabled = false;
                    enableBtnTime.restart();
                    if(!couldDirectExit)
                    {
                        sigSendFinishClass();
                        couldDirectExit = true;
                    }
                    //console.log("=====starsAssessView1===",starsAssessView1.starsValue , starsAssessView2.starsValue , textArea3.text)
                    continueExit(starsAssessView1.starsValue , starsAssessView2.starsValue , textArea3.text);
                }
            }
        }

    }
}

*/
