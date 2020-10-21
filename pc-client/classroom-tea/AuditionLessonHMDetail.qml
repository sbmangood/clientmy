import QtQuick 2.2
import QtQuick.Controls 1.1
import QtWebView 1.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.2
import QtWebEngine 1.4
import "Configuuration.js" as Cfg
/* 课件 课后作业 作业详情 */
Item {
    id:itemView

    property var viewTitleText: "";
    property var viewTimeText: "";
    property var create_time;
    property var lessonWorkId;
    property var update_time;
    property var useTimeTotal;

    property var questionInfoDto;

    property var statusTexts: 0;

    property var curentIsFinishClip: 0;//判断当前截图有没有被全部上传成功 全部上传成功之后发socket命令出去

    property var urlImgList : [];

    signal sendReportImgSocket(var imgarry);//发送当前的需要导入课堂的图片

    signal clipCurrentImg(var questionData,var imgArr);

    signal hideCurrentView();

    signal startClipHMImg();//开始生成作业截图

    signal finishedClipHmImg();//生成作业截图结束

    signal sigShowQuestionDetailView( var allData);//展示题目详情

    onVisibleChanged:
    {
        insertRoomButton.enabled = true;
    }

    Rectangle
    {
        anchors.fill: parent
        color: "white"
    }

    MouseArea
    {
        anchors.fill: parent
    }


    //头部文字显示
    Rectangle
    {
        id:topIndexItem
        width: parent.width
        height: 44 * widthRates
        color: "transparent"

        Image {
            width: 13 * widthRates * 0.7
            height: 21 * widthRates * 0.7
            anchors.left: parent.left
            anchors.leftMargin: 8 * widthRates
            anchors.top:parent.top
            anchors.topMargin: 23 * heightRates
            source: "qrc:/newStyleImg/Back Chevron@2x.png"
            MouseArea
            {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked:
                {
                    itemView.visible = false;
                }
            }
        }

        Text {
            text: viewTitleText
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 18 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 30 * widthRates
            anchors.top:parent.top
            anchors.topMargin: 10 * heightRates
        }

        Text {
            text: viewTimeText
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 12 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 30 * widthRates
            anchors.top:parent.top
            anchors.topMargin: 34 * heightRates
            color: "#666666"
        }

    }

    ListModel
    {
        id:homeWorkDetailModel
    }

    //课后作业
    Rectangle
    {
        width: parent.width - 25 * widthRates
        height: parent.height - topIndexItem.height - 54 * widthRates
        anchors.top:topIndexItem.bottom
        anchors.topMargin: 10 * heightRates
        color: "transparent"
        border.width: 1
        border.color: "#eeeeee"
        radius: 5
        anchors.horizontalCenter: parent.horizontalCenter
        z:20

        Rectangle
        {
            id:topRect
            width: parent.width - 2 * widthRates
            anchors.horizontalCenter: parent.horizontalCenter
            height: width * 44 / 518
            color: "#fbfdff"

            Text {
                text: qsTr("题号/题干")
                color: "#a6adb6"
                font.pixelSize: 13 * heightRate
                elide: Text.ElideRight
                font.family: "Microsoft YaHei"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 20 * widthRates
            }

            Text {
                text: qsTr("学生完成情况")
                color: "#a6adb6"
                font.pixelSize: 13 * heightRate
                elide: Text.ElideRight
                font.family: "Microsoft YaHei"
                anchors.right: parent.right
                anchors.rightMargin: 20 * widthRates
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        ListView//显示所有的课后作业
        {
            id:audioVideoHomeWorkListView
            width:parent.width
            height:parent.height - topRect.height - 20 * widthRates
            anchors.top:topRect.bottom
            model:homeWorkDetailModel
            delegate:audioVideoHomeWorkListViewDelegate
            clip:true

        }

        Component
        {
            id:audioVideoHomeWorkListViewDelegate
            Item{
                width:audioVideoHomeWorkListView.width - 8 * widthRates
                height: webEngine.height < 50 * widthRates ? 50 * widthRates : webEngine.height ;
                Rectangle
                {
                    width: parent.width
                    height: 1
                    color: "#f3f6f9"
                    anchors.bottom: parent.bottom
                    visible: index == 1

                }

                MouseArea
                {
                    width: 20 * widthRates
                    height: 20 * widthRates
                    anchors.left: parent.left
                    anchors.leftMargin: 5 * widthRates
                    anchors.verticalCenter: parent.verticalCenter
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        isBeSelected =  !isBeSelected;

                        if(isBeSelected)
                        {
                            ++statusTexts;
                        }else
                        {
                            --statusTexts;
                        }
                    }

                    Image {
                        anchors.fill: parent
                        source: isBeSelected ? "qrc:/newStyleImg/th_popwindow_btn_selected@2x.png" : "qrc:/newStyleImg/th_popwindow_btn_unselect@2x.png"
                    }
                }

                CheckBox
                {
                    id: checkBoxTh
                    width: 10 * widthRates
                    height: 10 * widthRates
                    anchors.left: parent.left
                    anchors.leftMargin: 5 * widthRates
                    anchors.top: parent.top
                    anchors.topMargin: 13 * widthRates
                    anchors.bottom: parent.top
                    anchors.bottomMargin: 10 * widthRates
                    z: 5
                    opacity: 0.5
                    visible: false
                    onCheckedChanged:
                    {
                        if(checked)
                        {
                            ++statusTexts;
                            isBeSelected = true;
                        }else
                        {
                            --statusTexts;
                            isBeSelected = false;
                        }
                    }

                }
                Text
                {
                    //                    MouseArea
                    //                    {
                    //                        id:textMousearea
                    //                        anchors.fill: parent
                    //                        hoverEnabled: true
                    //                    }
                    text: (index +1) + "." + questionTypeText;
                    //color: textMousearea.containsMouse ?"#ff6633":"#222222";
                    //anchors.centerIn: parent
                    color:"#222222"
                    anchors.left: parent.left
                    anchors.leftMargin: 30 * widthRates
                    // anchors.top: parent.top
                    //                    anchors.topMargin: 10 * widthRates
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 13 * heightRates
                    elide: Text.ElideRight
                    font.family: "Microsoft YaHei"
                }
                MouseArea
                {
                    width: 20 * widthRates
                    height: 20 * widthRates
                    anchors.right: parent.right
                    anchors.rightMargin: 10 * widthRates
                    anchors.verticalCenter: parent.verticalCenter
                    visible:  isRight == 0 || isRight == 1 || isRight == 2
                    onClicked:
                    {
                        isBeSelected =  !isBeSelected;

                        if(isBeSelected)
                        {
                            ++statusTexts;
                        }else
                        {
                            --statusTexts;
                        }
                    }

                    Image {
                        anchors.fill: parent
                        source:
                        {
                            if(isRight == 1)
                            {
                                return "qrc:/newStyleImg/th_popwindow_icon_right@2x.png";
                            }else if( isRight == 0 )
                            {
                                return "qrc:/newStyleImg/th_popwindow_icon_wrong@2x.png"
                            }else if(isRight == 2)
                            {
                                return "qrc:/newStyleImg/th_popwindow_icon_halfright@2x.png"
                            }
                            return "";
                        }
                    }
                }

                Text
                {
                    text: "未完成"
                    visible: isRight == 3
                    color:"#8d9ccc"
                    //anchors.centerIn: parent
                    anchors.right: parent.right
                    anchors.rightMargin: 10 * widthRates
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 13 * heightRates
                    elide: Text.ElideRight
                    font.family: "Microsoft YaHei"
                }
                WebEngineView
                {
                    id:webEngine
                    enabled: false
                    width: audioVideoHomeWorkListView.width / 1.4
                    height: 20 * widthRates
                    anchors.left: parent.left
                    anchors.leftMargin: 90 * widthRates
                    anchors.verticalCenter: parent.verticalCenter

                    onContentsSizeChanged:
                    {
                        webEngine.height = webEngine.contentsSize.height;
                    }

                    Component.onCompleted:
                    {
                        loadHtml(content);
                        // loadHtml("<html > <head> <style> p{font-family:\"Microsoft YaHei\"}    </style></head>" + content + "</html>");
                    }
                }


                MouseArea
                {
                    width: webEngine.width
                    height: webEngine.height
                    anchors.left: parent.left
                    anchors.leftMargin: 90 * widthRates
                    anchors.verticalCenter: parent.verticalCenter

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    z:10
                    onClicked:
                    {
                        sigShowQuestionDetailView(allData);
                    }
                }

                Rectangle
                {
                    width: parent.width
                    height: 1
                    color: "#f3f6f9"
                    anchors.bottom: parent.bottom

                }
            }

        }

    }

    Text {
        id:hasSelectOne
        text:"已选择"
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 14 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15 * heightRates
        anchors.left: parent.left
        anchors.leftMargin: 17 * heightRates
        color: "#666666"
    }
    Text {
        id:hasSelectNumber
        text:statusTexts
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 14 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15 * heightRates
        anchors.left: hasSelectOne.right
        color: "#FF6633"
    }
    Text {
        id:hasSelectTwo
        text:"道"
        font.family: Cfg.DEFAULT_FONT
        font.pixelSize: 14 * heightRate
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15 * heightRates
        anchors.left: hasSelectNumber.right
        color: "#666666"
    }
    Rectangle{
        id:insertRoomButton
        height: 30 * widthRates
        width: height * 5.2
        color:  statusTexts != 0 ? "#ff5000" : "#cccccc"
        radius: 5 * widthRates
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 7 * heightRates
        anchors.right: parent.right
        anchors.rightMargin: 15 * heightRates

        Text {
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 14 * heightRate
            text:  statusTexts == 0 ? qsTr("导入课堂") : (!insertRoomButton.enabled ? "正在导入课堂..." : "导入课堂" )
            color: "white"
            anchors.centerIn: parent
        }
        MouseArea
        {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked:
            {
                urlImgList = [];
                insertRoomButton.enabled = false;
                curentIsFinishClip = statusTexts;
                startClipHMImg();

                sendCurrentSelectQuestion();

            }
        }
    }
    function setHomeWorkdetailData(objData)
    {
        console.log("setHomeWorkdetailData(objData)",objData);
        homeWorkDetailModel.clear();
        statusTexts = 0;
        objData = objData.data;
        create_time = objData.useTimeTotal;
        lessonWorkId = objData.lessonWorkId;
        update_time =  objData.update_time;
        useTimeTotal = objData.useTimeTotal;

        questionInfoDto  = objData.questionInfoDtos;

        for(var a = 0; a<questionInfoDto.length; a++)
        {
            var questionTypeText = "";
            if( questionInfoDto[a].questionType == 1 )
            {
                questionTypeText = "[单选题]";
            }else if( questionInfoDto[a].questionType == 2 )
            {
                questionTypeText = "[多选题]";
            }else if( questionInfoDto[a].questionType == 3 )
            {
                questionTypeText = "[判断题]";
            }else if( questionInfoDto[a].questionType == 4 )
            {
                questionTypeText = "[填空题]";
            }else if( questionInfoDto[a].questionType == 5 )
            {
                questionTypeText = "[简答题]";
            }else if( questionInfoDto[a].questionType == 6 )
            {
                questionTypeText = "[综合题]";
            }
            if(questionTypeText == "")//题的类型有问题就不显示 不然会导致截图导入不成功
            {
                continue;
            }

            var isRight =  questionInfoDto[a].isRight;
            if( questionInfoDto[a].status == 0)
            {
                isRight = 3;//未完成
            }else if(questionInfoDto[a].status == 2)
            {
                isRight = 4;//什么都不显示
            }

            homeWorkDetailModel.append(
                        {
                            "id": questionInfoDto[a].id,
                            "isRight": isRight ,//答案是否正确 0：错误，1：正确，2：半对半错 3 未完成
                            "studentScore": questionInfoDto[a].studentScore,
                            "questionType": questionInfoDto[a].questionType,//题目大类型(1,单选题,2,多选题,3,判断题,4,填空题,5,简答题,6,综合题)
                            "status": questionInfoDto[a].status,//题目状态(0,学生未作2,等待批改4,已批改)
                            "content": questionInfoDto[a].content,//.substr(22)
                            "finishTime": questionInfoDto[a].finishTime,
                            "questionTypeText": questionTypeText,
                            "isBeSelected": false,
                            "hasClipImg": false,
                            "allData":questionInfoDto[a],
                        }
                        )
        }


    }


    function sendCurrentSelectQuestion()
    {
        for( var c = 0; c < homeWorkDetailModel.count; c++ )
        {
            console.log("sendCurrentSelectQuestion(imageUrl)",c,homeWorkDetailModel.get(c).isBeSelected);
            if(homeWorkDetailModel.get(c).isBeSelected && !homeWorkDetailModel.get(c).hasClipImg)
            {
                homeWorkDetailModel.get(c).hasClipImg = true;
                console.log("homeWorkDetailModel.get(c).hasClipImg",homeWorkDetailModel.get(c).hasClipImg);
                if(homeWorkDetailModel.get(c).questionType == 6)
                {
                    homeworkClipImgType = 1;
                }else
                {
                    homeworkClipImgType = 0;
                }
                //获取做题的Img数据
                var urlImgLists = [];
                var alldatas = homeWorkDetailModel.get(c).allData;

                if(alldatas.writeImages != null)
                {
                    urlImgLists = alldatas.writeImages;
                }

                if(alldatas.photos != null)
                {
                    for(var a = 0; a < alldatas.photos.length; a++)
                    {
                        urlImgLists.push(alldatas.photos[a]);
                    }
                }

                clipCurrentImg(homeWorkDetailModel.get(c).allData,urlImgLists);

                break;
            }
        }

    }

    function bufferHomeWorkClipImgs(imageUrl, imgWidth, imgHeight)
    {
        console.log("bufferHomeWorkClipImgs(imageUrl)111",imageUrl, imgWidth, imgHeight);

        //上传到服务器
        var imageNameArr = imageUrl.split("/");
        var imageName = imageNameArr[imageNameArr.length - 1];

        urlImgList.push(
                    {
                        "height":  imgHeight.toString(),
                        "width":  imgWidth.toString(),
                        "imageUrl": loadInforMation.uploadQuestionImgOSS("135920","135920","135920",imageName, imageUrl.toString())
                    })
        --curentIsFinishClip;
        console.log("=====AuditionLe ssonReportView::imagsseUrl====222");
        if(curentIsFinishClip == 0 && urlImgList.length > 0)
        {
            console.log("=====AuditionLe ssonReportView::imagsseUrl====333");
            //发socket出去

            //            for(var a = 0; a < urlImgList.length; a++)
            //            {
            //                console.log("=====AuditionLe ssonReportView::imagsseUrl====",urlImgList[a].imageUrl);
            //            }
            sendReportImgSocket(urlImgList);
            insertRoomButton.enabled = true;
            homeworkClipImgType = -1;//非课后作业截图模式
            finishedClipHmImg();
            hideCurrentView();

            for( var c = 0; c < homeWorkDetailModel.count; c++ )
            {
                homeWorkDetailModel.get(c).hasClipImg = false;
                homeWorkDetailModel.get(c).hasClipImg = false;
            }

        }else
        {
            console.log("=====AuditionLe ssonReportView::imagsseUrl====444");
            sendCurrentSelectQuestion();
        }
    }

}
