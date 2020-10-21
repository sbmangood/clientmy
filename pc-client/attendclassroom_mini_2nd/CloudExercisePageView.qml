import QtQuick 2.0
import "Configuration.js" as Cfg

/*
*开始练习、已练题目、上一题、下一题
*/

Item {
    width: parent.width
    height: 80 * heightRate

    property bool isVisibleStartButton: false;//是否显示开始练习
    property bool isStartMake: false;//是否开始练习标记
    property bool isVisiblePage: false;//是否显示分页

    property int currentPage: 0;    //当前页
    property int totalPage: 0;    //总页数

    signal sigStartExercise(var status);//true开始练习 false停止练习
    signal sigPage(string status)//pre:上一题、next:下一题
    signal sigJumpPage(int pages);    //跳转页面



    //开始练习
    MouseArea{
        width: 200 * heightRate
        height: 45 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        cursorShape: Qt.PointingHandCursor
visible: false
        Rectangle{
            anchors.fill: parent
            color: "#ff5000"
            radius: 50
        }

        Text {
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * heightRate
            text: isStartMake ? "停止练习" : qsTr("开始练习")
            color: "#ffffff"
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

    Rectangle {
        visible: isVisiblePage
        width: 200 * widthRate
        height: 45 * heightRate
//        anchors.bottom: parent.bottom
//        anchors.bottomMargin: 20 * heightRate
//        anchors.right: parent.right
        anchors.centerIn: parent

        radius: 6 * widthRate
        border.width: 1
        border.color: "#ABABAD"
        color: "white"

        //上一页按钮
        MouseArea{
            id:prePage
            anchors.left: parent.left
            width: 10 * widthRate
            height: 20 * heightRate
            anchors.leftMargin:  15  * widthRate  //30
            hoverEnabled: true
            anchors.verticalCenter: parent.verticalCenter
            //enabled:  currentPage == 1 ? false : true
            cursorShape: Qt.PointingHandCursor
            z:5

            Image {
                id: prePageImage
                width: 6 * widthRate
                height: 10 * heightRate
                anchors.centerIn: parent
                source: parent.containsMouse ? "qrc:/images/previous_sedtwox.png"  : "qrc:/images/previoustwox.png"
            }

            onClicked: {

                sigPage("pre");
            }

        }

        //当前页按钮
        Item{
            id:pageNum
            anchors.left:prePage.right
            width: 30 * widthRate
            height: 16 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            z:5
            Text{
                id:currentpageNum
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 14 * heightRate
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
            width: 35 * widthRate
            height: 16 * heightRate
            anchors.leftMargin:  0 * widthRate
            anchors.verticalCenter: parent.verticalCenter
            z:5
            Text{
                id:totalPageNum
                anchors.fill: parent
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 14 * heightRate
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
            width: 12 * widthRate
            height: 20 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            //enabled: currentPage == totalPage ? false :  true
            z:5
            Image {
                id: nextPageImage
                width: 6* widthRate
                height: 10* heightRate
                anchors.centerIn: parent
                source: parent.containsMouse ?  "qrc:/images/next_sedtwox.png" :  "qrc:/images/nexttwox.png"
            }

            onClicked: {
                sigPage("next");                
            }
        }

        //输入信息
        Rectangle{
            id:inputNum
            anchors.left:nextPage.right
            width: 50 * widthRate
            height: 20 * heightRate
            anchors.leftMargin: 15  * widthRate
            anchors.verticalCenter: parent.verticalCenter
            color: "#e6e6e6"
            radius: inputNum.height / 2
            z: 5
            TextInput{
                id:pageNumInput
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 14 * heightRate
                selectByMouse:true
                color:"#666666"  //666666 3c3c3e
                font.family: "Microsoft YaHei"
                validator: IntValidator{bottom: 1;top: totalPage}//RegExpValidator {regExp: /^[0-9]*$/}
                text: currentPage.toString()

                Keys.enabled:  true

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
        MouseArea{
            id:jumpBtn
            anchors.left:inputNum.right
            width: 28 * widthRate
            height: 14 * heightRate
            anchors.leftMargin: 8  * widthRate
            anchors.verticalCenter: parent.verticalCenter
            hoverEnabled: true
            z: 5
            Text {
                id: jumpBtnName
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 14 * heightRate
                font.family: "Microsoft YaHei"
                color: parent.containsMouse ?  "#ff5000" :  "#aaaaaa"
                text: qsTr("跳转")
            }

            onClicked: {
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

    function prePage()
    {
        if(currentPage - 1== 0){
            currentPage = 1;
        }else{
             currentPage--;
        }
    }

    function nextPage()
    {
        if(currentPage + 1 > totalPage){
            currentPage  = totalPage;
        }else{
            currentPage++;
        }
    }
}
