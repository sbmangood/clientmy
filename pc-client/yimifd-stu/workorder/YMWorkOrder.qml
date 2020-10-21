import QtQuick 2.0

Item {
    Rectangle{
        id: headItem
        width: parent.width
        height: 70

        Row{
            width: 400
            height: parent.height
            anchors.centerIn: parent

            Rectangle{
                width: 130
                height: parent.height
                Text{
                    text: "待处理"
                    color: "#ff7e00"
                    font.pixelSize: 24
                    anchors.centerIn: parent
                }

                Rectangle{
                    width: 10
                    height: 10
                    radius: 10
                    color: "#FF7E00"
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    Text{
                        text: "5"
                        color: "white"
                        anchors.centerIn: parent
                    }
                }
                Rectangle{
                    width: 90
                    height: 5
                    color: "#FF7E00"
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            Rectangle{
                width: 130
                height: parent.height
                Text{
                    text: "处理中"
                    font.pixelSize: 24
                    anchors.centerIn: parent
                }
            }
            Rectangle{
                width: 130
                height: parent.height
                Text{
                    text: "已处理"
                    font.pixelSize: 24
                    anchors.centerIn: parent
                }
            }
        }
    }

    Rectangle{
        width: parent.width
        height: 1
        color: "#e0e0e0"
        anchors.top: headItem.bottom
    }

    Rectangle{
        width: parent.width
        height: parent.height
        color: "#f3f3f3"

        ListView{
            width: parent.width - 30
            height: workModel.count * 45 + 45
            delegate: workComponent
            anchors.top: parent.top

        }
    }

    ListModel{
        id: workModel
    }

    Component{
        id: workComponent
        Rectangle{

        }
    }

}

