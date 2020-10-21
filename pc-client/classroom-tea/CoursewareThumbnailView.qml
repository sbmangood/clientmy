import QtQuick 2.7
import QtQuick.Controls 2.0
import "./Configuuration.js" as Cfg
import QtGraphicalEffects 1.0
import QtWebEngine 1.4
Rectangle {
    id:courseControl
    anchors.fill: parent
    color: "transparent"
    property bool couldClick: true;
    signal sigJumpPage(var indexs);//跳转页
    property string currentCourseId : "";
    property int currenCourseIndex: 1;
    property string currentColumnText: "";

    clip: true

    Rectangle
    {
        anchors.fill: parent
        color: "#111111"
        opacity: 0.8
    }

    MouseArea
    {
        anchors.fill: parent
        onClicked:
        {
            return;
        }
    }

    Timer{
        id: couldClickTimer
        interval: 700
        running: false
        repeat: false
        onTriggered: {
            couldClick = true;
        }
    }
    ListModel {
        id:showImageListViewModel
    }
    ListModel {
        id:currentBeShowImageListModel
    }
    Rectangle
    {
        height: parent.height * 0.843
        width: parent.width * 0.934
        color: "#F7F7F7"
        anchors.centerIn: parent
        radius: 5 * heightRates
        opacity: 1
        //关闭按钮
        MouseArea {
            width: 34 * heightRate
            height: 30 * heightRate
            anchors.right: parent.right
            anchors.top:parent.top
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: {
                parent.parent.visible = false
            }
            onEntered:
            {
                closeimage.source = "qrc:/newStyleImg/closeHover.png"
            }
            onExited:
            {
                closeimage.source = "qrc:/newStyleImg/closeCommon.png"
            }
            onPressed:
            {
                closeimage.source = "qrc:/newStyleImg/closeClick.png"
            }

            Image {
                id: closeimage
                anchors.fill: parent
                source: "qrc:/newStyleImg/closeCommon.png"
            }
        }

        Text {
            id:titleText
            text: currentColumnText
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 18 * heightRate
            color: "#737373"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:parent.top
            anchors.topMargin: 21 * heightRates
        }

        Text {
            text: "——  " //"  ————"
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 18 * heightRate
            color: "#CECECE"
            anchors.right: titleText.left
            anchors.rightMargin: 5 * heightRates
            anchors.top:parent.top
            anchors.topMargin: 21 * heightRates
        }

        Text {
            text: "  ——"
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 18 * heightRate
            color: "#CECECE"
            anchors.left: titleText.right
            anchors.leftMargin: 5 * heightRates
            anchors.top:parent.top
            anchors.topMargin: 21 * heightRates
        }

        GridView {
            id:showCourseImageListView
            height: parent.height * 0.82
            width: parent.width * 0.975
            //model: showImageListViewModel
            model:currentBeShowImageListModel
            clip: true
            cellWidth: showCourseImageListView.width / 3;
            cellHeight: showCourseImageListView.height / 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.0826

            delegate: Item{
                id:imgageDelegate
                width: showCourseImageListView.cellWidth
                height: showCourseImageListView.cellHeight
                property bool imgHasError: false;
                Rectangle {
                    width: parent.width - 20 * heightRate
                    height: width / 1.777
                    anchors.horizontalCenter: parent.horizontalCenter
                    border.width: 2 * heightRates
                    border.color: isBeSelectIndex ? "#FFB578" : "#E3E3E3"
                    radius: 5 * heightRates
                    clip: true

                    Rectangle{
                        id: photoView
                        width: parent.width - 3 * heightRate
                        height:beAddImage.height
                        anchors.centerIn: parent
                        radius: 5 * heightRates
                        visible: false
                    }

                    Image {
                        id: beAddImage
                        width: parent.width - 3 * heightRate
                        height: beAddImage.source.toString().indexOf("whiteBoard.png") != -1 ?  parent.height - 3 * heightRate : parent.height - 5 * heightRate
                        fillMode:beAddImage.source.toString().indexOf("whiteBoard.png") != -1 ? Image.Stretch : Image.PreserveAspectFit
                        anchors.centerIn: parent
                        sourceSize.width: beAddImage.width
                        sourceSize.height: beAddImage.height
                        source: imageFileUrl
                        visible: false
                        onStatusChanged: {
                            if(status == Image.Error)
                            {
                                imgageDelegate.imgHasError = true;
                            }else
                            {
                                imgageDelegate.imgHasError = false;
                            }
                        }

                    }

                    OpacityMask{
                        width: parent.width - 3 * heightRate
                        height: beAddImage.height
                        anchors.centerIn: parent
                        source: beAddImage
                        maskSource: photoView
                        cached: true
                        z:7
                        visible: !questionTitle.visible

                        Text {
                            id:errorText
                            text: "课件图片加载失败"
                            font.family: Cfg.DEFAULT_FONT
                            font.pixelSize: 20 * heightRate
                            color: "#999999"
                            anchors.centerIn: parent
                            visible: imgageDelegate.imgHasError
                        }
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        hoverEnabled: true

                        onEntered:
                        {
                            parent.border.color = "#FFB578";
                        }
                        onExited:
                        {
                            if(isBeSelectIndex)
                            {
                                parent.border.color = "#FFB578";
                            }else
                            {
                                parent.border.color = "#E3E3E3";
                            }


                        }

                        onReleased:
                        {
                            courseControl.visible = false;
                            couldClick = false;
                            couldClickTimer.restart();
                            sigJumpPage(indexTexts - 1);
                            //整理选中数据 model

                        }
                    }

                    MouseArea{
                        width: parent.width *　0.3
                        height: width
                        anchors.top: parent.top
                        anchors.right: parent.right
                        cursorShape: Qt.PointingHandCursor
                        visible: false
                        enabled: false
                        Image{
                            anchors.fill: parent
                            source: "qrc:/cloudImage/addpic_delet@2x.png"
                        }

                        onClicked: {
                            showImageListViewModel.remove(index)
                        }
                    }

                    WebEngineView{
                        id: questionTitle
                        enabled: false
                        width: parent.width - 20 * heightRate
                        height: width / 1.777
                        backgroundColor: "#00000000"
                        visible: false
                        clip: true

                        //右键的时候, 不弹出右键菜单
                        onContextMenuRequested: function(request) {
                            request.accepted = true;
                        }

                        onContentsSizeChanged: {
                            questionTitle.height = questionTitle.contentsSize.height;
                        }

                        Component.onCompleted: {
                            if(contents != "" && imageFileUrl.toString().indexOf("whiteBoard.png") != -1)
                            {
                                visible =  true;
                            }

                            contents = "<html>" + contents + "</html> \n" + "<style> *{font-size:1.5vw!important;} </style>";
                            loadHtml(contents);
                        }
                    }


                }

                Text
                {
                    text: indexTexts
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 18 * heightRate
                    color: "#737373"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 22 * heightRates
                }

            }
        }

    }



    ListModel {
        id:indexListViewViewModel
    }

    MouseArea
    {
        width: 32 * heightRates
        height: 32 * heightRates
        hoverEnabled: true
        anchors.right: indexListView.left
        anchors.rightMargin: 10 * heightRates
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 87 * heightRates
        z:10

        property bool enableClick: !(indexListView.currentIndex == 0) && !(indexListView.currentIndex == -1)
        enabled: enableClick

        onEnabledChanged:
        {
            backImg.source = enabled ? "qrc:/newStyleImg/backCommon.png" : "qrc:/newStyleImg/backDisable.png";
        }

        Image {
            id:backImg
            anchors.fill: parent
            source: parent.enabled ? "qrc:/newStyleImg/backCommon.png" : "qrc:/newStyleImg/backDisable.png"
        }

        onPressed:
        {
            backImg.source = "qrc:/newStyleImg/backClick.png"
        }
        onReleased:
        {
            if(enableClick)
            {
                backImg.source = "qrc:/newStyleImg/backCommon.png"
            }else
            {
                backImg.source = "qrc:/newStyleImg/backDisable.png"
            }
            --indexListView.currentIndex;
            getCurrentBeShowData(indexListView.currentIndex * 6 + 1);
            currenCourseIndex = indexListView.currentIndex * 6 + 1;
        }

        onExited:
        {
            if(enableClick)
            {
                backImg.source = "qrc:/newStyleImg/backCommon.png"
            }else
            {
                backImg.source = "qrc:/newStyleImg/backDisable.png"
            }
        }

        onEntered:
        {
            backImg.source = "qrc:/newStyleImg/backHover.png"
        }

    }


    ListView{
        id:indexListView
        orientation: ListView.Horizontal
        height: 50 * heightRate
        width: indexListViewViewModel.count > 10 ? 370 * heightRate : (indexListViewViewModel.count) * 48 * heightRate
        model: indexListViewViewModel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 85 * heightRates
        clip: true
        delegate: Item{
            width: 43 * heightRates
            height: 50 * heightRates

            Rectangle {
                width: 37 * heightRate
                height: 37 * heightRate
                anchors.centerIn: parent
                radius: 3 * heightRates
                color: (Math.ceil( currenCourseIndex / 6) - 1) == index ? "#FF8C44" : "#FFFFFF"
                border.width: 1
                border.color: (Math.ceil( currenCourseIndex / 6) - 1) == index ? "#FF8B41" : "#E9E9E9"
                Text {
                    text: currentIndex
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    color:  ((Math.ceil( currenCourseIndex / 6) - 1) == index ? "white" : indexMouse.containsMouse ? "#FF8B41" : "#737373")
                    anchors.centerIn: parent
                }

                MouseArea
                {
                    id:indexMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked:
                    {
                        indexListView.currentIndex = index;
                        getCurrentBeShowData(index * 6 + 1);
                        currenCourseIndex = index * 6 + 1;

                    }
                    onEntered:
                    {
                        parent.border.color = "#FF8B41";
                    }

                    onExited:
                    {
                        parent.border.color = "#E9E9E9";
                    }
                }

            }

        }
    }

    MouseArea
    {
        width: 32 * heightRates
        height: 32 * heightRates
        hoverEnabled: true
        anchors.left: indexListView.right
        anchors.leftMargin: 13 * heightRates
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 87 * heightRates
        z:10

        property bool enableClick: indexListView.currentIndex != indexListViewViewModel.count - 1
        enabled: enableClick

        onEnabledChanged:
        {
            nextImg.source = enabled ? "qrc:/newStyleImg/nextCommon.png" : "qrc:/newStyleImg/nextDisable.png";
        }

        Image {
            id:nextImg
            anchors.fill: parent
            source: parent.enabled ? "qrc:/newStyleImg/nextCommon.png" : "qrc:/newStyleImg/nextDisable.png"
        }

        onPressed:
        {
            nextImg.source = "qrc:/newStyleImg/nextClick.png"
        }
        onReleased:
        {
            if(enableClick)
            {
                nextImg.source = "qrc:/newStyleImg/nextCommon.png"
            }else
            {
                nextImg.source = "qrc:/newStyleImg/nextDisable.png"
            }
            ++indexListView.currentIndex;
            getCurrentBeShowData(indexListView.currentIndex * 6 + 1);
            currenCourseIndex = indexListView.currentIndex * 6 + 1;
        }

        onExited:
        {
            if(enableClick)
            {
                nextImg.source = "qrc:/newStyleImg/nextCommon.png"
            }else
            {
                nextImg.source = "qrc:/newStyleImg/nextDisable.png"
            }
        }

        onEntered:
        {
            nextImg.source = "qrc:/newStyleImg/nextHover.png"
        }

    }


    function resetAllBeShowedCourseData(viewData,contentArray,courseId,courseIndex)
    {
        if(currentCourseId == courseId )
        {
            if(showImageListViewModel.count == viewData.length)
            {
                return;
            }
        }
        currentCourseId = courseId;

        showImageListViewModel.clear();
        console.log("resetAllBeShowedCourseData",courseIndex,showImageListViewModel.count,viewData,contentArray)
        for(var a = 0; a < viewData.length; a++)
        {
            showImageListViewModel.append({
                                              "imageFileUrl":viewData[a] == "" ? "qrc:/newStyleImg/whiteBoard.png" : viewData[a],
                                                                                 "isBeSelectIndex":false,
                                                                                 "contents":contentArray[a]
                                          })
        }

        showImageListViewModel.setProperty(currenCourseIndex - 1,"isBeSelectIndex",false);
        showImageListViewModel.setProperty(courseIndex - 1,"isBeSelectIndex",true);
        currenCourseIndex = courseIndex;

        //计算index的数组大小 indexListViewViewModel
        indexListViewViewModel.clear();
        var arrySize = Math.ceil(viewData.length / 6)
        console.log("indexListViewViewModel",arrySize)
        for(var b = 0; b < arrySize; b++)
        {
            indexListViewViewModel.append(
                        {
                            "currentIndex": b + 1
                        })
        }
        getCurrentBeShowData(courseIndex);
    }

    function resetCurrentBeShowedCoursedata(courseIndex)
    {
        if(courseIndex <= showImageListViewModel.count)
        {
            resetSelectItem(courseIndex);
            currenCourseIndex = courseIndex;
            getCurrentBeShowData(courseIndex);
        }
    }

    function getCurrentBeShowData(courseIndex)
    {
        //获取当前要显示的数据值
        console.log("getCurrentBeShowData",courseIndex)
        var startIndex = (Math.ceil(courseIndex / 6) - 1) * 6

        currentBeShowImageListModel.clear();
        var runTimes = 0;
        for(var c = startIndex; c < showImageListViewModel.count && runTimes < 6; c++ ,runTimes ++)
        {
            //console.log("getCurrentBeShowData(courseIndex)",courseIndex,"",startIndex," ",c,showImageListViewModel.get(c).contents)
            currentBeShowImageListModel.append({
                                                   "imageFileUrl":showImageListViewModel.get(c).imageFileUrl,
                                                   "isBeSelectIndex":showImageListViewModel.get(c).isBeSelectIndex,
                                                   "indexTexts": c + 1,
                                                   "contents":showImageListViewModel.get(c).contents
                                               })
        }
    }

    function resetSelectItem(indexTexts)
    {
        for(var d = 0; d < showImageListViewModel.count; d ++)
        {
            showImageListViewModel.setProperty(d,"isBeSelectIndex",false);
        }
        showImageListViewModel.setProperty(indexTexts - 1,"isBeSelectIndex",true);
    }

    function insertPage(currentPage)
    {
        showImageListViewModel.insert(currentPage - 1,{
                                          "imageFileUrl":""
                                      })
    }

    function removePage(currentPage)
    {

    }

}
