import QtQuick 2.0
import "./Configuuration.js" as Cfg

/*
*批改、答题解析导航栏
*/

Item {
    signal sigModify();//批改信号
    signal sigAnswer();//答题信号
    signal sigFullScreen();//全屏信号

    property int currentPage: 0;    //当前页
    property int totalPage: 0;    //总页数
    signal sigPage(var status)//pre:上一题、next:下一题
    signal sigJumpPage(int pages);    //跳转页面
    signal sigAddPage();//加一页
    signal sigRemoverPage();//删除一页
    signal sigRecoverPage(); //收回分页权限

    //分页
    Rectangle {
        id: pageView
        width: 240 * widthRate
        height: 45 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 6 * widthRate
        border.width: 1
        border.color: "#ABABAD"
        color: "white"

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
                    sigRecoverPage();
                    sigRemoverPage();
                }
            }
        }

        //上一页按钮
        MouseArea{
            id:prePage
            anchors.left: addPageView.right
            width: 10 * widthRates
            height: 20 * heightRates
            anchors.leftMargin:  15  * widthRates  //30
            hoverEnabled: true
            anchors.verticalCenter: parent.verticalCenter
            //enabled:  currentPage == 1 ? false : true
            cursorShape: Qt.PointingHandCursor
            z:5

            Image {
                id: prePageImage
                width: 6 * widthRates
                height: 10 * heightRates
                anchors.centerIn: parent
                source: parent.containsMouse ? "qrc:/images/previous_sedtwox.png" :  "qrc:/images/previoustwox.png"
            }

            onClicked: {
                sigRecoverPage();
                if(currentPage - 1== 0){
                    currentPage = 1;
                }else{
                     currentPage--;
                }
                sigPage("pre");
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
            //enabled: currentPage == totalPage ? false :  true
            z:5
            Image {
                id: nextPageImage
                width: 6* widthRates
                height: 10* heightRates
                anchors.centerIn: parent
                source: parent.containsMouse ?  "qrc:/images/next_sedtwox.png" : "qrc:/images/nexttwox.png"
            }

            onClicked: {
                sigRecoverPage();
                sigPage("next");
                if(currentPage + 1 > totalPage){
                    currentPage  = totalPage;
                }else{
                    currentPage++;
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
            z: 5
            Text {
                id: jumpBtnName
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 14 * heightRates
                font.family: "Microsoft YaHei"
                color: parent.containsMouse ?  "#ff5000" :  "#aaaaaa"
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
            }

        }
    }

    //全屏
    MouseArea{
        hoverEnabled: true
        width: 60 * heightRate
        height: 60 * heightRate
        anchors.left: pageView.right
        anchors.leftMargin:  10 * widthRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12 * heightRate
        cursorShape: Qt.PointingHandCursor

        Image{
            anchors.fill: parent
            source: parent.containsMouse ? "qrc:/images/fullscreen@2x.png" : "qrc:/images/fullscreentwox.png"
        }

        onClicked: {
            sigFullScreen();
        }
    }

    //批改、答案解析
    Row{
        id: pageItem
        width: 300 * heightRate
        height: 45 * heightRate
        visible: isHomework == 1 || isHomework == 3 ? true : false
        anchors.right: parent.right
        anchors.rightMargin: 80 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -8 * widthRates
        spacing: 5 * heightRate

        MouseArea{
            hoverEnabled: true
            width: 258 * heightRate * 0.4
            height: 108 * heightRate * 0.4
            cursorShape: Qt.PointingHandCursor

            Image{
                anchors.fill: parent
                source: "qrc:/newStyleImg/pigai@2x.png"
                //source: parent.containsMouse ? "qrc:/cloudImage/btn_sd_pigai_Sed@2x.png" : "qrc:/cloudImage/btn_sd_pigai@2x.png"
            }

            onClicked: {
                sigModify();
            }
        }

        MouseArea{
            hoverEnabled: true
            width: 322 * heightRate * 0.4
            height: 108 * heightRate * 0.4
            cursorShape: Qt.PointingHandCursor

            Image{
                anchors.fill: parent
                source: "qrc:/newStyleImg/daanjiexi@2x.png"//parent.containsMouse ? "qrc:/cloudImage/btn_daanjiexi_sed@2x.png" : "qrc:/cloudImage/btn_daanjiexi@2x.png"
            }

            onClicked: {
                sigAnswer();
            }
        }

    }

}

