import QtQuick 2.0
import QtQuick.Controls 1.4
import YMLessonManagerAdapter 1.0

import "Configuration.js" as Cfg

/***课程表详细信息***/

MouseArea {
    id: lessonView
    z: 8888
    anchors.fill: parent
    onWheel: {
        return;
    }

    property var lessonData: [];
    property bool displayerStatus: false;//显示窗体状态


    property string subject: "";

    property int lessonId: 0;
    property string grade: "";
    property string name: "";
    property var startTime: ;
    property var endTime: ;
    property var nowTime: [];
    property string chargeName: "";
    property int hasRecord: 0;
    property string lessonType: "";
    property string lessonStatus: "";
    property string lessonName: "";
    property string teacherId: "";


    property double  widthRate : parent.width/ 1000.0;
    property double  heightRate : parent.height/ 600.0;

    signal lessonRefreshData();

    YMLessonManagerAdapter
    {
        id:liveLessonManager
    }

    //onVisibleChanged:
    //{
    //    if(visible)
    //    {
    //        lessonData=liveLessonManager.getLiveLessonDetailData("602");
    //     console.log("lessondata",JSON.stringify( lessonData.code));
    //    }
    //}
    //遮罩颜色
    Rectangle{
        color: "black"
        opacity: 0.4
        anchors.fill: parent
    }

    onDisplayerStatusChanged: {
        lessonView.visible = true;
        animateInOpacity.start();
    }
    //淡入效果
    NumberAnimation{
        id: animateInOpacity
        target: lessonView
        duration: 300
        properties: "opacity"
        from: 0.0
        to: 1.0
        onStarted: {
            animationHeight.start();
        }
    }

    //淡出效果
    NumberAnimation{
        id: animateOutOpactiy
        target: lessonView
        duration: 300
        properties: "opacity"
        from: 1.0
        to: 0.0
        onStopped: {
            lessonView.visible = false;
        }
        onStarted: {
            animation.start();
        }
    }

    //退出缩小动画
    PropertyAnimation{
        id: animation
        target: bodyItem
        property: "height"
        from: 245 * heightRate
        to: 0
        duration: 300
    }
    //弹出放大动画
    PropertyAnimation{
        id: animationHeight
        target: bodyItem
        property: "height"
        from: 0
        to: 245 * heightRate
        duration: 300
        onStarted:{
            bodyItem.visible = true;
        }
    }




    MouseArea{
        anchors.fill: parent
        hoverEnabled: true
    }

    //数据接收
    onLessonDataChanged: {
        if(lessonData == null || lessonData == [] || lessonData.lessonId == undefined){
            return;
        }
        //  console.log("===lessonInfo===",JSON.stringify(lessonData))
        lessonId = lessonData.lessonId;
        startTime = lessonData.startTime;
        endTime = lessonData.endTime;
        lessonStatus = lessonData.lessonStatus;
        lessonName = lessonData.lessonName;
        grade="";
        subject="";
        for( var a=0; a<lessonData.grade.length; a++)
        {
            grade += lessonData.grade[a];
        }
        for( var b=0; b<lessonData.subject.length; b++)
        {
            subject += lessonData.subject[b];
        }
    }

    Rectangle{
        id: bodyItem
        width: 270 * widthRate
        height: 245 * widthRate
        radius: 6 * heightRate
        color: "#ffffff"
        anchors.centerIn: parent

        MouseArea{
            id: closeButton
            z: 2
            width: 25 * widthRate
            height: 25 * widthRate
            hoverEnabled: true
            anchors.top: parent.top
            anchors.topMargin: 5*heightRate
            anchors.right: parent.right
            anchors.rightMargin: 5*heightRate
            Rectangle{
                anchors.fill: parent
                radius: 100
                color: parent.containsMouse ? "red" : "gray"

                Text{
                    text: "×"
                    font.bold: true
                    font.pixelSize: 16 * heightRate
                    color: "white"
                    anchors.centerIn: parent
                }
            }
            onClicked: {
                animateOutOpactiy.start();
            }
        }

        Rectangle{
            id: headItem
            width: parent.width
            height: 111 * widthRate
            radius: 6 * heightRate
            anchors.top: parent.top
            color: "#d0f2aa"
            Image
            {
                anchors.fill: parent
                source: "qrc:/images/greenbg@3x.png"
            }
            Image {
                width:  (lessonStatus == 3 ||lessonStatus == 4) ? 140 *widthRate : 72 * widthRate
                height: 22 * heightRate
                anchors.top: parent.top
                anchors.topMargin: 8 * heightRate
                anchors.left: parent.left
                source: lessonStatus == 0 ? "qrc:/images/greenbar@3x.png" : lessonStatus == 1 ? "qrc:/images/orgbar@3x.png" : lessonStatus == 2 ? "qrc:/images/bluebar@3x.png" : "qrc:/images/bluebar@3x.png"
            }
            Row{
                id: oneRow
                width: parent.width
                height: 30*heightRate
                anchors.left: parent.left
                anchors.leftMargin: 10 * widthRate
                spacing: 2*heightRate
                anchors.top: parent.top
                anchors.topMargin: 30 * heightRate

                Text{
                    width: 80 * widthRate
                    height: parent.height
                    text: analysisDate(startTime)
                    font.pixelSize: 15 * heightRate
                    color: "#6b9e0f"
                    verticalAlignment: Text.AlignVCenter
                }

                Text{
                    width: 100 * widthRate
                    height: parent.height
                    text: {
                        analysisTime(startTime,endTime);
                    }
                    font.pixelSize: 15 * heightRate
                    color: "#6b9e0f"
                    verticalAlignment: Text.AlignVCenter
                }
            }
            TextEdit {
                width: 239 * widthRate
                height: width / 4
                anchors.left: parent.left
                anchors.leftMargin: 10 * widthRate
                anchors.top: parent.top
                anchors.topMargin: 60 * heightRate
                wrapMode: TextEdit.Wrap
                font.pixelSize: 20 * heightRate
                color: "#6b9e0f"
                text: lessonName //"小学高分作文攻略高分作文小生也知道的写作敲门奇闻趣事"//lessonName
                enabled: false
            }

        }
        //head item end
        Item{
            width: parent.width
            height: parent.height - headItem.height
            anchors.top: headItem.bottom
            anchors.topMargin: 10 * heightRate
            Column{
                id: body1
                width: parent.width
                height: 48 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: Cfg.LESSON_MARGIN*widthRate
                anchors.top: parent.top
                anchors.topMargin: 10 * heightRate
                spacing: 10 * widthRate

                Row
                {
                    height: 20 * heightRate
                    width: 32 * widthRate
                    spacing: 10 * widthRate
                    Text{
                        height: parent.height * 0.5
                        verticalAlignment: Text.AlignVCenter
                        text: "课程编号"
                        font.family: Cfg.LESSON_FONT_FAMILY
                        font.pixelSize: Cfg.LESSON_FONT_SIZE * heightRate
                        color: Cfg.LESSON_HEAD_FONT_COLOR
                        width: 50 * widthRate
                    }
                    Text{
                        height: parent.height * 0.5
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 15 * heightRate
                        color: "#222222"
                        text: lessonId
                    }
                }
                Row
                {
                    height: 20 * heightRate
                    width: 32 * widthRate
                    spacing: 10 * widthRate
                    Text{
                        height: parent.height * 0.5
                        verticalAlignment: Text.AlignVCenter
                        text: "学科"
                        font.pixelSize: Cfg.LESSON_FONT_SIZE * heightRate
                        color: Cfg.LESSON_HEAD_FONT_COLOR
                        width: 50 * widthRate
                    }
                    Text{
                        height: parent.height * 0.5
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: Cfg.liveView_gradefont * heightRate
                        color: "#222222"
                        text: subject
                    }
                }

                Row
                {
                    height: 20 * heightRate
                    width: 32 * widthRate
                    spacing: 10 * widthRate
                    Text{
                        text: "年级"
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: Cfg.LESSON_FONT_SIZE*heightRate
                        color: Cfg.LESSON_HEAD_FONT_COLOR
                        width: 50 * widthRate
                    }
                    TextEdit {
                        width: 195 * widthRate
                        height: parent.height * 0.5
                        wrapMode: TextEdit.Wrap
                        font.pixelSize: Cfg.liveView_gradefont * heightRate
                        color: "#222222"
                        text: grade
                        enabled: false
                    }
                }
            }
        }
    }
    function analysisDate(startTime){
        var currentStartDate = new Date(parseInt(startTime));
        //console.log("====analysisDate====",currentStartDate,startTime);
        var year = currentStartDate.getFullYear();
        var month = Cfg.addZero(currentStartDate.getMonth() + 1);
        var day = Cfg.addZero(currentStartDate.getDate());

        return year + "-" + month + "-" + day;
    }

    function analysisTime(startTime,endTime){
        var currentStartDate = new Date(parseInt(startTime));
        var currentEndDate = new Date(parseInt(endTime));
        var sTime = Cfg.addZero(currentStartDate.getHours()) + ":" + Cfg.addZero(currentStartDate.getMinutes());
        var eTime = Cfg.addZero(currentEndDate.getHours()) + ":" + Cfg.addZero(currentEndDate.getMinutes());
        return sTime + "-" + eTime;
    }
    function getLiveLessonDetailData(lessonIds)
    {

        lessonData=liveLessonManager.getLiveLessonDetailData(lessonIds);
        lessonData=lessonData.data;
        lessonView.visible=true;
        animateInOpacity.start();
    }

}

