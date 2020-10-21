import QtQuick 2.0
import "./Configuuration.js" as Cfg

Item {
    id: meunView
    property var dataModels: [];//数据模型
    property bool disableButton: true;//禁用菜单点击
    property bool hideOrShow: menuModel.count > 1 ? true : false;
    width:  220 * widthRate

    onDataModelsChanged: {
        menuModel.clear();
        for(var i = 0; i < dataModels.length; i++){
            menuModel.append(
                        {
                            "itemId":dataModels[i].itemId,
                            "itemName": dataModels[i].itemName,
                            "itemType": dataModels[i].itemType,
                            "orderNo": dataModels[i].orderNo,
                            "lessonId": dataModels[i].lessonId,
                            "questionId": dataModels[i].questionId,
                            "planId": dataModels[i].planId,
                            "selected": false,
                        });
        }
        meunView.width = menuModel.count > 0 ? menuModel.count * 85 * heightRate : 220 * widthRate;
    }
    // /* 讲解模式 explainMode 1:学习目标 2:知识梳理 3:典型例题 4:课堂练习*/
    signal sigExplainMode(var itemId,var lessonId,var planId,var questionId,var itemType);
    signal sigLoadingSuccess();//加载完成

//    Image{
//        anchors.fill: parent
//        visible:  dataModels.length > 1 ? true : false
//        source: "qrc:/cloudImage/topbaar_bg_shadow@2x.png"
//    }

    Rectangle{
            id: menuView
            width: 80 * menuModel.count * heightRate
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            border.color: "#c0c0c0"
            border.width: 1
            radius: 12 * heightRate
    //        Image{
    //            width: parent.width
    //            height: meunView.height
    //            visible:  dataModels.length > 1 ? true : false
    //            verticalAlignment: Image.AlignHCenter
    //            source: "qrc:/cloudImage/topbaar_bg_shadow@2x.png"
    //        }
            Rectangle{
                width: parent.width
                height: 10 * heightRate
            }

            Rectangle{
                width: 1
                height: 10 * heightRate
                color: "#c0c0c0"
            }

            Rectangle{
                width: 1
                height: 10 * heightRate
                color: "#c0c0c0"
                anchors.right: parent.right
            }

            ListView{
                id: listView               
                anchors.fill: parent
                model: menuModel
                orientation: ListView.Horizontal
                boundsBehavior: ListView.StopAtBounds
                delegate: menuDelegate
            }
        }

        MouseArea{
            width: animaMake ? 31 : 58
            height: animaMake ? 16 : 34
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.top: menuView.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            Image{
                anchors.fill: parent
                source: animaMake ? "qrc:/cloudImage/bar_down.png" : "qrc:/cloudImage/bar_up.png"
            }
            onClicked: {
                if(animaMake){
                    topAnimation.running = true;
                    bottomAnimation.running = false;
                    animaMake = false;
                }else{
                    bottomAnimation.running = true;
                    topAnimation.running = false;
                    animaMake = true;
                }
            }

        }
        property bool animaMake: true;

        NumberAnimation {
            id: topAnimation
            target: menuView
            property: "y";
            from: 0
            to: -55 * heightRate
            duration: 500
        }

        NumberAnimation {
            id: bottomAnimation
            target: menuView
            property: "y";
            from: -55 * heightRate
            to: 0
            duration: 500
        }
    ListModel{
        id: menuModel
    }

    Component{
        id: menuDelegate
        Item{
            id: rowMeun
            width: 80 * heightRate
            height: listView.height

            property var selecteds: selected;

            onSelectedsChanged: {
                if(selecteds){
                    sigExplainMode(itemId, lessonId, planId, questionId,itemType);
                }
            }

            MouseArea{
                width: parent.width
                height: parent.height
                enabled: disableButton
                cursorShape: Qt.PointingHandCursor

                Image{
                    id: img1
                    width: 20 * widthRate
                    height: 20 * widthRate
                    anchors.top: parent.top
                    anchors.topMargin: (parent.height - (height + 22 * heightRate )) * 0.4
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: {
                        if(itemType == 0){
                            selected ? "qrc:/cloudImage/topbar_btn_target_sed@2x.png" :  "qrc:/cloudImage/topbar_btn_target@2x.png"
                            return;
                        }
                        if(itemType == 1){
                            selected ? "qrc:/cloudImage/topbar_btn_zhishishuli_sed@2x.png" : "qrc:/cloudImage/topbar_btn_zhishishuli@2x.png"
                            return;
                        }
                        if(itemType == 2){
                            selected ? "qrc:/cloudImage/topbaar_btn_lianxi_sed@2x.png" :  "qrc:/cloudImage/topbaar_btn_lianxi@2x.png"
                            return;
                        }
                        if(itemType == 3){
                            selected ? "qrc:/cloudImage/topbaar_btn_anlie_sed@2x.png" :  "qrc:/cloudImage/topbaar_btn_anlie@2x.png"
                            return;
                        }
                    }
                }

                Text {
                    text: itemName
                    height: 20 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 12 * heightRate
                    anchors.top: img1.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: selected ?  "#ff5000" :  "#000000"
                }

                onClicked: {
                    updateSelected(planId,itemId);
                }
            }
            Component.onCompleted: {
                if(menuModel.count -1 == index){
                    console.log("*********isSynLesson:**********",isSynLesson)
                    sigLoadingSuccess();
                }
            }
        }
    }

    function updateSelected(planId,itemId){
        var columnMake = true;
        for(var i = 0; i < menuModel.count; i++){
            var planIds = menuModel.get(i).planId;
            var itemsId = menuModel.get(i).itemId;
            console.log("=====updateSelected=====",planId,itemId ,planIds,itemsId);
            if(planId == 0 || itemId == 0){
                menuModel.get(i).selected = true;
                columnMake = false;
                break;
            }

            if(planIds == planId && itemId == itemsId){
                menuModel.get(i).selected = true;
                columnMake = false;
                continue;
            }
            menuModel.get(i).selected = false;
        }
        if(columnMake && menuModel.count >0){
            menuModel.get(0).selected = true;
        }
    }

}
