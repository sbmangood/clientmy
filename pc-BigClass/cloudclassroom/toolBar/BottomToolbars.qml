import QtQuick 2.7
import QtQuick.Controls 2.0
import "./Configuration.js" as Cfg
/*
* 底部工具栏
*/
Rectangle {
    id:bottomToolbars
    color: "#363744"
    width: parent.width
    height: parent.height

    property double ratesRates: widthRate > heightRate? heightRate : widthRate

    //是否允许点击
    property bool whetherAllowedClick: true
    property bool disabledButton: true;//禁用按钮
    property int currentPage: 0;//当前页
    property int  totalPage: 0;    //总页数
    property bool disableAnswer: true;//显示答案解析
    property bool disableCorrec: true;//显示批改
    property bool answerIsOpen: false;
    property bool modifyIsOpen: false;

    //跳转页面
    signal sigJumpPage(int pages, bool isPrevOrNext);

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
            prePageImage.source =  "qrc:/redPackge/syy1.png";
            nextPageImage.source =  "qrc:/redPackge/xyy1.png";
        }else {
            prePageImage.source =  "qrc:/redPackge/syy2.png";
            nextPageImage.source =  "qrc:/redPackge/xyy2.png";

        }
    }


    //主体窗口
    Row {
        id: pageView
        z: 2
        visible: currentUserRole == 0 ? true : false
        width: 240 * widthRate
        height: 54 * heightRate
        anchors.centerIn: parent
        //减一页
        MouseArea {
            id: addPageButton
            width: parent.height
            height: parent.height
            hoverEnabled: true
            enabled: disabledButton
            cursorShape: Qt.PointingHandCursor

            Image {
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/classImage/but_notify_cut_pressed.png" : "qrc:/classImage/but_notify_cut_normal.png"
            }

            onClicked: {
                disabledButton = false;
                disabledBtnTimer.restart();
                sigRecoverPage();
                sigRemoverPage();
            }
        }
        //加一页
        MouseArea {
            id: lessPageButton
            width: parent.height
            height: parent.height
            hoverEnabled: true
            enabled: disabledButton
            cursorShape: Qt.PointingHandCursor

            Image {
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/classImage/but_notify_plus_pressed.png" : "qrc:/classImage/but_notify_plus_normal.png"
            }

            onClicked: {
                disabledButton = false;
                disabledBtnTimer.restart();
                sigRecoverPage();
                sigAddPage();
            }
        }

        //上一页按钮
        MouseArea {
            id:prePage
            width: parent.height
            height: parent.height
            hoverEnabled: true
            enabled:  currentPage ==1 ? false : disabledButton ?  true : false
            cursorShape: Qt.PointingHandCursor
            z:5

            Image {
                id: prePageImage
                anchors.fill: parent
                source: parent.containsMouse ? "qrc:/classImage/but_notify_back_pressed.png" : "qrc:/classImage/but_notify_back_normal.png"
            }

            onReleased: {
                sigRecoverPage();
                sigPrePage();
                if(whetherAllowedClick ) {
                    if(currentPage - 2 < 0) {
                        sigJumpPage(0, true);
                    }
                    else {
                        sigJumpPage(currentPage - 2, true);
                    }
                }
                if(currentPage - 1 <= 0){
                    sigTipPage("onePage")
                }
                disabledButton = false;
                disabledBtnTimer.restart();
            }
        }

        //当前页按钮 /总页数
        Item{
            id:pageNum
            width: currentpageNum.width + totalPageNum.width
            height: parent.height
            z:5
            Text{
                id:currentpageNum
                font.pixelSize: 22 * heightRate
                wrapMode:Text.WordWrap
                font.family: Cfg.DEFAULT_FONT
                color:"#ffffff"
                text:currentPage.toString()
                anchors.verticalCenter: parent.verticalCenter
            }

            Text{
                id:totalPageNum
                anchors.left: currentpageNum.right
                anchors.leftMargin: 6 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 22 * heightRate
                font.family: Cfg.DEFAULT_FONT
                color: "#ffffff"
                text:"/ " + totalPage.toString()
            }
        }

        //下一页按钮
        MouseArea{
            id:nextPage
            width: parent.height
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: currentPage == totalPage ? false : disabledButton ? true : false
            z:5

            Image {
                id: nextPageImage
                anchors.fill: parent
                source: parent.containsMouse ?  "qrc:/classImage/but_notify_go_pressed.png" : "qrc:/classImage/but_notify_go_normal.png"
            }

            onReleased: {
                sigRecoverPage();
                sigNext();
                if(whetherAllowedClick ) {
                    if(currentPage  > totalPage) {
                        sigJumpPage(totalPage, true);
                    }else {
                        sigJumpPage(currentPage, true);
                    }
                }
                if(currentPage == totalPage){
                    sigTipPage("lastPage");
                }
                disabledButton = false;
                disabledBtnTimer.restart();
            }

        }

        //输入信息
        Rectangle{
            id:inputNum
            width: 124 * heightRate
            height: 36 * heightRate
            color: "transparent"
            border.width: 1
            border.color: "#686b7f"
            radius: 6 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            visible: false

            TextField{
                id:pageNumInput
                width: parent.width * 0.5
                height: parent.height
                font.pixelSize: 22 * heightRate
                selectByMouse:true
                enabled:  disabledButton
                color:"#ffffff"
                font.family: Cfg.DEFAULT_FONT
                validator: IntValidator{bottom: 1;top: totalPage}//RegExpValidator {regExp: /^[0-9]*$/}
                text: currentPage.toString()
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                Keys.enabled:  true
                background: Rectangle{
                    radius: 6 * heightRate
                    color: "#686b7f"
                }

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
                    sigJumpPage(nums1 - 1, false);
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

            //跳转按钮
            MouseArea {
                id:jumpBtn
                width: parent.width * 0.5
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                hoverEnabled: true
                enabled: disabledButton
                anchors.left: pageNumInput.right
                cursorShape: Qt.PointingHandCursor
                z: 5

                Image{
                    anchors.fill: parent
                    source: "qrc:/redPackge/tz1.png"
                }

                onReleased: {
                    sigRecoverPage();
                    if(whetherAllowedClick ) {
                        var nums1 = parseInt(pageNumInput.text);
                        var nums2 = parseInt(pageNumInput.text.replace("/","") );
                        if(nums1 <= 0) {
                            nums1 = 1;
                        }else if(nums1 >= nums2) {
                            nums1 = nums2 ;
                        }
                        currentPage = nums1;
                        if(currentPage - 1 < 0) {
                            sigJumpPage(0, false);
                        }else {
                            if(currentPage > totalPage) {
                                sigJumpPage(totalPage - 1, false);
                            }else {
                                sigJumpPage(currentPage - 1, false);
                            }
                        }
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

            }
        }

    }

    MouseArea {
        anchors.fill: parent
        z:1
        onClicked: {
            bottomToolbars.focus = true;
        }
    }


    Keys.enabled: true    
    Keys.onReleased: {
        if(event.key == Qt.Key_Up){
            if(whetherAllowedClick ) {
                if(currentPage - 2 < 0) {
                    sigJumpPage(0);
                }else {
                    sigJumpPage(currentPage - 2);
                }

            }else {
                applyPage();
            }
        }else {
            if(event.key == Qt.Key_Down) {
                if(whetherAllowedClick ) {
                    if(currentPage  > totalPage) {
                        sigJumpPage(totalPage );
                    }else {
                        sigJumpPage(currentPage);
                    }

                }else {
                    applyPage();
                }
            }
        }
        event.accepted = true;
    }

    function updatePrePage(){
        sigRecoverPage();
        if(whetherAllowedClick ) {
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

