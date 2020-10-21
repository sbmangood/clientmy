import QtQuick 2.5
import QtQuick.Controls 1.4
import VideoRender 1.0

import "./Configuration.js" as Cfg

Item {
    id: audiovideoviewstuview
    width: 240 * widthRate
    height: 190 * heightRate

    property double widthRates: fullWidths / 1440.0
    property double heightRates: fullHeights / 900.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates
    property string useRole: "stu";

    signal sigForceDown(var uid);// 强制下台信号
    signal sigSetUserAuth(string userId,string authStatus);//用户授权信号
    signal sigSetUserAuths(var userId, string up, int trail, int audio, int video);
    signal sigUpdateAllMute(int muteStatus);// 全体禁言信号

    property var currentUserId: [];

    MouseArea {
        id: mouseA
        z:2
        width: parent.width
        height: 80 * widthRate
        cursorShape: Qt.PointingHandCursor

        property point pressPos: "0,0"

        onPressed: {
            pressPos = Qt.point(mouse.x, mouse.y);
        }

        onPositionChanged: {
            var delta = Qt.point(mouse.x-pressPos.x, mouse.y-pressPos.y);
            var moveX = audiovideoviewstuview.x + delta.x;
            var moveY = audiovideoviewstuview.y + delta.y;
            var moveWidth = audiovideoviewstuview.parent.width - audiovideoviewstuview.width;
            var moveHeight = audiovideoviewstuview.parent.height - audiovideoviewstuview.height;

            if( moveX > 0 && moveX < moveWidth) {
                audiovideoviewstuview.x = audiovideoviewstuview.x + delta.x;
            }else{
                var loactionX = moveX < 0 ? 0 : (moveX > moveWidth ? moveWidth : moveX);
                audiovideoviewstuview.x = loactionX;
            }

            if(moveY  > 0 && moveY < moveHeight){
                audiovideoviewstuview.y = audiovideoviewstuview.y + delta.y;
            }else{
                audiovideoviewstuview.y = moveY < 0 ? 0 : (moveY > moveHeight ? moveHeight : moveY);
            }
        }

    }

    MouseArea {
        z: 3
        id: downbtn
        width: 50 * widthRate
        height: 26 * heightRate
        anchors.top: parent.top
        anchors.right: parent.right
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        enabled: useRole != "stu"
        visible: useRole != "stu"
        Rectangle{
            anchors.fill: parent
            color: "gray"
        }

        Text {
            anchors.centerIn: parent
            color: "#ffffff"
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * heightRate
            text: qsTr("下台")
        }

        onClicked: {
            sigForceDown(currentUserId);
        }

    }

    ListView {
        id: videoListView
        width: parent.width
        height: parent.height
        delegate: listViewDelegate
        model: listModel
        clip: true
        boundsBehavior: ListView.StopAtBounds
    }

    ListModel {
        id:listModel
    }

    Component {
        id:listViewDelegate
        Rectangle {
            id:itemDelegateBackGround
            width: videoListView.width
            height: videoListView.height
            border.color: "#3D3F4E"
            border.width: 1

            //视频显示
            VideoRender {
                id: videoRender
                width: parent.width
                height: parent.height
                imageId: uid
                z: 5
            }

            //学生信息与麦克风状态
            Item {
                z: 6
                width: parent.width
                height: 30 * heightRate
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter


                Rectangle{
                    anchors.fill: parent
                    color: "#454756"
                }

                Image{
                    width: 20 * heightRate
                    height: 20 * heightRate
                    anchors.right: parent.right
                    anchors.rightMargin:22 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                    source:  "qrc:/bigclassImage/mk1@2x.png"
                }

                Image {
                    id: micPhoneImg
                    width: 13 * heightRate
                    height: 20 * heightRate
                    anchors.right: parent.right
                    anchors.rightMargin: 9 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                    source:  {
                        if(volumes == "0"){
                            return "qrc:/bigclassImage/yin0@2x.png";
                        }
                        if(volumes == "1"){
                            return "qrc:/bigclassImage/yin1@2x.png"
                        }
                        if(volumes == "2"){
                            return "qrc:/bigclassImage/yin2@2x.png";
                        }
                        if(volumes == "3"){
                            return "qrc:/bigclassImage/yin3@2x.png";
                        }
                        if(volumes == "4"){
                            return "qrc:/bigclassImage/yin4@2x.png";
                        }
                        if(volumes == "5"){
                            return "qrc:/bigclassImage/yin5@2x.png";
                        }
                        if(volumes == "6"){
                            return "qrc:/bigclassImage/yin5@2x.png";
                        }
                    }
                }

                Text {
                    text: userName
                    width: 40 * heightRate
                    height: parent.height
                    anchors.left: parent.left
                    anchors.leftMargin: 10 * heightRate
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                    color: "#ffffff"
                }
            }
//            //操作背景
//            Image {
//                id: backImg
//                z: 5
//                width: parent.width
//                height: parent.height - 30 * heightRate
//                visible:  false
//                source: userOnline == "1" ?  (userUp == "0" ? "qrc:/avimages/xb_xianshi2.png" : (userVideo == "0"  ? "qrc:/avimages/xb_xianshi2.png"  :"qrc:/avimages/xb_xianshi1.png")) :  "qrc:/avimages/xb_xianshi1.png"
//            }

        }

    }


    // 增加学生信息
    function addUserInfo(userId,userNames){
        currentUserId = userId;
        listModel.clear()
        var isAdd = true;
        for(var i = 0; i < listModel.count; i++){
            if(listModel.get(i).userId == userId){
                isAdd = false;
                break;
            }
        }
        var isAttend = true;//curriculumData.isAttend(userId);
        if(isAdd && isAttend){
            console.log("==addUserInfo==",userId,userNames);
            var userName = userNames == "" ? userId : userNames;//dataObject.userName;//用户名
            var userOnline = 1;//dataObject.userOnline;//用户在线状态
            var userAuth = 0;//dataObject.userAuth;//用户权限
            var isVideo = 1;//dataObject.isVideo;//是否为视频
            var userAudio = 0;//dataObject.userAudio//麦克风状态
            var userVideo = 1;//dataObject.userVideo;//视频状态
            var imagePath = "";//视频路径
            var isteacher = 0;//dataObject.isteacher;//老师状态
            var supplier = "";//用户通道
            var headPicture = ""; //用户头像
            var userMute = 1;//dataObject.mute;//
            var uid = userId;//dataObject.uid;
            var userUp = 1;//dataObject.userUp;
            var rewardNum = 0;//dataObject.rewardNum;
            console.log("=====addUserInfo====",userId,userName,isVideo,userUp,userAuth,userAudio,userVideo);
            listModel.append(
                        {
                            "uid": uid,
                            "makeIndex": listModel.count + 1,
                            "userId": userId,
                            "userMute": userMute,
                            "userUp": userUp,
                            "userName": userName,
                            "userOnline":userOnline,
                            "userAuth":userAuth,
                            "isVideo": isVideo,
                            "userAudio": userAudio,
                            "userVideo": userVideo,
                            "imagePath": imagePath,
                            "isteacher":isteacher,
                            "supplier": supplier,
                            "headPicture": headPicture,
                            "volumes":"0", //设置音量
                            "prizeNumber":rewardNum,
                        });
        }
    }

    //设置开始上课
    function setStartClassTimeData(times){
        for(var j = 0 ; j < listModel.count ;j++){
            var userId = listModel.get(j).userId;
            var isVideo = curriculumData.getIsVideo();
            var supplier = curriculumData.getUserChanncel();
            var userVideo = curriculumData.getUserCamcera(userId);
            var userAudio = curriculumData.getUserPhone(userId);
            var userOnline = curriculumData.justUserOnline(userId)
            var userAuth = curriculumData.getUserIdBrushPermissions(userId);

            listModel.setProperty(j,"isVideo",isVideo);
            listModel.setProperty(j,"supplier",supplier);
            listModel.setProperty(j,"userVideo",userVideo);
            listModel.setProperty(j,"userAudio",userAudio);
            listModel.setProperty(j,"userOnline",userOnline);
            listModel.setProperty(j,"userAuth",userAuth);
        }
    }

    // 更新用户状态
    function updateUserState(userId, up,userName){
        if(up == "0"){
            for(var i  = 0; i < listModel.count; i ++){
                if(listModel.get(i).userId == userId){
                    //listModel.remove(i, 1);
                    listModel.clear();
                    audiovideoviewstuview.visible = false
                }
            }
        }
        else if(up == "1"){
            if(audiovideoviewstuview.visible == false){
                addUserInfo(userId,userName);
            }
        }
    }
}

