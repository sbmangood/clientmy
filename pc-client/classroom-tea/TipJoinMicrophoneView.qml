import QtQuick 2.0
import QtQuick.Controls 2.0
import "./Configuuration.js" as Cfg

/*
* 连接上麦页面
*/

Item {
    width: 170 * heightRate
    height: 80 * heightRate

    property bool disableButton: false;

    signal sigJoinMicrophone();//上麦信号


    MouseArea{
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        enabled: disableButton

        Image{
            anchors.fill: parent
            source: "qrc:/images/th_pt_btn_microphone_on.png"
        }

        onClicked: {
            sigJoinMicrophone();
        }

    }
}
