import QtQuick 2.0
import QtQuick.Controls 2.0
import "./Configuration.js" as Cfg

/*
*网络设置
*/

Item {
    id: networkItem

    onVisibleChanged: {
        if(visible){
            mgrRemind.getCurrentStage();
            updateStageSelecte(windowView.debugStage);
        }
    }

    Rectangle{
        anchors.fill: parent
        radius: 12 * heightRate
        border.color: "#c0c0c0"
        border.width: 1
    }

    ListModel{
        id: netModel
    }

    //关闭按钮
    MouseArea{
        width: 26 * heightRate
        height: 26 * heightRate
        hoverEnabled: true
        anchors.right: parent.right
        anchors.rightMargin: 5 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 5 * heightRate

        Rectangle{
            anchors.fill: parent
            color: parent.containsMouse ? "#e0e0e0" : "#f3f3f3"
            radius: 100
        }

        Text {
            id: name
            anchors.centerIn: parent
            font.pixelSize: 14 * heightRate
            font.family: Cfg.DEFAULT_FONT
            text: qsTr("×")
            color: parent.containsMouse ? "#FF5500" : "#000000"
        }

        onClicked: {
            networkItem.visible = false;
            okButton.visible = false;
        }
    }

    Text {
        id: headText
        width: parent.width
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 16 * heightRate
        text: qsTr("网络环境设置")
        anchors.top: parent.top
        anchors.topMargin: 15 * heightRate
        horizontalAlignment: Text.AlignHCenter
    }

    TextField{
        id: inputText
        width: parent.width - 20 * heightRate
        height: 48 * heightRate
        font.pixelSize: 16 * heightRate
        font.family: Cfg.DEFAULT_FONT
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: headText.bottom
        anchors.topMargin: 15 * heightRate
        placeholderText: "请输入环境,例如:stage2"
        onTextChanged: {
            if(text  != ""){
                okButton.visible = true;
            }else{
                okButton.visible = false;
            }
        }
    }

    ListView{
        id: netView
        width: parent.width - 20 * heightRate
        height: parent.height - headText.height - 40 * heightRate
        anchors.top: inputText.bottom
        anchors.topMargin: 15 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        model: netModel
        delegate: netDelegate
        boundsBehavior: ListView.StopAtBounds
        section.delegate: Rectangle{
            width: parent.width
            height: 1
            color: "#c0c0c0"
        }
        section.property: "id"
    }


    //确定按钮
    MouseArea{
        id: okButton
        visible: false
        width: parent.width - 20 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18 * heightRate
        height: 34 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        cursorShape: Qt.PointingHandCursor

        Rectangle{
            anchors.fill: parent
            color: "#FF5500"
        }

        Text {
            anchors.centerIn: parent
            font.pixelSize: 14 * heightRate
            font.family: Cfg.DEFAULT_FONT
            color: "#ffffff"
            text: qsTr("确定")
        }

        onClicked: {
            networkItem.visible = false;
            var stageData = getSelecteValue();
            var stageArray = stageData.split(",");

            console.log("=======homeWorkMgr.updateStage========", stageArray[0], stageArray[1]);
            mgrRemind.updateStage(stageArray[0],stageArray[1]);
        }
    }

    Component{
        id: netDelegate

        Rectangle{
            width: netView.width
            height: 45 * heightRate

            Text {
                text: netText
                height: parent.height
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                verticalAlignment: Text.AlignVCenter
            }

            Image {
                id: checkImg
                width: 14 * heightRate
                height: 14 * heightRate
                visible: selected
                source: "qrc:/images/login_btn_right.png"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 10 * heightRate
            }

            Rectangle{
                width: parent.width
                height: 1
                color: "#c0c0c0"
                anchors.bottom: parent.bottom
                visible: (netModel.count -1) == index ? true : false
            }

            MouseArea{
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    updateSelecte(index);
                    if(windowView.debugStage != stage){
                        okButton.visible = true;
                    }else{
                        okButton.visible = false;
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        netModel.append({"id": 0, "selected": false,"netText": "生产环境","stage": "test-api", "type": "1" });
        netModel.append({"id": 1, "selected": false,"netText": "Stage环境","stage": "stage", "type": "0" });
        netModel.append({"id": 2, "selected": false,"netText": "Pre环境", "stage": "pre", "type": "0"});
        netModel.append({"id": 3, "selected": false,"netText": "Dev环境","stage": "dev", "type": "0" });
    }

    function updateStageSelecte(stage){
        console.log("=======updateStageSelecte========1", stage);
        //生产环境, 是空
        if(stage == "")
        {
            netModel.get(0).selected = true;
            console.log("======*********======")
            return;
        }
        var isSelected = true;

        for(var i = 0; i < netModel.count; i++){
            console.log("=======updateStageSelecte========", netModel.get(i).stage, stage);
            if(netModel.get(i).stage == stage){
                isSelected = false;
                netModel.get(i).selected = true;
            }else{
                netModel.get(i).selected = false;
            }
        }
        if(isSelected){
            stage = stage.replace("-","");
            inputText.text = stage;
        }
    }

    function updateSelecte(index){
        console.log("=======updateSelecte========", index);
        for(var i = 0; i < netModel.count; i++){
            if(netModel.get(i).id == index){
                inputText.text = "";
                netModel.get(i).selected = true;
            }else{
                netModel.get(i).selected = false;
            }
        }
    }

    function getSelecteValue(){
        if(inputText.text != ""){
            return "0," + inputText.text.trim();
        }

        for(var i = 0; i < netModel.count; i++){
            if(netModel.get(i).selected == true){
                console.log("=======getSelecteValue========", netModel.get(i).type, netModel.get(i).stage);
                return netModel.get(i).type + "," + netModel.get(i).stage;
            }
        }
    }

}
