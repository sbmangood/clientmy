import QtQuick 2.7
import QtQuick.Window 2.2
import "./Configuuration.js" as Cfg
/*显示课件的所有的列表的数据 以及音视频列表  音视频图标 */

Rectangle {

    property  double  zoomWidthRate: Screen.width*0.7/966.0*1.1;
    property bool  audioVideoListViewVisible: false;//用于判断音视频列表是否被显示
    property bool isGetDocFail: false;
    color: "transparent"
    //课件列表
    Rectangle
    {
        id:coursewareListViewRectangle
        width: 330*zoomWidthRate
        height: 260*zoomWidthRate
        //        border.width: 1*zoomWidthRate
        //        border.color: "#c3c6c9"
        radius: 5*zoomWidthRate
        visible: coursewareListViewModel.count > 0 ? mainWindowTop.isOpenedStates : false;

        onVisibleChanged:
        {
            console.log("onVisibleChanged: ",coursewareListViewRectangle.visible)
        }

        Image {
            anchors.fill: parent
            source: "qrc:/images/chakankejian_xialalkuang@2x.png"
        }
        onFocusChanged:
        {
            //gainFocus
        }
        //anchors.centerIn: parent
        anchors.top:parent.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 85 * zoomWidthRate
        color: "transparent"
        clip: true
        MouseArea {
            id: closeButton
            width: 20*zoomWidthRate
            height: 20*zoomWidthRate
            anchors.right: parent.right
            anchors.rightMargin: 6*zoomWidthRate
            anchors.top: parent.top
            anchors.topMargin: 4*zoomWidthRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            visible: false
            Rectangle {
                anchors.fill: parent
                //color: parent.containsMouse ? "red" : "transparent"
                // radius: 10
                color: "transparent"

            }

            Image {
                source: "qrc:/images/cr_btn_quit@2x.png"
                anchors.centerIn: parent
                //  fillMode: Image.Pad
            }

            onClicked: {

            }
        }



        Component
        {
            id:coursewareListViewDelegate

            Item{

                width:coursewareListView.width-8*zoomWidthRate
                height:36*zoomWidthRate;
                // color: "#ffffff"
                //                anchors.leftMargin: 10
                //                anchors.rightMargin: 10

                //color: "gray"
                //radius: 10;//*****
                // anchors.bottomMargin: 10
                MouseArea
                {
                    anchors.fill: parent
                    id:textMousearea
                    hoverEnabled: true
                    Text {
                        anchors.fill: parent
                        text: namess;
                        color: parent.containsMouse ?"#ff6633":"#222222";
                        //anchors.centerIn: parent
                        anchors.left: parent.left
                        anchors.leftMargin: 30*zoomWidthRate
                        anchors.top: parent.top
                        anchors.topMargin: 10*zoomWidthRate
                        anchors.bottom: parent.top
                        anchors.bottomMargin: 10*zoomWidthRate
                        font.pixelSize: 16*zoomWidthRate
                        elide: Text.ElideRight
                        font.family: "Microsoft YaHei"

                    }
                    onClicked:
                    {

                        /*                        //加载课件
                        onCoursewareListViewItemClick(index);
                        //加载音视频文件
                        currentBeShowedCoursewareId=docIds;
                        resetCoursewareAudioVideoList();
                        changesTitleCursewareName(namess)*/
                        hasClicked = true;
                        console.log("hasClickedhasClickedhasClicked",hasClicked)
                        videoToolBackground.resetCourwareView(index + 1);

                    }
                }
            }
        }
        ListView//显示所有的音视频列表
        {
            //anchors.fill:parent
            anchors.top:closeButton.top
            anchors.topMargin:16*zoomWidthRate
            //anchors.centerIn:parent
            width:parent.width
            height:parent.height - 35 * zoomWidthRate
            id:coursewareListView
            model:coursewareListViewModel
            delegate:coursewareListViewDelegate
            clip:true

        }
    }
    //设置此界面是否被显示
    function controlcoursewareListViewRectangleShow()
    {
        coursewareListViewRectangle.visible=!coursewareListViewRectangle.visible;
    }

    ListModel//当前被显示的课件图片文件的urlList
    {
        id:currentBeShowedImageList;
    }

    //一视频文件交互区

    Rectangle//触发显示音视频文件列表的 图标
    {
        id:showAudioVideoRectangle
        height: 80*zoomWidthRate
        width:75*zoomWidthRate
        visible:audioModel.count > 0
        x:parent.width- 35*parent.width/966.0-showAudioVideoRectangle.width
        y:parent.height-showAudioVideoRectangle.height*2
        anchors.right: parent.right
        anchors.rightMargin: 30*zoomWidthRate
        color:"transparent"
        MouseArea
        {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked:
            {
                audioVideoListViewRectangle.visible=!audioVideoListViewRectangle.visible
                //console.log("click",showAudioVideoRectangle.y);
            }
        }
        Image {
            anchors.fill: parent
            source: "qrc:/images/Audio_btn_mv@2x.png"
            anchors.centerIn:parent
            // fillMode: Image.PreserveAspectFit
        }

    }

    Rectangle//音视频文件列表
    {
        id:audioVideoListViewRectangle
        anchors.bottom: showAudioVideoRectangle.top
        anchors.bottomMargin: 30*zoomWidthRate
        anchors.right: parent.right
        anchors.rightMargin: 30*zoomWidthRate
        width: 200*zoomWidthRate
        height: 304/240*100*zoomWidthRate*2
        border.width: 1*zoomWidthRate
        border.color: "#c3c6c9"
        radius: 5*zoomWidthRate
        //        x:696*parent.width/966.0
        //        y:180*parent.height/543.0
        color: "#ffffff"
        visible: audioVideoListViewVisible


        Component
        {
            id:audioVideoListViewDelegate
            Item{
                width:audioVideoListView.width-8*zoomWidthRate
                height:36*zoomWidthRate;
                // color: "#ffffff"
                //                anchors.leftMargin: 10
                //                anchors.rightMargin: 10

                //color: "gray"
                //radius: 10;//*****
                // anchors.bottomMargin: 10
                MouseArea
                {
                    anchors.fill: parent
                    id:textMousearea
                    hoverEnabled: true
                    Text
                    {
                        anchors.fill: parent
                        text: key;

                        color: parent.containsMouse ?"#ff6633":"#222222";
                        //anchors.centerIn: parent
                        anchors.left: parent.left
                        anchors.leftMargin: 20*zoomWidthRate
                        anchors.top: parent.top
                        anchors.topMargin: 10*zoomWidthRate
                        anchors.bottom: parent.top
                        anchors.bottomMargin: 10*zoomWidthRate
                        font.pixelSize: 16*zoomWidthRate
                        elide: Text.ElideRight
                        font.family: "Microsoft YaHei"
                    }
                    onClicked:
                    {
                        audioVideoListViewRectangle.visible = false;
                        videoToolBackground.resetAudioVideoPlayer(values,key);
                    }
                }
            }

        }
        ListView//显示所有的音视频列表
        {
            // anchors.fill:parent
            anchors.centerIn:parent
            width:parent.width
            height:parent.height
            id:audioVideoListView
            model:audioModel
            delegate:audioVideoListViewDelegate
            clip:true
        }
    }



    Image {
        source:idShowClassTrail == true ? "qrc:/images/btn_hide@2x.png" : "qrc:/images/btn_show@2x.png"
       width: 130 * heightRate
        height: width / 2.7
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5 * heightRate
        anchors.left: parent.left
        anchors.leftMargin:  38 * heightRate
        visible: lessonIsFinished == true ? true :false;
        MouseArea
        {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked:
            {
                idShowClassTrail = !idShowClassTrail;
            }
        }

    }


    function hideRectangle()
    {
        audioVideoListViewRectangle.visible = false;
    }

}
