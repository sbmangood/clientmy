import QtQuick 2.0
import "../Configuration.js" as Cfg

MouseArea{
    id: lessonButton
    width: parent.width
    height: parent.height
    // cursorShape: Qt.PointingHandCursor
    property var lessonData: [];
    property int currentHeight: height / 4;

    property int contentIndex: 0;
    property var contentData1: [];
    property var contentData2: [];
    property var contentData3: [];
    property var contentData4: [];
    property var timeSchedule: [];

    onLessonDataChanged: {
        if(lessonData == [] || lessonData == null){
            return;
        }
        //四个参数赋值排序
        var sortData = [];
        for(var k = 0; k < lessonData.count;k++){
            sortData.push(lessonData.get(k));
        }

        var VDateget= sortData ;
        var vdate=[];
        for(var q = 0; q < VDateget.length;q++)
        {
            var tempDate= VDateget[q];
            // console.log("fdhkajjhjhjsssss sortData ",tempDate.lessonType);
            if(tempDate.lessonType == "V"||tempDate.relateType == "V")
            {
                // console.log("fdhkajjhjhjsssss  vvvvvvvvvv",tempDate.lessonId,q);
                vdate.push(tempDate.lessonId);
            }
        }
        // console.log("fdhkajjhjhjsssss sortData ",tempDate.lessonType);


        for(var i = 0; i < sortData.length;i++){
            var dataObj = sortData[i];
            for(var j = i + 1; j < sortData.length; j++){
                var dataObject = sortData[j]
                if(dataObj.startTime > dataObject.startTime){
                    var temp = sortData[i];
                    sortData[i] = sortData[j];
                    sortData[j] = temp;
                }
            }
        }
        for(var i = 0; i < sortData.length;i++){
            var dataObj = sortData[i];
            for(var j = i + 1; j < sortData.length; j++){
                var dataObject = sortData[j]
                if(dataObj.startTime > dataObject.startTime){
                    var temp = sortData[i];
                    sortData[i] = sortData[j];
                    sortData[j] = temp;
                }
            }
        }
        //去重复数据
        for(var a = 0; a < sortData.length;){
            var repData = sortData[a];
            var mark = true;
            for(var b = a + 1; b < sortData.length;b++){
                var oldData = sortData[b];
                if(repData.lessonId == oldData.lessonId
                        && repData.startTime == oldData.startTime
                        && repData.endTime == oldData.endTime){
                    sortData.splice(a,1);
                    a = 0;
                    mark = false;
                    break;
                }
            }
            if(mark){
                a++;
            }
        }

        for(var aa = 0; aa < sortData.length;aa++)
        {
            var repDatas = sortData[aa];
            for(var bb=0; bb< vdate.length;bb++)
            {
                if(vdate[bb]==repDatas.lessonId)
                {
                    sortData.splice(aa,1);
                    vdate.splice(bb,1);
                    aa=-1;
                    break;
                }
            }
        }
        //  console.log("vdatevdatevdate ",vdate,vdate.length);
        for(var z =0; z < sortData.length;z++){
            if(z == 0){
                contentData1 = sortData[z]
            }
            if(z == 1){
                contentData2 = sortData[z]
            }
            if(z == 2){
                contentData3 = sortData[z]
            }
            if(z == 3){
                contentData4 = sortData[z]
            }
        }
    }

    Column{
        anchors.fill: parent
        spacing: 1

        YMLessonButtonInfo{
            height: currentHeight
            contentData: contentData1
            timeSchedule: lessonButton.timeSchedule
        }
        YMLessonButtonInfo{
            height: currentHeight
            contentData: contentData2
            timeSchedule: lessonButton.timeSchedule
        }
        YMLessonButtonInfo{
            height: currentHeight
            contentData: contentData3
            timeSchedule: lessonButton.timeSchedule
        }
        YMLessonButtonInfo{
            height: currentHeight
            contentData: contentData4
            timeSchedule: lessonButton.timeSchedule
        }
    }

    Rectangle{
        width: 1
        height: parent.height
        color: "#e3e6e9"
        anchors.right: parent.right
    }
}
