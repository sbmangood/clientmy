import QtQuick 2.0
import QtQuick.Controls 1.4
import "../../Configuration.js" as Cfg
import YMLessonManagerAdapter 1.0

/***课程表***/

Item {
    anchors.fill: parent

    property string year: "2016";
    property string week1: "周一";
    property string week2: "周二";
    property string week3: "周三";
    property string week4: "周四";
    property string week5: "周五";
    property string week6: "周六";
    property string week7: "周日";
    property int columnWidth: lessonListView.width  / 8;
    property int currentDateIndex: -1;
    property var contentDate: [];

    property var lessonInfo: [];

    YMLessonManagerAdapter{
        id: lessonMgr
        onTeachLessonInfoChanged:{
            var jsonObject = lessonInfo;
            updateWeek(jsonObject.data.dateOfWeek);
            updateLesonTime(jsonObject.data.timeSchedule);
            updateModelData(jsonObject.data.lessonSchedules);

        }
    }

    YMCalendarControl{
        id: calendar
        z: 23
        visible: false
        onDateTimeconfirm: {
            updateDateData(dateTime);
        }
    }


    Rectangle{
        id: headItem
        width: parent.width
        height: 40

        Text{
            id: titleText
            text: "课程表"
            font.bold: true
            font.pixelSize: 16
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
        }

        Image{
            width: 25
            height: 25
            anchors.left: titleText.right
            anchors.leftMargin: 10
            source: "qrc:/images/i.png"
            anchors.verticalCenter: parent.verticalCenter
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    console.log("========iiiiiiiiii============")
                    lessonDescribe.visible = true;
                }
            }
        }

        Rectangle{
            id: calendarItem
            width: 120
            height: 25
            radius: 4
            border.color: "#e0e0e0"
            border.width: 2
            anchors.right: currentDateItem.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            Row{
                anchors.fill: parent

                MouseArea{
                    width: 20
                    height: 10
                    anchors.verticalCenter: parent.verticalCenter

                    Image{
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/images/cr_btn_lastpage.png"
                    }
                    onClicked: {
                        var week = week7.split(" ");
                        var date = new Date(year +"-"+week[1])
                        date.setDate(date.getDate() - 7);
                        var month = date.getMonth() + 1;
                        var currentDate = date.getFullYear() + '-' + addZero(month) + '-' + addZero(date.getDate());
                        updateDateData(currentDate);
                    }
                }
                Rectangle{
                    width: 1
                    height: parent.height
                    color: "#e0e0e0"
                }

                Text{
                    width: parent.width - 40
                    height: parent.height
                    text: "日历"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            calendar.x = calendarItem.x - calendar.width + 140;
                            calendar.y = calendarItem.y + 30;
                            calendar.visible = true;
                        }
                    }
                }
                Rectangle{
                    width: 1
                    height: parent.height
                    color: "#e0e0e0"
                }
                MouseArea{
                    width: 20
                    height: 10
                    anchors.verticalCenter: parent.verticalCenter

                    Image{
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        source: 'qrc:/images/cr_btn_nextpage.png'
                    }

                    onClicked: {
                        var week = week7.split(" ");
                        var date = new Date(year +"-"+ week[1])
                        date.setDate(date.getDate()+ 7);
                        var month = date.getMonth() + 1;
                        var currentDate = date.getFullYear() + '-' + addZero(month) + '-' + addZero(date.getDate());
                        updateDateData(currentDate);
                    }
                }
            }
        }

        Rectangle{
            id: currentDateItem
            width: 25
            height: 25
            border.color: "#e0e0e0"
            border.width: 1
            radius: 4
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            Text{
                text: "今"
                font.bold: true
                font.pixelSize: 12
                anchors.centerIn: parent
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    var currentDate = getCurrentDate()
                    updateDateData(currentDate);
                }
            }
        }
    }

    Rectangle{
        id: headItem2
        width: parent.width
        height: 45
        anchors.top: headItem.bottom
        Row{
            anchors.fill: parent

            Text{
                width: columnWidth
                height: parent.height
                text: year
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Text{
                width: columnWidth
                height: parent.height
                text: week1
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Text{
                width: columnWidth
                height: parent.height
                text: week2
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Text{
                width: columnWidth
                height: parent.height
                text: week3
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Text{
                width: columnWidth
                height: parent.height
                text: week4
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Text{
                width: columnWidth
                height: parent.height
                text: week5
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Text{
                width: columnWidth
                height: parent.height
                text: week6
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            Text{
                width: columnWidth
                height: parent.height
                text: week7
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Rectangle{
        width: parent.width
        height: 2
        color: "#e0e0e0"
        anchors.top: headItem2.bottom
    }

    Rectangle{
        width: parent.width
        height: parent.height
        color: "white"
        anchors.top: headItem2.bottom

        ListView{
            id:lessonListView
            clip: true
            width: parent.width - 20
            height: parent.height - 100
            delegate: contentComponent
            model: lessonModel
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle{
            width: 1
            height: lessonListView.height
            anchors.left: lessonListView.left
            color: "#e0e0e0"
            anchors.top: parent.top
            anchors.topMargin: 10
        }
    }

    ListModel{
        id: lessonModel
    }

    Component{
        id: contentComponent
        Item{
            width: lessonListView.width
            height: 45

            Row{
                anchors.fill: parent
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                    text: time
                }

                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                }
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                }
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                }
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                }
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                }
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                }
                YMLessonButon{
                    width: columnWidth
                    height: parent.height
                }
            }

            Rectangle{
                width: columnWidth
                height: lessonModel.count * 45
                color: "#F3F8FF"
                opacity: 0.6
                visible: (currentDateIndex != -1)
                x: currentDateIndex * columnWidth
            }

            YMLessonInfoControl{
                z: 6
                width: columnWidth - 2
                height: 45 * getDisplayerInfo(lessonInfoData,1,"lineHeight")
                x: 1 * columnWidth
                visible: getDisplayerInfo(lessonInfoData,1,"dateId")
                lessonId: getDisplayerInfo(lessonInfoData,1,"lessonId")
                studentName: getDisplayerInfo(lessonInfoData,1,"studentName")
                grade: getDisplayerInfo(lessonInfoData,1,"grade")
                lessonName: getDisplayerInfo(lessonInfoData,1,"subject")
                status: getDisplayerInfo(lessonInfoData,1,"status")
                lessonType: getDisplayerInfo(lessonInfoData,1,"lessonType")
                currentDate: getDisplayerInfo(lessonInfoData,1,"currentDate")
                onLessonIdConfirm: {
                    lessonControl.lessonData = getCurrentLessonInfo(lessonInfoData,1,lessonId);
                    lessonControl.visible = true;
                }
            }
            YMLessonInfoControl{
                z: 7
                width: columnWidth - 2
                height: 45 * getDisplayerInfo(lessonInfoData,2,"lineHeight")
                x: 2 * columnWidth
                visible: getDisplayerInfo(lessonInfoData,2,"dateId")
                lessonId: getDisplayerInfo(lessonInfoData,2,"lessonId")
                studentName: getDisplayerInfo(lessonInfoData,2,"studentName")
                grade: getDisplayerInfo(lessonInfoData,2,"grade")
                lessonName: getDisplayerInfo(lessonInfoData,2,"subject")
                status: getDisplayerInfo(lessonInfoData,2,"status")
                lessonType: getDisplayerInfo(lessonInfoData,2,"lessonType")
                currentDate: getDisplayerInfo(lessonInfoData,2,"currentDate")
                onLessonIdConfirm: {
                    lessonControl.lessonData = getCurrentLessonInfo(lessonInfoData,2,lessonId);
                    lessonControl.visible = true;
                }
            }
            YMLessonInfoControl{
                z: 8
                width: columnWidth - 2
                height: 45 * getDisplayerInfo(lessonInfoData,3,"lineHeight")
                x: 3 * columnWidth
                visible: getDisplayerInfo(lessonInfoData,3,"dateId")
                lessonId: getDisplayerInfo(lessonInfoData,3,"lessonId")
                studentName: getDisplayerInfo(lessonInfoData,3,"studentName")
                grade: getDisplayerInfo(lessonInfoData,3,"grade")
                lessonName: getDisplayerInfo(lessonInfoData,3,"subject")
                status: getDisplayerInfo(lessonInfoData,3,"status")
                lessonType: getDisplayerInfo(lessonInfoData,3,"lessonType")
                currentDate: getDisplayerInfo(lessonInfoData,3,"currentDate")
                onLessonIdConfirm: {
                    lessonControl.lessonData = getCurrentLessonInfo(lessonInfoData,3,lessonId);
                    lessonControl.visible = true;
                }
            }
            YMLessonInfoControl{
                z: 9
                width: columnWidth - 2
                height: 45 * getDisplayerInfo(lessonInfoData,4,"lineHeight")
                x: 4 * columnWidth
                visible: getDisplayerInfo(lessonInfoData,4,"dateId")
                lessonId: getDisplayerInfo(lessonInfoData,4,"lessonId")
                studentName: getDisplayerInfo(lessonInfoData,4,"studentName")
                grade: getDisplayerInfo(lessonInfoData,4,"grade")
                lessonName: getDisplayerInfo(lessonInfoData,4,"subject")
                status: getDisplayerInfo(lessonInfoData,4,"status")
                lessonType: getDisplayerInfo(lessonInfoData,4,"lessonType")
                currentDate: getDisplayerInfo(lessonInfoData,4,"currentDate")
                onLessonIdConfirm: {
                    lessonControl.lessonData = getCurrentLessonInfo(lessonInfoData,4,lessonId);
                    lessonControl.visible = true;
                }
            }
            YMLessonInfoControl{
                z: 10
                width: columnWidth - 2
                height: 45 * getDisplayerInfo(lessonInfoData,5,"lineHeight")
                x: 5 * columnWidth
                visible: getDisplayerInfo(lessonInfoData,5,"dateId")
                lessonId: getDisplayerInfo(lessonInfoData,5,"lessonId")
                studentName: getDisplayerInfo(lessonInfoData,5,"studentName")
                grade: getDisplayerInfo(lessonInfoData,5,"grade")
                lessonName: getDisplayerInfo(lessonInfoData,5,"subject")
                status: getDisplayerInfo(lessonInfoData,5,"status")
                lessonType: getDisplayerInfo(lessonInfoData,5,"lessonType")
                currentDate: getDisplayerInfo(lessonInfoData,5,"currentDate")
                onLessonIdConfirm: {
                    lessonControl.lessonData = getCurrentLessonInfo(lessonInfoData,5,lessonId);
                    lessonControl.visible = true;
                }
            }
            YMLessonInfoControl{
                z: 11
                width: columnWidth - 2
                height: 45 * getDisplayerInfo(lessonInfoData,6,"lineHeight")
                x: 6 * columnWidth
                visible: getDisplayerInfo(lessonInfoData,6,"dateId")
                lessonId: getDisplayerInfo(lessonInfoData,6,"lessonId")
                studentName: getDisplayerInfo(lessonInfoData,6,"studentName")
                grade: getDisplayerInfo(lessonInfoData,6,"grade")
                lessonName: getDisplayerInfo(lessonInfoData,6,"subject")
                status: getDisplayerInfo(lessonInfoData,6,"status")
                lessonType: getDisplayerInfo(lessonInfoData,6,"lessonType")
                currentDate: getDisplayerInfo(lessonInfoData,6,"currentDate")
                onLessonIdConfirm: {
                    lessonControl.lessonData = getCurrentLessonInfo(lessonInfoData,6,lessonId);
                    lessonControl.visible = true;
                }
            }
            YMLessonInfoControl{
                z: 12
                width: columnWidth - 2
                height: 45 * getDisplayerInfo(lessonInfoData,7,"lineHeight")
                x: 7 * columnWidth
                visible: getDisplayerInfo(lessonInfoData,7,"dateId")
                lessonId: getDisplayerInfo(lessonInfoData,7,"lessonId")
                studentName: getDisplayerInfo(lessonInfoData,7,"studentName")
                grade: getDisplayerInfo(lessonInfoData,7,"grade")
                lessonName: getDisplayerInfo(lessonInfoData,7,"subject")
                status: getDisplayerInfo(lessonInfoData,7,"status")
                lessonType: getDisplayerInfo(lessonInfoData,7,"lessonType")
                currentDate: getDisplayerInfo(lessonInfoData,7,"currentDate")
                onLessonIdConfirm: {
                    lessonControl.lessonData = getCurrentLessonInfo(lessonInfoData,7,lessonId);
                    lessonControl.visible = true;
                }
            }

            Rectangle{
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
                color: "#e0e0e0"
            }

            Rectangle{
                width: parent.width
                height: 1
                anchors.top: parent.top
                color: "#e0e0e0"
                visible: index == 0 ? true: false
            }

            Rectangle{
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
                color: "#e0e0e0"
            }
        }
    }

    Component.onCompleted: {
        var timeList = Cfg.timeSchedule;
        for(var i = 0; i < timeList.length;i++){
            lessonModel.append({
                                   time: timeList[i],
                                   check: false,
                                   lessonInfoData: [],
                               })


        }
        var currentDate = getCurrentDate();
        contentDate = currentDate;
        updateDateData(currentDate);
    }


    function refreshPage(){
        var currentDate = getCurrentDate();
        contentDate = currentDate;
        updateDateData(currentDate);
        console.log("=======lessonTable::onRefreshPage========");
    }

    function getWeek(dateString){
        var dateArray = dateString.split("-");
        var date = new Date(dateArray[0], parseInt(dateArray[1] - 1), dateArray[2]);

        var date2 = new Date(contentDate + " 00:00:00");
        if(date2.getTime() - date.getTime() == 0){
           var currentDate = date.getDay();
            currentDateIndex  = currentDate == 0 ? 7 : currentDate
        }

        var weeks = ["日", "一", "二", "三", "四", "五", "六"];
        return "周" + weeks[date.getDay()];
    }

    function updateLesonTime(timeList){
        for(var i = 0; i < timeList.length;i++){
            lessonModel.get(i).time = timeList[i];
        }
    }

    function updateDateData(date){
        lessonMgr.getTeachLessonInfo(date);
    }

    function updateWeek(dateOfWeek){
        console.log("dateOfWeek",dateOfWeek);
        var yearArray = dateOfWeek[0].split("-");
        var yearArray1 = dateOfWeek[1].split("-");
        var yearArray2 = dateOfWeek[2].split("-");
        var yearArray3 = dateOfWeek[3].split("-");
        var yearArray4 = dateOfWeek[4].split("-");
        var yearArray5 = dateOfWeek[5].split("-");
        var yearArray6 = dateOfWeek[6].split("-");
        year = yearArray[0];
        currentDateIndex = -1;
        week1 = getWeek(dateOfWeek[0]) + " " + yearArray[1] + "-" + yearArray[2];
        week2 = getWeek(dateOfWeek[1]) + " " + yearArray1[1] + "-" + yearArray1[2];
        week3 = getWeek(dateOfWeek[2]) + " " + yearArray2[1] + "-" + yearArray2[2];
        week4 = getWeek(dateOfWeek[3]) + " " + yearArray3[1] + "-" + yearArray3[2];
        week5 = getWeek(dateOfWeek[4]) + " " + yearArray4[1] + "-" + yearArray4[2];
        week6 = getWeek(dateOfWeek[5]) + " " + yearArray5[1] + "-" + yearArray5[2];
        week7 = getWeek(dateOfWeek[6]) + " " + yearArray6[1] + "-" + yearArray6[2];
    }

    function updateModelData(temp){
        lessonInfo = temp;
        clearModel();
        for(var i = 0; i < lessonModel.count; i++){
            //1、遍历所有数据判断当前行有几条数据，增加至缓存
            var bufferData = [];
            for(var z = 0; z < lessonInfo.length;z++){
                if(i === lessonInfo[z].scheduleId){
                    bufferData.push(lessonInfo[z]);
                }
            }

            //2、遍历缓存数据当前行的lessonId是否是最后一行
            for(var a = 0; a < bufferData.length;a++){
                var resolveData = bufferData[a];
                for(var b = 0; b < lessonInfo.length;b++){
                    if(resolveData.lessonId === lessonInfo[b].lessonId
                            && lessonInfo[b].scheduleId > i){
                        bufferData.splice(a,1);
                        a = 0;
                        break;
                    }
                }
            }
            //console.log("====updateModelData===",i,JSON.stringify(bufferData))
            var lessonInfoData = [];
            for(var c = 0; c < bufferData.length; c++){
                //3、遍历缓存数据存在的lessonId一共有多少条数据
                var lessonId = bufferData[c].lessonId;
                var cospanSum = 0;
                for(var d = 0; d < lessonInfo.length; d++){
                    if(lessonId === lessonInfo[d].lessonId){
                        cospanSum++;
                    }
                }
                lessonInfoData.push({
                                        dateId: bufferData[c].dateId + 1,
                                        enableClass: false,
                                        lessonId: lessonId,
                                        lineHeight: cospanSum,
                                        name: bufferData[c].name,
                                        grade: bufferData[c].grade,
                                        subject: bufferData[c].subject,
                                        lessonStatus: bufferData[c].lessonStatus,
                                        contractNo: bufferData[c].contractNo,
                                        parentContactInfo: bufferData[c].parentContactInfo,
                                        clientNo: bufferData[c].clientNo,
                                        relateType: bufferData[c].relateType,
                                        hasCourseware: bufferData[c].hasCourseware,
                                        chargeMobile: bufferData[c].chargeMobile,
                                        parentRealName: bufferData[c].parentRealName,
                                        startTime: bufferData[c].startTime,
                                        endTime: bufferData[c].endTime,
                                        chargeName: bufferData[c].chargeName,
                                        hasRecord: bufferData[c].hasRecord,
                                        lessonType: bufferData[c].lessonType,
                                        status: bufferData[c].lessonStatus,
                                    })

                //4、是则添加，否则下次循环增加到model里面
                var addMark = true;
                for(var e = 0; e < lessonModel.count; e++){
                    if(lessonModel.get(e).currentLessonId === lessonId){
                        addMark = false;
                        break;
                    }
                }
                if(addMark){
                    lessonModel.get(i).lessonInfoData = lessonInfoData;
                }
            }
        }
    }

    function clearModel(){
        for(var i = 0; i < lessonModel.count; i++){
            lessonModel.get(i).lessonInfoData = [];
        }
    }

    function getDisplayerInfo(temp,dateId,columnName){
        var tempValue;
        if(columnName === "dateId"){
            tempValue = false;
        }
        if(columnName === "lineHeight"){
            tempValue = 0;
        }
        if(columnName === "lessonId"){
            tempValue = 0;
        }else{
            tempValue = "";
        }

        for(var i = 0; i < temp.count; i++){
            if(temp.get(i).dateId === dateId && columnName === "dateId"){
               return tempValue =  true;
            }
            if(temp.get(i).dateId === dateId && columnName === "lineHeight"){
               return tempValue = temp.get(i).lineHeight;
            }
            if(temp.get(i).dateId === dateId && columnName === "lessonId"){
               return tempValue = temp.get(i).lessonId;
            }
            if(temp.get(i).dateId === dateId && columnName === "studentName"){
               return tempValue = temp.get(i).name;
            }
            if(temp.get(i).dateId === dateId && columnName === "status"){
               return tempValue = temp.get(i).status;
            }
            if(temp.get(i).dateId === dateId && columnName === "grade"){
               return tempValue = temp.get(i).grade;
            }
            if(temp.get(i).dateId === dateId && columnName === "subject"){
               return tempValue = temp.get(i).subject;
            }
            if(temp.get(i).dateId === dateId && columnName === "lessonType"){
               return tempValue = temp.get(i).lessonType;
            }
            if(temp.get(i).dateId === dateId && columnName === "currentDate"){
               return tempValue = temp.get(i).startTime;
            }
        }
        return tempValue;
    }

    function getCurrentLessonInfo(temp,dateId,lessonId){
        for(var i = 0; i < temp.count; i++){
            if(temp.get(i).dateId == dateId && temp.get(i).lessonId == lessonId){
                //console.log("getCurrentLessonInfo::",JSON.stringify(temp.get(i)))
                return temp.get(i);
            }
        }
    }

    function getCurrentDate(){
        var date = new Date();
        var year = date.getFullYear();
        var month = addZero(date.getMonth() + 1);
        var day = addZero(date.getDate());
        return year + "-" + month + "-" + day;
    }

    function addZero(tmp){
        var fomartData;
        if(tmp < 10){
            fomartData = "0" + tmp;
        }else{
            fomartData = tmp;
        }
        return fomartData;
    }
}

