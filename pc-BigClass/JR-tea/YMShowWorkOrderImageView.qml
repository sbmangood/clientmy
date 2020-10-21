import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import "./Configuration.js" as Cfg

MouseArea {
    id: showImageView
    anchors.fill: parent
    property int  childCurrentIndex: 0;
    property string currentBeShowedCoursewareId:"";//当前被显示的课件的Id
    onVisibleChanged:
    {
        if(visible)
        {
        }
    }
    ListModel//当前被显示的课件图片文件的urlList
    {
        id:currentBeShowedImageList;
    }
    MouseArea{
        width: 20 * widthRate
        height: 20 * widthRate
        anchors.right: parent.right
        anchors.rightMargin: 10 * widthRate
        anchors.top: parent.top
        anchors.topMargin: 10 * widthRate
        cursorShape: Qt.PointingHandCursor
        z:10
        Image{
            anchors.fill: parent
            source: "qrc:/images/bar_btn_close (2).png"
        }
        onClicked: {
            showImageView.visible = false;
        }
    }
    Rectangle{
        anchors.fill: parent
        color: "black"
        opacity: 0.4
        radius: 12 * heightRate
    }

    Rectangle{
        id: showImageRectangle
        width: parent.width - 50 * heightRate
        height:  parent.height - 50 * heightRate
        radius: 12 * widthRate
        color: "transparent"
        Drag.active: dragArea.drag.active
        Drag.hotSpot.x: 10
        Drag.hotSpot.y: 10
        Drag.supportedActions: Qt.CopyAction;
        Drag.mimeData: {"color": color, "width": width, "height": height};

        Image {
            id: viewToShowImage
            fillMode: Image.PreserveAspectFit
            anchors.fill: parent
            source: ""
            cache: true
            antialiasing: true
            smooth: true
            mipmap: true
        }

        MouseArea
        {
            id:dragArea
            anchors.fill: parent
            drag.target: showImageRectangle
            //            drag.maximumY:parent.height
            //            drag.maximumX: parent.width
            //            drag.minimumX: - parent.width
            //            drag.minimumY:- parent.height
            onWheel: {
                if (wheel.angleDelta.y > 0) {
                    showImageRectangle.width += 30;
                    showImageRectangle.x -= 15
                    showImageRectangle.height += 30 ;
                    showImageRectangle.y -= 16
                }else
                {
                    if(showImageRectangle.width>showImageRectangle.parent.width/2)
                    {
                        showImageRectangle.width -= 30 ;
                        showImageRectangle.x += 15
                        showImageRectangle.height -= 30 ;
                        showImageRectangle.y += 16
                    }
                }
            }
            onClicked:
            {
                console.log("dsasadsad")
            }

        }

    }
    Timer {
        id:runningTimer
        interval: 3000;
        running: false;
        repeat: false;
        onTriggered:
        {
            cursoRemindRectangle.visible=false
        }
    }
    Rectangle//显示上一个image
    {
        id:previousImageRectangle
        height: 50*parent.width/966.0
        width: 50*parent.width/966.0
        color:"transparent"
        x:35*parent.width/966.0
        y:parent.height/2-previousImageRectangle.height/2
        focus: true
        MouseArea
        {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked:
            {
                if(childCurrentIndex!=0)
                {
                    if(childCurrentIndex<currentBeShowedImageList.count)
                    {
                        childCurrentIndex=childCurrentIndex-1;
                        viewToShowImage.source=currentBeShowedImageList.get(childCurrentIndex).imageUrl;

                    }
                }else
                {
                    tipText.text="已经是第一页了"
                    cursoRemindRectangle.visible=true
                    runningTimer.running=true
                }
            }
        }
        Image {
            id: showImageShowPreviousImage
            source: childCurrentIndex!=0 ? "qrc:/images/right@2x.png" : "qrc:/images/ckkj_btn_right_none@2x.png"
            anchors.centerIn:parent
            anchors.fill: parent
        }


    }
    Rectangle//显示下一个image
    {
        id:nextImageRectangle
        height: 50*parent.width/966.0
        width: 50*parent.width/966.0
        color:"transparent"
        x:parent.width- 35*parent.width/966.0-nextImageRectangle.width
        y:parent.height/2-nextImageRectangle.height/2
        MouseArea
        {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked:
            {
                //console.log("click",currentBeShowedImageList.count);

                if(childCurrentIndex<currentBeShowedImageList.count-1)
                {
                    childCurrentIndex=childCurrentIndex+1;
                    viewToShowImage.source=currentBeShowedImageList.get(childCurrentIndex).imageUrl;

                }else
                {
                    //最后一页了 给提示
                    tipText.text="已经是最后一页了"
                    cursoRemindRectangle.visible=true
                    runningTimer.running=true

                }

            }
        }
        Image {
            id: showImageShowNextImage
            source: childCurrentIndex<currentBeShowedImageList.count-1 ? "qrc:/images/left@2x.png" : "qrc:/images/ckkj_btn_left_none@2x.png"
            anchors.centerIn:parent
            anchors.fill: parent
            //fillMode: Image.PreserveAspectFit
        }

    }
    Rectangle
    {
        id:cursoRemindRectangle
        color:"#3c3c3e"
        opacity: 0.7
        width: 400*heightRate
        height:30*heightRate
        visible: false
        //anchors.centerIn: parent
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12*heightRate
        x:(parent.width-width)/2
        clip: true
        radius: 4 * heightRate
        Text {
            id: tipText
            text: qsTr("")
            anchors.centerIn: parent
            font.pixelSize:16*heightRate
            //font.bold: true

            color: "white"

        }
    }
    function onShowImage(datalist)
    {
        showImageRectangle.width = showImageView.width - 50 * heightRate
        showImageRectangle.height = showImageView.height - 50 * heightRate
        showImageRectangle.x = (showImageView.width - showImageRectangle.width)/2;
        showImageRectangle.y = (showImageView.height - showImageRectangle.height)/2;

        showImageView.visible = true;
        childCurrentIndex=0;//重设课件显示页数
        currentBeShowedImageList.clear();//重设显示页数据list
        //重设课件List数据
        //console.log("onCoursewareListViewItemClick",datalist.length);
        for(var a=0;a<datalist.length;a++)
        {
            currentBeShowedImageList.append({imageUrl:datalist[a],index:a})
        }
        //初始化显示第一页
        if(currentBeShowedImageList.count>0)
        {
            viewToShowImage.source=currentBeShowedImageList.get(0).imageUrl;
            //console.log("onCoursewareListViewItemClick",currentBeShowedImageList.get(0).imageUrl);
        }else
        {
            viewToShowImage.source="";
        }
    }
}
