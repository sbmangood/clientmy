import QtQuick 2.0
import QtQuick.Controls 2.0
import "Configuration.js" as Cfg

Popup {
    id: exitMouseArea
    width: 90 * widthRate
    height: 2 * 46 * heightRate

    signal exitConfirm();
    signal showDeviceTestWidget();//显示测试设备信号
    signal showWorkOrderView();//显示工单信号

    background: Image{
        anchors.fill: parent
        source: "qrc:/images/accountMa.png"
        fillMode: Image.Stretch
    }
    Column
    {
        anchors.fill: parent
        spacing: 4 * heightRate

        MouseArea{
            hoverEnabled: true
            width: parent.width
            height: 30 * heightRate
            cursorShape: Qt.PointingHandCursor
            Text{
                text: "设备检测"
                color: parent.containsMouse ? "#ff5000" : "#222222"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 8 * heightRate
                verticalAlignment: Text.AlignVCenter
                font.family: Cfg.SETTING_FAMILY
                font.pixelSize: Cfg.SETTING_FONTSIZE * heightRate
            }

            onClicked: {
                showDeviceTestWidget();
            }

            onReleased:
            {
                exitMouseArea.visible = false;
            }
        }

        /*
        MouseArea{
            hoverEnabled: true
            width: parent.width
            height: 30 * heightRate
            cursorShape: Qt.PointingHandCursor
            Text{
                text: "我的工单"
                color: parent.containsMouse ? "#ff5000" : "#222222"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 8 * heightRate
                verticalAlignment: Text.AlignVCenter
                font.family: Cfg.SETTING_FAMILY
                font.pixelSize: Cfg.SETTING_FONTSIZE * heightRate
            }

            onClicked: {
                showWorkOrderView();
                exitMouseArea.close();
            }
            onReleased:
            {
                exitMouseArea.visible = false;
            }
        }
        */

        MouseArea{
            hoverEnabled: true
            width: parent.width
            height: 30 * heightRate
            cursorShape: Qt.PointingHandCursor
            Text{
                id: exitText
                text: "退出登录"
                color: parent.containsMouse ? "#ff5000" : "#222222"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 8 * heightRate
                verticalAlignment: Text.AlignVCenter
                font.family: Cfg.SETTING_FAMILY
                font.pixelSize: Cfg.SETTING_FONTSIZE * heightRate
            }

            onClicked: {
                exitConfirm();
                exitMouseArea.close();
            }
            onReleased:
            {
                exitMouseArea.visible = false;
            }
        }
    }

}

