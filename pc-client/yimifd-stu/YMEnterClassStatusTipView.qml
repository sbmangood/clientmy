import QtQuick 2.0
import "Configuration.js" as Cfg

//进入教室时的状态提醒弹窗 可进入 不可进入时的状态信息
Rectangle {
    property bool isStudentBeselect: true;
    id:mainBackGroundRectangle
    visible: true
    color:Qt.rgba(0,0,0,0.60)
    width: 280 * widthRate
    height:50 * heightRate
    radius: 10 * heightRate
    property string enterRoomTipsText: "还未开始上课，暂时无法旁听";

    Text {
        anchors.centerIn: parent
        text: enterRoomTipsText
        color:"white"
        font.family: Cfg.CLASSROOM_FAMILY
        font.pixelSize: (Cfg.CLASSROOM_FONTSIZE + 11) * heightRate
    }
    Timer{
        id: timer
        interval: 3000
        running: false
        repeat: false
        onTriggered: {
            parent.visible=false;
        }
    }

    function startTimer(text)
    {
        enterRoomTipsText=text;
        mainBackGroundRectangle.visible = true;
        timer.start();
        classView.visible=false;//隐藏进入教室弹窗
    }
}



