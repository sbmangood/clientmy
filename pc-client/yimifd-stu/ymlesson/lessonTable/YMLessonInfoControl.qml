import QtQuick 2.0

Rectangle {
    width: parent.width
    height: parent.height
    border.color: "blue"
    border.width: 1   
    anchors.bottom: parent.bottom

    property string lessonId: ""
    property string studentName: "";
    property string grade: "";
    property string lessonName: "";
    property string status: "";
    property string lessonType: "O";
    property string relateType: "O";
    property var currentDate: 0;

    signal lessonIdConfirm(var lessonId);

    color: {
        if(analysisDate(currentDate)){
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
            lessonIdConfirm(lessonId);
        }
    }

    Item{
        id: oneItem
        width: parent.width
        height: 20
        anchors.top: parent.top
        anchors.topMargin: (parent.height - 40) * 0.5

        Text{
            text:studentName + " " + grade
            anchors.centerIn: parent
        }
    }

    Item{
        width: parent.width
        height: 20
        anchors.top: oneItem.bottom
        Text{
            text:{
                var type = ""
                if(lessonType == 'O'){
                  return lessonName + "(订)";
                }else if(lessonType == 'A'){
                  return  lessonName + "(试)";

                }else if(lessonType == 'L'){
                    return  "直播课";

                }else if(lessonType == 'V'){
                    return "请假";
                }

                lessonName + lessonType
            }
            anchors.centerIn: parent
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
                if(status == 1){
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

