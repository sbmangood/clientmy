import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import "Configuration.js" as Cfg

import YMHomeworkManagerAdapter 1.0
import YMHomeworkWrittingBoard 1.0
/*
添加作业答案页面

//综合体答案提交逻辑
题目翻页时 缓存题目答案数据  点击做好了的时候  使用 答案图片 触发提交 所有的题目答案

*/
Rectangle {
    // border.color: "lightblue"
    //border.width: 1
    property var hasShowedImageModelList: [];
    signal addWrittingAnswer();

    //题目做好了信号
    signal sigFinishedWork( var imageUrlString);

    //查看解析信号
    signal sigShowAnswerDetail();
    //显示被添加的图片
    signal sigShowAddAnswerPhoto(var imageFileUrl);
    //删除图片确认
    signal sigDeleteImageTip();
    property int currentDeleteImageIndex: -1;//当前要删除图片所在的索引位置
    //显示模式 1 单选 多选 判断模式  2 需要添加手写的 模式  3 做好后的讲评模式
    property int currentBeShowedModel : -1;

    property var currentBeShowedQId : "" ;

    property bool answerSubmitting: false;//当前是否正在提交答案

    property  bool pageItemVisable: false;

    //是否允许点击 批改和答案解析
    property bool whetherAllowedClick: true

    onVisibleChanged:
    {
        visible =  false;
    }

    onCurrentBeShowedModelChanged:
    {
        //addWrittingBottomView.visible = false;
        console.log("onCurrentBeShowedModelChanged:",currentBeShowedModel)

        if(currentBeShowedModel == -1 ){return;}
        console.log("onCurrentBeShowedModelChanged:",currentBeShowedModel,hasShowedImageModelList.length,currentBeShowedQId);

        if(currentBeShowedModel == 2)
        {
            showUploadImageListViewModel.clear();
            for(var a = 0 ; a<hasShowedImageModelList.length; a++)
            {
                if(hasShowedImageModelList[a].id == currentBeShowedQId )
                {
                    var tempLists = hasShowedImageModelList[a].imageData;//id
                    var froms = hasShowedImageModelList[a].from;//id
                    for(var b = 0; b < tempLists.length; b++)
                    {
                        showUploadImageListViewModel.append({
                                                                "imageFileUrl":tempLists[b],
                                                                "from": froms[b]
                                                            })
                    }
                }

            }
            //addWrittingBottomView.visible = true;
        }
    }


    //显示大题的上一个或下一个题
    signal sigPage(string status)//pre:上一题、next:下一题

    //    MouseArea {
    //        anchors.fill: parent
    //        onPressed: {
    //            return;
    //        }
    //    }

    ListModel
    {
        id:showUploadImageListViewModel
    }
    Rectangle
    {
        id:addWrittingView
        color: "white"
        width: midWidth
        height: midHeight - 50  * fullHeights / 900
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: -3 * heightRate
        z:10
        visible: false
        onVisibleChanged:
        {
            homeworkWrittingBoard.clearScreen();
        }
        YMHomeworkWrittingBoard
        {
            id:homeworkWrittingBoard
            anchors.fill: parent
            onSigBeSavedGrapAnswer:
            {
                console.log("onSigBeSavedGrapAnswer",imageUrl.toString())
                showUploadImageListViewModel.append({
                                                        "imageFileUrl": "file:///" + imageUrl.toString(),
                                                        "from":"write"
                                                    })
                addWrittingView.visible = false;

            }
        }
    }
    //底部操作区
    Rectangle
    {
        width: parent.width - 70 * heightRate
        height: 105 * heightRate
        color: "transparent"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        Row
        {
            id:addWrittingBottomView
            anchors.fill: parent
            spacing: 40 * heightRate
            visible:  currentBeShowedModel == 2 ? ( addWrittingView.visible ? false : true ) : false
            Rectangle {
                height: 60 * heightRate
                width: 120 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                enabled: showUploadImageListViewModel.count < 5
                Image {
                    id:tempimage
                    width: 50 * heightRate
                    height: width
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    source:addWriteMouseArea.containsMouse ? "qrc:/images/btn_shouxie@2x.png" : "qrc:/images/btn_shouxie_disable@2x.png"//btn_shouxie@2x
                }
                Text {
                    //height:parent.height
                    text: qsTr("添加手写")
                    //                    verticalAlignment: Text.AlignVCenter
                    //                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left:tempimage.right
                    anchors.rightMargin: 10 * heightRate
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    color: addWriteMouseArea.containsMouse ? "#ff5000" : "#666666";
                }

                MouseArea
                {
                    id:addWriteMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        addWrittingView.visible = true;
                        //隐藏做好了按钮
                        hasFinishedButton.visible = false;
                        pageItemVisable = pageItem.visible;
                        pageItem.visible = false;
                    }
                }
            }

            Rectangle {
                height: 60 * heightRate
                width: 120 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                enabled: showUploadImageListViewModel.count < 5
                Image {
                    id:tempimage1
                    width: 50 * heightRate
                    height: width
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    source:addImageMouseArea.containsMouse ? "qrc:/images/btn_zhaopian@2x.png" : "qrc:/images/btn_zhaopian_disable@2x.png"//btn_shouxie@2x
                }
                Text {
                    //height:parent.height
                    text: qsTr("添加图片")
                    //                    verticalAlignment: Text.AlignVCenter
                    //                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left:tempimage1.right
                    anchors.rightMargin: 10 * heightRate
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    color: addImageMouseArea.containsMouse ? "#ff5000" : "#666666";
                }

                MouseArea
                {
                    id:addImageMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        fileDialog.open();
                    }

                }
            }
            //上传图片显示区
            ListView
            {
                id:showUploadImageListView
                height: parent.height //- 10 * heightRate
                width: parent.width * 0.4
                model: showUploadImageListViewModel
                orientation: ListView.Horizontal
                clip: true
                anchors.verticalCenter: parent.verticalCenter
                snapMode: ListView.SnapOneItem
                boundsBehavior: ListView.StopAtBounds
                delegate: Rectangle
                {
                    width: showUploadImageListView.height //- 10 * heightRate
                    height: showUploadImageListView.height //- 10 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                    color: "transparent"

                    Rectangle
                    {
                        width: showUploadImageListView.height - 15 * heightRate
                        height: showUploadImageListView.height - 15 * heightRate
                        anchors.centerIn: parent
                        Image {
                            id: beAddImage
                            anchors.fill: parent
                            source: imageFileUrl
                            sourceSize.width: parent.width
                            sourceSize.height: parent.height

                            MouseArea
                            {
                                anchors.fill: parent
                                onClicked:
                                {
                                    sigShowAddAnswerPhoto(imageFileUrl);
                                }
                            }
                        }

                        Image {
                            width: parent.width *　0.3
                            height: width
                            anchors.top: parent.top
                            anchors.right: parent.right
                            source: "qrc:/images/addpic_delet@2x.png"

                            MouseArea
                            {
                                anchors.fill: parent
                                onClicked:
                                {
                                    console.log("remove photo click",index)
                                    currentDeleteImageIndex = index;
                                    sigDeleteImageTip();
                                    //showUploadImageListViewModel.remove(index)
                                }
                            }
                        }
                    }
                }
            }

        }

        //写字板底部操作区
        Row
        {
            visible: addWrittingView.visible
            anchors.fill: parent
            spacing: 15 * heightRate
            Rectangle
            {
                width: parent.width * 0.62 + 50 * heightRate
                height: parent.height
                color: "transparent"
            }
            Image {
                source: "qrc:/images/shouxie_btn_bg@2x.png"
                width: 270 * heightRate
                height:  width / 3.3
                anchors.verticalCenter: parent.verticalCenter
                Rectangle
                {
                    width: 250 * heightRate
                    height:  width / 4.3
                    anchors.centerIn: parent
                    radius: 5 * heightRate
                    color: "transparent"

                    Image {
                        id:image1
                        width: 30 * heightRate
                        height: 33 * heightRate
                        source: "qrc:/images/th_btn_chexiao@2x.png" // gray th_btn_chexiao_disable@2x
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 25 * heightRate
                        MouseArea
                        {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                            {
                                homeworkWrittingBoard.undo();
                            }
                        }
                    }

                    Image {
                        width: 30 * heightRate
                        height: 33 * heightRate
                        source: "qrc:/images/th_btn_xiayibu@2x.png" // gray th_btn_xiayibu_disable@2x
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: image1.right
                        anchors.leftMargin: 50 * heightRate
                        MouseArea
                        {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                            {
                                console.log("dasddddddddddddddddddddddd")
                                homeworkWrittingBoard.fallback();
                            }
                        }
                    }
                    Image {
                        width: 30 * heightRate
                        height: 33 * heightRate
                        source: "qrc:/images/th_btn_shanchu@2x.png" // gray th_btn_shanchu_disable@2x
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 30 * heightRate
                        MouseArea
                        {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                            {
                                homeworkWrittingBoard.clearScreen();
                            }
                        }
                    }
                }
            }

            Rectangle
            {
                width: 100 * heightRate
                height: width / 1.6
                anchors.verticalCenter: parent.verticalCenter
                radius: 5 * heightRate
                color: "transparent"//"transparent"
                Image {
                    width: 120  * heightRate
                    height: width / 1.43
                    source: "qrc:/images/shouxie_btn_cancel@2x.png" // gray th_btn_shanchu_disable@2x
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.centerIn: parent
                }

                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        homeworkWrittingBoard.clearScreen();
                        addWrittingView.visible = false;
                        //显示主界面的 做好了按钮
                        hasFinishedButton.visible = true;
                        pageItem.visible = pageItemVisable;
                    }
                }
            }
            Rectangle
            {
                width: 100 * heightRate
                height: width / 1.6
                anchors.verticalCenter: parent.verticalCenter
                radius: 5 * heightRate
                color: "transparent"
                Image {
                    width: 120  * heightRate
                    height: width / 1.43
                    source: "qrc:/images/shouxie_btn_finish@2x.png" // gray th_btn_shanchu_disable@2x
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.centerIn: parent
                }

                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        homeworkWrittingBoard.grapItemImage(addWrittingView);

                        //显示主界面的 做好了按钮
                        hasFinishedButton.visible = true ;

                        pageItem.visible = pageItemVisable;
                    }
                }
            }

        }

        Rectangle
        {
            id: hasFinishedButton
            width: 220 * heightRate
            height: width / 4
            color: "#ff5000"
            radius: 5 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            //visible: !addWrittingView.visible
            visible: true
            Text {
                id:finishText
                anchors.centerIn: parent
                text: qsTr("做好了")
                font.pixelSize: 18 * heightRate
                font.family: Cfg.DEFAULT_FONT
                color:"white"

                SequentialAnimation {
                    id: textAnimation
                    loops: Animation.Infinite;
                    PropertyAnimation {
                        target: finishText
                        property: "text"
                        to: "答案处理中"
                        duration: 250
                    }
                    PropertyAnimation {
                        target: finishText
                        property: "text"
                        to: "答案处理中."
                        duration: 250
                    }
                    PropertyAnimation {
                        target: finishText
                        property: "text"
                        to: "答案处理中.."
                        duration: 250
                    }
                    PropertyAnimation {
                        target: finishText
                        property: "text"
                        to: "答案处理中..."
                        duration: 250
                    }
                }
            }

            MouseArea
            {
                id:finishMoussare
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked:
                {
                    //判断是否提示 未做好提示 暂时不做
                    if(compositeTopicView.hasDoneQuestionList + 1 < compositeTopicView.allQuestionNumber)
                    {

                    }
                    answerSubmitting = true;
                    finishMoussare.enabled = false;
                    pageItem.visible = false;
                    textAnimation.running = true;
                    //判断当前题目是不是有图没有上传

                    //传图
                    var temiurl = upLoadPhoto();

                    textAnimation.running = false;
                    hasFinishedButton.visible = false;
                    finishText.text = "做好了"
                    finishMoussare.enabled = true;
                    //发信号 自动批改的 发信号出去  非自动批改的 直接显示答案解析老师批改
                    if(currentBeShowedModel == 2 || compositeTopicView.visible == true)
                    {
                        currentBeShowedModel = 1;
                        currentBeShowedModel = -1;
                        sigFinishedWork(temiurl);
                        console.log("teacherCheckButton.visible = true;",temiurl)
                        //显示答案解析 老师批改界面
                        //teacherCheckButton.visible = true;
                        //answerDetailButton.visible = true;
                        //addWrittingBottomView.visible = false;
                    }else
                    {
                        currentBeShowedModel = 1;
                        currentBeShowedModel = -1;
                        console.log("发信号 自动批改的 ");
                        sigFinishedWork(temiurl);
                    }
                    //显示modle判断 显示对应的答案解析 老师批改   选择题做对了不显示老师批改

                    answerSubmitting = false;
                }
            }
        }

        Rectangle{
            id: pageItem
            visible: false
            width: 200 * heightRate
            height: 45 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: hasFinishedButton.left
            anchors.rightMargin: 20 * heightRate
            color:"transparent"
            Rectangle
            {
                id: upButton
                width: parent.width * 0.5
                height: parent.height
                border.width: 1
                border.color: tempMousare.containsMouse ? "#ff5000" : "#666666"
                radius: 5 *　heightRate
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    anchors.centerIn: parent
                    text: qsTr("上一题")
                    font.pixelSize: 18 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    color: tempMousare.containsMouse ? "#ff5000" : "#666666"
                }
                MouseArea{
                    id:tempMousare
                    anchors.fill: parent
                    hoverEnabled: true
                    anchors.verticalCenter: parent.verticalCenter
                    cursorShape: Qt.PointingHandCursor
                    //                        Image {
                    //                            source: parent.containsMouse ? "qrc:/cloudImage/btn_fanye_left_hover@2x.png" :"qrc:/cloudImage/btn_fanye_left@2x.png"
                    //                            anchors.centerIn: parent
                    //                        }
                    onClicked: {
                        sigPage("pre");
                    }
                }
            }
            Rectangle
            {

                width: parent.width * 0.5
                height: parent.height
                border.width: 1
                border.color: tempsMousarea1.containsMouse ? "#ff5000" : "#666666"
                radius: 5 *　heightRate
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: upButton.right
                anchors.leftMargin: 10 * heightRate
                Text {
                    anchors.centerIn: parent
                    text: qsTr("下一题")
                    font.pixelSize: 18 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    color: tempsMousarea1.containsMouse ? "#ff5000" : "#666666"
                }
                MouseArea{
                    id:tempsMousarea1
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    anchors.verticalCenter: parent.verticalCenter
                    //                        Image {
                    //                            source:  parent.containsMouse ? "qrc:/cloudImage/btn_fanye_right_hover@2x.png" :  "qrc:/cloudImage/btn_fanye_right@2x.png"
                    //                            anchors.centerIn: parent
                    //                        }

                    onClicked: {
                        sigPage("next");
                    }
                }
            }
        }


        //答案解析 废弃

        MouseArea {
            id:answerDetailButton
            hoverEnabled: true
            width: 155 * heightRate
            height: width / 3
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            visible: false
            cursorShape: Qt.PointingHandCursor
            onVisibleChanged:
            {
                visible = false;
            }

            Image {
                id:analyButtonImage
                width: parent.width
                height: width / 1.9
                anchors.centerIn: parent
                source: whetherAllowedClick ? ( parent.containsMouse ? "qrc:/cloudImage/btn_daanjiexi_sed@2x.png" : "qrc:/cloudImage/btn_daanjiexi@2x.png" ) : "qrc:/cloudImage/btn_daanjiexi_disable@2x.png";
            }

            onClicked:{

                sigShowAnswerDetail();
            }

        }

        //老师批改 废弃
        MouseArea{
            id:teacherCheckButton
            hoverEnabled: true
            width: 155 * heightRate
            height: width / 3
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: answerDetailButton.left
            anchors.rightMargin: 20 * heightRate
            visible: false
            cursorShape: Qt.PointingHandCursor
            onVisibleChanged:
            {
                visible = false;
            }
            Image{
                width: parent.width
                height: width / 1.9
                anchors.centerIn: parent
                source:whetherAllowedClick ? (  parent.containsMouse ? "qrc:/cloudImage/btn_sd_pigai_Sed@2x.png" : "qrc:/cloudImage/btn_sd_pigai@2x.png" ) : "qrc:/cloudImage/btn_sd_pigai_disable@2x.png"
            }

            onClicked: {

            }
        }


    }

    FileDialog{
        id: fileDialog
        nameFilters: [ "Image files (*.jpg *.png)"]
        title: "请选择图片"
        folder: shortcuts.home
        selectMultiple: false
        onAccepted: {
            console.log("You chose: " + fileDialog.fileUrl)
            showUploadImageListViewModel.append({
                                                    "imageFileUrl":fileDialog.fileUrl.toString(),
                                                    "from":"select"
                                                })
            //console.log("You chose: " , showUploadImageListViewModel.get(0).imageFileUrl)

        }
    }

    //C++方法
    YMHomeworkManagerAdapter
    {
        id:homeworkManagerAdapter
    }

    //上传
    function upLoadPhoto()
    {
        var imgUrlLIst = [];
        var imgUrl = "";
        console.log(" upLoadPhoto() showUploadImageListViewModel.count",showUploadImageListViewModel.count);
        for( var a = 0 ; a < showUploadImageListViewModel.count; a++)
        {
            console.log("showUploadImageListViewModel.get(a).imageFileUrl",showUploadImageListViewModel.get(a).imageFileUrl)
            if(showUploadImageListViewModel.get(a).imageFileUrl != "")
            {
                imgUrlLIst.push(homeworkManagerAdapter.uploadImage(showUploadImageListViewModel.get(a).imageFileUrl,currentOrderNumber,showUploadImageListViewModel.get(a).from));
            }
        }

        //整理上传后的 imageUrl
        for(var tempa = 0 ; tempa < imgUrlLIst.length ; tempa++)
        {
            imgUrl = imgUrl + imgUrlLIst[tempa];
            if(tempa + 1 != imgUrlLIst.length)
            {
                imgUrl = imgUrl + ",";
            }
        }
        console.log("function upLoadPhoto()",imgUrl);
        return imgUrl;
    }

    //根据返回状态（答案对错 等） 来重新显示底部操作区的 对应显示状态
    function resetBottomOperationView( isRight )
    {
        console.log("resetBottomOperationView( isRight )",isRight,currentBeShowedModel)
        answerDetailButton.visible = true;
        if(currentBeShowedModel == 1 &&　isRight)
        {
            teacherCheckButton.visible = false;
            return;
        }
        teacherCheckButton.visible = true;
    }

    function showNextProButton()
    {
        pageItem.visible = true;
        answerDetailButton.visible = false;
        teacherCheckButton.visible = false;
    }

    function showFnishedWorkButton()
    {
        hasFinishedButton.visible = true;
        answerDetailButton.visible = false;
        teacherCheckButton.visible = false;
    }

    function hideTcheckAndAswDetail()
    {
        answerDetailButton.visible = false;
        teacherCheckButton.visible = false;
    }

    function showTcheckAndAswDetail()
    {
        teacherCheckButton.visible = true;
        answerDetailButton.visible = true;
    }

    //根据题目id 存储当前题目的图片信息
    function getCurrentImageUrlList(childQId)
    {
        console.log("根据题目id 存储当前题目的图片信息");
        var imgUrlLIst = [];
        var fromList = [] ;
        for( var a = 0 ; a < showUploadImageListViewModel.count; a++)
        {
            console.log("getCurrentImageUrlList",showUploadImageListViewModel.get(a).imageFileUrl)
            imgUrlLIst.push(showUploadImageListViewModel.get(a).imageFileUrl);
            fromList.push(showUploadImageListViewModel.get(a).from)
        }

        //已存在的id直接替换数据信息
        var hasExits = false;
        for(var b = 0; b < hasShowedImageModelList.length; b++)
        {
            if(hasShowedImageModelList[b].id == childQId )
            {
                hasShowedImageModelList[b].imageData = imgUrlLIst;
                hasShowedImageModelList[b].from = fromList;
                hasExits = true;
            }
        }
        if(!hasExits)
        {
            hasShowedImageModelList.push({"imageData":imgUrlLIst,
                                             "id":childQId,
                                             "from": fromList
                                         });
        }
        //showUploadImageListViewModel.clear();
        return imgUrlLIst;
    }
    //根据题目id上传图片 返回图片地址
    function upLoadPhotoByid( qId,orderNumber)
    {
        for (var a = 0 ;a　<hasShowedImageModelList.length ; a++ )
        {
            if(hasShowedImageModelList[a].id == qId )
            {
                var tempImageList = hasShowedImageModelList[a].imageData;
                var fromss = hasShowedImageModelList[a].from;

                var imgUrlLIst = [];
                var imgUrl = "";

                for( var b = 0 ; b < tempImageList.length; b++)
                {
                    if(tempImageList[b] != "")
                    {
                        imgUrlLIst.push(homeworkManagerAdapter.uploadImage(tempImageList[b],orderNumber,fromss));
                    }
                }

                //整理上传后的 imageUrl
                for(var tempa = 0 ; tempa < imgUrlLIst.length ; tempa++)
                {
                    imgUrl = imgUrl + imgUrlLIst[tempa];
                    if(tempa + 1 != imgUrlLIst.length)
                    {
                        imgUrl = imgUrl + ",";
                    }
                }
                return imgUrl;
            }
        }
    }

    //根据命令 停止答题
    function stopAnswerByOrder()
    {
        addWrittingView.visible = false;
        //传图
        var temiurl = upLoadPhoto();

        hasFinishedButton.visible = false;

        pageItem.visible = false;

        //发信号 自动批改的 发信号出去  非自动批改的 直接显示答案解析老师批改
        if(currentBeShowedModel == 2 || compositeTopicView.visible == true)
        {
            currentBeShowedModel = 1;
            currentBeShowedModel = -1;
            sigFinishedWork(temiurl);
            console.log("teacherCheckButton.visible = true;")
            //显示答案解析 老师批改界面
            //            teacherCheckButton.visible = true;
            //            answerDetailButton.visible = true;
            //addWrittingBottomView.visible = false;

        }else
        {
            currentBeShowedModel = 1;
            currentBeShowedModel = -1;
            console.log("发信号 自动批改的 ");
            sigFinishedWork(temiurl);
        }
        //清空缓存图片的数组
        hasShowedImageModelList.splice( 0,hasShowedImageModelList.length);
    }

    function deleteImage()
    {
        showUploadImageListViewModel.remove(currentDeleteImageIndex);

    }

}
