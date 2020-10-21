import QtQuick 2.2
import QtQuick.Controls 1.1
import QtWebView 1.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.2
import QtWebEngine 1.4
import "Configuuration.js" as Cfg

Rectangle {
    border.width: 1
    border.color: "#eeeeee"
    radius: 5

    signal showHomeWorkDetail( var homeWorkId, var title, var time);
    Rectangle
    {
        id:noReportViewt
        width: parent.width - 4 * widthRates
        height: parent.height - 4 * widthRates
        anchors.centerIn: parent
        color: "white"
        z:20
        visible: homeWorkModel.count == 0;
        Image {
            id:emptyImgs
            width: 296 * heightRates * 0.5
            height: 380 * heightRates * 0.5
            source: "qrc:/newStyleImg/pc_status_empty@2x.png"
            anchors.centerIn: parent
        }
        Text {
            text: canImportReportImgs ? qsTr("暂时没有课后作业哦~") : qsTr("学生端版本过低，不支持试课后作业导入哦~~")
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 14 * heightRate
            color: "#666666"
            anchors.top: emptyImgs.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
    Rectangle
    {
        id:topRect
        width: parent.width - 2 * widthRates
        anchors.top:parent.top
        anchors.topMargin: 2 * widthRates
        anchors.horizontalCenter: parent.horizontalCenter
        height: width * 44 / 518
        color: "#fbfdff"

        Text {
            text: qsTr("作业名称")
            font.pixelSize: 13 * heightRate
            elide: Text.ElideRight
            font.family: "Microsoft YaHei"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 18 * widthRates
            color: "#a6adb6"
        }

        Text {
            text: qsTr("上课时间")
            font.pixelSize: 13 * heightRate
            elide: Text.ElideRight
            font.family: "Microsoft YaHei"
            anchors.right: parent.right
            anchors.rightMargin: 152 * widthRates
            anchors.verticalCenter: parent.verticalCenter
            color: "#a6adb6"
        }
    }

    ListView//显示所有的课后作业
    {
        width:parent.width - 2 * heightRates
        height:parent.height - topRect.height - 20 * widthRates
        anchors.top:topRect.bottom
        anchors.horizontalCenter:parent.horizontalCenter
        id:audioVideoHomeWorkListView
        model:homeWorkModel
        delegate:audioVideoHomeWorkListViewDelegate
        clip:true

    }

    ListModel
    {
        id:homeWorkModel
    }

    Component
    {
        id:audioVideoHomeWorkListViewDelegate
        Item{
            width:audioVideoHomeWorkListView.width
            height: 50 * widthRates;
            Rectangle
            {
                anchors.fill: parent
                color: textMousearea.containsMouse ? "#f9f9f9" : "transparent"
            }
            Rectangle
            {
                width: parent.width
                height: 1
                color: "#f3f6f9"
                anchors.top: parent.top
                visible: index == 0
            }

            Text
            {
                text: lessonWorkName;
                //color: textMousearea.containsMouse ?"#ff6633":"#333333";
                color:"#333333"
                //anchors.centerIn: parent
                anchors.left: parent.left
                anchors.leftMargin: 20*widthRates
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14 * heightRates
                elide: Text.ElideRight
                font.family: "Microsoft YaHei"
            }

            Text
            {
                text: analysisTime(lessonStartTime,lessonEndTime)//"2018-09-12  11:45~12:55 >";
                //color: textMousearea.containsMouse ?"#ff6633":"#333333";
                color:"#333333"
                //anchors.centerIn: parent
                anchors.right: parent.right
                anchors.rightMargin: 30 * widthRates
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14 * heightRates
                elide: Text.ElideRight
                font.family: "Microsoft YaHei"
            }

            Image {
                id: name
                height: 12 * widthRates;
                width: 8 * widthRates;
                anchors.right: parent.right
                anchors.rightMargin: 10 * widthRates
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/newStyleImg/btn_arrow_s@2x.png"
            }

            Rectangle
            {
                width: parent.width
                height: 1
                color: "#f3f6f9"
                anchors.bottom: parent.bottom

            }

            MouseArea
            {
                anchors.fill: parent
                id:textMousearea
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked:
                {
                    showHomeWorkDetail(id,lessonWorkName,analysisTime(lessonStartTime,lessonEndTime));
                }
            }
        }

    }
    function setHomeWorkListDatas(objData)
    {
        console.log("setHomeWorkListData",objData)
        homeWorkModel.clear();
        var data = objData.data;
        for(var a = 0; a<data.length; a++)
        {
            homeWorkModel.append(
                        {
                            "createTime": data[a].createTime,
                            "create_name": data[a].create_name,
                            "description": data[a].description,
                            "endTime": data[a].endTime,
                            "enterTime": data[a].enterTime,
                            "create_name": data[a].create_name,
                            "finishTime": data[a].finishTime,
                            "gradeId": data[a].gradeId,
                            "id": data[a].id,
                            "isActive": data[a].isActive,
                            "isReadComment": data[a].isReadComment,
                            "isReadFinish": data[a].isReadFinish,
                            "lessonEndTime": data[a].lessonEndTime,
                            "lessonId": data[a].lessonId,
                            "lessonStartTime": data[a].lessonStartTime,
                            "lessonWorkName": data[a].lessonWorkName,
                            "lessonWorkStatus": data[a].lessonWorkStatus,
                            "lessonWorkType": data[a].lessonWorkType,
                            "questionCount": data[a].questionCount,
                            "scoreAvg": data[a].scoreAvg,
                            "scoreCount": data[a].scoreCount,
                            "studentId": data[a].studentId,
                            "studentName": data[a].studentName,
                            "subjectId": data[a].subjectId,
                            "teacherId": data[a].teacherId,
                            "useTime": data[a].useTime
                        }
                        );
        }
    }

    function analysisDate(startTime){
        var currentStartDate = new Date(startTime);
        var year = currentStartDate.getFullYear();
        var month = Cfg.addZero(currentStartDate.getMonth() + 1);
        var day = Cfg.addZero(currentStartDate.getDate());
        var tepmW = currentStartDate.getDay() ;
        //        var week;
        //        if(tepmW == 0)
        //        {
        //            week = "周日"
        //        }else if(tepmW == 1)
        //        {
        //            week = "周一"
        //        }else if(tepmW == 2)
        //        {
        //            week = "周二"
        //        }else if(tepmW == 3)
        //        {
        //            week = "周三"
        //        }else if(tepmW == 4)
        //        {
        //            week = "周四"
        //        }else if(tepmW == 5)
        //        {
        //            week = "周五"
        //        }else if(tepmW == 6)
        //        {
        //            week = "周六"
        //        }

        return year + "-" + month + "-" + day + " ";
    }

    function analysisTime(startTime,endTime){
        var date = analysisDate(startTime);
        var currentStartDate = new Date(startTime);
        var currentEndDate = new Date(endTime);
        var sTime = Cfg.addZero(currentStartDate.getHours()) + ":" + Cfg.addZero(currentStartDate.getMinutes());
        var eTime = Cfg.addZero(currentEndDate.getHours()) + ":" + Cfg.addZero(currentEndDate.getMinutes());
        return date + " " + sTime + "~" + eTime;
    }



}
