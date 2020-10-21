import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import YMHomeWorkManagerAdapter 1.0
import YMHomeworkWrittingBoard 1.0
import "./Configuuration.js" as Cfg

/*
添加作业答案页面
*/

Rectangle {
//    border.color: "lightblue"
//    border.width: 1

    signal addWrittingAnswer();

    MouseArea {
        anchors.fill: parent
        onPressed: {
            return;
        }
    }

    ListModel {
        id:showUploadImageListViewModel
    }

    Rectangle{
        id:addWrittingView
        color: "white"
        width: midWidth
        height: midHeight - 50  * fullHeights / 900
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: -3 * heightRate
        z:10
        visible: false
        onVisibleChanged: {
            homeworkWrittingBoard.clearScreen();
        }

        YMHomeworkWrittingBoard{
            id:homeworkWrittingBoard
            anchors.fill: parent
            onSigBeSavedGrapAnswer: {
                console.log("onSigBeSavedGrapAnswer",imageUrl.toString())
                showUploadImageListViewModel.append({
                                                        "imageFileUrl": "file:///" + imageUrl.toString()
                                                    })
                addWrittingView.visible = false;

            }
        }
    }
    //底部操作区
    Rectangle{
        width: parent.width - 70 * heightRate
        height: 80 * heightRate
        color: "transparent"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        Row {
            anchors.fill: parent
            spacing: 40 * heightRate
            visible: !addWrittingView.visible
            MouseArea {
                height: 60 * heightRate
                width: 120 * heightRate
                anchors.verticalCenter: parent.verticalCenter                
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                enabled: showUploadImageListViewModel.count < 5
                Image {
                    id:tempimage
                    width: 50 * heightRate
                    height: width
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    source:parent.containsMouse ? "qrc:/cloudImage/btn_shouxie@2x.png" : "qrc:/cloudImage/btn_shouxie_disable@2x.png"//btn_shouxie@2x
                }
                Text {
                    text: qsTr("添加手写")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left:tempimage.right
                    anchors.rightMargin: 10 * heightRate
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    color: parent.containsMouse ? "#ff5000" : "#666666";
                }

                onClicked: {
                    addWrittingView.visible = true;
                }

            }

            MouseArea {
                height: 60 * heightRate
                width: 120 * heightRate
                anchors.verticalCenter: parent.verticalCenter                
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                enabled: showUploadImageListViewModel.count < 5
                Image {
                    id:tempimage1
                    width: 50 * heightRate
                    height: width
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    source:parent.containsMouse ? "qrc:/cloudImage/btn_zhaopian@2x.png" : "qrc:/cloudImage/btn_zhaopian_disable@2x.png"//btn_shouxie@2x
                }
                Text {
                    //height:parent.height
                    text: qsTr("添加图片")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left:tempimage1.right
                    anchors.rightMargin: 10 * heightRate
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    color: parent.containsMouse ? "#ff5000" : "#666666";
                }

                onClicked: {
                    fileDialog.open();
                }

            }

            //上传图片显示区
            ListView {
                id:showUploadImageListView
                height: parent.height //- 10 * heightRate
                width: parent.width * 0.5
                model: showUploadImageListViewModel
                orientation: ListView.Horizontal
                clip: true
                anchors.verticalCenter: parent.verticalCenter
                snapMode: ListView.SnapOneItem
                boundsBehavior: ListView.StopAtBounds
                delegate: Item{
                    width: showUploadImageListView.height //- 10 * heightRate
                    height: showUploadImageListView.height //- 10 * heightRate
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: showUploadImageListView.height - 15 * heightRate
                        height: showUploadImageListView.height - 15 * heightRate
                        anchors.centerIn: parent

                        Image {
                            id: beAddImage
                            anchors.fill: parent
                            source: imageFileUrl
                        }

                        MouseArea{
                            width: parent.width *　0.3
                            height: width
                            anchors.top: parent.top
                            anchors.right: parent.right
                            cursorShape: Qt.PointingHandCursor

                            Image{
                                anchors.fill: parent
                                source: "qrc:/cloudImage/addpic_delet@2x.png"
                            }

                            onClicked: {
                                console.log("remove photo click",index)
                                showUploadImageListViewModel.remove(index)
                            }
                        }

                    }
                }
            }

            //间隔
            Rectangle{
                width: 50 * heightRate
                height: parent.height
                color: "transparent"
            }


            MouseArea {
                width: 220 * heightRate
                height: width / 4
                anchors.verticalCenter: parent.verticalCenter
                cursorShape: Qt.PointingHandCursor

                Rectangle{
                    anchors.fill: parent
                    color: "#ff5000"
                    radius: 5 * heightRate
                }

                Text {
                    anchors.centerIn: parent
                    text: qsTr("做好了")
                    font.pixelSize: 18 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    color:"white"
                }

                onClicked: {
                    //传图
                    upLoadPhoto();
                    //发信号
                }

            }
        }

        //写字板底部操作区
        Row {
            visible: addWrittingView.visible
            anchors.fill: parent
            spacing: 15 * heightRate

            Item {
                width: parent.width * 0.7 + 50 * heightRate
                height: parent.height
                //color: "transparent"
            }

            Rectangle {
                width: 250 * heightRate
                height:  parent.height
                radius: 5 * heightRate
                color: "transparent"

                MouseArea {
                    id:image1
                    width: 30 * heightRate
                    height: 33 * heightRate                    
                    cursorShape: Qt.PointingHandCursor
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 25 * heightRate

                    Image {
                        anchors.fill: parent
                        source: "qrc:/cloudImage/th_btn_chexiao@2x.png" // gray th_btn_chexiao_disable@2x
                    }

                    onClicked:{
                       homeworkWrittingBoard.undo();
                    }
                }

                MouseArea{
                    width: 30 * heightRate
                    height: 33 * heightRate
                    cursorShape: Qt.PointingHandCursor
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: image1.right
                    anchors.leftMargin: 50 * heightRate

                    Image {
                        anchors.fill: parent
                        source: "qrc:/cloudImage/th_btn_xiayibu@2x.png" // gray th_btn_xiayibu_disable@2x
                    }

                    onClicked:{
                        homeworkWrittingBoard.fallback();
                    }
                }

                MouseArea {
                    width: 30 * heightRate
                    height: 33 * heightRate
                    cursorShape: Qt.PointingHandCursor
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 30 * heightRate

                    Image{
                        anchors.fill: parent
                        source: "qrc:/cloudImage/th_btn_shanchu@2x.png" // gray th_btn_shanchu_disable@2x
                    }

                    onClicked:  {
                       homeworkWrittingBoard.clearScreen();
                    }
                }
            }

            MouseArea {
                width: 100 * heightRate
                height: parent.height
                cursorShape: Qt.PointingHandCursor
                Rectangle{
                    anchors.fill: parent
                    radius: 5 * heightRate
                    color: "transparent"
                }

                Image {
                    width: 120  * heightRate
                    height: width / 1.43
                    source: "qrc:/cloudImage/shouxie_btn_finish@2x.png" // gray th_btn_shanchu_disable@2x
                    anchors.verticalCenter: parent.verticalCenter
                }

                onClicked:{
                    homeworkWrittingBoard.grapItemImage(addWrittingView);
                }

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
                                                    "imageFileUrl":fileDialog.fileUrl.toString()
                                                })
            //console.log("You chose: " , showUploadImageListViewModel.get(0).imageFileUrl)
        }
    }

    //C++方法
    YMHomeWorkManagerAdapter{
        id:homeworkManagerAdapter
    }

    //上传  传图地址待定  成功的图片地址格式待定
    function upLoadPhoto()
    {
        var imgUrlLIst = [];
        var imgUrl = "";

        for( var a = 0 ; a < showUploadImageListViewModel.count; a++)
        {
            console.log("showUploadImageListViewModel.get(a).imageFileUrl",showUploadImageListViewModel.get(a).imageFileUrl)
            imgUrlLIst.push(homeworkManagerAdapter.uploadImage(showUploadImageListViewModel.get(a).imageFileUrl,"135920"));
        }

        //整理上传后的 imageUrl
        for(var tempa = 0 ; tempa < imgUrlLIst.length ; tempa++)
        {
            imgUrl = imgUrl + imgUrlLIst[tempa];
            if(tempa + 1 != imgUrlLIst.length)
            {
                imgUrl = imgUrl + "@,";
            }
        }
        console.log("function upLoadPhoto()",imgUrl,imgUrlLIst);

    }

}
