import QtQuick 2.0
import "./Configuration.js" as Cfg

Item {
    width: parent.width
    height: parent.height

    signal sigClassDisconnect();

    Image{
        width: 490 * heightRate
        height: 200 * heightRate
        source: "qrc:/bigclassImage/disconnect.png"
        anchors.centerIn: parent


        MouseArea{
            width: 250 * heightRate
            height: 45 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20 * heightRate
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            Image {
                source: "qrc:/bigclassImage/button_pop_leave_normal.png"
                anchors.fill: parent
            }

            onClicked: {
                sigClassDisconnect();
            }
        }
    }

}
