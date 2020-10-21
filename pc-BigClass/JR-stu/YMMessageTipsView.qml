import QtQuick 2.0
import YMMassgeRemindManager 1.0
import "Configuration.js" as Cfg
/*
* 顶部  消息提醒页面
*/
Rectangle {
    id: msgView
    width: closeButton.width + rowView.width + img.width + 33 * heightRate > implicitWidth ? implicitWidth : closeButton.width + rowView.width + img.width + 33 * heightRate
    height: 40 * heightRate
    border.width: 1
    border.color: Cfg.MASSGE_BORDER_COLOR
    radius:  8 * heightRate
    color: "#fffcee"
    anchors.verticalCenter: parent.verticalCenter

    property var lessonId:[];
    property var remindStatus: [];
    property var remindType: [];
    property var remindId: [];
    property string content: "";
    //property string debugText: "==========法撒旦法撒旦飞洒地方撒旦飞洒地方撒旦发==========="
    property var remindTime: [];
    property var currentData: [];
    property int total: 0;

    signal pramLessonId(var lessonId,var remindId);//传递课程id和消息id信号

    onCurrentDataChanged: {
        analysisRemind(currentData);
    }

    Image{
        id: img
        width: 3 * heightRate
        height: 16 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 10 * widthRate
        source: "qrc:/images/icon_warn_msg.png"
        anchors.verticalCenter: parent.verticalCenter
    }

    MouseArea{
        id: closeButton
        width: 25 * widthRate
        height: 25 * widthRate
        cursorShape: Qt.PointingHandCursor
        anchors.right: parent.right
        anchors.rightMargin: 1 * widthRate
        anchors.verticalCenter: parent.verticalCenter
        Image{
            width:  14 * heightRate
            height: 14 * heightRate
            anchors.centerIn: parent
            source: "qrc:/images/btn_notice_close.png"
        }
        onClicked: {
            msgView.visible = false;
        }
    }

    Row{
        id: rowView
        spacing: 10 * widthRate
        anchors.left: img.right
        anchors.leftMargin:  10 * widthRate
        anchors.verticalCenter: parent.verticalCenter

        //如果字符太长则滚动显示
        Rectangle{
            color: "transparent"
            clip: true
            width: {
                if(content.length * Cfg.MASSGE_FONTSIZE * heightRate> msgView.implicitWidth){
                    textAnimation.start();
                    //console.log("white:",contentText.text.length * 16 * heightRate ,msgView.implicitWidth)
                    contentText.width = content.length * Cfg.MASSGE_FONTSIZE * heightRate;
                    return msgView.implicitWidth - 130 * heightRate;
                }else{
                    return content.length * Cfg.MASSGE_FONTSIZE * heightRate + 100 * heightRate ;
                }
            }
            height: parent.height
            Text{
                id: contentText
                width: parent.width// - 10
                text: "(" + remindTime + ") " + content
                font.family: Cfg.MASSGE_FAMILY
                font.pixelSize: Cfg.MASSGE_FONTSIZE * heightRate
                anchors.verticalCenter: parent.verticalCenter
                color:  Cfg.MASSGE_FONT_COLOR
            }
        }

        MouseArea{
            id: lookButton
            width: 20 * widthRate
            height:  25 * heightRate
            cursorShape:  Qt.PointingHandCursor

            Text{
                text: "查看"
                font.family: Cfg.MASSGE_FAMILY
                font.pixelSize: Cfg.MASSGE_FONTSIZE * heightRate
                color: Cfg.MASSGE_LINK_COLOR
                font.underline: true
                anchors.verticalCenter: parent.verticalCenter
            }

            onClicked: {
                pramLessonId(lessonId,remindId);
                //                if(remindStatus == 0)
                //                {
                //                    total = total - 1;
                //                    remindStatus = 1;
                //                }
            }
        }


    }

    NumberAnimation{
        id: textAnimation
        running: false
        properties: "x"
        target: contentText
        loops: Animation.Infinite
        from: 0
        to: -content.length * 14 * widthRate
        duration: content.length * 200
    }

    //解析消息提醒数据
    function analysisRemind(data){
        total = 0;
        var remindList = data.remindList;
        if(remindList  == undefined){
            return;
        }
        //console.log("==analysisRemind===",total,JSON.stringify(remindList))
        for(var i = 0; i <remindList.length; i ++){
            if(total ==0){
                lessonId = remindList[i].lessonId;
                remindStatus =remindList[i].remindStatus;
                remindType = remindList[i].remindType;
                remindId = remindList[i].remindId;
                content = addLessonText(remindList[i].content);// + debugText;
                remindTime = analysisTime(remindList[i].remindTime);
            }
            if(remindList[i].remindStatus == 0){
                total++;
            }
        }

    }

    //解析时间格式
    function analysisTime(time){
        var dataTime = new Date(time);
        var year = dataTime.getFullYear();
        var month = Cfg.addZero(dataTime.getMonth() + 1);
        var day = Cfg.addZero(dataTime.getDate());

        var hours = Cfg.addZero(dataTime.getHours());
        var minute = Cfg.addZero(dataTime.getMinutes());

        var currentData = year +"-"+ month + "-" + day + " " + hours + ":" + minute
        return currentData;
    }

    //添加课程编号文字
    function addLessonText(contentText){
        var textSplit = contentText.split('(');
        return textSplit[0] + " (课程编号:" + textSplit[1];
    }
}

