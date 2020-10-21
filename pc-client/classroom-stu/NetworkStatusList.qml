import QtQuick 2.7

/*
 *网络状态列表
 */

Rectangle {
    id:networkStatusList


    property double widthRates: networkStatusList.width / 245.0
    property double heightRates: networkStatusList.height / 186.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates


    Rectangle{
        id:tagBakcGrond
        anchors.left: parent.left
        anchors.top: parent.top
        width: 100
        height: 30
        color:"#00000000"
        Text {
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: "Microsoft YaHei"
            text: qsTr("")
        }

    }

    //网络列表
    ListView{
        id:netWorkList
        width: parent.width
        height: parent.height - tagBakcGrond.height
        anchors.left: parent.left
        anchors.top: tagBakcGrond.bottom
        delegate:itemDelegate

    }

    Component{
        id:itemDelegate
        Rectangle{
            id:itemDelegates
            width: netWorkList.width
            height: 100
            color: "#00000000"

        }
    }




}
