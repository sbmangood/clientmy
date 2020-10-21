import QtQuick 2.0

Rectangle {
    id: studenView
    width: parent.width
    height: parent.height
    border.color: "blue"
    border.width: 1
    anchors.bottom: parent.bottom
//color:"red"
    property var contentData: [];

    property string lessonId: ""
    property string teacherName: "";
    property string hasCourseware: "";
    property string lessonName: "";
    property string status: "";
    property string lessonType: "O";
    property string relateType: "O";
    property int lessonStatus: 0; //0，未完成；1，已完成；2，请假(不扣课时)；3，$请假((扣课时))；4，旷课
    property string subject: ""
    //property int dateId: 0
    property var startTime: 0;
    property var endTime:0;
    property int hasRecord:0;
    property int scheduleId:0;

    onContentDataChanged: {

    }

    signal lessonIdConfirm(var lessonId);

    color: {
        if(analysisDate(startTime)){
            return "#FF5B00"
        }
        if(lessonType == 'O'){
            return "#DFF5FF";
        }else if(lessonType == 'A'){
            return  "#FFCA35";

        }else if(lessonType == 'L'){
            return  "#00FFCF";

        }else if(lessonType == 'V'){
            return "#539822";
        }else{
            return "white";
        }

        //#CCF5FF 今天
        //#FF5B00 当前
        //#00FF9B 订单课
        //#FFCA35 试听课
        //#00FFCF 直播课
        //#539822 请假
        //#D0D1C7 非工作时间
    }

    MouseArea{
        anchors.fill: parent
        onClicked: {
            if(lessonType == 'L'){
                //我的直播课
                var url = URL_MyLive
                console.log(url);
                Qt.openUrlExternally(url)

                return;
            }else{
                lessonIdConfirm(lessonId);
            }
        }
    }

    Column{
        width: parent.width
        height: parent.height

        Text{
            width: parent.width
            height: 20
            text:{
                if(lessonType == 'L'){
                    timeText.height = 0;
                    return  "直播课";

                }else if(lessonType == 'V'){
                    timeText.height = 0;
                    return "请假";
                }
                teacherName +" "+ subject
                 timeText.height = 20;
            }

            verticalAlignment: Text.AlignVCenter
        }

        Text{
            id: timeText
            text: "00:00-23:59"
            width: parent.width
            height: 20
            verticalAlignment: Text.AlignVCenter
        }
    }

    Rectangle{        
        id: statusItem
        width: 35
        height: 20
        color: "green"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        anchors.right: parent.right
        anchors.rightMargin: 2
        Text{
            text: {
                if(lessonStatus == 1){
                    statusItem.visible = true;
                    return "已完成";
                }else{
                    statusItem.visible = false;
                    return "";
                }
            }
            color: "white"
            anchors.centerIn: parent
        }
    }

    function analysisDate(startTime){
        var currentStartDate = new Date(startTime);
        var year = currentStartDate.getFullYear();
        var month = currentStartDate.getMonth();
        var day = currentStartDate.getDate();

        var contentDate = new Date();
        var contentYear = contentDate.getFullYear();
        var contentMonth = contentDate.getMonth();
        var contentDay = contentDate.getDate();
        if(year == contentYear && month == contentMonth && day ==contentDay){
            return true
        }else{
            return false;
        }
    }
}

