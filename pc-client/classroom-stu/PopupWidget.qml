import QtQuick 2.7
import CurriculumData  1.0


Rectangle {
    id:popupWidget
    color: Qt.rgba(0.5,0.5,0.5,0.6)

    property double widthRates: popupWidget.width /  1440.0
    property double heightRates: popupWidget.height / 900.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    //退出教室
    signal sigCloseAllWidget();

    //等待界面显示内容
    property string  waitWidgetContent: "0"

    //主动退出教室的
    signal selectWidgetType(int types);

    //学生类型
    property  string  studentType: videoToolBackground.getCurrentUserType()

    //判断是否显示启用 新的结束课程View
    property bool  isShowNewEvaluateItemView: false;

    //评价
    signal sigEvaluateContent(bool content , bool attitude , bool homework , string contentText);

    //保存学生的评价信息
    signal sigSaveStuEvaluations(int stuSatisfiedFlag , string optionId , string otherReason);


    //发送结束课程信号
    signal sigEndLesson();

    //留在教室
    signal sigStayInclassroom();
    //关闭音频
    signal sigExitRoomName();

    //课程结束
    signal classOverView();
    //设置留在教室窗口
    function setExitRoomName( types , cname){
        hideTime.stop();
        hideTimeWidget();
        tipWaitIntoClassRoom.visible = false;
        tipDropClassroom.visible = false;

        if(types == "TEA" )  {
            if(studentType == "A") {
                //如果有其他老师在教室不弹窗
                if(curriculumData.justHasTeacherInRoom())
                {
                    return;
                }
                tipExitClassroom.stuNameContent = "老师 " + cname;
                popupWidget.visible = true;
                tipExitClassroom.visible = true;
                sigExitRoomName();

            }else {
                tipDropClassroomBstudentItem.exitName = "老师 " + cname + " ";
                popupWidget.visible = true;
                tipDropClassroomBstudentItem.visible = true;

            }

            return;
        }
        if(types == "A" && studentType != "A")  {
            tipDropClassroomBstudentItem.exitName = "学生 " + cname  + " ";
            popupWidget.visible = true;
            tipDropClassroomBstudentItem.visible = true

            return;
        }
        if( types == "B" )  {
            return;
        }
    }


    // 设置弹窗的界面
    function setPopupWidget(popups){

        console.log("popups ==",popups,kickOutView.visible,studentType)
        if(popups == "getLessonListFail") {
            hideTimeWidget();
            tipWaitIntoClassRoom.visible = false;
            kickOutView.resetShowText("课件加载失败，请退出教室重新进入");
            kickOutView.visible = true;
            popupWidget.visible = true;
            return ;
        }
        if(popups == "createRoomFail") {
            hideTimeWidget();
            tipWaitIntoClassRoom.visible = false;
            kickOutView.resetShowText("加入音视频通道失败，请退出重试");
            kickOutView.visible = true;
            popupWidget.visible = true;
            return ;
        }
        if(tipLoginError.visible == true)
        {
            return;
        }
        if(kickOutView.visible == true )
        {
            return;
        }

        if(tipAutoChangeIpView.visible == true && popups !== "autoChangeIpSuccess" && popups !== "autoChangeIpFail")
        {
            console.log("popups ==",popups)
            return;
        }
        hideTime.stop();
        if(popups == "65" ) {
            if(studentType == "A") {
                hideTimeWidget();
                classOverView();
                tipDropClassroom.visible = false;
                if(isShowNewEvaluateItemView)
                {
                    tipLessonEvaluateWidgetItem.visible = true;
                }else
                {
                    tipEvaluateWidgetItem.visible = true;
                }
                popupWidget.visible = true;

            }else {
                tipDropClassroomBstudentItem.exitName = "课程结束请";
                popupWidget.visible = true;
                tipDropClassroomBstudentItem.visible = true
            }

            return;
        }
        //同意结束课程弹窗
        if(popups == "56"){
            classOverView();
            popupWidget.selectWidgetType( 2);
            hideTimeWidget();
            if(isShowNewEvaluateItemView)
            {
                tipLessonEvaluateWidgetItem.visible = true;
            }else
            {
                tipEvaluateWidgetItem.visible = true;
            }
            popupWidget.visible = true;
        }

        if(popups == "0") {
            tipWaitIntoClassRoom.visible = false;
            tipLoginError.visible = true;
            popupWidget.visible = true;
            return ;
        }
        if(popups == "1") {

            waitWidgetContent = "1";
            tipWaitIntoClassRoom.visible = true;
            popupWidget.visible = true;

            return;
        }
        if(popups == "2") {

            if(studentType == "A") {
                tipWaitIntoClassRoom.visible = false;
                popupWidget.visible = false;
            }else {
                waitWidgetContent = "2";
            }

            return;
        }
        //为b学生进入教室
        if(popups == "6") {
            tipWaitIntoClassRoom.visible = false;
            popupWidget.visible = false;
            return;
        }

        if(popups == "startclass" ) {
            hideTimeWidget();
            tipWaitIntoClassRoom.visible = false;
            tipTeacherGoOnClassItem.visible = true;
            popupWidget.visible = true;
            hideTime.start();
            return;
        }
        if(popups == "close" ) {
            hideTimeWidget();
            tipWaitIntoClassRoom.visible = false;
            popupWidget.visible = true;
            tipDropClassroom.visible = true;
            return;
        }
        if(popups == "bclose" ) {
            hideTimeWidget();
            tipWaitIntoClassRoom.visible = false;
            popupWidget.visible = true;
            tipExitClassroomItem.visible = true;
            return;
        }

        if(popups == "64" ) {
            hideTimeWidget();
            if(tipDropClassroom.visible == true || tipEvaluateWidgetItem.visible == true ) {
                return;
            }

            popupWidget.visible = true;
            tipCannotLeaveWidgetItem.visible = true;
            hideTime.start();
            return;
        }
        if(popups == "63" ) {
            hideTimeWidget();
            if(tipDropClassroom.visible == true || tipEvaluateWidgetItem.visible == true ) {
                return;
            }
            popupWidget.visible = true;
            tipClassOverWidgetItem.visible = true;
            hideTime.start();
            return;
        }
        //允许进入
        if(popups == "66" ) {
            tipWaitIntoClassRoom.visible = false;
            popupWidget.visible = false;
        }
        //拒绝进入
        if(popups == "67" ) {
            popupWidget.sigCloseAllWidget();
        }

        if( popups == "noselectpower")
        {
            popupWidget.color = Qt.rgba(0.5,0.5,0.5,0.0);
            fillMousearea.enabled = false;
            hideTimeWidget();
            popupWidget.visible = true;
            noSelectPowerTip.visible = true;
            hideTime.start();
        }

        //ip自动切换

        if( popups == "showAutoChangeIpview" || popups == "autoChangeIpSuccess" || popups == "autoChangeIpFail" )
        {
            if(popups == "showAutoChangeIpview")
            {
                hideTimeWidget();
                popupWidget.visible = true;
                tipAutoChangeIpView.visible = true;
            }
            if(popups == "autoChangeIpSuccess")
            {
                hideTime.start();
                console.log("pup widget change success")
            }
            if(popups == "autoChangeIpFail")
            {
                //change for Http
                hideTimeWidget();
                popupWidget.visible = true;
                tipAutoChangeIpView.visible = true;
                tipAutoChangeIpView.setAutoChangeIpFail();
            }
            return;
        }
        if(popups == "80") {
            hideTimeWidget();
            tipWaitIntoClassRoom.visible = false;
            kickOutView.visible = true;
            popupWidget.visible = true;
            return ;
        }



    }

    //隐藏界面
    function hideTimeWidget(){
        if(tipClassOverWidgetItem.visible == true) {
            popupWidget.sigCloseAllWidget();
        }

        tipAskTeacherForLeaveItem.visible = false;
        tipCannotLeaveWidgetItem.visible = false
        tipClassOverWidgetItem.visible = false;
        tipTeacherGoOnClassItem.visible = false;
        tipExitClassroom.visible = false;
        if(!tipWaitIntoClassRoom.visible)
        {
            popupWidget.visible = false;
        }
        noSelectPowerTip.visible = false;
        tipAutoChangeIpView.visible = false;
        tipEndLessonView.visible = false;
        kickOutView.visible = false;
        tipLessonEvaluateWidgetItem.visible = false;
    }
    CurriculumData{
        id:curriculumData
    }
    //正在向老师请假离开
    TipAskTeacherForLeaveItem{
        id:tipAskTeacherForLeaveItem
        anchors.left: parent.left
        anchors.top: parent.top
        width: 300.0 *  popupWidget.width / 1440
        height:  225.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipAskTeacherForLeaveItem.width ) / 2
        anchors.topMargin: (popupWidget.height - tipAskTeacherForLeaveItem.height ) / 2
        visible: false
        z:5
        onHideItem:
        {
            tipEndLessonView.visible = false;
            popupWidget.visible = false;
        }
    }

    //评价提醒窗
    TipAssessView{
        id: assessView
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: (popupWidget.width - assessView.width ) / 2
        anchors.topMargin: (popupWidget.height - assessView.height ) / 2
        visible: false
        z:5
        onSigOk: {
            sigCloseAllWidget();
        }

        onSigRefuse: {
            tipEvaluateWidgetItem.visible = true;
            popupWidget.visible = true;
        }
    }

    //暂时不能离开，请认真听讲
    TipCannotLeaveWidgetItem{
        id:tipCannotLeaveWidgetItem
        anchors.left: parent.left
        anchors.top: parent.top
        width: 300.0 * popupWidget.width / 1440
        height:  225.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipCannotLeaveWidgetItem.width ) / 2
        anchors.topMargin: (popupWidget.height - tipCannotLeaveWidgetItem.height ) / 2
        visible: false
        z:5
    }

    //正在离开教室，稍后可以回来继续上课哦！
    TipClassOverWidgetItem{
        id:tipClassOverWidgetItem
        anchors.left: parent.left
        anchors.top: parent.top
        width: 300.0 * popupWidget.width / 1440
        height:  225.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipClassOverWidgetItem.width ) / 2
        anchors.topMargin: (popupWidget.height - tipClassOverWidgetItem.height ) / 2
        visible: false
        z:5
    }

    //课程暂时中断，请退出 学生 某某某某 退出教室 用于b学生
    TipDropClassroomBstudentItem{
        id:tipDropClassroomBstudentItem
        anchors.left: parent.left
        anchors.top: parent.top
        width: 240.0 *  popupWidget.width / 1440
        height:  137.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipDropClassroomBstudentItem.width ) / 2
        anchors.topMargin: (popupWidget.height - tipDropClassroomBstudentItem.height ) / 2
        visible: false
        z:5
        onSigExitRoom: {
            popupWidget.sigCloseAllWidget();
        }
    }

    //老师回来啦，现在继续上课
    TipTeacherGoOnClassItem{
        id:tipTeacherGoOnClassItem
        anchors.left: parent.left
        anchors.top: parent.top
        width: 300.0 *  popupWidget.width / 1440
        height:  225.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipTeacherGoOnClassItem.width ) / 2
        anchors.topMargin: (popupWidget.height - tipTeacherGoOnClassItem.height ) / 2
        visible: false
        z:5
    }



    //down new *************
    TipLessonEvaluationItem
    {
        id:tipLessonEvaluateWidgetItem
        anchors.left: parent.left
        anchors.top: parent.top
        width: 300.0 *  popupWidget.width / 1440
        height: width * 1.6
        anchors.leftMargin: (popupWidget.width - tipEvaluateWidgetItem.width ) / 2
        anchors.topMargin: (popupWidget.height - tipEvaluateWidgetItem.height ) / 2
        visible: false
        z:500000

        onSigSaveStuEvaluation:
        {
            sigSaveStuEvaluations(stuSatisfiedFlag , optionId , otherReason);
        }
        onCloseTheWidget:
        {
            sigCloseAllWidget();
        }

        onVisibleChanged:
        {
            if(visible == false)
            {
                parent.visible = true;
                tipLessonEvaluateWidgetItem.visible = false;
            }
        }
    }
    //    onVisibleChanged:
    //    {

    //        if(popupWidget.visible == false)
    //        {
    //            popupWidget.visible = true;
    //            tipLessonEvaluateWidgetItem.visible = true;
    //        }
    //    }
    //    //************ up new

    //Component.objectName:
    //{
    //    visible = false
    //}
    //评价
    TipEvaluateWidgetItem{
        id:tipEvaluateWidgetItem
        anchors.left: parent.left
        anchors.top: parent.top
        width: 300.0 *  popupWidget.width / 1440
        height:  400.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipEvaluateWidgetItem.width ) / 2
        anchors.topMargin: (popupWidget.height - tipEvaluateWidgetItem.height ) / 2
        visible: false
        z:5
        studentName: videoToolBackground.getUserName("0");

        onCloseTheWidget: {
            sigCloseAllWidget();
            //直接退出 不在二次询问
            //            assessView.visible = true;
            //            tipEvaluateWidgetItem.visible = false;
            //            popupWidget.visible = true;
        }
        onSigEvaluateContents:{

            var contents =  false;
            if(content == 1) {
                contents = true;
            }

            var attitudes = false;
            if(attitude == 1) {
                attitudes = true;
            }

            var homeworks = false;
            if(homework == 1) {
                homeworks = true;
            }
            popupWidget.sigEvaluateContent(contents,attitudes,homeworks,contentText);
        }
    }

    //请求结束课程
    TipEndLessonView{
        id:tipEndLessonView
        anchors.left: parent.left
        anchors.top: parent.top
        width: 240.0 *  popupWidget.width  / 1440
        height:  224.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipEndLessonView.width ) / 2
        anchors.topMargin: (popupWidget.height - tipEndLessonView.height ) / 2
        visible: false
        z:5
        onHideItem:
        {
            tipEndLessonView.visible = false;
            popupWidget.visible = false;
        }
    }


    //主动退出教室课程结束
    TipDropClassroom{
        id:tipDropClassroom
        anchors.left: parent.left
        anchors.top: parent.top
        width: 270.0 *  popupWidget.width  / 1440  * 0.75
        height:  290.0 *  popupWidget.height / 900  * 0.75
        anchors.leftMargin: (popupWidget.width - tipDropClassroom.width ) / 2
        anchors.topMargin: (popupWidget.height - tipDropClassroom.height ) / 2
        visible: false
        z:5
        onSelectWidgetType: {
            //popupWidget.selectWidgetType( types);
            if(types == 1) {
                popupWidget.selectWidgetType(types);
                hideTimeWidget();
                tipAskTeacherForLeaveItem.visible = true;
                popupWidget.visible = true;
                //hideTime.start();
            }
            if(types == 2) {
                hideTimeWidget();
                //tipEvaluateWidgetItem.visible = true;
                tipEndLessonView.visible = true;
                popupWidget.visible = true;
                sigEndLesson();

            }
        }
        onCloseWidget: {
            tipDropClassroom.visible = false;
            popupWidget.visible = false;
        }
    }


    //老师退出教室 a学生用
    TipExitClassroom{
        id:tipExitClassroom
        anchors.left: parent.left
        anchors.top: parent.top
        width: 240.0 *  popupWidget.width / 1440
        height:  154.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipExitClassroom.width ) / 2
        anchors.topMargin: (popupWidget.height - tipExitClassroom.height ) / 2
        visible: false
        z:5
        //离开教室
        onLeaveTheclassroom: {
            popupWidget.sigCloseAllWidget();
        }
        //留在教室
        onStayInclassroom: {
            tipExitClassroom.visible = false;
            popupWidget.visible = false;
            popupWidget.sigStayInclassroom();

        }

    }


    //用于b学生主动退出教室
    TipExitClassroomItem{
        id:tipExitClassroomItem
        anchors.left: parent.left
        anchors.top: parent.top
        width: 240.0 *  popupWidget.width / 1440
        height:  137.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipExitClassroomItem.width ) / 2
        anchors.topMargin: (popupWidget.height - tipExitClassroomItem.height ) / 2
        visible: false
        z:5
        //同意
        onAgreeTheCmd: {
            popupWidget.sigCloseAllWidget();

        }
        //取消
        onRefuseTheCmd: {
            popupWidget.visible = false;
            tipExitClassroomItem.visible = false;
        }
    }

    //登录错误
    TipLoginError{
        id:tipLoginError
        anchors.left: parent.left
        anchors.top: parent.top
        width: 240.0 *  popupWidget.width / 1440
        height:  172.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipLoginError.width ) / 2
        anchors.topMargin: (popupWidget.height - tipLoginError.height ) / 2
        visible: false
        z:5
        onSigCloseAllWidget: {
            popupWidget.sigCloseAllWidget();
        }
    }
    TipKickOutView
    {
        id:kickOutView
        anchors.left: parent.left
        anchors.top: parent.top
        width: 240.0 *  popupWidget.width / 1440
        height:  152.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipLoginError.width ) / 2
        anchors.topMargin: (popupWidget.height - tipLoginError.height ) / 2
        visible: false
        z:5
        onSigCloseAllWidget: {
            popupWidget.sigCloseAllWidget();
        }
    }

    //等待进入教室画面
    TipWaitIntoClassRoom{
        id:tipWaitIntoClassRoom
        anchors.left: parent.left
        anchors.top: parent.top
        width: 240.0 *  popupWidget.width / 1440
        height:  153.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipWaitIntoClassRoom.width ) / 2
        anchors.topMargin: (popupWidget.height - tipWaitIntoClassRoom.height ) / 2
        visible: true
        tagNameContent:waitWidgetContent == "0" ? "进入教室中…":(waitWidgetContent == "1" ? "正在同步上课记录...":"请求进入教室...")
        z:5
        onSigCloseAllWidget: {
            popupWidget.sigCloseAllWidget();
        }
    }
    //自动切换IP画面
    TipAutoChageIpView
    {
        id:tipAutoChangeIpView
        anchors.left: parent.left
        anchors.top: parent.top
        width: 240.0 *  popupWidget.width / 1440
        height:  153.0 *  popupWidget.height / 900
        anchors.leftMargin: (popupWidget.width - tipAutoChangeIpView.width ) / 2
        anchors.topMargin: (popupWidget.height - tipAutoChangeIpView.height ) / 2
        visible: false
        z:6
        onSigCloseAllWidget: {
            popupWidget.sigCloseAllWidget();
        }
    }

    //没有操作权限提示
    TipNoSelectPowerItem{
        id:noSelectPowerTip
        visible: false
        anchors.centerIn: parent
        z:50
    }

    MouseArea{
        id: fillMousearea
        anchors.fill: parent
        onClicked: {

        }
    }

    Timer{
        id:hideTime
        interval: 3000
        repeat: false
        onTriggered: {
            hideTimeWidget();
            popupWidget.color =  Qt.rgba(0.5,0.5,0.5,0.6);
            fillMousearea.enabled = true;
        }
    }

    Component.onCompleted:
    {
        hideTimeWidget();
    }

    function upTipEvaluateWidgetItem(data)
    {
        isShowNewEvaluateItemView = true;
        tipLessonEvaluateWidgetItem.resetAllReasonModel(data);
    }

}

