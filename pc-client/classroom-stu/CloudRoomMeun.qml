import QtQuick 2.0
import "Configuration.js" as Cfg
import YMCloudClassManagerAdapter 1.0
Item {
    id:roomenu
    property var dataModels: [];//数据模型
    property var planId: ;
    property var columnId: ;
    property var planName: ;
    property var pageIndex: ;
    property int currentSeletIndex : -1;
    property int  currenItemType : -1 ;//当前栏目的类型
    signal sigLearningTargets(var dataObjecte,var index);//学习目标信号 发送数据  和 当前要显示的页
    signal sigKnowledgeCombs(var dataObjecte, var index);//知识梳理信号
    signal sigTypicalExamples(var dataObjecte ,var index);//典型例题信号
    signal sigClassroomPractices(var dataObjecte,var index);//课堂练习信号
    signal sigTeacherSendQuestionDatas(var findDatas,var questionData); //返回老师发送的练习题的数据内容 和查找时所用的数据

    signal sigUploadStudentAnswerBackDatas(var isSuccess,var findData ,var isFinished); //学生上传答案是否成功标示 true 为success

    signal sigShowPages(var currentPages,var totalPages);//分页数据

    signal sigShowItemNamesInMainView(var itemName);//发送item名字在中间状态栏进行显示

    //显示答案解析面板
    signal sigShowAnswerAnalyseViews(var findDatas,var questionDatas);
    //显示批改面板
    signal sigShowCorrectViews(var findDatas,var questionDatas);

    //是否允许点击
    property bool whetherAllowedClick: true

    //申请翻页
    signal applyPage();

    width:  220 * widthRate
    onDataModelsChanged: {
        menuModel.clear();
        if(dataModels.length == 0)
        {
            console.log("onDataModelsChanged: cloudroommenu ",dataModels.length,dataModels)
            roomenu.visible = false;
            return;
        }
        roomenu.visible = true;
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
        roomenu.width = menuModel.count > 0 ? menuModel.count * 85 * heightRate : 220 * widthRate
        console.log("onDataModelsChanged: cloudroommenu not null ",dataModels.length,dataModels)
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
        height: parent.height// - 10 * heightRate
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

            Rectangle
            {
                width: 80 * heightRate
                height: parent.height - 8 * heightRate
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
                cursorShape: Qt.PointingHandCursor

                Image{
                    id: img1
                    width: 20 * widthRate
                    height: 20 * widthRate
                    //                    anchors.top: parent.top
                    //                    anchors.topMargin: (parent.height - (height + 20 * heightRate )) * 0.4
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

                    console.log("addAnswerView",addAnswerView.visible)

                    if(addAnswerView.visible){return;}
                    if(toobarWidget.teacherEmpowerment)
                    {
                        if(currentSeletIndex == index)
                        {
                            return;
                        }
                        sigShowItemNamesInMainView(itemName);
                        currentSeletIndex = index;
                        updateSelected(index);
                    }
                    else
                    {
                        console.log("no power click")
                        //applyPage();
                        popupWidget.setPopupWidget("noselectpower");
                    }

                }
            }
        }

    }

    //课件信息获取C++方法
    YMCloudClassManagerAdapter
    {
        id: yMCloudClassManagerAdapter

        onSigLessonCommentConfig:
        {
            mainView.lessonCommentConfigInfo = dataArray;
        }

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
            console.log(" onSigTeacherSendQuestionData: onSigTeacherSendQuestionData:",findData.planId,findData.columnId,findData.questionId);
            sigTeacherSendQuestionDatas(findData,questionData);
        }

        onUploadStudentAnswerBackData:
        {
            sigUploadStudentAnswerBackDatas(isUpSuccess,findData,isFinished);
        }
        onSigShowPage: {
            console.log(" onSigShowPage: { clod menu",currentPage,totalPage);
            sigShowPages(currentPage,totalPage);
        }

        onSigShowAnswerAnalyseView:
        {
            sigShowAnswerAnalyseViews(findData,questionData);
        }

        onSigShowCorrectView:
        {
            sigShowCorrectViews(findData,questionData);
        }
        onSigGetLessonListFail:
        {
            popupWidget.setPopupWidget("getLessonListFail");
        }

    }

    Component.onCompleted:
    {
        yMCloudClassManagerAdapter.justGetCourseIsSuccess();
        //模拟数据
        //dataModels = Cfg.menuTestData.content.columns;
        //console.log("YMCloudClassManagerAdapter::getLessonList::dataObj  33")
    }

    function getLessonCommentConfigInfo(){
        yMCloudClassManagerAdapter.getLessonCommentConfig();
    }
    //手动点击 更新被选项
    function updateSelected(index){
        console.log("手动点击 更新被选项",index);
        for(var i = 0; i < menuModel.count; i++){
            if(index == i){
                menuModel.get(i).selected = true;
                sigExplainMode(menuModel.get(i).itemId,menuModel.get(i).itemName,planId,menuModel.get(i).questions,menuModel.get(i).itemType);
                //yMCloudClassManagerAdapter.getColumnPageData(planId,menuModel.get(i).itemId,0);
                currenItemType = menuModel.get(i).itemType;
                columnId = menuModel.get(i).itemId;
                sigShowItemNamesInMainView( menuModel.get(i).itemName);
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
                currenItemType = menuModel.get(i).itemType;
                sigShowItemNamesInMainView( menuModel.get(i).itemName);
                continue;
            }
            menuModel.get(i).selected = false;
        }
        //更新显示面板 , QString pageIndex
        pageIndex = indexData.pageIndex;
        columnId = indexData.columnId;
        console.log("updateSelectedIndexByteacher(indexData) next ",indexData.planId.toString(),indexData.columnId.toString());
        yMCloudClassManagerAdapter.getColumnPageData(indexData.planId.toString(),indexData.columnId.toString(),indexData.pageIndex.toString());

    }

    function updateUiIndexview( columnIds , pageIndexs )
    {
        //更新UI选中项
        console.log("更新UI选中项",columnIds);
        columnId = columnIds;
        for(var i = 0; i < menuModel.count; i++){
            if(columnIds == menuModel.get(i).itemId ){
                menuModel.get(i).selected = true;
                sigShowItemNamesInMainView( menuModel.get(i).itemName);
                currenItemType = menuModel.get(i).itemType;
                continue;
            }
            menuModel.get(i).selected = false;
        }
        //更新显示面板 , QString pageIndex
        //pageIndex = pageIndexs;
    }


    //根据传入数据获取 要显示的数据  根据类型来发送相应的信号 dataType 1 为做题 2 为答案解析 3 为批改
    function getTeacherSendQuestionData(objdata,dataType)
    {
        console.log("getTeacherSendQuestionData(objdata)",objdata)
        resetAllCourseware();
        yMCloudClassManagerAdapter.getQuestionDataById(objdata,dataType);
    }

    function savaStudentAnswerToserver(useTime,studentSelectAnswer,currentQuestionOwnerData,isFinished,imageAnswers,childQId)
    {
        console.log("cloudRoomMenu savaStudentAnswerToserver",imageAnswers,useTime,currentQuestionOwnerData.planId,currentQuestionOwnerData.columnId,currentQuestionOwnerData.questionId);
        yMCloudClassManagerAdapter.saveStudentAnswer(useTime,studentSelectAnswer,currentQuestionOwnerData,isFinished,imageAnswers,childQId);
    }

    function preTopic()
    {
        yMCloudClassManagerAdapter.preTopic();
    }

    function nextTopic()
    {
        yMCloudClassManagerAdapter.nextTopic();
    }

    function jumpPage(pageIndexs)
    {
        yMCloudClassManagerAdapter.jumpTopic(pageIndexs);
    }

    function resetAllCourseware()
    {
        yMCloudClassManagerAdapter.getLessonList();
    }

    function getModelCount()
    {
        return menuModel.count;
    }

}
