import QtQuick 2.7
import QtQuick.Controls 2.0
import "./Configuration.js" as Cfg
/*
* 底部工具栏
*/
Rectangle {
    id:bottomToolbars1
    color: "#363744"
    width: parent.width
    height: parent.height

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
    signal sigCMVJumpPage(int pages, bool isPrevOrNext);

    signal sigCMVPrePage();
    signal sigCMVNext();

    //申请翻页
    signal applyCMVPage();

    //收回分页权限
    signal sigCMVRecoverPage();

    //删除分页
    signal sigCMVRemoverPage();

    //添加分页
    signal sigCMVAddPage();

    //最后一页信号
    signal sigCMVTipPage(string message);

    Timer {
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

    // 上下页按钮
    Item {
        width: 89 * widthRate
        height: 26 * heightRate
        z: 10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        visible: currentUserRole == 0 ? true : false
        //上一页按钮
        Item {
            width: 26 * widthRate
            height: 26 * heightRate
            anchors.left: parent.left
            Image {
                id: prePageImage
                anchors.fill: parent
                source: whetherAllowedClick ?  "qrc:/redPackge/syy1.png" : "qrc:/redPackge/syy2.png"
            }
            MouseArea {
                id: prePage
                anchors.fill: parent
                hoverEnabled: true
                enabled:  currentPage ==1 ? false : disabledButton ?  true : false
                cursorShape: Qt.PointingHandCursor

                onReleased: {
                    sigCMVRecoverPage();
                    sigCMVPrePage();
                    if(whetherAllowedClick ) {
                        if(currentPage - 2 < 0) {
                            sigCMVJumpPage(0, true);
                        }
                        else {
                            sigCMVJumpPage(currentPage - 2, true);
                        }
                    }
                    if(currentPage - 1 <= 0){
                        sigCMVTipPage("onePage")
                    }
                    disabledButton = false;
                    disabledBtnTimer.restart();
                }
            }
        }

        // 下一页按钮
        Item {
            width: 26 * widthRate
            height: 26 * heightRate
            anchors.right: parent.right
            Image {
                id: nextPageImage
                anchors.fill: parent
                source:whetherAllowedClick ?  "qrc:/redPackge/xyy1.png" : "qrc:/redPackge/xyy2.png"
            }
            MouseArea {
                id: nextPage
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                enabled: currentPage == totalPage ? false : disabledButton ? true : false
                onReleased: {
                    sigCMVRecoverPage();
                    sigCMVNext();
                    if(whetherAllowedClick ) {
                        if(currentPage  > totalPage) {
                            sigCMVJumpPage(totalPage, true);
                        }else {
                            sigCMVJumpPage(currentPage, true);
                        }
                    }
                    if(currentPage == totalPage){
                        sigCMVTipPage("lastPage");
                    }
                    disabledButton = false;
                    disabledBtnTimer.restart();
                }
            }
        }
    }

    // 当前页/总页数
    Item {
        id:pageNum
        width: 32 * widthRate
        height: 14 * heightRate
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        z:5
        Text{
            id:currentpageNum
            anchors.fill: parent
            font.pixelSize: 14 * heightRate
            wrapMode: Text.WordWrap
            font.family: Cfg.DEFAULT_FONT
            color:"#ffffff"
            text: currentPage.toString() + "/" + totalPage.toString()
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
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
                    sigCMVJumpPage(0);
                }else {
                    sigCMVJumpPage(currentPage - 2);
                }

            }else {
                applyCMVPage();
            }
        }else {
            if(event.key == Qt.Key_Down) {
                if(whetherAllowedClick ) {
                    if(currentPage  > totalPage) {
                        sigCMVJumpPage(totalPage );
                    }else {
                        sigCMVJumpPage(currentPage);
                    }

                }else {
                    applyCMVPage();
                }
            }
        }
        event.accepted = true;
    }

    function updatePrePage(){
        sigCMVRecoverPage();
        if(whetherAllowedClick ) {
            if(currentPage - 2 < 0) {
                sigCMVJumpPage(0);
            }else {
                sigCMVJumpPage(currentPage - 2);
            }
        }
        if(currentPage - 1 <= 0){
            sigCMVTipPage("onePage")
        }
        disabledButton = false;
        disabledBtnTimer.restart();
    }

    function updateNextPage(){
        sigCMVRecoverPage();
        if(whetherAllowedClick ) {
            if(currentPage  > totalPage) {
                sigCMVJumpPage(totalPage );
            }else {
                sigCMVJumpPage(currentPage);
            }
        }
        if(currentPage == totalPage){
            sigCMVTipPage("lastPage");
        }
        disabledButton = false;
        disabledBtnTimer.restart();
    }
}

