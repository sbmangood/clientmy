import QtQuick 2.7
import QtQuick.Controls 2.0
import "Configuration.js" as Cfg
//课堂评价
Rectangle {
    id: assessView
    width: 710 * heightRate
    height: 572 * heightRate
    color: "#3D3F54"
    radius: 4 * heightRate

    property string paramTitle1: "知识掌握情况";
    property string paramTitle2:  "课堂表现";
    property string paramTitle3: "老师评价";
    property int inputMax: 400;
    property int inputMin: 20;
    property string aStudentName: "";

    //提交退出信号
    signal continueExit(var contentText1,var contentText2,var contentText3, var contentText4,var contentText5);
    //关闭信号
    signal confirmClose();

    ListModel
    {
        id:showTextModel
    }

    onVisibleChanged: {
//        if(visible){
//            console.log("====AssessView1111=====",JSON.stringify(lessonCommentConfigInfo));
//            for(var i = 0; i < lessonCommentConfigInfo.length; i++){
//                var lessonObj = lessonCommentConfigInfo[i];
//                var paramTitle = lessonObj.paramTitle;
//                var paramId = lessonObj.paramId;
//                var paramValue = lessonObj.paramValue;
//                console.log("====AssessView=====",JSON.stringify(lessonObj));
//                if(i == 0){
//                    paramTitle1 = paramTitle;
//                }
//                if(i == 1){
//                    paramTitle2 = paramTitle;
//                }
//                if(i == 2){
//                    paramTitle3 = paramTitle;

//                }
//            }
//        }
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

    //title
    Rectangle{
        width:  parent.width
        height: 42 * heightRate
        color: "#37394C"
        anchors.top :parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 18 * heightRate
            text: "课堂评价"
            color: "#FFFFFF"

            anchors.centerIn: parent
        }

        MouseArea{
            id: closeImage
            width:  42 * heightRate
            height: 42 * heightRate
            anchors.top: parent.top
            anchors.right: parent.right
            cursorShape: Qt.PointingHandCursor
            visible: true

            Text {
                font.pixelSize: 25 * heightRate
                font.bold: true
                color: "#6F7596"
                anchors.centerIn: parent
                text: qsTr("×")
            }

            onClicked: {
//                assessView.visible = false;
                confirmClose();

            }
        }

    }

    //评价等级
    Rectangle{
        width: 244 * heightRate
        height: 196 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 58 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 28 * heightRate
        color: "#37394C"
        radius: 4 * heightRate
        z:5

        Rectangle{
            anchors.left: parent.left
            anchors.leftMargin: 15 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 15 * heightRate
            height: 17 * heightRate
            width: parent.width
            color: "transparent"

            Rectangle{
                height: 17 * heightRate
                width: 3 * heightRate
                anchors.left: parent.left
                color: "#35D0B0"
                radius: 1.5 * heightRate
                anchors.top: parent.top
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 16 * heightRate
                text: "选择评价等级"
                color: "#FFFFFF"
                anchors.left: parent.left
                anchors.leftMargin: 12 * heightRate
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row{
            id:rowOne
            height: 20 * heightRate
            spacing: 0
            anchors.top: parent.top
            anchors.topMargin: 49 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 15 * heightRate
            property int currentSelectIndex: -1;

            onCurrentSelectIndexChanged: {
                if(textArea3.length >= inputMin && rowOne.currentSelectIndex != -1 && rowTwo.currentSelectIndex != -1 && rowThree.currentSelectIndex != -1 && rowFour.currentSelectIndex != -1){
                    continueButton.enabled = true
                }else{
                    continueButton.enabled = false;
                }
            }

            Text {
                width: 78 * heightRate
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                text: "课堂表现：  "
                color: "#FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle{
                width: 48 * heightRate
                height: 20 * heightRate
                radius: 10 * heightRate
                color: rowOne.currentSelectIndex == 1 ? "#6186E9" : "transparent"

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    text: "优秀"
                    color: "#FFFFFF"
                    anchors.centerIn: parent
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
            }
            Rectangle{
                width: 48 * heightRate
                height: 20 * heightRate
                radius: 10 * heightRate
                color: rowOne.currentSelectIndex == 2 ? "#6186E9" : "transparent"

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    text: "良好"
                    color: "#FFFFFF"
                    anchors.centerIn: parent
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
            }
            Rectangle{
                width: 48 * heightRate
                height: 20 * heightRate
                radius: 10 * heightRate
                color: rowOne.currentSelectIndex == 3 ? "#6186E9" : "transparent"

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    text: "一般"
                    color: "#FFFFFF"
                    anchors.centerIn: parent
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
        }

        Row{
            id:rowTwo
            height: 20 * heightRate
            spacing: 0
            anchors.top: parent.top
            anchors.topMargin: 84 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 15 * heightRate
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
                color: "#FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle{
                width: 48 * heightRate
                height: 20 * heightRate
                radius: 10 * heightRate
                color: rowTwo.currentSelectIndex == 1 ? "#6186E9" : "transparent"

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    text: "优秀"
                    color: "#FFFFFF"
                    anchors.centerIn: parent
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
            }
            Rectangle{
                width: 48 * heightRate
                height: 20 * heightRate
                radius: 10 * heightRate
                color: rowTwo.currentSelectIndex == 2 ? "#6186E9" : "transparent"

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    text: "良好"
                    color: "#FFFFFF"
                    anchors.centerIn: parent
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
            }
            Rectangle{
                width: 48 * heightRate
                height: 20 * heightRate
                radius: 10 * heightRate
                color: rowTwo.currentSelectIndex == 3 ? "#6186E9" : "transparent"

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    text: "一般"
                    color: "#FFFFFF"
                    anchors.centerIn: parent
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

        }

        Row{
            id:rowThree
            height: 20 * heightRate
            spacing: 0
            anchors.top: parent.top
            anchors.topMargin: 122 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 15 * heightRate
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
                text: "知识点掌握: "
                color: "#FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle{
                width: 48 * heightRate
                height: 20 * heightRate
                radius: 10 * heightRate
                color: rowThree.currentSelectIndex == 1 ? "#6186E9" : "transparent"

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    text: "优秀"
                    color: "#FFFFFF"
                    anchors.centerIn: parent
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
            }
            Rectangle{
                width: 48 * heightRate
                height: 20 * heightRate
                radius: 10 * heightRate
                color: rowThree.currentSelectIndex == 2 ? "#6186E9" : "transparent"

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    text: "良好"
                    color: "#FFFFFF"
                    anchors.centerIn: parent
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
            }
            Rectangle{
                width: 48 * heightRate
                height: 20 * heightRate
                radius: 10 * heightRate
                color: rowThree.currentSelectIndex == 3 ? "#6186E9" : "transparent"

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    text: "一般"
                    color: "#FFFFFF"
                    anchors.centerIn: parent
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

        }

        Row{
            id:rowFour
            height: 20 * heightRate
            spacing: 0
            anchors.top: parent.top
            anchors.topMargin: 157 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 15 * heightRate
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
                color: "#FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle{
                width: 48 * heightRate
                height: 20 * heightRate
                radius: 10 * heightRate
                color: rowFour.currentSelectIndex == 1 ? "#6186E9" : "transparent"

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    text: "优秀"
                    color: "#FFFFFF"
                    anchors.centerIn: parent
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
            }
            Rectangle{
                width: 48 * heightRate
                height: 20 * heightRate
                radius: 10 * heightRate
                color: rowFour.currentSelectIndex == 2 ? "#6186E9" : "transparent"

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    text: "良好"
                    color: "#FFFFFF"
                    anchors.centerIn: parent
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
            }
            Rectangle{
                width: 48 * heightRate
                height: 20 * heightRate
                radius: 10 * heightRate
                color: rowFour.currentSelectIndex == 3 ? "#6186E9" : "transparent"

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    text: "一般"
                    color: "#FFFFFF"
                    anchors.centerIn: parent
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


    }

    //评价描述
    Rectangle{
        width: 396 * heightRate
        height: 196 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 58 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 286 * heightRate
        color: "#37394C"
        z:5
        radius: 4 * heightRate
        clip: true

        Text {
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * heightRate
            text: "添加全部"
            color: "#4D90FF"
            anchors.right: parent.right
            anchors.rightMargin: 12 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 7 * heightRate
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

        Rectangle{
            anchors.left: parent.left
            anchors.leftMargin: 15 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 15 * heightRate
            height: 17 * heightRate
            width: parent.width
            color: "transparent"

            Rectangle
            {
                height: 17 * heightRate
                width: 3 * heightRate
                anchors.left: parent.left
                color: "#35D0B0"
                radius: 1.5 * heightRate
                anchors.top: parent.top
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 16 * heightRate
                text: "选择评价描述"
                color: "#FFFFFF"
                anchors.left: parent.left
                anchors.leftMargin: 12 * heightRate
                anchors.verticalCenter: parent.verticalCenter

            }
        }

        ListView{
            id:indexListView
            height: 154 * heightRate
            width: 366 * heightRate
            model: showTextModel
            anchors.left: parent.left
            anchors.leftMargin: 15 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 42 * heightRate
            delegate: Item{
                width:indexListView.width
                height: showTextId.height + 18 * heightRate

                Rectangle {
                    width: showTextId.width + 20 * heightRate
                    height: showTextId.height + 8 * heightRate
                    radius: 18 * heightRate
                    color: indexMouse.containsMouse ? "#6186E9" : "#4B4E6A"

                    Text {
                        id:showTextId
                        text: showText
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 14 * heightRate
                        color: "#FFFFFF"
                        anchors.centerIn: parent
                        wrapMode: Text.WordWrap

                        onWidthChanged:
                        {
                            showTextId.width = showTextId.width > indexListView.width ? indexListView.width - 10 * heightRate : showTextId.width

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

    //评价总览
    Rectangle{
        width: 654 * heightRate
        height: 224 * heightRate
        color: "#37394C"
        radius: 4 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 268 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        TextAreaControl{
            id: textArea3
            width: parent.width - 15 * heightRate
            height: parent.height - 30 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 30 * heightRate
            font.pixelSize: 16 * heightRate
            color: "#FFFFFF"
            maximumLength: 400

            text: aStudentName + "同学:               " + aStudentName + "同学，继续加油哦！"
            placeholderText: "请填写评价内容，不少于20个中文字符"//+ inputMin.toString() + "-" + inputMax.toString()+"字)"

            onTextChanged: {
                if(textArea3.length >= inputMin && rowOne.currentSelectIndex != -1 && rowTwo.currentSelectIndex != -1 && rowThree.currentSelectIndex != -1 && rowFour.currentSelectIndex != -1){
                    continueButton.enabled = true
                }else{
                    continueButton.enabled = false;
                }
            }
        }

        Rectangle{
            anchors.left: parent.left
            anchors.leftMargin: 15 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 15 * heightRate
            height: 17 * heightRate
            width: parent.width
            color: "transparent"
            Rectangle{
                height: 17 * heightRate
                width: 3 * heightRate
                anchors.left: parent.left
                color: "#35D0B0"
                radius: 1.5 * heightRate
                anchors.top: parent.top
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 16 * heightRate
                text: "评价总览"
                color: "#FFFFFF"
                anchors.left: parent.left
                anchors.leftMargin: 12 * heightRate
                anchors.verticalCenter: parent.verticalCenter

            }
        }


        Rectangle{
            height: 14 * heightRate
            width: 68 * heightRate
            anchors.right: parent.right
            anchors.top:textArea3.bottom
            anchors.rightMargin:  5 * heightRate
            anchors.topMargin: 6 * heightRate
            color: "transparent"

            Text {
                text: textArea3.length
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                wrapMode: Text.WordWrap
                color:  "#4D90FF"
                anchors.right: midText.left
            }
            Text {
                id:midText
                text: "/"
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                wrapMode: Text.WordWrap
                color:  "#6E7298"
                anchors.right: totalTextLength.left
            }

            Text {
                id:totalTextLength
                text: "400"
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                wrapMode: Text.WordWrap
                color:  textArea3.length == 400 ? "#FF5000" : "#6E7298"
                anchors.right: parent.right
                anchors.rightMargin: -5 * heightRate
            }

        }
    }

    MouseArea{
        id: continueButton
        width: 250 * heightRate
        height: 36 * heightRate
        cursorShape: Qt.PointingHandCursor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 22 * heightRate
        enabled: false

        Rectangle{
            anchors.fill: parent
            radius: 4 * heightRate
            color: parent.enabled ? "#6186E9" :"#37394C"
        }

        Text {
            text: qsTr("提交课堂评价")
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * heightRate
            anchors.centerIn: parent
            color: parent.enabled ? "#FFFFFF" :"#7C7F9E"
        }

        onClicked: {
            continueButton.enabled = false;
            enableBtnTime.restart();
            continueExit(rowOne.currentSelectIndex,rowTwo.currentSelectIndex, rowThree.currentSelectIndex,rowFour.currentSelectIndex, textArea3.text);
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
        return valueOne * 10 + valueTwo;
    }

}

