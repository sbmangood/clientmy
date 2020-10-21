import QtQuick 2.0
import QtQuick.Controls 2.0
import "Configuration.js" as Cfg
/*    请假页面
  包含:
      请假须知页面
      课程是否在24小时之内提示
      请假原因提示
      请假成功提示
*/
MouseArea {
    id:askForLeaveViewItem
    property bool isWithinTwentyFourHoursLesson: true;//用于判断是否是24小时之内的课  true为24 小时之内的课
    signal askForLeaveSuccess();
    property bool isAskForLeaveTimesOutOff: true;//24时之外的请假次数标识 是否超过请假次数 ture 为超过

    property int withinTwentyFourAFKTimes: 0;//24时之内课程免费请假次数标示

    property string lessonId:"" ;

    Rectangle//主背景 黑色透明
    {
        anchors.fill: parent
        color: "black"
        opacity: 0.4
        radius: 12 * widthRate
    }

    //请假须知
    Rectangle
    {
        id:askForLeaveView
        width: 260 * widthRate
        height: 290 * widthRate
        border.color: "gray"
        border.width: 1
        radius: 16 * heightRate
        anchors.centerIn: parent
        color: "white"
        visible: false
        z:100000
        Rectangle{
            id:topPhoto
            width: parent.width-2
            height: parent.height / 3 - 20
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 16 * heightRate
            Image {
                anchors.fill: parent
                source: "qrc:/images/dialog_askforleave.png"
            }
        }

        Rectangle
        {
            width: 250 * widthRate
            clip: false
            height: 120 * widthRate
            anchors.top: topPhoto.bottom
            anchors.topMargin: 25 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter

            Column
            {
                width: parent.width * 0.8
                anchors.centerIn: parent
                spacing: 5 * heightRate
                Text
                {
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    horizontalAlignment: Text.horizontalAlignment
                    text: "• 学员如需请假，请提前24小时"
                    color: "#3c3c3e"
                }
                Text
                {
                    width: parent.width
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    text: "提交请假申请。"
                    color: "#3c3c3e"
                }
                Text
                {
                    width: parent.width
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    text: "• 学员在距离上课不足24小时提"
                    color: "#3c3c3e"
                }
                Text
                {
                    width: parent.width
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    text: "交请假，如剩余免费次数大于零"
                    color: "#3c3c3e"
                }
                Text
                {
                    width: parent.width
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    text: "则请假不扣课时数，如免费次数"
                    color: "#3c3c3e"
                }
                Text
                {
                    width: parent.width
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    text: "用完则扣除本次请假课程的课时数。"
                    color: "#3c3c3e"
                }
                Text
                {
                    width: parent.width
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    text: "• 请假后，如需销假，请及时联系班主任或任课老师。"
                    wrapMode: Text.WordWrap
                    color: "#3c3c3e"
                }
            }
        }
        Rectangle{
            width: 200 * widthRate
            height: 34 * widthRate
            radius: 3 * widthRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#ff5000"
            MouseArea
            {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked:
                {
                    askForLeaveView.visible = false
                    //修改请假须知是否被显示状态 为已经被显示
                    isAskForLeaveViewHasBeShowed=true;
                    var nowUserSettingData=accountMgr.getUserLoginInfo();
                    accountMgr.saveUserInfo(nowUserSettingData[0],nowUserSettingData[1],nowUserSettingData[2],nowUserSettingData[3],nowUserSettingData[4],nowUserSettingData[5],1);

                    if(isWithinTwentyFourHoursLesson)
                    {
                        //24小时之内的课 判断是否超过请假次数
                        console.log("24 之内")
                        //   lessonStatusTipsView.visible=true;

                        if(withinTwentyFourAFKTimes <= 0)
                        {//超过请假次数
                            //弹出超过请假次数 请假扣除课时提示
                            askForLeaveTimesView.visible=true;
                        }else
                        {
                            askForLeavingTipsView.visible=true;
                        }
                    }else
                    {//24小时之外的课  判断是否超过请假次数
                        console.log("24之外")
                        // askForLeavingTipsView.visible=true;

                        if(isAskForLeaveTimesOutOff)
                        {//超过请假次数
                            //弹出超过请假次数 请假扣除课时提示
                            askForLeaveTimesView.visible=true;
                        }else
                        {
                            askForLeavingTipsView.visible=true;
                        }
                    }

                }
            }
            Text {
                color:"#ffffff"
                font.family: Cfg.LEAVE_FAMILY
                font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                anchors.centerIn: parent
                text: qsTr("知道了")
            }
        }
    }

    //请假次数提示
    Rectangle
    {
        id:askForLeaveTimesView
        width: 240 * widthRate
        height: 155 * widthRate
        border.color: "gray"
        border.width: 1
        radius: 16 * heightRate
        anchors.centerIn: parent
        color: "white"
        visible: false
        z:8;
        Rectangle
        {
            width: 230 * widthRate
            clip: true
            height: 120 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 15 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            // color:"lightblue"
            Column
            {
                anchors.centerIn: parent
                spacing: 6 * heightRate
                Text
                {
                    // width: parent.width
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    horizontalAlignment: Text.horizontalAlignment
                    text: "您的免费请假次数已用" //
                    color: "#3c3c3e"
                }
                Text
                {
                    width: parent.width
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    text: "完，如请假将扣除本次" //
                    color: "#3c3c3e"
                }
                Text
                {
                    width: parent.width
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    text: "课程课时数，是否还要" //
                    color: "#3c3c3e"
                }
                Text
                {
                    width: parent.width
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    text: "继续请假？"            //
                    color: "#3c3c3e"
                }
            }
        }

        Row
        {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20 * heightRate
            Rectangle
            {
                width: 95 * widthRate
                height: width / 3
                radius: 3 * widthRate
                color: "#ffffff"
                border.width: 1
                border.color: "#96999c"
                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        askForLeaveViewItem.visible = false;
                    }
                }
                Text {
                    color:"#96999c"
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    anchors.centerIn: parent
                    text: qsTr("取消")
                }
            }
            Rectangle
            {
                width: 95 * widthRate
                height: width / 3
                radius: 3 * widthRate
                color: "#ff5000"
                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        askForLeaveTimesView.visible = false;
                        askForLeaveReasonView.visible=true;
                    }
                }
                Text {
                    color:"#ffffff"
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    anchors.centerIn: parent
                    text: qsTr("确定")
                }
            }

        }
    }

    //据开课时间不足24小时提示
    Rectangle
    {
        id:lessonStatusTipsView
        width: 240 * widthRate
        height: 155 * widthRate
        border.color: "gray"
        border.width: 1
        radius: 16 * heightRate
        anchors.centerIn: parent
        color: "white"
        visible: false
        z:8;
        Rectangle{
            width: 230 * widthRate
            clip: true
            height: 120 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 15 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            TextArea{
                font.family: Cfg.LEAVE_FAMILY
                font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                width: parent.width
                color: "#3c3c3e"
                readOnly: true
                wrapMode: TextEdit.Wrap
                anchors.verticalCenter: parent.verticalCenter
                text: "距离上课时间不足24小时，如继续请假，系统将自动扣除本次课时数"
            }
            /*
            // color:"lightblue"
            Column
            {
                anchors.centerIn: parent
                spacing: 6 * heightRate
                Text
                {
                    // width: parent.width
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    horizontalAlignment: Text.horizontalAlignment
                    text: "距离上课时间不足24小时，" //您的请假次数已经超过
                    color: "#3c3c3e"
                }
                Text
                {
                    width: parent.width
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    text: "如继续请假，系统将自动" //次数，如继续请假系统
                    color: "#3c3c3e"
                }
                Text
                {
                    width: parent.width
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    text: "扣除本次课时数" //将扣除您此次上课课时
                    color: "#3c3c3e"
                }
                Text
                {
                    width: parent.width
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    text: ""            //,确定继续请假吗？
                    color: "#3c3c3e"
                }
            }*/
        }

        Row
        {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20 * heightRate
            Rectangle
            {
                width: 95 * widthRate
                height: width / 3
                radius: 3 * widthRate
                color: "#ffffff"
                border.width: 1
                border.color: "#96999c"
                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        askForLeaveViewItem.visible = false;
                    }
                }
                Text {
                    color:"#96999c"
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    anchors.centerIn: parent
                    text: qsTr("取消")
                }
            }
            Rectangle
            {
                width: 95 * widthRate
                height: width / 3
                radius: 3 * widthRate
                color: "#ff5000"
                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        lessonStatusTipsView.visible = false;
                        askForLeaveReasonView.visible=true;
                    }
                }
                Text {
                    color:"#ffffff"
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    anchors.centerIn: parent
                    text: qsTr("确定")
                }
            }

        }
    }

    //正在请假提示
    Rectangle
    {
        id:askForLeavingTipsView
        width: 240 * widthRate
        height: 155 * widthRate
        border.color: "gray"
        border.width: 1
        radius: 16 * heightRate
        anchors.centerIn: parent
        color: "white"
        visible: false
        z:8;
        Rectangle
        {
            width: 220 * widthRate
            clip: true
            height: 90 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 15 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            TextArea{
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                font.family: Cfg.LEAVE_FAMILY
                font.pixelSize: (Cfg.LEAVE_FONTSIZE + 2) * heightRate
                wrapMode: TextEdit.Wrap
                readOnly: true
                text:{
                    if(isWithinTwentyFourHoursLesson){
                        return  "您的免费请假次数还剩下" + withinTwentyFourAFKTimes + "次，是否继续请假？"
                    }else{
                        return  "您正在执行请假操作，请假成功之后将无法撤销请假，确定还要请假吗？"
                    }
                }
            }
        }

        Row{
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20 * heightRate
            Rectangle {
                width: 95 * widthRate
                height: width / 3
                radius: 3 * widthRate
                color: "#ffffff"
                border.width: 1
                border.color: "#96999c"
                MouseArea{
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:{
                        askForLeaveViewItem.visible = false;
                    }
                }
                Text {
                    color:"#96999c"
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    anchors.centerIn: parent
                    text: qsTr("取消")
                }
            }
            Rectangle {
                width: 95 * widthRate
                height: width / 3
                radius: 3 * widthRate
                color: "#ff5000"
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        askForLeavingTipsView.visible = false;
                        askForLeaveReasonView.visible=true;
                    }
                }
                Text {
                    color:"#ffffff"
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    anchors.centerIn: parent
                    text: qsTr("确定")
                }
            }
        }
    }

    //请假原因
    Rectangle{
        id:askForLeaveReasonView
        width: 260 * widthRate
        height: 268 * widthRate
        border.color: "gray"
        border.width: 1
        radius: 16 * heightRate
        anchors.centerIn: parent
        color: "white"
        visible: false
        Rectangle{
            anchors.top: parent.top
            anchors.topMargin: 50 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                font.family: Cfg.LEAVE_FAMILY
                font.pixelSize: Cfg.LEAVE_HEAD_FONTSIZE * heightRate
                anchors.centerIn: parent
                text: "请假原因"
                color: "#222222"
            }
        }
        Rectangle{
            id: reasonTextrectangle
            width: 230 * widthRate
            height: 120 * widthRate
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true
            border.color: reasonTextEdit.text.length < 50 ? "#c3c6c9" : "#ff3e00"
            border.width: 1
            anchors.top: parent.top
            anchors.topMargin: 100 * heightRate

            TextArea  {
                id: reasonTextEdit
                font.family: Cfg.LEAVE_FAMILY
                font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                height: parent.height - 10 * widthRate
                width: parent.width - 10 * widthRate
                anchors.centerIn: parent
                placeholderText:  qsTr("请输入请假原因")
                selectByMouse: true
                color: reasonTextEdit.text.length < 50 ? "#222222" : "#666666" // #222222
                wrapMode: TextEdit.Wrap
                selectedTextColor: "white"
                selectionColor: "#3a80cd"

                onTextChanged: {
                    if(reasonTextEdit.text.length > 50)
                    {
                        reasonTextEdit.text = reasonTextEdit.getText(0,49);
                    }
                }
            }
        }

        Rectangle   {
            anchors.top: parent.top
            anchors.topMargin: 295 * heightRate
            anchors.right: parent.right
            anchors.rightMargin: 42 * heightRate
            height: 20 * heightRate
            width: 20 * heightRate
            Row {
                anchors.centerIn: parent
                Text{
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: (Cfg.LEAVE_FONTSIZE + 2)* heightRate
                    text: reasonTextEdit.text.length
                    color: "#ff5000"

                }
                Text {
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: (Cfg.LEAVE_FONTSIZE + 2)* heightRate
                    text: "/50"
                    color: "#666666"
                }
            }
        }

        Row {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20 * heightRate
            Rectangle{
                width: 110 * widthRate
                height: width / 3
                radius: 3 * widthRate
                color: "#ffffff"
                border.width: 1
                border.color: "#979797"
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        askForLeaveViewItem.visible = false
                    }
                }
                Text {
                    color:"#333333"
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    anchors.centerIn: parent
                    text: qsTr("取消")
                }
            }
            Rectangle
            {
                width: 110 * widthRate
                height: width / 3
                radius: 3 * widthRate
                color: reasonTextEdit.text.length > 0 ? "#ff5000" : "gray"
                enabled: reasonTextEdit.text.length > 0 ;
                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        console.log(reasonTextEdit.text,lessonId);
                        if(accountMgr.insertLeave(lessonId,reasonTextEdit.text.toString()) == 1) {
                            askForLeaveReasonView.visible = false
                            askForLeaveSuccessView.visible = true;
                        }
                        else {
                            askForLeaveViewItem.visible = false;
                        }
                    }
                }
                Text {
                    color:"#ffffff"
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    anchors.centerIn: parent
                    text: qsTr("确定")
                }
            }
        }
    }

    //请假成功
    Rectangle {
        id:askForLeaveSuccessView
        width: 240 * widthRate
        height: 155 * widthRate
        border.color: "gray"
        border.width: 1
        radius: 16 * heightRate
        anchors.centerIn: parent
        color: "white"
        visible: false
        Rectangle {
            width: 210 * widthRate
            clip: true
            height: 120 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 15 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            TextArea{
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                readOnly: true
                wrapMode: TextEdit.Wrap
                font.family: Cfg.LEAVE_FAMILY
                font.pixelSize: (Cfg.LEAVE_FONTSIZE +2) * heightRate
                text:{
                    if(isWithinTwentyFourHoursLesson){
                        if(withinTwentyFourAFKTimes <= 0 ){
                            return "您已经请假成功，系统已扣除本次课时数"
                        }else{
                            return "您已经请假成功，请联系班主任安排补课时间！"
                        }
                    }else{
                        if(isAskForLeaveTimesOutOff){
                            return "您已经请假成功，系统已扣除本次课时数"
                        }else{
                            return "您已经请假成功，请联系班主任安排补课时间！"
                        }
                    }
                }
            }
        }

        Row {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20 * heightRate
            Rectangle{
                width: 200 * widthRate
                height: width / 7
                radius: 3 * widthRate
                color: "#ff5000"
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        askForLeaveViewItem.visible = false
                        //刷新页面
                        askForLeaveSuccess();
                    }
                }
                Text {
                    color:"#ffffff"
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: Cfg.LEAVE_FONTSIZE * heightRate
                    anchors.centerIn: parent
                    text: qsTr("确定")
                }
            }
        }
    }



    function submitAskForLeaveReason(reasonString)
    {

    }


    function showAskForLeaveView()
    {
        var number =   accountMgr.getLeaveLastCount();
        //判断24小时之外的课的请假次数是否用完
        if(number.data.remainCountYear != undefined )
        {
            isAskForLeaveTimesOutOff= number.data.remainCountYear > 0 ? false : true;

            //判断24小时之内的请假次数是否剩余
            withinTwentyFourAFKTimes=number.data.remainCountHour;
            askForLeaveView.visible = false;
            askForLeaveTimesView.visible = false;
            lessonStatusTipsView.visible = false;
            askForLeaveReasonView.visible = false;
            askForLeaveSuccessView.visible = false;
            askForLeavingTipsView.visible = false;
            reasonTextEdit.text = "";
            if(isAskForLeaveViewHasBeShowed)
            {
                //原请假逻辑
                //第一次使用弹窗被显示过
                //            if(isAskForLeaveTimesOutOff)
                //            {//超过请假次数
                //                //弹出超过请假次数 请假扣除课时提示
                //                askForLeaveTimesView.visible=true;
                //            }else
                //            {
                //                if(isWithinTwentyFourHoursLesson)
                //                {//24小时之内的课
                //                    console.log("24 之内")
                //                    lessonStatusTipsView.visible=true;
                //                }else
                //                {//24小时之外的课  弹出正在请假的弹窗
                //                    console.log("24之外")
                //                    askForLeavingTipsView.visible=true;
                //                }
                //            }


                if(isWithinTwentyFourHoursLesson)
                {
                    //24小时之内的课 判断是否超过请假次数
                    console.log("24 之内")
                    //   lessonStatusTipsView.visible=true;

                    if(withinTwentyFourAFKTimes <= 0)
                    {//超过请假次数
                        //弹出超过请假次数 请假扣除课时提示
                        askForLeaveTimesView.visible=true;
                    }else
                    {
                        askForLeavingTipsView.visible=true;
                    }
                }else
                {//24小时之外的课  判断是否超过请假次数
                    console.log("24之外")
                    // askForLeavingTipsView.visible=true;

                    if(isAskForLeaveTimesOutOff)
                    {//超过请假次数
                        //弹出超过请假次数 请假扣除课时提示
                        askForLeaveTimesView.visible=true;
                    }else
                    {
                        askForLeavingTipsView.visible=true;
                    }
                }


            }else
            {
                askForLeaveView.visible = true;
            }
        }
    }
}
