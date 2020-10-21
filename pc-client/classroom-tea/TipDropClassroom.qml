import QtQuick 2.7

/*
 *主动退出教室课程结束
 */

Rectangle {
    id:tipDropClassroom

    color: "white"
    property double widthRates: tipDropClassroom.width / 240.0
    property double heightRates: 224.0 *  popupWidget.height / 900 / 226.0 //tipDropClassroom.height / 226.0
    property double ratesRates: tipDropClassroom.widthRates > tipDropClassroom.heightRates? tipDropClassroom.heightRates : tipDropClassroom.widthRates
    property string tagNameContent: qsTr("")

    property int selectBtnBakcground: 3

    property bool hasFinishListenReports:hasFinishListenReport;

    radius: 10 * ratesRates
    clip: true

    signal selectWidgetType(int types);
    signal closeWidget();

    onVisibleChanged:
    {
        //重设文字显示
        if(currentListenRoleType == 1)
        {
            if(hasFinishListenReport || subjectId == 0)//已完成课堂报告 或者是 演示课默认选择临时退出按钮
            {
                selectBtnBakcground = 1;
            }else
            {
                selectBtnBakcground = 3;
            }

        }else
        {
             selectBtnBakcground = 1;//显示1个
        }
    }

    onHasFinishListenReportsChanged:
    {
        if(hasFinishListenReports)
        {

            selectBtnBakcground = 1;
            //                temporarilyExit.border.color =  "#ff5000"
            //                temporarilyExitName.color =  "#ff5000"

            //                courseEvaluation.border.color =  "#666666"
            //                courseEvaluationName.color =  "#666666"

            //                courseEnd.border.color =  "#666666"
            //                courseEndName.color =  "#666666"
            //                contentName.text = qsTr("课程尚未结束，确认退出？")
        }
    }


    onSelectBtnBakcgroundChanged: {
        if(selectBtnBakcground == 1){
            temporarilyExit.border.color =  "#ff5000"
            temporarilyExitName.color =  "#ff5000"

            courseEvaluation.border.color =  "#666666"
            courseEvaluationName.color =  "#666666"

            courseEnd.border.color =  "#666666"
            courseEndName.color =  "#666666"
            //contentName.text = qsTr("课程尚未结束，确认退出？")
        }

        if(selectBtnBakcground == 2){
            temporarilyExit.border.color =  "#666666"
            temporarilyExitName.color =  "#666666"

            courseEvaluation.border.color =  "#666666"
            courseEvaluationName.color =  "#666666"

            courseEnd.border.color =  "#ff5000"
            courseEndName.color =  "#ff5000"
            //contentName.text = qsTr("课程结束后无法再次回到教室，确认退出？")
        }

        if(selectBtnBakcground == 3){
            courseEnd.border.color =  "#666666"
            courseEndName.color =  "#666666"

            temporarilyExit.border.color =  "#666666"
            temporarilyExitName.color =  "#666666"

            courseEvaluation.border.color =  "#ff5000"
            courseEvaluationName.color =  "#ff5000"
            //contentName.text = qsTr("确定要填写试听课报告吗？")
        }

    }

    Text {
        id: tagName
        width: 84 * tipDropClassroom.widthRates
        height: 20 * tipDropClassroom.heightRates
        anchors.left: parent.left
        anchors.top: parent.top
        font.pixelSize: 18 * tipDropClassroom.ratesRates
        anchors.leftMargin: 73 * tipDropClassroom.widthRates
        anchors.topMargin: 20 * tipDropClassroom.heightRates
        color:  "#222222"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        text: qsTr("退出教室")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }


    //临时退出 退出旁听
    Rectangle{
        id:temporarilyExit
        width: 238 * tipDropClassroom.widthRates * 0.8
        height: 44 * tipDropClassroom.heightRates * 0.8
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 24 * tipDropClassroom.widthRates
        anchors.topMargin: currentListenRoleType == 1 ? (125 * tipDropClassroom.heightRates) : 83 * tipDropClassroom.heightRates //isStartLesson ? 100 * tipDropClassroom.heightRates : 130 * heightRates
        color: selectBtnBakcground == 1 ? "#FFF3E9" : "#ffffff"
        border.color: selectBtnBakcground == 1 ? "#ff5000": "#666666"
        border.width: 1
        radius: 5 * tipDropClassroom.heightRates
        Text {
            id: temporarilyExitName
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 13  * tipDropClassroom.heightRates
            color:  selectBtnBakcground == 1 ? "#ff5000": "#666666"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            text: qsTr("临时退出")//currentIsAttend ? qsTr("退出旁听") : qsTr("临时退出")  //根据当前是不是旁听身份来判断需要显示的文字
        }
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                tipDropClassroom.selectBtnBakcground = 1;
            }
        }
    }

    //课程结束
    Rectangle{
        id:courseEnd
        width: 238 * tipDropClassroom.widthRates * 0.8
        height: 44 * tipDropClassroom.heightRates * 0.8
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 24 * tipDropClassroom.widthRates
        anchors.topMargin:currentListenRoleType == 1 ? 167 * tipDropClassroom.heightRates : 125 * tipDropClassroom.heightRates
        color: selectBtnBakcground == 2 ? "#FFF3E9" : "#ffffff"
        border.color: "#666666"
        border.width: 1
        radius: 5 * tipDropClassroom.heightRates
        visible: !currentIsAuditionLesson ? ((isStartLesson ) ?  !currentIsAttend : false) : ((currentListenRoleType == 2 || currentListenRoleType == 1) ? true : false)
        //enabled: currentIsAuditionLesson ? (isStartLesson ? true : false) : true //标准试听课只有学生在的时候才可以结束课程
        Text {
            id: courseEndName
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 13  * tipDropClassroom.heightRates
            color: "#666666"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            text: qsTr("课程结束")
        }

        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                tipDropClassroom.selectBtnBakcground = 2;
            }
        }
    }

    //试听课报告
    Rectangle{
        id:courseEvaluation
        width: 238 * tipDropClassroom.widthRates * 0.8
        height: 44 * tipDropClassroom.heightRates * 0.8
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 24 * tipDropClassroom.widthRates
        anchors.topMargin: 83 * tipDropClassroom.heightRates // isStartLesson ? 58 * tipDropClassroom.heightRates : 80 * heightRates
        color: selectBtnBakcground == 3 ? "#FFF3E9" : "#ffffff"
        border.color: selectBtnBakcground == 3 ? "#ff5000" : "#666666"
        border.width: 1
        radius: 5 * tipDropClassroom.heightRates
        visible: currentListenRoleType == 1 && subjectId != 0 //用户类型是老师 并且不是演示课时才显示此项
        enabled: currentIsAuditionLesson ? true : !hasFinishListenReports
        Text {
            id: courseEvaluationName
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 13  * tipDropClassroom.heightRates
            color: selectBtnBakcground == 3 ? "#ff5000" : "#666666"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            text: currentIsAuditionLesson ? (hasFinishListenReports ? qsTr("修改试听课报告") : qsTr("试听课报告")):(hasFinishListenReports ? qsTr("课堂评价(已提交)") : qsTr("课堂评价"))
        }

        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                tipDropClassroom.selectBtnBakcground = 3;
            }
        }
    }

    Text {
        id: contentName
        width: 198 * tipDropClassroom.widthRates
        height: 28 * tipDropClassroom.heightRates
        anchors.left: parent.left
        anchors.top: parent.top
        font.pixelSize: 11.5 * tipDropClassroom.ratesRates
        anchors.leftMargin: 20 * tipDropClassroom.widthRates
        anchors.topMargin: 45 * tipDropClassroom.heightRates
        //anchors.topMargin: (currentListenRoleType == 1 && !currentIsAttend) ? (currentIsAuditionLesson ? 140 * tipDropClassroom.heightRates :182 * tipDropClassroom.heightRates) :(140 * tipDropClassroom.heightRates)
        color: "#333333"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        text: {
            if(selectBtnBakcground == 3)
            {
                if(currentIsAuditionLesson)
                {
                    return qsTr("确定要填写试听课报告吗？");
                }
                return qsTr("确定要填写订单课报告吗？");
            }else if(selectBtnBakcground == 2)
            {
                return qsTr("课程结束后无法再次回到教室，确认退出？");
            }else if(selectBtnBakcground == 1)
            {
                return qsTr("课程尚未结束，确认退出？")
            }

        }
        horizontalAlignment: Text.AlignHCenter
        //verticalAlignment: Text.AlignVCenter
    }

    //确定按钮
    Rectangle{
        id:okBtn
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20 *  tipDropClassroom.widthRates
        anchors.topMargin: (currentListenRoleType == 1 && !currentIsAttend) ? (currentIsAuditionLesson ? 216 * tipDropClassroom.heightRates : 216 * tipDropClassroom.heightRates):(174 * tipDropClassroom.heightRates )
        width:  200  *  tipDropClassroom.widthRates
        height:  32 * tipDropClassroom.heightRates
        color: "#ff5000"
        radius: 5 * tipDropClassroom.heightRates
        Text {
            id: okBtnName
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 13  * tipDropClassroom.ratesRates
            color: "#ffffff"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            text: qsTr("确定")
        }
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {

                // 1临时退出 2 老师结束课程退出  3 填写试听课报告 4 填写课堂报告 5老师退出旁听 6 学生 cr 退出旁听 7 cr结束课程
                if(tipDropClassroom.selectBtnBakcground == 3)
                {
                    if(currentIsAuditionLesson)
                    {
                        selectWidgetType(3);
                    }else
                    {
                        selectWidgetType(4);
                    }
                }else if(tipDropClassroom.selectBtnBakcground == 1)
                {
                    //退出旁听
                    if(currentIsAttend)
                    {
                        if(currentListenRoleType == 1)
                        {
                            selectWidgetType(5);
                        }else
                        {
                            selectWidgetType(6);
                        }
                    }else
                    {
                        //临时退出
                        selectWidgetType(1);
                    }
                }else if(tipDropClassroom.selectBtnBakcground == 2)
                {
                    //结束课程
                    if(currentListenRoleType == 1)
                    {
                        selectWidgetType(2);
                    }else
                    {
                        selectWidgetType(7);
                    }
                }

                if(tipDropClassroom.selectBtnBakcground == 3)
                {
                    return;
                }
                if(hasFinishListenReports)
                {
                    tipDropClassroom.selectBtnBakcground = 1;
                }else
                {
                    tipDropClassroom.selectBtnBakcground = 3;
                    tipDropClassroom.visible = false;
                }

            }
        }
    }

    //关闭按钮
    MouseArea{
        id:closeBtn
        width: 18  * tipDropClassroom.ratesRates
        height: 18 * tipDropClassroom.ratesRates
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin:5 * tipDropClassroom.ratesRates
        anchors.rightMargin:  5 * tipDropClassroom.ratesRates
        cursorShape: Qt.PointingHandCursor

        Image {
            width: parent.width
            height: parent.height
            source: "qrc:/images/cr_btn_quittwo.png"
        }

        onClicked: {
            closeWidget();
            tipDropClassroom.selectBtnBakcground = 1;
        }

    }
}

