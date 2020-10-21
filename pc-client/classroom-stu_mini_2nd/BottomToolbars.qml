import QtQuick 2.7
import QtGraphicalEffects 1.0
/*
  * 底部工具栏
  */

Rectangle {
    id:bottomToolbars

    property double widthRates: fullWidths / 1440.0
    property double heightRates: fullHeights / 900.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    // radius: bottomToolbars.height / 2

    //是否允许点击
    property bool whetherAllowedClick: true

    //当前页
    property int currentPage: 0

    //总页数
    property int  totalPage: 0

    color: "#00000000"

    //跳转页面
    signal sigJumpPage(int pages);

    //申请翻页
    signal applyPage();
    //最后一页信号
    signal atLastPage();
    //第一页信号
    signal atFirstPage();

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
    Rectangle{

    }

    Image {
        id:background
        width: parent.width
        height: parent.height
        anchors.left: parent.left
        anchors.top: parent.top
        source: "qrc:/images/bar_bottomtwo.png"
    }

    //主体窗口
    Item {
        id: container;
        anchors.centerIn: parent;
        //        anchors.left: parent.left
        //        anchors.top: parent.top
        //        anchors.leftMargin: 20 * widthRates;
        //        anchors.topMargin:  20 * heightRates;
        //        width: 220  * widthRates;
        //        height: 40 * heightRates;
        width: parent.width;
        height: parent.height;
        z:2

        Rectangle {
            id: mainRect
            width: container.width   //- ( 2*rectShadow.radius);
            height: container.height  // - ( 2*rectShadow.radius);

            color: "#00000000"
            //   radius:rectShadow.radius;
            anchors.centerIn: parent;
            z:3
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    bottomToolbars.focus = true;
                }
            }

            //上一页按钮
            Rectangle{
                id:prePage
                anchors.left:parent.left
                anchors.top: parent.top
                width: 12 * widthRates
                height: 20 * heightRates
                anchors.topMargin: 10 * heightRates
                anchors.leftMargin:  15  * widthRates  //30
                color: "#00000000"
                z:5
                enabled: curriculumData.getCurrentUserType() != "B" ? true : false
                Image {
                    id: prePageImage
                    anchors.right:  parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 5 * heightRates
                    width: 6* widthRates
                    height: 10* heightRates
                    source:whetherAllowedClick ?  "qrc:/images/previoustwox.png" : "qrc:/images/previous_nonetwox.png"
                }




                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onPressed: {
                        bottomToolbars.focus = true;
                        if(whetherAllowedClick ) {
                            prePageImage.source =  "qrc:/images/previous_sedtwox.png";
                        }else {
                            prePageImage.source =  "qrc:/images/previous_nonetwox.png";

                        }

                    }
                    onReleased: {
                        if(whetherAllowedClick ) {
                            prePageImage.source =  "qrc:/images/previoustwox.png";
                            if(currentPage - 2 < 0) {
                                sigJumpPage(0);
                            }else {
                                sigJumpPage(currentPage - 2);
                            }

                            if( currentPage == 1 )
                            {
                                atFirstPage();
                            }
                        }else {
                            prePageImage.source =  "qrc:/images/previous_nonetwox.png";
                            applyPage();
                        }

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

            }


            //当前页按钮
            Rectangle{
                id:pageNum
                anchors.left:prePage.right
                anchors.top: parent.top
                width: 35 * widthRates
                height: 16 * heightRates
                anchors.topMargin: 12 * heightRates
                anchors.leftMargin:  0 * widthRates
                color: "#00000000"
                z:5
                Text{
                    id:currentpageNum
                    width: parent.width
                    height: parent.height
                    anchors.left: parent.left
                    anchors.top: parent.top
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14 * heightRates
                    wrapMode:Text.WordWrap
                    font.family: "Microsoft YaHei"
                    color:"#666666"
                    text:currentPage.toString()

                }
            }

            //当全部的页数按钮
            Rectangle{
                id:totalPages
                anchors.left:pageNum.right
                anchors.top: parent.top
                width: 35 * widthRates
                height: 16 * heightRates
                anchors.topMargin: 12 * heightRates
                anchors.leftMargin:  0 * widthRates
                color: "#00000000"
                z:5
                Text{
                    id:totalPageNum
                    width: parent.width
                    height: parent.height
                    anchors.left: parent.left
                    anchors.top: parent.top
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14 * heightRates
                    wrapMode:Text.WordWrap
                    font.family: "Microsoft YaHei"
                    color: "#666666"
                    text:"/" + totalPage.toString()

                }
            }



            //下一页按钮
            Rectangle{
                id:nextPage
                anchors.left:totalPages.right
                anchors.top: parent.top
                width: 12 * widthRates
                height: 20 * heightRates
                anchors.topMargin: 10 * heightRates
                anchors.leftMargin:  0 * widthRates
                color: "#00000000"
                z:5
                enabled: curriculumData.getCurrentUserType() != "B" ? true : false
                Image {
                    id: nextPageImage
                    anchors.left:   parent.left
                    anchors.top: parent.top
                    anchors.topMargin: 5 * heightRates
                    width: 6* widthRates
                    height: 10* heightRates
                    source:whetherAllowedClick ?  "qrc:/images/nexttwox.png" : "qrc:/images/next_nonetwox.png"
                }


                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onPressed: {
                        bottomToolbars.focus = true;
                        if(whetherAllowedClick ) {
                            nextPageImage.source =  "qrc:/images/next_sedtwox.png";
                        }else {
                            nextPageImage.source =  "qrc:/images/next_nonetwox.png";

                        }

                    }
                    onReleased: {
                        if(whetherAllowedClick ) {
                            nextPageImage.source =  "qrc:/images/nexttwox.png";
                            if(currentPage  > totalPage) {
                                sigJumpPage(totalPage );
                            }else {
                                sigJumpPage(currentPage);
                            }
                            if(currentPage != 0 && currentPage == totalPage )
                            {
                                atLastPage();
                            }

                        }else {
                            nextPageImage.source =  "qrc:/images/next_nonetwox.png";
                            applyPage();
                        }

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

            }


            //输入信息
            Rectangle{
                id:inputNum
                anchors.left:nextPage.right
                anchors.top: parent.top
                width: 50 * widthRates
                height: 20 * heightRates
                anchors.topMargin:  10 * heightRates
                anchors.leftMargin: 15  * widthRates
                color: "#eeeeee"
                radius: inputNum.height / 2
                z:5
                enabled: curriculumData.getCurrentUserType() != "B" ? true : false
                TextInput{
                    id:pageNumInput
                    width: parent.width
                    height: parent.height
                    anchors.left: parent.left
                    anchors.top: parent.top
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14 * heightRates
                    selectByMouse:true
                    enabled: whetherAllowedClick
                    color:"#666666"  //666666 3c3c3e
                    font.family: "Microsoft YaHei"
                    //validator: RegExpValidator {regExp: /^[0-9]*$/}
                    validator: IntValidator{bottom: 1;top: totalPage}
                    text: currentPage.toString()

                    Keys.enabled: true

                    onAccepted:  {
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
            Rectangle{
                id:jumpBtn
                anchors.left:inputNum.right
                anchors.top: parent.top
                width: 28 * widthRates
                height: 14 * heightRates
                anchors.topMargin:  13 * heightRates
                anchors.leftMargin: 8  * widthRates
                color: "#00000000"
                z:5
                Text {
                    id: jumpBtnName
                    width: parent.width
                    height: parent.height
                    anchors.left: parent.left
                    anchors.top: parent.top
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14 * heightRates
                    // wrapMode:Text.WordWrap
                    font.family: "Microsoft YaHei"
                    color:whetherAllowedClick ?  "#333333" :  "#aaaaaa"
                    text: qsTr("跳转")
                }

                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onPressed: {
                        bottomToolbars.focus = true;
                        if(whetherAllowedClick ) {
                            jumpBtnName.color =  "#ff5000";
                        }else {
                            jumpBtnName.color =  "#aaaaaa";

                        }

                    }
                    onReleased: {

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
                            applyPage();
                        }

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
    }

    MouseArea{
        anchors.fill: parent
        z:1
        onClicked: {
            bottomToolbars.focus = true;
        }
    }


    Keys.enabled: true;

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

    function setPrePage()
    {
        if(whetherAllowedClick ) {
            prePageImage.source =  "qrc:/images/previoustwox.png";
            if(currentPage - 2 < 0) {
                sigJumpPage(0);
            }else {
                sigJumpPage(currentPage - 2);
            }

            if( currentPage == 1 )
            {
                atFirstPage();
            }
        }else {
            prePageImage.source =  "qrc:/images/previous_nonetwox.png";
            applyPage();
        }
    }

    function setNextPage()
    {
        if(whetherAllowedClick ) {
            nextPageImage.source =  "qrc:/images/nexttwox.png";
            if(currentPage  > totalPage) {
                sigJumpPage(totalPage );
            }else {
                sigJumpPage(currentPage);
            }
            if(currentPage != 0 && currentPage == totalPage )
            {
                atLastPage();
            }

        }else {
            nextPageImage.source =  "qrc:/images/next_nonetwox.png";
            applyPage();
        }
    }
    //绘制阴影
    //    DropShadow {
    //        id: rectShadow;
    //        anchors.fill: source
    //        cached: true;
    //        horizontalOffset: 0;
    //        verticalOffset: 0;
    //        radius: 20 * heightRates;
    //        samples: 16;
    //        color: "#80000000";
    //        smooth: true;
    //        source: container;
    //    }


}

