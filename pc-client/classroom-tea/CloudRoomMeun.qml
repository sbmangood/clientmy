import QtQuick 2.0
import "./Configuuration.js" as Cfg

Item {
    id: meunView
    property var dataModels: [];//数据模型
    property bool disableButton: true;//禁用菜单点击
    width:  220 * widthRate

    signal sigShowItemNamesInMainView(var itemName);//发送item名字在中间状态栏进行显示

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
    // /* 讲解模式 explainMode 1:学习目标 2:知识梳理 3:典型例题 4:课堂练习*/  栏目选择过后发送的信号 用来获取当前栏目的数据信息
    signal sigExplainMode(var itemId,var lessonId,var planId,var questionId,var itemType);
    signal sigLoadingSuccess();//加载完成

    Image{
        anchors.fill: parent
        visible:  dataModels.length > 1 ? true : false
        source: "qrc:/cloudImage/topbaar_bg_shadow@2x.png"
    }

    ListView{
        id: listView
        visible:  menuModel.count > 1 ? true : false
        width: 80 * menuModel.count * heightRate
        height: parent.height - 10 * heightRate
        model: menuModel
        orientation: ListView.Horizontal
        boundsBehavior: ListView.StopAtBounds
        delegate: menuDelegate
        anchors.horizontalCenter: parent.horizontalCenter
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
            Rectangle
            {
                anchors.fill: parent
                visible: selected
                color: selected ?  "#FF7935" :  "#ffffff"
                radius: (index == 0 || index == menuModel.count - 1) ? 8 * heightRate : 0;

                Rectangle
                {
                    height: parent.height
                    width: 10 * heightRate
                    anchors.left: parent.left
                    color: "#FF7935"
                    visible: index == menuModel.count - 1
                }

                Rectangle
                {
                    height: parent.height
                    width: 10 * heightRate
                    anchors.right: parent.right
                    color: "#FF7935"
                    visible: index == 0
                }

                Rectangle
                {
                    width: parent.width
                    height: 10 * heightRate
                    anchors.top: parent.top
                    color: "#FF7935"
                    visible: (index == menuModel.count - 1 || index == 0)
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
                    anchors.topMargin: (parent.height - (height + 16 * heightRate )) * 0.4
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: {
                        if(itemType == 0){
                            //"趣味导入", "互动小结"
                            selected ? "qrc:/newStyleImg/pc_topbar_list_sed@2x.png" : "qrc:/newStyleImg/pc_topbar_list@2x.png"
                            return;
                        }
                        if(itemType == 1){
                            //"知识梳理"
                            selected ? "qrc:/newStyleImg/pc_topbar_starse_sed@2x.png" :  "qrc:/newStyleImg/pc_topbar_star@2x.png"
                            return;
                        }
                        if(itemType == 2){
                            //"课堂练习"
                            selected ? "qrc:/newStyleImg/pc_topbar_exercise_sed@2x.png" :  "qrc:/newStyleImg/pc_topbar_exercise@2x.png"
                            return;
                        }
                        if(itemType == 3){
                            selected ? "qrc:/newStyleImg/pc_topbar_book_sed@2x.png" :  "qrc:/newStyleImg/pc_topbar_book@2x.png"
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
                    color: selected ?  "#ffffff" :  "#ff5000"
                }

                onClicked: {
                    updateSelected(planId,itemId);
                    sigShowItemNamesInMainView(itemName);
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
        for(var i = 0; i < menuModel.count; i++)
        {
            var planIds = menuModel.get(i).planId;
            var itemsId = menuModel.get(i).itemId;

            console.log("=====updateSelected=====",planId,itemId ,planIds,itemsId);
            if(planId == 0 || itemId == 0)
            {
                menuModel.get(i).selected = true;
                sigShowItemNamesInMainView( menuModel.get(i).itemName);
                columnMake = false;
                break;
            }

            if(planIds == planId && itemId == itemsId)
            {
                menuModel.get(i).selected = true;
                sigShowItemNamesInMainView( menuModel.get(i).itemName);
                columnMake = false;
                continue;
            }

            menuModel.get(i).selected = false;
        }

        if(columnMake && menuModel.count >0)
        {
            menuModel.get(0).selected = true;
            sigShowItemNamesInMainView( menuModel.get(0).itemName);
        }
    }

}
