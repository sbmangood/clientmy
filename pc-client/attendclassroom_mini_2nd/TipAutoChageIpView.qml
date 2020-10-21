import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

/*
 *自动切换Ip界面
 */
Item {
    id:tipWaitIntoClassRoom

    property string tagNameContent: "正在重新链接教室，请稍后……"

    //关闭界面
    signal sigCloseAllWidget();

    Image {
        id: duduImg
        width: 180 * heightRate
        height: 218 * heightRate
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        source: "qrc:/miniClassImage/dudumouse.gif"
    }
    Text {
        id: tagName
        anchors.left: parent.left
        anchors.leftMargin: (parent.width - width) * 0.5 + 35 * heightRate
        anchors.top: duduImg.bottom
        anchors.topMargin: 10 * heightRate
        font.pixelSize: 25 * heightRate
        font.family: "Microsoft YaHei"
        color: "#ffffff"
        text: tagNameContent
    }

    Timer {
        id:changeText
        interval: 3000;
        running: false;
        repeat: false;
        onTriggered:
        {
            tagNameContent = "连接失败，请退出后重新进入教室（3秒后自动退出教室）";
            cangeIpFailTimer.start();
        }
    }

    Timer {
        id:cangeIpFailTimer
        interval: 3000;
        running: false;
        repeat: false;
        onTriggered:
        {
            sigCloseAllWidget();
        }
    }

    function setAutoChangeIpFail(){
        //更改样式
        //启动定时器退出教室
        changeText.start();
    }

}
