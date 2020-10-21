import QtQuick 2.2
import QtWebView 1.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtWebEngine 1.4
import "./../Configuration.js" as Cfg
import YMLessonManagerAdapter 1.0
import QtGraphicalEffects 1.0
/***课程表***/

Item {
    anchors.fill: parent
    id:tMiniClassDetail

    property string coverImageUrl: "";

    property string introduceImageUrl: "";


    property var widthRates: widthRate;

    property var classTitleText: ""
    property var classPrice: "800"

    property int currentIndexsss: 1;

    property var currentBufferData;


    function resetDataModel(modelData)
    {
        currentIndexsss = 1;
        currentBufferData = modelData;
        var data = currentBufferData.data;
        data = data.courseInfoDto;
        coverImageUrl = data.smallCoverUrl;
        introduceImageUrl = data.introduction;
        classTitleText = data.name;
        classPrice = data.price;
        var teacherData = data.teachers;
        var chapters = data.chapters;
        introModel.clear();
        introModel.append({
                              introduceImageUrls:introduceImageUrl
                          })
        teacherModel.clear();
        for(var a = 0; a < teacherData.length; a++ )
        {
            teacherModel.append(
                        {
                            teacherId: teacherData[a].teacherId,
                            teachingResults: teacherData[a].teachingResults,
                            teacherImage: teacherData[a].headUrl,
                            teacherName: teacherData[a].teacherName,
                            teacherDeatail: teacherData[a].teachingExperience
                        }
                        )
        }

        planModel.clear();

        for(var a = 0; a < chapters.length; a++ )
        {
            planModel.append(
                        {
                            indextext:chapters[a].className,
                            lessonContext:chapters[a].title
                        }
                        )
            console.log("chapters[a]",chapters[a].className,chapters[a].title)
        }

    }

    Rectangle
    {
        anchors.fill: parent
        color: "white"
        radius: 12
    }
    MouseArea
    {
        anchors.fill: parent
        onClicked:
        {
            return;
        }
    }
    Rectangle
    {
        width: 25 * widthRate
        height: 25 * widthRate
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 15 * widthRate
        anchors.leftMargin: 15 * widthRate
        Image {
            anchors.fill: parent
            source: "qrc:/miniClassImg/xbk_btn_back@2x.png"
        }
        MouseArea
        {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked:
            {
                tMiniClassDetail.visible = false;
            }
        }
    }

    Rectangle
    {
        id:centerRect
        width: parent.width * 0.8956
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#ffffff"
        anchors.top:parent.top
        anchors.topMargin: 0.1 * parent.height

        Row{
            id:tRows
            width: parent.width
            height: parent.height * 0.152
            spacing: 10 * widthRates
            Image {
                id:lessonImage
                width: parent.width * 0.183
                height: width / 1.756
                source: coverImageUrl
            }

            Rectangle
            {
                height: parent.height
                width: parent.width * 0.7

                Text{
                    id: classText
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 16 * widthRates
                    text: classTitleText
                    wrapMode: Text.WordWrap
                    width: parent.width - 15 * widthRates
                    anchors.top:parent.top
                    anchors.topMargin: 5 * widthRates
                    anchors.left: parent.left
                    anchors.leftMargin: 5 * widthRates
                }

                Text{
                    anchors.bottom:parent.bottom
                    //anchors.bottomMargin: 5 * widthRates
                    anchors.left: parent.left
                    anchors.leftMargin: 5 * widthRates
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 16 * widthRates
                    text:"￥" + classPrice
                    wrapMode: Text.WordWrap
                    width: parent.width - 15 * widthRates
                    color: "#ff7777"
                }

            }

            Image {
                height: parent.height
                width: height
                source: "qrc:/miniClassImg/coursedetail_waiting.png"
            }

        }

        Row {
            id:rowsOne
            height: 20 * widthRates
            width: parent.width * 0.427
            spacing: 2 * widthRates
            anchors.top:tRows.bottom
            anchors.topMargin: 40 * widthRates

            Rectangle
            {
                width: parent.width * 0.3
                height:width * 0.363
                Text {
                    id:text1
                    text: qsTr("课程介绍")
                    color:currentIndexsss == 1 ? "#ff6633" : "#666666"
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: 13 * widthRates
                }

                Rectangle
                {
                    width: 53 * widthRates
                    height: 2 * widthRates
                    anchors.top: text1.bottom
                    anchors.topMargin: 5 * widthRates
                    color: currentIndexsss == 1 ? "#ff6633" : "transparent"
                }

                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        currentIndexsss = 1;
                    }
                }

            }

            Rectangle
            {
                width: parent.width * 0.3
                height:width * 0.363
                Text {
                    id:text2
                    text: qsTr("课程安排")
                    color:currentIndexsss == 2 ? "#ff6633" : "#666666"
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: 13 * widthRates
                }
                Rectangle
                {
                    width: 53 * widthRates
                    height: 2 * widthRates
                    anchors.top: text2.bottom
                    anchors.topMargin: 5 * widthRates
                    color: currentIndexsss == 2 ? "#ff6633" : "transparent"
                }
                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        currentIndexsss = 2;
                    }
                }

            }

            Rectangle
            {
                width: parent.width * 0.3
                height:width * 0.363
                Text {
                    id:text3
                    text: qsTr("师资力量")
                    color:currentIndexsss == 3 ? "#ff6633" : "#666666"
                    font.family: Cfg.LEAVE_FAMILY
                    font.pixelSize: 13 * widthRates
                }

                Rectangle
                {
                    width: 53 * widthRates
                    height: 2 * widthRates
                    anchors.top: text3.bottom
                    anchors.topMargin: 5 * widthRates
                    color: currentIndexsss == 3 ? "#ff6633" : "transparent"
                }

                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        currentIndexsss = 3;
                    }
                }
            }
        }
        Rectangle
        {
            width: parent.width
            height: 1
            anchors.top: rowsOne.bottom
            anchors.topMargin: 5 * widthRates
            color: "#eeeeee"
        }

        Item
        {
            width: parent.width
            height:centerRect.height - tRows.height - rowsOne.height - 100 * widthRates
            anchors.top:rowsOne.bottom
            anchors.topMargin: 8 * widthRates
            ListModel{
                id: introModel
            }
            ListModel{
                id: planModel
            }
            ListModel{
                id: teacherModel
            }

            //课程介绍
            Item
            {
                anchors.fill: parent
                ListView{
                    id: introListView
                    clip: true
                    anchors.fill: parent
                    model: introModel
                    visible: currentIndexsss == 1
                    delegate:bodyComponet
                }

                Component{
                    id: bodyComponet
                    Rectangle
                    {
                        width: introListView.width
                        height: bodyText.height //这个高度, 比ListView大的时候, 就默认支持滚动了

                        Text {
                            id: bodyText //自适应图片的高度
                            text: introduceImageUrl
                            width: introListView.width
                            wrapMode: Text.WordWrap
                            font.family: Cfg.DEFAULT_FONT
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            textFormat: Text.StyledText
                        }

                        MouseArea
                        {
                            anchors.fill: parent
                            onClicked:
                            {
                                console.log("introduceImageUrl",introduceImageUrl)
                            }
                        }

                        Component.onCompleted:
                        {
                            console.log("introduceImageUrl",introduceImageUrl)
                        }
                    }
                }
            }


            ListView{
                id: planListView
                clip: true
                anchors.fill: parent
                model: planModel
                visible: currentIndexsss == 2
                delegate: Rectangle
                {
                    color:"transparent"
                    width:parent.width
                    height: 60 * widthRates < idxText.height + texts1.height ? idxText.height + texts1.height : 60 * widthRates
                    Text {
                        id:idxText
                        text: indextext//"第" +  Number(index+1) + "课"
                        font.family: Cfg.LEAVE_FAMILY
                        font.pixelSize: 12 * widthRates
                        wrapMode: Text.WordWrap
                        color: "#bbbbbb"
                        anchors.verticalCenter: parent.verticalCenter
                        z:2
                    }
                    Text {
                        id:texts1
                        text: lessonContext
                        font.family: Cfg.LEAVE_FAMILY
                        font.pixelSize: 12 * widthRates
                        wrapMode: Text.WordWrap
                        width: parent.width - idxText.width - 20 * widthRates
                        color: "#333333"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left:idxText.right
                        anchors.leftMargin: 10 * widthRates
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


            ListView{
                id: teacherListView
                clip: true
                anchors.fill: parent
                model: teacherModel
                visible: currentIndexsss == 3
                delegate: Rectangle
                {
                    width:parent.width
                    height: tImagets.height + tDeatail.height + 15 * widthRates

                    Rectangle{
                        id: rundItem
                        radius: 100
                        width: 50 * heightRate
                        height: 50 * heightRate
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: 10 * widthRates
                        anchors.topMargin: 20 * widthRates
                    }

                    Image {
                        id:tImagets
                        width: 50 * widthRates
                        height: width
                        source: teacherImage == "" ? "qrc:/miniClassImg/defult_profile.png" : teacherImage
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: 10 * widthRates
                        anchors.topMargin: 20 * widthRates
                        visible: false
                    }

                    OpacityMask{
                        anchors.fill: rundItem
                        source: tImagets
                        maskSource: rundItem
                    }

                    Text {
                        text: teacherName
                        font.family: Cfg.LEAVE_FAMILY
                        font.pixelSize: 12 * widthRates
                        width: parent.width
                        wrapMode: Text.WordWrap
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: tImagets.width + 6 * widthRates
                        anchors.topMargin: 18 * widthRates
                        color: "#000000"
                    }

                    Text {
                        id:tDeatail
                        text: teacherDeatail
                        font.family: Cfg.LEAVE_FAMILY
                        font.pixelSize: 12 * widthRates
                        width: parent.width - 50 * widthRates
                        wrapMode: Text.WordWrap
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: tImagets.width + 6 * widthRates
                        anchors.topMargin: 40 * widthRates
                        color:"#333333"
                    }

                    Rectangle
                    {
                        width: parent.width
                        height: 1
                        anchors.bottom: parent.bottom
                        color: "#f3f6f9"
                    }

                }
            }

        }


    }
}
