import QtQuick 2.7
import QtGraphicalEffects 1.0

/*
* 底部工具栏
*/

Item {
    id:bottomToolbars

    property double widthRates: fullWidths / 1440.0
    property double heightRates: fullHeights / 900.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    // radius: bottomToolbars.height / 2

    //是否允许点击
    property bool whetherAllowedClick: true
    property bool disabledButton: !currentIsAuditionLesson ? true : false;//禁用按钮
    property int currentPage: 0;//当前页
    property int  totalPage: 0;    //总页数
    property bool disableAnswer: true;//显示答案解析
    property bool disableCorrec: true;//显示批改
    property bool answerIsOpen: false;
    property bool modifyIsOpen: false;

    //跳转页面
    signal sigJumpPage(int pages);

    //申请翻页
    signal applyPage();

    //收回分页权限
    signal sigRecoverPage();

    //删除分页
    signal sigRemoverPage();

    //添加分页
    signal sigAddPage();

    //最后一页信号
    signal sigTipPage(string message);
    signal sigModify();//批改信号
    signal sigAnswer();//答题信号


    Timer{
        id: disabledBtnTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            disabledButton = true;
        }
    }

    onWhetherAllowedClickChanged: {
        if(whetherAllowedClick) {
            prePageImage.source =  "qrc:/images/previoustwox.png";
            nextPageImage.source =  "qrc:/images/nexttwox.png";
            jumpBtnName.color =  "#333333";
        }else {
            prePageImage.source =  "qrc:/images/previous_nonetwox.png";
            nextPageImage.source =  "qrc:/images/next_nonetwox.png";
            jumpBtnName.color =  "#aaaaaa";

        }
    }


    //主体窗口
    Rectangle {
        id: pageView
        z: 2
        width: 469 * heightRates / 1.3
        height: 44 * heightRates / 1.3
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"

        Image {
            anchors.fill: parent
            source: "qrc:/newStyleImg/btmbar@2x.png"
        }

        Item {
            id: mainRect
            anchors.fill: parent
            anchors.centerIn: parent;
            z: 3

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    bottomToolbars.focus = true;
                }
            }

            Rectangle{
                id: addPageView
                width: 50 * widthRates
                height: 20 * heightRates
                radius: 10 * heightRates
                color: "transparent"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin:  20  * widthRates
                //加一页
                MouseArea{
                    id: addPageButton
                    width: 20 * widthRates
                    height: width
                    hoverEnabled: true
                    enabled: disabledButton
                    cursorShape: Qt.PointingHandCursor
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: lessPageButton.right
                    anchors.leftMargin: 16 * heightRate

                    Image{
                        width: 20 * widthRates
                        height: width
                        anchors.centerIn: parent
                        source: parent.containsMouse ? "qrc:/newStyleImg/pc_btn_add@2x.png" : "qrc:/newStyleImg/pc_btn_add_disable@2x.png"
                    }

                    onClicked: {
                        disabledButton = false;
                        disabledBtnTimer.restart();
                        sigRecoverPage();
                        sigAddPage();
                    }
                }

                //减一页
                MouseArea{
                    id: lessPageButton
                    width: 20 * widthRates
                    height: width
                    hoverEnabled: true
                    enabled: disabledButton
                    anchors.left: parent.left
                    anchors.leftMargin: 12 * widthRates
                    anchors.verticalCenter: parent.verticalCenter
                    cursorShape: Qt.PointingHandCursor
                    Image{
                        width: 20 * widthRates
                        height: width
                        anchors.centerIn: parent
                        source: parent.containsMouse ? "qrc:/newStyleImg/pc_btn_minus@2x.png" : "qrc:/newStyleImg/pc_btn_minus_disable@2x.png"
                    }

                    onClicked: {
                        disabledButton = false;
                        disabledBtnTimer.restart();
                        sigRecoverPage();
                        sigRemoverPage();
                    }
                }

            }

            //上一页按钮
            MouseArea{
                id:prePage
                anchors.left:addPageView.right
                width: 10 * widthRates
                height: 20 * heightRates
                anchors.leftMargin:  28  * widthRates  //30
                hoverEnabled: true
                anchors.verticalCenter: parent.verticalCenter
                enabled:  currentPage ==1 ? false : disabledButton ?  true : false
                cursorShape: Qt.PointingHandCursor
                z:5

                Image {
                    id: prePageImage
                    width: 9 * heightRates
                    height: 15 * heightRates
                    anchors.centerIn: parent
                    source:whetherAllowedClick ?  "qrc:/images/previoustwox.png" : "qrc:/images/previous_nonetwox.png"
                }

                onPressed: {
                    bottomToolbars.focus = true;
                    if(whetherAllowedClick ) {
                        prePageImage.source =  "qrc:/images/previous_sedtwox.png";
                    }else {
                        prePageImage.source =  "qrc:/images/previous_nonetwox.png";
                    }

                }
                onReleased: {
                    sigRecoverPage();
                    if(whetherAllowedClick ) {
                        prePageImage.source =  "qrc:/images/previoustwox.png";
                        if(currentPage - 2 < 0) {
                            sigJumpPage(0);
                        }else {
                            sigJumpPage(currentPage - 2);
                        }
                    }
                    if(currentPage - 1 <= 0){
                        sigTipPage("onePage")
                    }
                    disabledButton = false;
                    disabledBtnTimer.restart();
                }
                onExited:{
                    if(whetherAllowedClick ) {
                        prePageImage.source =  "qrc:/images/previoustwox.png";
                    }else {
                        prePageImage.source =  "qrc:/images/previous_nonetwox.png";

                    }
                }

                onEntered: {
                    if(whetherAllowedClick ) {
                        prePageImage.source =  "qrc:/images/previous_sedtwox.png";
                    }else {
                        prePageImage.source =  "qrc:/images/previous_nonetwox.png";
                    }
                }

            }

            //当前页按钮
            Item{
                id:pageNum
                anchors.left:prePage.right
                anchors.leftMargin:  15 * heightRates
                width: 30 * widthRates
                height: 16 * heightRates
                anchors.verticalCenter: parent.verticalCenter
                z:5
                Text{
                    id:currentpageNum
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14 * heightRates
                    wrapMode:Text.WordWrap
                    font.family: "Microsoft YaHei"
                    color:"#737373"
                    text:currentPage.toString()
                }
            }

            //总页数按钮
            Item{
                id:totalPages
                anchors.left:pageNum.right
                width: 35 * widthRates
                height: 16 * heightRates
                anchors.leftMargin:  0 * widthRates
                anchors.verticalCenter: parent.verticalCenter
                z:5
                Text{
                    id:totalPageNum
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14 * heightRates
                    //wrapMode:Text.WordWrap
                    font.family: "Microsoft YaHei"
                    color: "#737373"
                    text:"/  " + totalPage.toString()
                }
            }

            //下一页按钮
            MouseArea{
                id:nextPage
                anchors.left:totalPages.right
                anchors.leftMargin:  10 * heightRates
                width: 12 * widthRates
                height: 20 * heightRates
                anchors.verticalCenter: parent.verticalCenter
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                enabled: currentPage == totalPage ? false : disabledButton ? true : false
                z:5
                Image {
                    id: nextPageImage
                    width: 9 * heightRates
                    height: 15 * heightRates
                    anchors.centerIn: parent
                    source:whetherAllowedClick ?  "qrc:/images/nexttwox.png" : "qrc:/images/next_nonetwox.png"
                }

                onPressed: {
                    bottomToolbars.focus = true;
                    if(whetherAllowedClick ) {
                        nextPageImage.source =  "qrc:/images/next_sedtwox.png";
                    }else {
                        nextPageImage.source =  "qrc:/images/next_nonetwox.png";

                    }

                }
                onReleased: {
                    sigRecoverPage();
                    if(whetherAllowedClick ) {
                        nextPageImage.source =  "qrc:/images/nexttwox.png";
                        if(currentPage  > totalPage) {
                            sigJumpPage(totalPage );
                        }else {
                            sigJumpPage(currentPage);
                        }
                    }
                    if(currentPage == totalPage){
                        sigTipPage("lastPage");
                    }
                    disabledButton = false;
                    disabledBtnTimer.restart();
                }
                onExited:{
                    if(whetherAllowedClick ) {
                        nextPageImage.source =  "qrc:/images/nexttwox.png";
                    }else {
                        nextPageImage.source =  "qrc:/images/next_nonetwox.png";
                    }
                }

                onEntered: {
                    if(whetherAllowedClick ) {
                        nextPageImage.source =  "qrc:/images/next_sedtwox.png";
                    }else {
                        nextPageImage.source =  "qrc:/images/next_nonetwox.png";
                    }
                }
            }

            //输入信息
            Rectangle{
                id:inputNum
                anchors.left:nextPage.right
                width: 112 * widthRates / 1.7
                height: 32 * widthRates / 1.7
                anchors.leftMargin: 17  * widthRates
                anchors.verticalCenter: parent.verticalCenter
                color: "#F3F3F3"
                radius: inputNum.height / 2
                z: 5

                TextInput{
                    id:pageNumInput
                    height: parent.height
                    width: parent.width * 0.5
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.left: parent.left

                    font.pixelSize: 14 * heightRates
                    selectByMouse:true
                    enabled:  disabledButton
                    color:"#666666"  //666666 3c3c3e
                    font.family: "Microsoft YaHei"
                    validator: IntValidator{bottom: 1;top: totalPage}//RegExpValidator {regExp: /^[0-9]*$/}
                    text: currentPage.toString()

                    Keys.enabled:  true

                    onAccepted:  {
                        sigRecoverPage();
                        var nums1 = parseInt(pageNumInput.text);
                        var nums2 = parseInt(pageNumInput.text.replace("/","") );
                        if(nums1 <= 0) {
                            nums1 = 1;
                        }else if(nums1 >= nums2) {
                            nums1 = nums2 ;
                        }
                        currentPage = nums1;
                        sigJumpPage(nums1 - 1);
                        if(currentPage - 1 <= 0){
                            sigTipPage("onePage")
                        }
                        if(currentPage == totalPage){
                            sigTipPage("lastPage");
                        }
                        disabledButton = false;
                        disabledBtnTimer.restart();
                    }
                }

                Rectangle
                {
                    width: parent.width * 0.5
                    height: parent.height
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    radius: inputNum.height / 2
                    color: "#AAAAAA"

                    Rectangle
                    {
                        width: parent.width * 0.5
                        height: parent.height
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#AAAAAA"
                    }
                }
                //跳转按钮
                MouseArea{
                    id:jumpBtn
                    anchors.right:inputNum.right
                    width: 28 * widthRates
                    height: 14 * heightRates
                    anchors.rightMargin: 4 * widthRates
                    anchors.verticalCenter: parent.verticalCenter
                    hoverEnabled: true
                    enabled: disabledButton
                    z: 5
                    Text {
                        id: jumpBtnName
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 11 * heightRates
                        font.family: "Microsoft YaHei"
                        color:whetherAllowedClick ?  "white" :  "#aaaaaa"
                        text: qsTr("跳转")
                    }

                    onPressed: {
                        bottomToolbars.focus = true;
                        if(whetherAllowedClick ) {
                            jumpBtnName.color =  "#ff5000";
                        }else {
                            jumpBtnName.color =  "#aaaaaa";
                        }
                    }

                    onReleased: {
                        sigRecoverPage();
                        if(whetherAllowedClick ) {
                            jumpBtnName.color =  "#333333";
                            var nums1 = parseInt(pageNumInput.text);
                            var nums2 = parseInt(pageNumInput.text.replace("/","") );
                            if(nums1 <= 0) {
                                nums1 = 1;
                            }else if(nums1 >= nums2) {
                                nums1 = nums2 ;
                            }
                            currentPage = nums1;
                            if(currentPage - 1 < 0) {
                                sigJumpPage(0);
                            }else {
                                if(currentPage > totalPage) {
                                    sigJumpPage(totalPage - 1);
                                }else {
                                    sigJumpPage(currentPage - 1);
                                }
                            }
                        }else {
                            jumpBtnName.color =  "#aaaaaa";
                        }
                        if(currentPage - 1 <= 0){
                            sigTipPage("onePage")
                        }
                        if(currentPage == totalPage){
                            sigTipPage("lastPage");
                        }
                        disabledButton = false;
                        disabledBtnTimer.restart();
                    }
                    onExited:{
                        if(whetherAllowedClick ) {
                            jumpBtnName.color =  "white";
                        }else {
                            jumpBtnName.color =  "#aaaaaa";

                        }
                    }

                    onEntered: {
                        if(whetherAllowedClick ) {
                            jumpBtnName.color =  "#ff5000";
                        }else {
                            jumpBtnName.color =  "#aaaaaa";
                        }
                    }
                }

            }

        }
    }

    //批改、答案解析
    Row{
        id: pageItem
        z: 3
        width: 300 * heightRate
        height: 50 * heightRate
        anchors.right: parent.right
        anchors.rightMargin: 40 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -8 * widthRates
        spacing: 5 * heightRate

        MouseArea{
            hoverEnabled: true
            width: 258 * heightRate * 0.4
            height: 108 * heightRate * 0.4
            cursorShape: Qt.PointingHandCursor
            visible: disableCorrec
            enabled: disabledButton

            Image{
                anchors.fill: parent
                source: "qrc:/newStyleImg/pigai@2x.png"
                //source: parent.containsMouse ? "qrc:/cloudImage/btn_sd_pigai_Sed@2x.png" : "qrc:/cloudImage/btn_sd_pigai@2x.png"
            }

            onClicked: {
                console.log("======sigModify======");
                sigModify();
            }

            //            onPressed: {
            //                if(modifyIsOpen) {
            //                    if(modifyHomework.visible == false) {
            //                        sigModify();
            //                        return;
            //                    }
            //                    modifyIsOpen = !modifyIsOpen;
            //                    return;
            //                }

            //                if(!modifyIsOpen) {
            //                    sigModify();
            //                }
            //                modifyIsOpen = !modifyIsOpen;
            //            }
        }

        MouseArea{
            hoverEnabled: true
            width: 322 * heightRate * 0.4
            height: 108 * heightRate * 0.4
            cursorShape: Qt.PointingHandCursor
            visible: disableAnswer
            enabled: disabledButton

            Image{
                anchors.fill: parent
                source: "qrc:/newStyleImg/daanjiexi@2x.png"//parent.containsMouse ? "qrc:/cloudImage/btn_daanjiexi_sed@2x.png" : "qrc:/cloudImage/btn_daanjiexi@2x.png"
            }

            onClicked: {
                console.log("======sigAnswer======");
                sigAnswer();
            }

            //            onPressed: {
            //                console.log("toobarWidget.teacherEmpowerment",answerIsOpen,knowledgesView.visible);
            //                if(answerIsOpen) {
            //                    if(knowledgesView.visible == false){
            //                        sigAnswer();
            //                        return;
            //                    }
            //                    answerIsOpen = !answerIsOpen;
            //                    return;
            //                }

            //                if(!answerIsOpen){
            //                    sigAnswer();
            //                }
            //                answerIsOpen = !answerIsOpen;
            //            }
        }
    }

    MouseArea{
        anchors.fill: parent
        z:1
        onClicked: {
            bottomToolbars.focus = true;
        }
    }


    Keys.enabled: true

    Keys.onPressed: {
        if(event.key == Qt.Key_Up){
            bottomToolbars.focus = true;
            if(whetherAllowedClick ) {
                prePageImage.source =  "qrc:/images/previous_sedtwox.png";
            }else {
                prePageImage.source =  "qrc:/images/previous_nonetwox.png";

            }

        }else {
            if(event.key == Qt.Key_Down) {
                bottomToolbars.focus = true;
                if(whetherAllowedClick ) {
                    nextPageImage.source =  "qrc:/images/next_sedtwox.png";
                }else {
                    nextPageImage.source =  "qrc:/images/next_nonetwox.png";

                }
            }
        }
        event.accepted = true;
    }

    Keys.onReleased: {
        if(event.key == Qt.Key_Up){
            if(whetherAllowedClick ) {
                prePageImage.source =  "qrc:/images/previoustwox.png";
                if(currentPage - 2 < 0) {
                    sigJumpPage(0);
                }else {
                    sigJumpPage(currentPage - 2);
                }

            }else {
                prePageImage.source =  "qrc:/images/previous_nonetwox.png";
                applyPage();
            }
        }else {
            if(event.key == Qt.Key_Down) {
                if(whetherAllowedClick ) {
                    nextPageImage.source =  "qrc:/images/nexttwox.png";
                    if(currentPage  > totalPage) {
                        sigJumpPage(totalPage );
                    }else {
                        sigJumpPage(currentPage);
                    }

                }else {
                    nextPageImage.source =  "qrc:/images/next_nonetwox.png";
                    applyPage();
                }
            }
        }
        event.accepted = true;
    }

    function updatePrePage(){
        sigRecoverPage();
        if(whetherAllowedClick ) {
            prePageImage.source =  "qrc:/images/previoustwox.png";
            if(currentPage - 2 < 0) {
                sigJumpPage(0);
            }else {
                sigJumpPage(currentPage - 2);
            }
        }
        if(currentPage - 1 <= 0){
            sigTipPage("onePage")
        }
        disabledButton = false;
        disabledBtnTimer.restart();
    }

    function updateNextPage(){
        sigRecoverPage();
        if(whetherAllowedClick ) {
            nextPageImage.source =  "qrc:/images/nexttwox.png";
            if(currentPage  > totalPage) {
                sigJumpPage(totalPage );
            }else {
                sigJumpPage(currentPage);
            }
        }
        if(currentPage == totalPage){
            sigTipPage("lastPage");
        }
        disabledButton = false;
        disabledBtnTimer.restart();
    }

}

