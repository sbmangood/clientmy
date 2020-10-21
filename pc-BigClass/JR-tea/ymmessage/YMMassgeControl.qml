import QtQuick 2.0
import QtQuick.Controls 1.4
import "../Configuration.js" as Cfg

Item {

    Rectangle{
        id: headItemOne
        width: parent.width - 80 * widthRate
        height: 80 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 40 * widthRate
        anchors.top:parent.top
        anchors.topMargin:10* heightRate
        Text{
            id: headText
            width: 60 * widthRate
            height: parent.height - 10 * heightRate
            text: "提醒"
            font.pixelSize: 40 * heightRate
            verticalAlignment: Text.AlignVCenter
            anchors.top:parent.top
            anchors.topMargin: 10 * heightRate
        }

        Rectangle{
            width: 60
            height: 4
            color: "#e0e0e0"
            anchors.top: headText.bottom
        }
        Rectangle{
            width: parent.width
            height: 1
            color: "#e3e6e9"
            anchors.bottom: parent.bottom
        }

        MouseArea{
            width: 90 * widthRate
            height: 30 * heightRate
            hoverEnabled: true
            anchors.right: allMarkButton.left
            anchors.rightMargin: 20 * widthRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10 * heightRate
            cursorShape: Qt.PointingHandCursor
            Rectangle{
                anchors.fill: parent
                border.width: 1
                border.color: "#c3c6c9"
                radius: 4 * heightRate
                //color: parent.containsMouse ? Cfg.NAV_HOVERED_CLR : "transparent"
                color:"transparent"
            }

            Text{
                text: "标记为已读"
                anchors.centerIn: parent
                font.pixelSize: 16 * heightRate
                color:"#222222"
            }

            onClicked: {
                updateReady(false);
            }
        }

        MouseArea{
            id: allMarkButton
            width: 120 * widthRate
            height: 30 * heightRate
            hoverEnabled: true
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10 * heightRate
            cursorShape: Qt.PointingHandCursor
            Rectangle{
                anchors.fill: parent
                border.width: 1
                border.color: "#96999c"
                radius: 4 * heightRate
                color:"transparent"
                //  color: parent.containsMouse ? Cfg.NAV_HOVERED_CLR : "transparent"
            }

            Text{
                text: "全部标记为已读"
                anchors.centerIn: parent
                font.pixelSize: 16 * heightRate
                color:"#222222"
            }

            onClicked: {
                updateAllReady()
            }
        }
    }

    Rectangle{
        id: headItemTow
        width: parent.width - 80 * widthRate
        height: 40 * heightRate
        anchors.top: headItemOne.bottom
        anchors.topMargin: 20 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: 40 * widthRate
        color: "#f3f6f9"
        Row{
            anchors.fill: parent
            anchors.left: parent.left
            anchors.leftMargin: 10*widthRate
            spacing: 5*widthRate
            CheckBox{
                width: 20 * heightRate
                height: 20 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                onCheckedChanged: {
                    updateCheck(checked);
                }
            }
            Text{
                width: 200 * widthRate
                height: parent.height
                text: "日期"
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 16 * heightRate
                color:"#96999c"
            }
            Text{
                height: parent.height
                text: "内容"
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 16 * heightRate
                color:"#96999c"
            }
        }
    }

    ListView{
        id: msgListView
        clip: true
        width: parent.width - 80* widthRate
        height: parent.height - 200* heightRate
        anchors.top: headItemTow.bottom
        anchors.left: parent.left
        anchors.leftMargin: 40* widthRate
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
            height: 70 * heightRate

            color: number % 2 ? "#fafafa" : "#ffffff"
            Row{
                anchors.fill: parent
                anchors.left: parent.left
                anchors.leftMargin: 10 * widthRate
                spacing: 5*widthRate
                CheckBox{
                    width: 20 * heightRate
                    height: 20 * heightRate
                    checked: checkeds
                    anchors.verticalCenter: parent.verticalCenter
                    onCheckedChanged: {
                        updateModel(index,checked);
                    }
                }
                Text{
                    width: 180 * widthRate
                    height: parent.height
                    text: dataTime
                    font.bold: remindStatus == 0 ? true : false
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 16 *heightRate
                    color: remindStatus == 0 ? "#111111" : "#666666"
                }
                Text{
                    width: parent.width - 290 *widthRate
                    height: parent.height
                    text: currentBody
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 16 *heightRate
                    color: remindStatus == 0 ? "#111111" : "#666666"
                }
                MouseArea{
                    width: 60 *widthRate
                    height: parent.height
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    Text{

                        text: "请查看"
                        //  color: parent.containsMouse ? "blue" : "#FF7E00"
                        color:"#ff5000"
                        font.underline: true
                        anchors.centerIn: parent
                        font.pixelSize: 16 *heightRate
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
                                remindStatus: 0,
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

