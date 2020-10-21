import QtQuick 2.7


/*
 *其他设备进入教室
 */
Rectangle {
    id:tipLoginError

    color: "white"
    border.color: "#e0e0e0"
    border.width: 1
    property double widthRates: tipLoginError.width / 240.0
    property double heightRates: tipLoginError.height / 172.0
    property double ratesRates: tipLoginError.widthRates > tipLoginError.heightRates? tipLoginError.heightRates : tipLoginError.widthRates
    property string tagNameContent: "获取讲义信息失败，请退出录播重新进入!"

    radius: 10 * ratesRates
    clip: true

    //退出教室
    signal sigCloseAllWidget();

    Text {
        id: tagName
        width: 192 * tipLoginError.widthRates
        height: 40 * tipLoginError.heightRates
        anchors.left: parent.left
        anchors.top: parent.top
        font.pixelSize: 18 * tipLoginError.ratesRates
        anchors.leftMargin: 25 * tipLoginError.widthRates
        anchors.topMargin: 30 * tipLoginError.heightRates
        color: "#222222"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        text: tagNameContent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Rectangle{
        id:okBtn
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin:  125 * tipLoginError.heightRates
        width:  160  *  tipLoginError.widthRates
        height:  32 * tipLoginError.heightRates
        color: "#ff5000"
        radius: 5 * tipLoginError.heightRates
        Text {
            id: okBtnName
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14  * tipLoginError.ratesRates
            color: "#ffffff"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            text: qsTr("知道了")
        }
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: {
                okBtn.color = "#c3c6c9";

            }
            onReleased: {
                okBtn.color = "#ff5000";
                Qt.quit();
            }
        }
    }


}

