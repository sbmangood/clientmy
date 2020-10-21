import QtQuick 2.7

//提示框
Rectangle{
    property double widthRates: fullWidths / 1440.0
    property double heightRates: fullHeights / 900.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    id:toopBracund
    color: "#3C3C3E"
    opacity: 0.6
    width: 400 * widthRates
    height: 40 * heightRates
    z:20
    //    anchors.left: left
    //    anchors.bottom: bottom
    //    anchors.leftMargin:  width / 2 - 100 * widthRates
    //    anchors.bottomMargin: 100 * heightRates
    visible: false
    radius: 5 * heightRates
    onVisibleChanged: {
        toopBracundTimer.stop();
        if(visible){
            toopBracundTimer.start();
        }
    }

    Timer {
        id:toopBracundTimer
        interval: 3000;
        running: false;
        repeat: false
        onTriggered: {
            toopBracund.visible = false;
        }
    }
    Image {
        id: toopBracundImage
        anchors.top: parent.top
        anchors.left: parent.left
        width: 20 * ratesRates
        height: 20 * ratesRates
        anchors.leftMargin: 20 * heightRates
        anchors.topMargin:   20 * heightRates  - 10 * ratesRates
        source: "qrc:/images/progessbar_logo.png"
    }
    Text {
        id: toopBracundImageText
        width: 350 * ratesRates
        height: 20 * ratesRates
        anchors.left: toopBracundImage.right
        anchors.top: toopBracundImage.top
        font.pixelSize: 14 * ratesRates
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        color: "#ffffff"
        text: qsTr("")
    }


    //设置开始练习
    function setShowFirstPageTip(){
        toopBracund.visible = false;
        toopBracundImageText.text = qsTr("已经到第一页了")
        toopBracund.visible = false;
        toopBracund.visible = true;
    }

    //设置开始讲题
    function setShowLastPageTIp(){
        toopBracund.visible = false;
        toopBracundImageText.text = qsTr("已经到最后一页了")
        toopBracund.visible = false;
        toopBracund.visible = true;
    }    
    //no allow power
    function setNoPowerTip(){
        toopBracund.visible = false;
        toopBracundImageText.text = qsTr("旁听时不能操作哦")
        toopBracund.visible = false;
        toopBracund.visible = true;
    }

}
