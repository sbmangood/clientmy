import QtQuick 2.7
import QtGraphicalEffects 1.0

/*
* 底部工具栏
*/

Item {
    id:bottomToolbars

    property double ratesRates: widthRates > heightRates? heightRates : widthRates


    property bool whetherAllowedClick: true;//是否允许点击
    property bool disabledButton: true;//禁用按钮
    property int currentPage: 0;//当前页
    property int  totalPage: 0;//总页数

    //跳转页面
    signal sigJumpPage(int pages);

    signal sigPrePage();
    signal sigNext();

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
        width: 240 * widthRate
        height: 45 * heightRate
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 6 * widthRate
        border.width: 1
        border.color: "#ABABAD"
        color: "white"

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
                color: "#e6e6e6"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin:  15  * widthRates
                //加一页
                MouseArea{
                    id: addPageButton
                    width: 12 * widthRates
                    height: 20 * heightRates
                    hoverEnabled: true
                    enabled: disabledButton
                    cursorShape: Qt.PointingHandCursor
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10 * widthRates
                    Image{
                        width: 12 * widthRates
                        height: 12 * widthRates
                        anchors.centerIn: parent
                        source: parent.containsMouse ? "qrc:/images/cr_btn_addhover.png" : "qrc:/images/btn_addonepage.png"
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
                    width: 12 * widthRates
                    height: 20 * heightRates
                    hoverEnabled: true
                    enabled: disabledButton
                    anchors.left: addPageButton.right
                    anchors.leftMargin: 10 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                    cursorShape: Qt.PointingHandCursor
                    Image{
                        width: 12 * widthRates
                        height: 12 * widthRates
                        anchors.centerIn: parent
                        source: parent.containsMouse ? "qrc:/images/cr_dele_hover.png" : "qrc:/images/btn_deletonepage.png"
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
                anchors.leftMargin:  15  * widthRates  //30
                hoverEnabled: true
                anchors.verticalCenter: parent.verticalCenter
                enabled:  currentPage ==1 ? false : disabledButton ?  true : false
                cursorShape: Qt.PointingHandCursor
                z:5

                Image {
                    id: prePageImage
                    width: 6 * widthRates
                    height: 10* heightRates                    
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
                    sigPrePage();
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
                    color:"#666666"
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
                    color: "#666666"
                    text:"/ " + totalPage.toString()
                }
            }

            //下一页按钮
            MouseArea{
                id:nextPage
                anchors.left:totalPages.right
                width: 12 * widthRates
                height: 20 * heightRates
                anchors.verticalCenter: parent.verticalCenter
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                enabled: currentPage == totalPage ? false : disabledButton ? true : false
                z:5
                Image {
                    id: nextPageImage
                    width: 6* widthRates
                    height: 10* heightRates
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
                    sigNext();
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
                width: 50 * widthRates
                height: 20 * heightRates
                anchors.leftMargin: 15  * widthRates
                anchors.verticalCenter: parent.verticalCenter
                color: "#e6e6e6"
                radius: inputNum.height / 2
                z: 5
                TextInput{
                    id:pageNumInput
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
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
            }

            //跳转按钮
            MouseArea{
                id:jumpBtn
                anchors.left:inputNum.right
                width: 28 * widthRates
                height: 14 * heightRates
                anchors.leftMargin: 8  * widthRates
                anchors.verticalCenter: parent.verticalCenter
                hoverEnabled: true
                enabled: disabledButton
                z: 5
                Text {
                    id: jumpBtnName
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14 * heightRates
                    font.family: "Microsoft YaHei"
                    color:whetherAllowedClick ?  "#333333" :  "#aaaaaa"
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
                        jumpBtnName.color =  "#333333";
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

