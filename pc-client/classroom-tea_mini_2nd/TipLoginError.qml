import QtQuick 2.7


/*
 *登录错误
 */
Rectangle {
    id:tipLoginError

    color: "white"
    property double widthRates: tipLoginError.width / 240.0
    property double heightRates: tipLoginError.height / 172.0
    property double ratesRates: tipLoginError.widthRates > tipLoginError.heightRates? tipLoginError.heightRates : tipLoginError.widthRates
    property string tagNameContent: ""


    radius: 10 * ratesRates
    clip: true

    //退出教室
    signal sigCloseAllWidget();

    Image{
        id: imgBackgund
        width: 120 * heightRates
        height: 90 * heightRates
        anchors.top: parent.top
        anchors.topMargin: 10 * heightRate
        source: "qrc:/images/yanzhengcuowu@3x.png"
        anchors.horizontalCenter: parent.horizontalCenter
    }

    /*Text {
        id: tagName
        width: 192 * tipLoginError.widthRates
        height: 40 * tipLoginError.heightRates
        anchors.left: parent.left
        anchors.top: parent.top
        font.pixelSize: 18 * tipLoginError.ratesRates
        anchors.leftMargin: 25 * tipLoginError.widthRates
        anchors.topMargin: 20 * tipLoginError.heightRates
        color: "#222222"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        text: qsTr("用户名密码错误")+ tagNameContent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }*/


    Text {
        id: contentName
        width: 200 * tipLoginError.widthRates
        height: 34 * tipLoginError.heightRates
        anchors.left: parent.left
        anchors.top: imgBackgund.bottom
        font.pixelSize: 14 * tipLoginError.ratesRates
        anchors.leftMargin: 20 * tipLoginError.widthRates
        color: "#999999"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        text: qsTr("验证错误，请重新登录")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Rectangle{
        id:okBtn
        width:  200  *  tipLoginError.widthRates
        height:  40 * heightRate
        color: "#ff5000"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
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
            text: qsTr("确定")
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

