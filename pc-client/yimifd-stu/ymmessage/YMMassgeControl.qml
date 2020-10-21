import QtQuick 2.0
import QtQuick.Controls 1.4
import "../Configuration.js" as Cfg

Item {
    Rectangle{
        id: headItemOne
        width: parent.width - 80
        height: 45
        anchors.left: parent.left
        anchors.leftMargin: 40
        Text{
            id: headText
            width: 60
            height: parent.height - 5
            text: "提醒"
            font.bold: true
            font.pixelSize: 24
            verticalAlignment: Text.AlignBottom
        }


        Rectangle{
            width: parent.width
            height: 1
            color: "#e0e0e0"
            anchors.bottom: parent.bottom
        }

        MouseArea{
            width: 120
            height: 30
            hoverEnabled: true
            anchors.right: allMarkButton.left
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter

            Rectangle{
                anchors.fill: parent
                border.width: 1
                border.color: "#e0e0e0"
                radius: 4
                color: parent.containsMouse ? Cfg.NAV_HOVERED_CLR : "transparent"
            }

            Text{
                text: "标记为已读"
                anchors.centerIn: parent
            }

            onClicked: {
                updateReady(false);
            }
        }

        MouseArea{
            id: allMarkButton
            width: 160
            height: 30
            hoverEnabled: true
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.verticalCenter: parent.verticalCenter
            Rectangle{
                anchors.fill: parent
                border.width: 1
                border.color: "#e0e0e0"
                radius: 4
                color: parent.containsMouse ? Cfg.NAV_HOVERED_CLR : "transparent"
            }

            Text{
                text: "全部标记为已读"
                anchors.centerIn: parent
            }

            onClicked: {
                updateAllReady()
            }
        }
    }

    Rectangle{
        id: headItemTow
        width: parent.width - 80
        height: 40
        anchors.top: headItemOne.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 40
        color: "#e0e0e0"

        Row{
            anchors.fill: parent
            anchors.left: parent.left
            anchors.leftMargin: 10
            CheckBox{
                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                onCheckedChanged: {
                    updateCheck(checked);
                }
            }
            Text{
                width: 200
                height: parent.height
                text: "日期"
                verticalAlignment: Text.AlignVCenter
            }
            Text{
                height: parent.height
                text: "内容"
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    ListView{
        id: msgListView
        width: parent.width - 80
        height: msgModel.count *  45 + 45
        anchors.top: headItemTow.bottom
        anchors.left: parent.left
        anchors.leftMargin: 40
        model: msgModel
        delegate: msgComponent
    }

    ListModel{
        id: msgModel
    }

    Component{
        id: msgComponent

        Rectangle{
            width: msgListView.width
            height: 40

            color: number % 2 ? "#f3f3f3" : "white"

            Row{
                anchors.fill: parent
                anchors.left: parent.left
                anchors.leftMargin: 10
                CheckBox{
                    width: 20
                    height: 20
                    checked: checkeds
                    anchors.verticalCenter: parent.verticalCenter
                    onCheckedChanged: {
                        updateModel(index,checked);
                    }
                }
                Text{
                    width: 200
                    height: parent.height
                    text: dataTime
                    verticalAlignment: Text.AlignVCenter
                }
                Text{
                    width: parent.width - 290
                    height: parent.height
                    text: currentBody
                    font.bold: ready
                    verticalAlignment: Text.AlignVCenter
                }
                MouseArea{
                    width: 60
                    height: parent.height
                    hoverEnabled: true
                    Text{

                        text: "请查看"
                        color: parent.containsMouse ? "blue" : "#FF7E00"
                        font.underline: true
                        anchors.centerIn: parent
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        for(var i = 0; i < 6;i++){
            msgModel.append({
                                number: i,
                                checkeds: false,
                                dataTime: "2017-08-25",
                                ready: i % 2 ? false : true,
                                currentBody: "测试测试...........",
                            })
        }
    }

    function updateModel(index,checked){
        for(var i = 0; i < msgModel.count; i++){
            if(i === index){
                msgModel.get(i).checkeds = checked;
            }
        }
    }

    function updateCheck(checked){
        for(var i = 0; i < msgModel.count; i++){
            msgModel.get(i).checkeds = checked
        }
    }

    function updateReady(ready){
        for(var i = 0; i < msgModel.count; i++){
            if(msgModel.get(i).checkeds){
                msgModel.get(i).ready = ready
            }
        }
    }

    function updateAllReady(){
        for(var i = 0; i < msgModel.count; i++){
            msgModel.get(i).ready = false;
        }
    }

}

