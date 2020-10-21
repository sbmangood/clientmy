import QtQuick 2.0
import QtQuick.Controls 2.0
import "./Configuration.js" as Cfg

/*
*学员列表
*/

Item {
    width: parent.width
    height: parent.height

    ListView{
        id: stuListview
        anchors.fill: parent
        model: stuModel
        delegate: stuComponet
    }

    ListModel{
        id: stuModel
    }

    Component{
        id: stuComponet
        Item{
            width: stuListview.width
            height: 52 * heightRate

            Row{
                anchors.fill: parent

                Item{//学员姓名
                    width: 80 * heightRate
                    height: parent.height

                    Text {
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 14 * heightRate
                        text: userName
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12 * heightRate
                    }
                }

                MouseArea{//举手状态
                    width: 80 * heightRate
                    height: parent.height
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    Image {
                        width: 32 * heightRate
                        height: 32 * heightRate
                        source: "qrc:/images/green3.png"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    onClicked: {

                    }
                }

                MouseArea{//上下台
                    width: 120 * heightRate
                    height:  parent.height
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    Image {
                        width: 32 * heightRate
                        height: 32 * heightRate
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/images/grey2.png"
                    }
                }

                MouseArea{//禁言/解禁
                    width: 80 * heightRate
                    height: parent.height
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    Image {
                        width: 32 * heightRate
                        height: 32 * heightRate
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/images/blue2.png"
                    }

                    onClicked: {

                    }
                }

            }

            Rectangle{
                width: parent.width
                height: 1
                color: "#ffffff"
                anchors.bottom: parent.bottom
            }
        }
    }

    function addStuList(userId,userName){
        stuModel.append(
                    {
                        "userId":userId,
                        "userName": userName,
                        "raiseHands": false,
                        "userUp": false,
                        "banned": false
                    });
    }

    Component.onCompleted: {
        addStuList("716","张三");
        addStuList("717","李四");
        addStuList("718","王五");
    }

}
