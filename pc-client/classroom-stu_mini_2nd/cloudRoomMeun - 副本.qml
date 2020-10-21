import QtQuick 2.0
import "Configuration.js" as Cfg
import YMCloudClassManagerAdapter 1.0
Item {
    property var dataModels: [];//数据模型
    property var planId: ;
    property var planName: ;
    property var pageIndex: ;

    signal sigLearningTargets(var dataObjecte,var index);//学习目标信号 发送数据  和 当前要显示的页
    signal sigKnowledgeCombs(var dataObjecte, var index);//知识梳理信号
    signal sigTypicalExamples(var dataObjecte,var index);//典型例题信号
    signal sigClassroomPractices(var dataObjecte,var index);//课堂练习信号
    signal sigTeacherSendQuestionDatas(var findDatas,var questionData); //返回老师发送的练习题的数据内容 和查找时所用的数据


    onDataModelsChanged: {
        menuModel.clear();
        for(var i = 0; i < dataModels.length; i++){
            menuModel.append(
                        {
                            "itemId":dataModels[i].columnId, //栏目id
                            "itemName": dataModels[i].columnName,//栏目名字
                            "itemType": dataModels[i].columnType,//栏目类型
                            // "orderNo": dataModels[i].orderNo,
                            // "lessonId": dataModels[i].lessonId,
                            // "questionId": dataModels[i].questionId,
                            "questions": dataModels[i].questions,//题Id数组
                            "planId": planId,
                            "planName": planName,
                            //"selected": i == 0 ? true : false,
                            "selected": false,
                        });
        }
    }

    signal sigCurrentBeselectItem()

    //    // /* 讲解模式 explainMode 1:学习目标 2:知识梳理 3:典型例题 4:课堂练习*/
    signal sigExplainMode(var itemId,var itemName,var planId,var questionId,var itemType);

    Image{
        anchors.fill: parent
        source: "qrc:/cloudImage/topbaar_bg_shadow@2x.png"
    }

    ListView{
        id: listView
        width: 80 * menuModel.count * heightRate
        height: parent.height - 10 * heightRate
        model: menuModel
        orientation: ListView.Horizontal
        boundsBehavior: ListView.StopAtBounds
        delegate: menuDelegate
        //anchors.horizontalCenter: parent.horizontalCenter
        anchors.centerIn: parent
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

            MouseArea{
                width: parent.width
                height: parent.height
                cursorShape: Qt.PointingHandCursor

                Image{
                    id: img1
                    width: 24 * widthRate
                    height: 24 * widthRate
                    anchors.top: parent.top
                    anchors.topMargin: (parent.height - (height + 20 * heightRate )) * 0.4
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
                            selected ? "qrc:/cloudImage/topbaar_btn_anlie_sed@2x.png" :  "qrc:/cloudImage/topbaar_btn_anlie@2x.png"
                            return;
                        }
                        if(itemType == 3){
                            selected ? "qrc:/cloudImage/topbaar_btn_lianxi_sed@2x.png" :  "qrc:/cloudImage/topbaar_btn_lianxi@2x.png"
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
                    updateSelected(index);
                    // sigExplainMode(itemId, lessonId, planId, questionId,itemType);
                }
            }
        }

    }

    //课件信息获取C++方法
    YMCloudClassManagerAdapter
    {
        id: yMCloudClassManagerAdapter

        onSigLearningTarget:
        {
            sigLearningTargets(dataObjecte,pageIndex);
        }

        onSigKnowledgeComb:
        {
            sigKnowledgeCombs(dataObjecte,pageIndex);
        }

        onSigTypicalExample:
        {
            sigTypicalExamples(dataObjecte,pageIndex);
        }

        onSigClassroomPractice:
        {
            sigClassroomPractices(dataObjecte,pageIndex);
        }

        onSigTeacherSendQuestionData:
        {
            sigTeacherSendQuestionDatas(findData,questionData);
        }
    }

    Component.onCompleted:
    {
        //模拟数据
        //dataModels = Cfg.menuTestData.content.columns;
        //console.log("dataModels = Cfg.menuTestData.columns",Cfg.menuTestData.content.columns)
    }

    //手动点击 更新被选项
    function updateSelected(index){
        for(var i = 0; i < menuModel.count; i++){
            if(index == i){
                menuModel.get(i).selected = true;
                sigExplainMode(menuModel.get(i).itemId,menuModel.get(i).itemName,planId,menuModel.get(i).questions,menuModel.get(i).itemType);
                continue;
            }
            menuModel.get(i).selected = false;
        }
    }

    function updateSelectedIndexByteacher(indexData)
    {
        console.log("updateSelectedIndexByteacher(indexData)",indexData.planId,planId,indexData.columnId);

        if(indexData.planId != planId)
        {
            return;
        }

        //更新UI选中项
        for(var i = 0; i < menuModel.count; i++){
            if(indexData.columnId == menuModel.get(i).itemId ){
                menuModel.get(i).selected = true;
                //发送点击信号
                // sigExplainMode(menuModel.get(i).itemId,menuModel.get(i).itemName,planId,menuModel.get(i).questions,menuModel.get(i).itemType);
                continue;
            }
            menuModel.get(i).selected = false;
        }
        //更新显示面板 , QString pageIndex
        pageIndex = indexData.pageIndex;

        console.log("updateSelectedIndexByteacher(indexData) next ",indexData.planId.toString(),indexData.columnId.toString());
        yMCloudClassManagerAdapter.getColumnPageData(indexData.planId.toString(),indexData.columnId.toString(),indexData.pageIndex.toString());

    }

    function getTeacherSendQuestionData(objdata)
    {
        console.log("getTeacherSendQuestionData(objdata)")
        yMCloudClassManagerAdapter.getQuestionDataById(objdata);
    }

    function savaStudentAnswerToserver(useTime,studentSelectAnswer,currentQuestionOwnerData)
    {
        yMCloudClassManagerAdapter.saveStudentAnswer("");
    }

}
