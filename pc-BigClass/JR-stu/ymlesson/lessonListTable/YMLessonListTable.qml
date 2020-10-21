import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import YMLessonManagerAdapter 1.0
import "../../Configuration.js" as Cfg

/*******课程列表******/

Item {
    anchors.fill: parent

    property int mark: 0;// 0起始日期 1结束日期
    property int pageIndex: 1;
    property int pageSize: 10;
    property int totalPage: 1;
    property string keywords: "";
    property string startDate: "";
    property string endDate: "";
    property string queryStatus: "";
    property string queryPeriod: "TODAY";

    YMLessonManagerAdapter{
        id: lessonMgr
        onTeacherLesonListInfoChanged:{
            analysisData(lessonInfo);
        }
    }

    Rectangle{
        id: seacheItem
        width: parent.width - 40
        height: 40
        border.color: "#e0e0e0"
        border.width: 2
        radius: 4
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter

        Image{
            id: searchImage
            width: 20
            height: 20
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/images/th_icon_search.png"
        }

        TextField{
            id: filterText
            width: parent.width - 40
            height: parent.height
            anchors.left: searchImage.right
            anchors.leftMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            placeholderText: "学生姓名、客户编号、课程编号"
            style: TextFieldStyle{
                background: Item{
                    anchors.fill: parent
                }
            }
            onAccepted: {
                pageIndex = 1;
                keywords = filterText.text;
                if(keywords == ""){
                    var currentDate = getCurrentDate();
                    startTimeText.text = currentDate
                    startDate = currentDate.replace("年","-").replace("月","-").replace("日","");;
                }
                queryData();
            }
        }
    }

    YMCalendarControl{
        id: calendarControl
        z: 66
        visible: false
        onDateTimeconfirm: {
            var sdate;
            var edate;
            if(mark == 0){
                startDate = dateTime.replace("年","-").replace("月","-").replace("日","");
                startTimeText.text = dateTime;
                sdate = new Date(startDate);
                if(endDate == ""){
                    calendarControl.visible = false;
                    queryData();
                    return;
                }
                edate = new Date(endDate);
                if(edate.getTime() - sdate.getTime() > 0){
                    calendarControl.visible = false;
                    queryData();
                }
            }else{
                endDate = dateTime.replace("年","-").replace("月","-").replace("日","");
                endTimeText.text = dateTime;
                edate = new Date(endDate);
                if(startDate == ""){
                    calendarControl.visible = false;
                    queryData();
                    return;
                }
                sdate = new Date(startDate);
                if(edate.getTime() - sdate.getTime() > 0){
                    calendarControl.visible = false;
                    queryData();
                }
            }

        }
    }

    Rectangle{
        id: filterItem
        width: parent.width - 40
        height: 40
        anchors.top: seacheItem.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10

        ComboBox {
            id: comboBox
            height: 35
            width: 200
            anchors.left: parent.left
            anchors.leftMargin: 10
            model: ["全部课程","已完成课程","预排课程"]
            style: ComboBoxStyle{
                background: Rectangle{
                    anchors.fill: parent
                    border.color: "#e0e0e0"
                    border.width: 1
                }
            }
            onCurrentIndexChanged: {
                if(currentIndex == 1){
                    queryStatus = "0"
                }
                if(currentIndex == 2){
                    queryStatus = "1"
                }
                else{
                    queryStatus = ""
                }
                queryData();
                console.log("====",currentIndex)
            }
        }

        Row{
            width: filterItem.width  - 220
            height: 35
            anchors.left: comboBox.right
            anchors.leftMargin: 20
            spacing: 10

            Text{
                height: parent.height
                text:"请选择时间:"
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle{
                id: startItem
                width: 100
                height: parent.height
                border.color: "#e0e0e0"
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter

                TextField{
                    id: startTimeText
                    placeholderText:  "年/月/日"
                    anchors.centerIn: parent
                    style: TextFieldStyle{
                        background: Rectangle{
                            color: "transparent"
                        }
                    }
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        mark = 0;
                        var location = contentItem.mapFromItem(startItem,0,0);
                        calendarControl.x = location.x - 440;
                        calendarControl.y = location.y;
                        calendarControl.visible = true;
                    }
                }
            }

            Text{
                height: parent.height
                text: "至"
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle{
                id: endTimeItem
                width: 100
                height: parent.height
                border.color: "#e0e0e0"
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter

                TextField{
                    id: endTimeText
                    placeholderText: "年/月/日"
                    anchors.centerIn: parent
                    style: TextFieldStyle{
                        background: Rectangle{
                            color: "transparent"
                        }
                    }
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        mark = 1;
                        var location = contentItem.mapFromItem(endTimeItem,0,0);
                        calendarControl.x = location.x - 440;
                        calendarControl.y = location.y;
                        calendarControl.visible = true;
                    }
                }
            }

            Rectangle{
                width: 60
                height: parent.height
                border.color: "#e0e0e0"
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter

                Text{
                    text: "清空时间"
                    anchors.centerIn: parent
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        startDate = "";
                        endDate = "";
                        startTimeText.text = "";
                        endTimeText.text = "";
                        queryData();
                    }
                }
            }
        }
    }

    Rectangle{
        width: parent.width - 40
        height: 1
        color: "#e0e0e0"
        anchors.top: filterItem.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Rectangle{
        id: listItem
        width: parent.width - 40
        height: parent.height - 160
        anchors.top: filterItem.bottom
        anchors.topMargin: 3
        color: "#f3f3f3"
        anchors.horizontalCenter: parent.horizontalCenter
    }

    ListView{
        id: teachListView
        clip: true
        anchors.fill: listItem
        anchors.top: listItem.top
        anchors.topMargin: 12
        model: teachModel
        delegate: teachDelegate

        onContentYChanged: {
            if(contentY > 270){
                pagtingControl.visible = true
            }else{
                pagtingControl.visible = false
            }
        }
    }

    Image{
        id: backgImage
        width: listItem.width
        height: listItem.height - 20
        anchors.top: listItem.top
        anchors.topMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        visible: false
        fillMode: Image.PreserveAspectFit
        source: "qrc:/images/pic_empty2x.png"
    }

    ListModel{
        id: teachModel
    }

    YMPagingControl{
        id: pagtingControl
        visible: false
        anchors.bottom: parent.bottom
        onPageChanged: {
            pageIndex = page;
            queryData()
        }
        onPervPage: {
            pageIndex -= 1;
            currentPage = pageIndex;
            queryData()
        }

        onNextPage: {
            pageIndex += 1;
            currentPage = pageIndex;
            queryData()
        }
    }

    Component{
        id: teachDelegate
        Rectangle{
            width: teachListView.width
            height: 100
            color: "#f3f3f3"

            Rectangle{
                id: contentItem
                width: parent.width - 20
                height: parent.height - 10
                border.color: "#e0e0e0"
                border.width: 1
                radius: 4
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Item{
                id: timeItem
                width: parent.width * 0.2
                height: contentItem.height
                anchors.left: contentItem.left
                anchors.verticalCenter: contentItem.verticalCenter
                Text{
                    id: spatimeText                    
                    width: parent.width
                    text: "距离上课时间"
                    anchors.top: parent.top
                    anchors.topMargin: 25
                    horizontalAlignment: Text.AlignHCenter
                }

                Text{
                    id: timeText
                    width: parent.width
                    anchors.top: spatimeText.bottom
                    anchors.topMargin: 10
                    text: {
                        var textData = lessonSecondSum(remaining,startTime,endTime,index)
                        var textArray = textData.split(",")
                        if(textArray[1] == "true"){
                            if(!timeClock.running){
                                timeClock.running = true;
                            }
                        }

                        return textArray[0];
                    }
                    horizontalAlignment: Text.AlignHCenter
                }

                Timer{
                    id: timeClock
                    interval: 1000
                    running: false
                    repeat: true
                    onTriggered: {
                        updateDateTime(index,remaining - 1);
                    }
                }
            }

            Rectangle{
                width: 2
                height: contentItem.height - 20
                color: "#e0e0e0"
                anchors.left: timeItem.right
                anchors.verticalCenter: contentItem.verticalCenter
            }

            Item{
                width: parent.width - timeItem.width - 2
                height: contentItem.height
                anchors.verticalCenter: contentItem.verticalCenter
                anchors.left: timeItem.right
                anchors.leftMargin: 40
                Row{
                    id: oneRow
                    width: parent.width
                    height: parent.height * 0.5
                    spacing: (parent.width - 500) / 5
                    Text{
                        width: 180
                        height: parent.height
                        text: "课程编号:" + lessonId
                        verticalAlignment: Text.AlignVCenter
                    }
                    Text{
                        width: 180
                        height: parent.height
                        text: {
                            var endTimeArray = endTime.split(" ");
                            return "课程时间:" + startTime + "-" + endTimeArray[1]
                        }
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text{
                        width: 80
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                    }


                    MouseArea{
                        width: 120
                        height: 30
                        enabled: hasRecord == 1 ? true : (enableClass ? true : false)
                        anchors.verticalCenter: parent.verticalCenter
                        Rectangle{
                            radius: 2
                            color: hasRecord == 1 ? Cfg.TB_CLR : (enableClass ? Cfg.TB_CLR : "gray")
                            anchors.fill: parent
                            border.color: hasRecord == 1 ? Cfg.TB_CLR : (enableClass ? Cfg.TB_CLR : "gray")
                            border.width: 1
                        }

                        Text{
                            text: hasRecord == 0  ? "进入教室" : "查看录播"
                            anchors.centerIn: parent
                        }
                    }
                }

                Row{
                    width: parent.width
                    height: parent.height * 0.5
                    anchors.top: oneRow.bottom
                    spacing: (parent.width - 500) / 5
                    Text{
                        width: 80
                        height: parent.height
                        text: "科目:" + subjectName
                        verticalAlignment: Text.AlignVCenter
                    }
                    Text{
                        width: 80
                        height: parent.height
                        text: "年级:" + gradeName
                        verticalAlignment: Text.AlignVCenter
                    }
                    Text{
                        width: 440 - 160
                        height: parent.height
                        text: "学生:" + studentName
                        verticalAlignment: Text.AlignVCenter
                    }

                    MouseArea{
                        width: 120
                        height: 30
                        enabled: hasDoc == 1 ? true : false
                        anchors.verticalCenter: parent.verticalCenter
                        Rectangle{
                            radius: 2
                            color: hasDoc == 1 ? Cfg.TB_CLR : "gray"
                            anchors.fill: parent
                            border.color: hasDoc == 1 ? Cfg.TB_CLR : "gray"
                            border.width: 1
                        }

                        Text{
                            text: "查看课件"
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        queryData();
    }

    function refreshPage(){
        queryData();
    }

    function analysisData(objectData){
        var items = objectData.items;
        teachModel.clear();
        console.log("analysisData:",items.length);
        for(var i = 0; i < items.length; i++){
            teachModel.append({
                                  "enableClass": false,
                                  "afterSecond":items[i].afterSecond,
                                  "beforeSecond":items[i].beforeSecond,
                                  "endTime":items[i].endTime,
                                  "gradeName":items[i].gradeName,
                                  "hasDoc":items[i].hasDoc,
                                  "hasRecord":items[i].hasRecord,
                                  "keywords":items[i].keywords,
                                  "lessonId":items[i].lessonId,
                                  "lessonSecondCount":items[i].lessonSecondCount,
                                  "lessonStatus":items[i].lessonStatus,
                                  "lessonType":items[i].lessonType,
                                  "remaining":items[i].remaining,
                                  "startTime":items[i].startTime,
                                  "studentAppraiseType":items[i].studentAppraiseType,
                                  "studentAppraises":items[i].studentAppraises,
                                  "studentName":items[i].studentName,
                                  "subjectName":items[i].subjectName,
                                  "title":items[i].title,
                              })
        }
        totalPage = Math.ceil(objectData.total / pageSize);
        pagtingControl.totalPage = totalPage;
        backgImage.visible = teachModel.count == 0 ? true : false;
    }

    function lessonSecondSum(dateTime,startTime,endTime,index){
        var date = dateTime / 60 / 60 / 24;
        var startDateTime = new Date(startTime);
        var endDateTime = new Date(endTime);
        var hours = dateTime / 60 / 60;
        var minutes = dateTime / 60;

        var dataSpan = endDateTime.getHours() - startDateTime.getHours();//1小时内
        console.log("dataSpan",dataSpan);

        var disable = disableClassButton(minutes,dataSpan,index,date);
        if(disable){
            teachModel.get(index).enableClass = true;
        }else{
            teachModel.get(index).enableClass = false;
        }

        if(date < 0){
            return "后结束课程,false"
        }

        if(date < 1){
            return (Math.floor(minutes / 60) + "时" + Math.floor(minutes % 60) + "分"  + Math.floor(dateTime % 60) + "秒") + ",true";
        }

        if(date > 1){
            return Math.ceil(date) + "天,false,true"
        }
        return date;
    }

    function disableClassButton(startTime,endTime,index,date){
        if(startTime <= 30 && endTime >= 1 && teachModel.get(index).lessonStatus == 0 && date < 1){
            return true;
        }else if(date > 1){
            return false;
        }
        return false;
    }

    function queryData(){
        var seachPram = {
            "keywords": keywords,
            "pageIndex": pageIndex == 0 ? 1 : pageIndex.toString(),
            "pageSize": pageSize,
            "queryStartDate": startDate,
            "queryEndDate": endDate,
            "queryPeriod": queryPeriod,
            "queryStatus": queryStatus,
        }
        console.log("seachParm::",JSON.stringify(seachPram));
        lessonMgr.getTeachLessonListInfo(seachPram);
    }

    function getCurrentDate(){
        var date = new Date();
        var year = date.getFullYear();
        var month = Cfg.addZero(date.getMonth() + 1);
        var day = Cfg.addZero(date.getDate());
        return year + "年" + month + "月" + day + "日";
    }

    function updateDateTime(index,times){
        teachModel.get(index).remaining = times;
    }
}

