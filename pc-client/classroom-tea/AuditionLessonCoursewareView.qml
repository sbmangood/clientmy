import QtQuick 2.2
import QtQuick.Controls 2.0
import QtWebView 1.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.2
import QtWebEngine 1.4
import "Configuuration.js" as Cfg
import LoadInforMation 1.0
/* 课件 课后作业 试听课报告显示界面 */
Popup {
    id:itemView
    modal: true
    focus: true
    closePolicy: Popup.CloseOnPressOutside
    background: Rectangle
    {
        anchors.fill: parent
        color: "white"
        border.width: 0
        border.color: "#e3e6e9"

        Image {
            width: parent.width - 7 * widthRates
            height: parent.height - 5* widthRates
            anchors.centerIn: parent
            source: "qrc:/newStyleImg/popwindow_shadow@2x.png"
        }
    }
    property int currentSelectIndex:1;//当前显示的index
    property bool insertHomeWorkPower: true;
    signal sendReportImgSockets(var imgarry,var status);//发送当前的需要导入课堂的图片 status 1 为试听课报告导入课堂 2为课后作业导入课堂

    signal showHomeWorkDetails( var homeWorkId);

    signal clipCurrentImgs(var questionData,var imgArr);

    signal startClipHMImgs(var status);// 1开始生产课堂报告截图 2开始生成作业截图

    signal finishedClipHmImgs();//生成作业截图结束
    //上传图片
    LoadInforMation{
        id:loadInforMation
    }


    MouseArea
    {
        anchors.fill: parent
    }

    //头部index 选项
    Rectangle
    {
        id:topIndexItem
        width: parent.width// - 5 * widthRates
        anchors.left: parent.left
        anchors.leftMargin: 5 * widthRates
        height: 44 * widthRates
        color: "transparent"
        clip: true

        Rectangle
        {
            width: parent.width
            height: 1
            anchors.top: rowsOne.bottom
            anchors.topMargin: -4 * widthRates
            color: "#e3e6e9"
        }

        Row {
            id:rowsOne
            width: parent.width
            height: parent.height
            spacing: 10 * widthRates

            Rectangle
            {
                width: currentIsAuditionLesson ? (parent.width / 4 ) : (parent.width / 3)
                height: parent.height
                color: "transparent"
                Text {
                    id:text2
                    text: qsTr("课件")
                    color:currentSelectIndex == 1 ? "#ff6633" : "#666666"
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    anchors.centerIn: parent
                }

                Rectangle
                {
                    width: parent.width// 65 * widthRates
                    height: 2 * widthRates
                    anchors.top: text2.bottom
                    anchors.topMargin: 9 * widthRates
                    color: currentSelectIndex == 1 ? "#ff6633" : "transparent"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {

                        currentSelectIndex = 1;
                    }
                }

            }

            Rectangle
            {
                width: currentIsAuditionLesson ? (parent.width / 4 ) : (parent.width / 3)
                //width: parent.width / 5.2
                height: parent.height
                color: "transparent"
                Text {
                    id:text3
                    text: qsTr("音视频文件")
                    color:currentSelectIndex == 2 ? "#ff6633" : "#666666"
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    anchors.centerIn: parent
                }
                Rectangle
                {
                    width: parent.width// 65 * widthRates
                    height: 2 * widthRates
                    anchors.top: text3.bottom
                    anchors.topMargin: 9 * widthRates
                    color: currentSelectIndex == 2 ? "#ff6633" : "transparent"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        currentSelectIndex = 2;
                    }
                }

            }

            Rectangle
            {
                width: currentIsAuditionLesson ? (parent.width / 4 ) : (parent.width / 3)
                height: parent.height
                color: "transparent"
                Text {
                    id:text33
                    text: qsTr("课后作业")
                    color:currentSelectIndex == 3 ? "#ff6633" : "#666666"
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    anchors.centerIn: parent
                }

                Rectangle
                {
                    width: parent.width// 65 * widthRates
                    height: 2 * widthRates
                    anchors.top: text33.bottom
                    anchors.topMargin: 9 * widthRates
                    color: currentSelectIndex == 3 ? "#ff6633" : "transparent"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        if(!insertHomeWorkPower)
                        {
                            showMessageTips("无法使用此功能，监测到学生版本过低");
                            itemView.visible = false;
                        }
                        currentSelectIndex = 3;
                    }
                }

            }

            Rectangle
            {
                width: currentIsAuditionLesson ? (parent.width / 5) : 0
                height: parent.height
                color: "transparent"
                visible: currentIsAuditionLesson
                Text {
                    id:text4
                    text: qsTr("试听课报告")
                    color:currentSelectIndex == 4 ? "#ff6633" : "#666666"
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    anchors.centerIn: parent
                }
                Rectangle
                {
                    width: parent.width// 65 * widthRates
                    height: 2 * widthRates
                    anchors.top: text4.bottom
                    anchors.topMargin: 9 * widthRates
                    color: currentSelectIndex == 4 ? "#ff6633" : "transparent"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        currentSelectIndex = 4;
                    }
                }

            }

        }

    }

    //课件显示
    Rectangle
    {
        width: parent.width + 5 * widthRates
        height: parent.height - topIndexItem.height
        anchors.left: parent.left
        anchors.leftMargin: 4 * widthRates
        anchors.top:topIndexItem.bottom
        anchors.topMargin: -3 * heightRates
        visible:currentSelectIndex == 1
        color: "transparent"

        ListView//显示所有的音视频列表
        {
            anchors.fill:parent
            id:coursewareListView
            model:coursewareListViewModel
            delegate:coursewareListViewDelegate
            clip:true
        }
        Rectangle
        {
            id:noReportView
            width: parent.width - 4 * widthRates
            height: parent.height - 4 * widthRates
            anchors.centerIn: parent
            color: "white"
            z:20
            visible: coursewareListViewModel.count == 0;
            Image {
                id:emptyImg
                width: 296 * heightRates * 0.5
                height: 380 * heightRates * 0.5
                source: "qrc:/newStyleImg/pc_status_empty@2x.png"
                anchors.centerIn: parent
            }
            Text {
                text: qsTr("暂时没有课件哦~")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                color: "#BBBBBB"
                anchors.top: emptyImg.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Component
        {
            id:coursewareListViewDelegate

            Item{
                width:coursewareListView.width
                height: 50 * widthRates;
                Rectangle
                {
                    anchors.fill: parent
                    color: textMousearea.containsMouse ? "#f9f9f9" : "transparent"
                }

                Image {
                    id: name
                    height: 23 * widthRates;
                    width: 23 * widthRates;
                    anchors.left: parent.left
                    anchors.leftMargin: 10 * heightRates
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/newStyleImg/th_popwindow_btn_kejian@2x.png"
                }

                Text {
                    text: namess;
                    //anchors.centerIn: parent
                    anchors.left: parent.left
                    anchors.leftMargin: 35 * widthRates
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 14 * heightRates
                    elide: Text.ElideRight
                    color: "#333333"
                    font.family: "Microsoft YaHei"

                }

                Rectangle
                {
                    width: parent.width - 20 * widthRates
                    height: 1
                    color: "#EEEEEE"
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 10 * widthRates

                }
                MouseArea
                {

                    id:textMousearea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked:
                    {
                        itemView.visible = false;
                        videoToolBackground.resetCourwareView(index + 1);
                    }
                }
            }
        }

    }

    //音视频列表
    Rectangle
    {
        width: parent.width + 5 * widthRates
        height: parent.height - topIndexItem.height
        anchors.top:topIndexItem.bottom
        anchors.left: parent.left
        anchors.leftMargin: 4 * widthRates
        visible: currentSelectIndex == 2
        color: "transparent"
        anchors.topMargin: -3 * heightRates
        ListView//显示所有的音视频列表
        {
            anchors.fill:parent
            id:audioVideoListView
            model:audioModel
            delegate:audioVideoListViewDelegate
            clip:true
        }

        Rectangle
        {
            id:noReportViews
            width: parent.width - 4 * widthRates
            height: parent.height - 4 * widthRates
            anchors.centerIn: parent
            color: "white"
            z:20
            visible: audioModel.count == 0;
            Image {
                id:emptyImgs
                width: 296 * heightRates * 0.5
                height: 380 * heightRates * 0.5
                source: "qrc:/newStyleImg/pc_status_empty@2x.png"
                anchors.centerIn: parent
            }

            Text {
                text: qsTr("暂时没有音视频文件哦~")
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
                color: "#BBBBBB"
                anchors.top: emptyImgs.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Component
        {
            id:audioVideoListViewDelegate
            Item{
                width:audioVideoListView.width
                height:50 * widthRates;

                Rectangle
                {
                    anchors.fill: parent
                    color: textMousearea.containsMouse ? "#f9f9f9" : "transparent"
                }

                Image {
                    id: name
                    height: 23 * widthRates;
                    width: 23 * widthRates;
                    anchors.left: parent.left
                    anchors.leftMargin: 10 * heightRates
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/newStyleImg/th_popwindow_btn_yinpin@2x.png"
                }

                Text {
                    text: key;
                    //anchors.centerIn: parent
                    anchors.left: parent.left
                    anchors.leftMargin: 35 * widthRates
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 14 * heightRates
                    elide: Text.ElideRight
                    color: "#333333"
                    font.family: "Microsoft YaHei"

                }

                MouseArea
                {
                    anchors.fill: parent
                    id:textMousearea
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    Rectangle
                    {
                        width: parent.width - 20 * widthRates
                        height: 1
                        color: "#EEEEEE"
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: 10 * widthRates

                    }
                    onClicked:
                    {
                        itemView.visible = false;
                        videoToolBackground.resetAudioVideoPlayer(values,key);
                    }
                }
            }

        }

    }

    //试听课报告
    Rectangle
    {
        width: parent.width - 5 * widthRates
        height: parent.height - topIndexItem.height
        anchors.left: parent.left
        anchors.leftMargin: 5 * widthRates
        anchors.top:topIndexItem.bottom
        visible:currentSelectIndex == 4
        color: "transparent"

        onVisibleChanged:
        {
            if(visible)
            {
                reportView.visible = true;
            }
        }

        AuditionLessonReportView
        {
            id:reportView
            anchors.fill: parent
            onStartClipHMImg:
            {
                startClipHMImgs(1);//开始生成作业截图
            }

            onFinishedClipHmImg:
            {
                finishedClipHmImgs();//生成作业截图结束
            }

            onHideCurrentView: {
                itemView.visible = false;
            }

            onSendReportImgSocket:
            {
                sendReportImgSockets(imgarry,1);
            }
        }
    }

    //课后作业
    Rectangle
    {
        width: parent.width
        height: parent.height - topIndexItem.height
        anchors.top:topIndexItem.bottom
        visible: currentSelectIndex == 3
        color: "transparent"
        anchors.left: parent.left
        anchors.leftMargin: 7 * widthRates

        AuditionLessonhomeWork
        {
            id:auditionLessonhomeWork
            width: parent.width - 25 * widthRates
            height: parent.height - 20 * widthRates
            anchors.centerIn: parent
            onShowHomeWorkDetail:
            {
                showHomeWorkDetails(homeWorkId);
                homeWorkDetail.viewTimeText = time;
                homeWorkDetail.viewTitleText = title;
                homeWorkDetail.visible = true;
            }
        }

        MouseArea
        {
            anchors.fill: parent
            enabled: !insertHomeWorkPower
            onClicked:
            {
                if(!insertHomeWorkPower)
                {
                    showMessageTips("无法使用此功能，监测到学生版本过低");
                    itemView.visible = false;
                }
            }
        }


    }
    //显示作业预览题目详情
    Rectangle
    {
        id: questionShowView
        //anchors.fill: parent
        width: parent.width - 1
        height: parent.height -1
        visible: false
        anchors.left: parent.left
        anchors.leftMargin: 6 * widthRates
        z:1000

        Image {
            width: 13 * widthRates * 0.7
            height: 21 * widthRates * 0.7
            anchors.left: parent.left
            anchors.leftMargin: 8 * widthRates
            anchors.top:parent.top
            anchors.topMargin: 9 * heightRates
            source: "qrc:/newStyleImg/Back Chevron@2x.png"
            z:100
            MouseArea
            {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked:
                {
                    questionShowView.visible = false;
                }
            }
        }

        Text {
            text: qsTr("返回")
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 14 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 25 * widthRates
            anchors.top:parent.top
            anchors.topMargin: 8 * heightRates

            MouseArea
            {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked:
                {
                    questionShowView.visible = false;
                }
            }
        }

        Rectangle
        {
            width: parent.width - 20 * widthRates
            height: 2
            color: "#EEEEEE"
            anchors.top: parent.top
            anchors.topMargin: 35 * widthRates// * 0.7
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ShowQuestionHandlerView{
            id: coursewareViewQuestionHandlerView
            border.width: 0
            width: parent.width
            height: parent.height - 20 * widthRates
            anchors.top: parent.top
            anchors.topMargin: 21 * widthRates
            isCompleStatus: false
            isStuHomeWorkView:true
            onVisibleChanged: {
                console.log("======onVisibleChanged==========")
            }
        }

        CloudCompositeTopicView{
            id: coursewareViewCompositeTopicView
            anchors.fill: parent
        }

        function getQuestionItems(questionItemsData,answerArray,photosArray,browseStatus){//true
            if(questionItemsData.questionType == undefined || questionItemsData == null){
                console.log("======getQuestionItems::null========");
                return;
            }

            var knowledgesModels = questionItemsData.knowledges //Cfg.zongheti.knowledges;
            var answerModel = questionItemsData.answer //Cfg.zongheti.answer;
            var questionItems = questionItemsData.questionItems //Cfg.zongheti.questionItems;
            var type = questionItemsData.questionType //Cfg.zongheti.questionType;
            var childQuestionInfo = questionItemsData.childQuestionInfo;
            var questionStatus = questionItemsData.status;

            //console.log("========photosArray==========",JSON.stringify(photosArray),questionStatus);
            //console.log("#######answerArray#########", JSON.stringify(answerArray));

            var questionId = questionItemsData.id;
            var questionMake = false;
            for(var i = 0; i < questionBufferModel.count; i++){

                var modelQuestionId = questionBufferModel.get(i).questionId;
                var modelQuestionStatus = questionBufferModel.get(i).status;

                console.log("**********1111111111111***************",modelQuestionId,modelQuestionStatus);
                if(modelQuestionId == questionId && (modelQuestionStatus == 1)){
                    questionMake = true;
                    break;
                }
            }
            if(type == 6){
                coursewareViewQuestionHandlerView.visible = false;
                coursewareViewQuestionHandlerView.isCompleStatus = true;

                console.log("======综合题6=======");
                coursewareViewCompositeTopicView.visible = true;
                coursewareViewCompositeTopicView.answerModel = answerArray;
                coursewareViewCompositeTopicView.dataModel = questionItemsData;
                return;
            }

            coursewareViewCompositeTopicView.visible = false;
            //五大题型展示
            coursewareViewQuestionHandlerView.isCompleStatus = false;
            coursewareViewQuestionHandlerView.knowledgesModels = knowledgesModels;
            coursewareViewQuestionHandlerView.answerModel = answerModel;
            coursewareViewQuestionHandlerView.questionItemsData = questionItems;
            coursewareViewQuestionHandlerView.setCurrentBeShowedView(questionItemsData,type,browseStatus,topicModel);
            coursewareViewQuestionHandlerView.visible = true;
        }

    }
    AuditionLessonHMDetail
    {
        id:homeWorkDetail
        width: parent.width + 2 * heightRates
        height: parent.height - 5 * heightRates
        anchors.left: parent.left
        anchors.leftMargin: 6 * widthRates
        z:20
        visible: false

        onSigShowQuestionDetailView:
        {
            questionShowView.visible = true;
            var emptyList = [];
            questionShowView.getQuestionItems(allData,emptyList,emptyList,false);

        }

        onClipCurrentImg:
        {
            clipCurrentImgs(questionData ,imgArr);
        }
        onSendReportImgSocket:
        {
            sendReportImgSockets(imgarry,2);
        }
        onHideCurrentView:
        {
            itemView.visible = false;
        }
        onStartClipHMImg:
        {
            currentIsHomeWorkClipImg = true;
            startClipHMImgs(2);//开始生成作业截图
        }

        onFinishedClipHmImg:
        {
            currentIsHomeWorkClipImg = false;
            finishedClipHmImgs();//生成作业截图结束
        }
    }

    function setHomeWorkListData(objData)
    {
        auditionLessonhomeWork.setHomeWorkListDatas(objData);
    }
    function setHomeWorkdetailData(objData)
    {
        homeWorkDetail.setHomeWorkdetailData(objData);
    }

    function bufferHomeWorkClipImg(imageUrl, imgWidth, imgHeight)
    {
        homeWorkDetail.bufferHomeWorkClipImgs(imageUrl, imgWidth, imgHeight);
    }

    function setCancleInsertHomework()
    {
        insertHomeWorkPower = false;
    }

}
