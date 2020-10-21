import QtQuick 2.7


/*
 *其他设备进入教室
 */
Rectangle {
    id:tipLoginError

    color: "white"
    property double widthRates: tipLoginError.width / 240.0
    property double heightRates: tipLoginError.height / 172.0
    property double ratesRates: tipLoginError.widthRates > tipLoginError.heightRates? tipLoginError.heightRates : tipLoginError.widthRates
    property string tagNameContent: "当前账号在其他设备进入教室，您已被迫退出"

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


//    Text {
//        id: contentName
//        width: 200 * tipLoginError.widthRates
//        height: 34 * tipLoginError.heightRates
//        anchors.left: parent.left
//        anchors.top: parent.top
//        font.pixelSize: 12 * tipLoginError.ratesRates
//        anchors.leftMargin: 20 * tipLoginError.widthRates
//        anchors.topMargin: 71 * tipLoginError.heightRates
//        color: "#3c3c3e";
//        wrapMode:Text.WordWrap
//        font.family: "Microsoft YaHei"
//        text: qsTr("")
//        horizontalAlignment: Text.AlignHCenter
//        verticalAlignment: Text.AlignVCenter
//    }

    Rectangle{
        id:okBtn
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20 *  tipLoginError.widthRates
        anchors.topMargin:  125 * tipLoginError.heightRates
        width:  200  *  tipLoginError.widthRates
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
                sigCloseAllWidget();

            }
        }
    }


}

