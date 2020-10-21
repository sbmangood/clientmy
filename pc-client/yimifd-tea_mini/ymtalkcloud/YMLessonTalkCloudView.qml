import QtQuick 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import YMLessonManagerAdapter 1.0
import "../Configuration.js" as Cfg

/*
*我的课程
*/

MouseArea {
    id: btnArea
    hoverEnabled: true
    focus: true

    property int pageIndex: 1;//当前页
    property int pageSize: 9;//每页显示多少条数据

    signal sigCourseCatalog(var id,var dataJson,var currentPage);//课程目录信号
    signal sigRoback();

    //按键盘上下进行滚动页面
    Keys.onPressed: {
        switch(event.key) {
        case Qt.Key_Up:
            if(talkCloudGridView.contentY > 0){
                talkCloudGridView.contentY -= 20;
            }
            break;
        case Qt.Key_Down:
            if(button.y < scrollbar.height - button.height){
                talkCloudGridView.contentY += 20;
            }
            break;
        default:
            return;
        }
        event.accepted = true
    }


    Rectangle {
        id:noLessonItem
        anchors.fill: parent
        color: "white"
        border.color: "#e0e0e0"
        border.width: 1
        radius: 12
        z:1000
        visible: false

        Item {
            width: parent.width * 0.5
            height: parent.height * 0.5
            anchors.centerIn: parent

            Image {
                id:noLessonImage
                width: 161 * widthRate
                height: 150 * widthRate
                source: "qrc:/talkcloudImage/bg_kong.png"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * widthRate
                color: "#666666"
                text: "暂时没有课程哦~~"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top:noLessonImage.bottom
            }
        }
    }

    YMPagingControl{
        id: pageView
        z: 66
        anchors.bottom: parent.bottom
        visible: true
        onPageChanged: {
            pageIndex = page;
            refreshPage();
        }
        onPervPage: {
            pageIndex -= 1;
            refreshPage();
        }
        onNextPage: {
            pageIndex += 1;
            refreshPage();
        }
    }

    YMLessonManagerAdapter{
        id: lessonMgr

        onSigMyLessonInfo: {
            //console.log("====mylessonInfo===",JSON.stringify(lessonInfo));
            if(lessonInfo.data == {} || lessonInfo.data == undefined){
                noLessonImage.visible = true;
                return;
            }
            noLessonImage.visible = false;
            talkCloudModel.clear();
            var totalNumber = lessonInfo.data.total;//总多少条数据
            pageView.totalPage = Math.ceil(totalNumber / pageSize);

            console.log("====11111111111====",totalNumber,pageView.totalPage);

            var dataList = lessonInfo.data.list;
            for(var i = 0; i < dataList.length; i++){
                var dataListObj = dataList[i];
                talkCloudModel.append(
                            {
                                currentIndexs: (i + 1).toString(),
                                classId: dataListObj.classId,
                                name: dataListObj.name,
                                bigCoverUrl: dataListObj.bigCoverUrl,
                                categoryName: dataListObj.categoryName,
                                startTime: dataListObj.startTime,
                                endTime: dataListObj.endTime,
                                teachText: "测试",
                                headImagUrl: "qrc:/images/index_profile_defult@2x.png",
                            });
            }
        }
    }

    //滚动条
    Item {
        id: scrollbar
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 12 * heightRate
        width:10 * widthRate
        height: parent.height - 20 * heightRate
        z: 23
        Rectangle{
            width: 2
            height: parent.height
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        // 按钮
        Rectangle {
            id: button
            x: 2
            y: talkCloudGridView.visibleArea.yPosition * scrollbar.height
            width: 6 * widthRate
            height: talkCloudGridView.visibleArea.heightRatio * scrollbar.height

            color: "#cccccc"
            radius: 4 * widthRate

            // 鼠标区域
            MouseArea {
                id: mouseArea
                anchors.fill: button
                drag.target: button
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY: scrollbar.height - button.height
                cursorShape: Qt.PointingHandCursor
                // 拖动
                onMouseYChanged: {
                    talkCloudGridView.contentY = button.y / scrollbar.height * talkCloudGridView.contentHeight
                }
            }
        }
    }

    Item{
        width: parent.width - 60 * heightRate
        height: parent.height - 60 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 30 * heightRate

        GridView{
            id: talkCloudGridView
            anchors.fill: parent
            clip: true
            cellWidth: parent.width / 3 //- 6 * heightRate
            cellHeight: 250 * widthRate
            model: talkCloudModel
            delegate: talkcomponent

            onContentYChanged: {
                if(contentY >= contentHeight - height && pageView.currentPage == pageView.totalPage){
                    tipsText.visible = true;
                }else{
                    tipsText.visible = false;
                }
            }
        }
        Text {
            id: tipsText
            z: 66
            visible: false
            color: "#666666"
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * heightRate
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("没有更多课程了")
        }
    }

    ListModel{
        id: talkCloudModel
    }

    Component{
        id: talkcomponent
        Item{
            width: talkCloudGridView.cellWidth - 20 * heightRate
            height: talkCloudGridView.cellHeight - 20 * heightRate

            //点击按钮
            MouseArea{
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                //背景颜色
                Rectangle{
                    color: "#f9f9f9"
                    width: parent.width
                    height: parent.height
                    anchors.centerIn: parent
                    radius: 4 * heightRate
                }

                onClicked: {
                    var jsonData = {
                        "classId": classId,
                        "name": model.name,
                        "teachText": teachText,
                        "bigCoverUrl": bigCoverUrl,
                        "categoryName": categoryName,
                        "startTime": startTime,
                        "endTime":endTime,
                    }
                    sigCourseCatalog(classId,jsonData,pageIndex);
                }
            }

            //课程图文
            Image{
                id: lessonImg
                width: parent.width - 4
                height: 150 * widthRate
                source: bigCoverUrl
                anchors.top: parent.top
                anchors.topMargin: 1
                anchors.horizontalCenter: parent.horizontalCenter
                sourceSize.width: width
                sourceSize.height: height
                asynchronous: true
            }

            Text{
                id: classText
                width: parent.width - 12 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: 12 * heightRate
                anchors.top: lessonImg.bottom
                anchors.topMargin: 12 * widthRate
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 16 * heightRate
                color: "#333333"
                text: model.name
                wrapMode: Text.WordWrap
            }

            Column{
                width: parent.width - lessonImg.width - 20 * heightRate
                height: parent.height - 45 * heightRate
                anchors.top: classText.bottom
                anchors.topMargin: 12 * widthRate
                anchors.left: parent.left
                anchors.leftMargin: 12 * heightRate
                spacing: 12 * widthRate

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    text: qsTr("开课时间：") + categoryName
                    color: "#666666"
                }

                Text {
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    text: qsTr("上课时段：") + startTime + "-" + endTime
                    color: "#666666"
                }

                //头像和老师名称
                Item{
                    id: headButton
                    width: 35 * heightRate
                    height: 35 * heightRate
                    visible: false

                    Rectangle{
                        id: rundItem
                        radius: 100
                        width: 30 * heightRate
                        height: 30 * heightRate
                        anchors.centerIn: parent
                        Image{
                            anchors.fill: parent
                            source: "qrc:/images/index_profile_defult@2x.png"
                        }
                    }

                    Image{
                        id: headImage
                        visible: false
                        width: 30 * heightRate
                        height: 30 * heightRate
                        anchors.centerIn: parent
                        source: headImagUrl == "" ? "qrc:/images/index_profile_defult@2x.png" : headImagUrl
                        smooth: false

                        Image{
                            id: towImg
                            anchors.fill: parent
                            source: "qrc:/images/index_profile_defult@2x.png"
                        }
                    }

                    OpacityMask{
                        anchors.fill: rundItem
                        source: headImage
                        maskSource: rundItem
                    }

                    Text{
                        text: teachText
                        anchors.left: rundItem.right
                        anchors.leftMargin: 10 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 10 * heightRate
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#666666"
                    }
                }
            }

        }
    }

    function refreshPage(){
        talkCloudClassroom.visible = false;
        talkCloudClassroom.resetWebViewUrl("1");        
        pageView.currentPage = pageIndex;
        lessonMgr.getMyLessonInfo(pageIndex,pageSize);
    }

    function resetValue(){
        pageIndex = 1;
        pageView.currentPage = 1;
        pageView.totalPage = 1;
    }

}
