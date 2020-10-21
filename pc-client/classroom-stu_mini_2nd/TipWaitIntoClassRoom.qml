import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

/*
 *等待进入教室画面
 */
Item {
    id:tipWaitIntoClassRoom

    property double widthRates: tipWaitIntoClassRoom.width / 240.0
    property double heightRates: tipWaitIntoClassRoom.height / 153.0
    property double ratesRates: tipWaitIntoClassRoom.widthRates > tipWaitIntoClassRoom.heightRates? tipWaitIntoClassRoom.heightRates : tipWaitIntoClassRoom.widthRates
    property string tagNameContent: "进入教室中…"

    //关闭界面
    signal sigCloseAllWidget();

    AnimatedImage {
        id: duduImg
        width: 180 * heightRate
        height: 218 * heightRate
        anchors.centerIn: parent
        source: "qrc:/miniClassImage/dudumouse.gif"
    }

    Text {
        id: tagName
        anchors.top: duduImg.bottom
        anchors.topMargin: 10 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: (parent.width - width) * 0.5 + 35 * heightRate
        font.pixelSize: 25 * heightRate
        font.family: "Microsoft YaHei"
        color: "#ffffff"
        text: tagNameContent
    }
}
