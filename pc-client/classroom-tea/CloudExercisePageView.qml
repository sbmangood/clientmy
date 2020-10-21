import QtQuick 2.0
import "./Configuuration.js" as Cfg

/*
*开始练习、已练题目、上一题、下一题
*/

Item {
    width: parent.width

    property bool isVisibleStartButton: false;//是否显示开始练习
    property bool isStartMake: false;//是否开始练习标记
    property bool isVisiblePage: false;//是否显示分页

    property int currentPage: 0;    //当前页
    property int totalPage: 0;    //总页数
    property bool disabledButton: true;//禁用按钮

    signal sigTipPage(string message); //最后一页信号
    signal sigStartExercise(var status);//true开始练习 false停止练习
    signal sigPage(string status,var pages)//pre:上一题、next:下一题
    signal sigJumpPage(int pages);//跳转页面
    signal sigRecoverPage();  //收回分页权限


    Timer{
        id: disabledBtnTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            disabledButton = true;
        }
    }

    Rectangle {
        id: bottomView
        visible: isVisiblePage
        width: 469 * heightRates / 1.3
        height: 44 * heightRates / 1.3
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"

        Image {
            anchors.fill: parent
            source: "qrc:/newStyleImg/btmbar@2x.png"
        }


        Rectangle{
            id: addPageView
            width: 50 * widthRates
            height: 20 * heightRates
            color: "transparent"
            radius: 10 * heightRates
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin:  20  * widthRates

            //加一页
            MouseArea{
                id: addPageButton
                width: 20 * widthRates
                height: width
                hoverEnabled: true
                enabled: false
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
            }

            //减一页
            MouseArea{
                id: lessPageButton
                width: 20 * widthRates
                height: width
                hoverEnabled: true
                enabled: false
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
            }

        }

        //上一页按钮
        MouseArea{
            id:prePage
            width: 10 * widthRates
            height: 20 * heightRates
            anchors.left:addPageView.right
            anchors.leftMargin:  28  * widthRates
            hoverEnabled: true
            anchors.verticalCenter: parent.verticalCenter
            enabled:  currentPage == 1 ? false : disabledButton ?  true : false
            cursorShape: Qt.PointingHandCursor
            z: 5

            Image {
                id: prePageImage
                width: 9 * heightRates
                height: 15 * heightRates
                anchors.centerIn: parent
                source: parent.containsMouse ? "qrc:/images/previous_sedtwox.png"  : "qrc:/images/previoustwox.png"
            }

            onClicked: {
                sigRecoverPage();
                if(currentPage - 2 < 0) {
                    sigPage("pre",0);
                }else {
                    sigPage("pre",currentPage - 2);
                }
                if(currentPage - 1 <= 0){
                    sigTipPage("onePage")
                }
                disabledButton = false;
                disabledBtnTimer.restart();
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
                text: currentPage.toString()
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
                text:"/ " + totalPage.toString()
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
                source: parent.containsMouse ?  "qrc:/images/next_sedtwox.png" :  "qrc:/images/nexttwox.png"
            }

            onClicked: {
                sigRecoverPage();
                console.log("===============",currentPage)
                if(currentPage  > totalPage) {
                    sigPage("next",totalPage );
                }else {
                    sigPage("next",currentPage);
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
            z: 5
            Text {
                id: jumpBtnName
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 11 * heightRates
                font.family: "Microsoft YaHei"
                color: parent.containsMouse ?  "#ff5000" :  "white"
                text: qsTr("跳转")
            }

            onClicked: {
                sigRecoverPage();
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

    //开始练习
    MouseArea{
        width: 120 * heightRate * 0.78
        height: 44 * heightRate * 0.78
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2 * widthRates
        anchors.left: bottomView.right
        anchors.leftMargin: isStartMake ? -220 * heightRate : 155 * heightRate
        cursorShape: Qt.PointingHandCursor
        visible: isStartLesson ?( currentIsAuditionLesson ? (isVisibleStartButton && "T" == teacherType): isVisibleStartButton) : false
        enabled: disabledButton
        Rectangle{
            anchors.fill: parent
            color: "#ffffff"
            radius: 16 * widthRate
            border.width: 1
            border.color: "#C9C9C9"
        }

        Text {
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 13 * heightRate
            text: isStartMake ? qsTr("停止练习") : qsTr("开始练习")
            color: "#ff5000"
            anchors.centerIn: parent
        }

        onClicked: {
            if(isStartMake == false){
                sigStartExercise(true);
                isStartMake = true;
            }else{
                sigStartExercise(false);
                isStartMake = false;
            }
        }
    }

}
