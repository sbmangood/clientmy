import QtQuick 2.0
import "../Configuration.js" as Cfg

MouseArea{
    id: lessonButton
    width: parent.width
    height: parent.height
    // cursorShape: Qt.PointingHandCursor
    property var lessonData: [];
    property int currentHeight: height / 3;

    property int contentIndex: 0;
    property var contentData1: [];
    property var contentData2: [];
    property var contentData3: [];

    signal sigJoinClassrooms(var url);
    signal sigReadyLessons(var id,var dataJson);

    onLessonDataChanged: {
        if(lessonData == [] || lessonData == null){
            return;
        }
        //console.log("==lessonData=======",lessonData.count)
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
            if(tempDate.lessonType == "V"||tempDate.relateType == "V")
            {
                vdate.push(tempDate.classGroupId);
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
                if(repData.lessonId == oldData.classGroupId
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
                if(vdate[bb]==repDatas.classGroupId)
                {
                    sortData.splice(aa,1);
                    vdate.splice(bb,1);
                    aa=-1;
                    break;
                }
            }
        }

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
        }
    }

    Column{
        anchors.fill: parent
        spacing: 1

        YMLessonButtonInfo{
            height: currentHeight
            contentData: contentData1
            onSigJoinClassroomUrl: {
                sigJoinClassrooms(url);
            }
            onSigReadyLesson: {
                sigReadyLessons(classId,dataJson)
            }
        }

        YMLessonButtonInfo{
            height: currentHeight
            contentData: contentData2
            onSigJoinClassroomUrl: {
                sigJoinClassrooms(url);
            }
            onSigReadyLesson: {
                sigReadyLessons(classId,dataJson)
            }
        }

        YMLessonButtonInfo{
            height: currentHeight
            contentData: contentData3
            onSigJoinClassroomUrl: {
                sigJoinClassrooms(url);
            }
            onSigReadyLesson: {
                sigReadyLessons(classId,dataJson)
            }
        }
    }

    Rectangle{
        width: 1
        height: parent.height
        color: "#e3e6e9"
        anchors.right: parent.right
    }
}
