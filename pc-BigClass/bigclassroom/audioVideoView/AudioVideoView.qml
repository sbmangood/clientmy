import QtQuick 2.5
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import VideoRender 1.0
import "./Configuration.js" as Cfg

Item {
    id: audiovideoview
    property double widthRates: fullWidths / 1440.0
    property double heightRates: fullHeights / 900.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    property string userName: "";

    property string userAVRole: "tea";

    signal sigResolutionValue(var resValue);// 分辨率值

    //背景
    Item {
        id:audiovideoviewColor
        width: parent.width
        height: parent.height
        z:2
        ListView {
            id:videoListView
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
            Item {
                width: videoListView.width
                height: videoListView.height

                Rectangle {
                    id:itemDelegateBackGround
                    width: parent.width
                    height: parent.height
                    anchors.right: parent.right
                    //radius: 6 * heightRate
                    color: "#ffffff"

                    // 视频显示
                    VideoRender {
                        id: videoRender
                        width: parent.width
                        height: parent.height
                        imageId: uid
                        z: 5
                        //visible: false
                        Component.onCompleted:{
                            videoRender.enableBeauty(false);// 小组课默认关闭美颜
                        }
                    }

                    // 信息与麦克风状态
                    Rectangle {
                        z: 6
                        width: parent.width
                        height: 30 * heightRate
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#454756"

                        // 用户名
                        Text {
                            id: userTxt
                            text: userName
                            height: parent.height
                            anchors.left: parent.left
                            anchors.leftMargin: 10 * heightRate
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 16 * heightRate
                            font.family: Cfg.DEFAULT_FONT
                            color: "#ffffff"
                        }

                        // 摄像头开关
                        Item {
                            id: cameraBtn
                            width: 22 * heightRate
                            height: 22 * heightRate
                            anchors.left: userTxt.right
                            anchors.leftMargin: 100 * heightRate
                            anchors.verticalCenter: parent.verticalCenter
                            visible: false
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                Image {
                                    anchors.fill: parent
                                    source: userVideo == 1 ? "qrc:/bigclassImage/sxt1@2x.png" : "qrc:/bigclassImage/sxt3@2x.png"
                                }
                                onClicked: {
                                    var closeVideo = userVideo == 0 ? 1 : 0;
                                    userVideo = closeVideo.toString();
                                    toolbar.closeVideo(closeVideo.toString());
                                }
                            }
                        }

                        // 麦克风开关
                        Item {
                            id: mkBtn
                            width: 20 * heightRate
                            height: 20 * heightRate
                            anchors.left: cameraBtn.right
                            anchors.leftMargin: 6 * heightRate
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                Image {
                                    anchors.fill: parent
                                    source:  userAudio == 1 ? "qrc:/bigclassImage/mk1@2x.png" : "qrc:/bigclassImage/mk3@2x.png"
                                }
                                onClicked: {
                                    var closeAudio = userAudio == 0 ? 1 : 0;
                                    userAudio = closeAudio;
                                    toolbar.closeAudio(closeAudio);
                                }
                            }
                        }

                        // 音量显示
                        Image {
                            id: micPhoneImg
                            width: 13 * heightRate
                            height: 20 * heightRate
                            anchors.left: mkBtn.right
                            anchors.leftMargin: 4 * heightRate
                            anchors.verticalCenter: parent.verticalCenter
                            source:  {
                                if(userAudio == 1){
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
                                    return "qrc:/bigclassImage/yin5@2x.png";
                                }else{
                                    return "qrc:/bigclassImage/yin0@2x.png";
                                }

                            }
                        }

                        // 分辨率切换按钮
                        Item {
                            id: resChange
                            width: 46 * heightRate
                            height: 20 * heightRate
                            anchors.right: parent.right
                            anchors.rightMargin: 6 * heightRate
                            anchors.verticalCenter: parent.verticalCenter
                            visible: userAVRole == "tea"
                            enabled: userAVRole == "tea"
                            Rectangle {
                                anchors.fill: parent
                                color: "#5C678A"
                                border.color: "#4D90FF"
                                opacity: 0.2
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        resList.visible = !resList.visible;
                                    }
                                }
                            }
                            // 上边框线
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#4D90FF"
                                anchors.top: parent.top
                            }
                            // 下边框线
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#4D90FF"
                                anchors.bottom: parent.bottom
                            }
                            // 左边框线
                            Rectangle {
                                width: 1
                                height: parent.height
                                color: "#4D90FF"
                                anchors.left: parent.left
                            }
                            // 右边框线
                            Rectangle {
                                width: 1
                                height: parent.height
                                color: "#4D90FF"
                                anchors.right: parent.right
                            }
                            Text {
                                id: resTxt
                                text: qsTr("360P")
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                font.pixelSize: 13 * heightRate
                                font.family: Cfg.DEFAULT_FONT
                                color: "#ffffff"
                            }
                        }

                        // 分辨率切换列表
                        Item {
                            id: resList
                            visible: false
                            z: 100
                            width: 104 * widthRate
                            height: 3 * 37 * heightRate
                            anchors.bottom: parent.top
                            anchors.bottomMargin: 4 * heightRate
                            anchors.right: resChange.right
                            // 360P
                            Item {
                                id: p_360
                                anchors.bottom: parent.bottom
                                width: 104 * widthRate
                                height: 37 * heightRate
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#000000"
                                    opacity: 0.6
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            resTxt.text = qsTr("360P");
                                            sigResolutionValue(1);
                                            resList.visible = false;
                                        }
                                        onEntered: {
                                            p_360_txt.color = "#4D90FF";
                                        }
                                        onExited: {
                                             p_360_txt.color = "#ffffff";
                                        }
                                    }
                                }
                                Text {
                                    id: p_360_txt
                                    text: qsTr("标清360P")
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: 13 * heightRate
                                    font.family: Cfg.DEFAULT_FONT
                                    color: "#ffffff"
                                }
                            }
                            // 480P
                            Item {
                                id: p_480
                                anchors.bottom: p_360.top
                                width: 104 * widthRate
                                height: 37 * heightRate
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#000000"
                                    opacity: 0.6
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            resTxt.text = qsTr("480P");
                                            sigResolutionValue(2);
                                            resList.visible = false;
                                        }
                                        onEntered: {
                                            p_480_txt.color = "#4D90FF";
                                        }
                                        onExited: {
                                             p_480_txt.color = "#ffffff";
                                        }
                                    }
                                }
                                Text {
                                    id: p_480_txt
                                    text: qsTr("高清480P")
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: 13 * heightRate
                                    font.family: Cfg.DEFAULT_FONT
                                    color: "#ffffff"
                                }
                            }
                            // 720P
                            Item {
                                id: p_720
                                anchors.bottom: p_480.top
                                width: 104 * widthRate
                                height: 37 * heightRate
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#000000"
                                    opacity: 0.6
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            resTxt.text = qsTr("720P");
                                            sigResolutionValue(3);
                                            resList.visible = false;
                                        }
                                        onEntered: {
                                            p_720_txt.color = "#4D90FF";
                                        }
                                        onExited: {
                                             p_720_txt.color = "#ffffff";
                                        }
                                    }
                                }
                                Text {
                                    id: p_720_txt
                                    text: qsTr("超清720P")
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: 13 * heightRate
                                    font.family: Cfg.DEFAULT_FONT
                                    color: "#ffffff"
                                }
                            }
                        }
                    }

                    //操作背景
                    Image {
                        id: backImg
                        z: 5
                        width: parent.width
                        height: parent.height
                        visible:  userVideo == 1 ? false : true
                        source:  "qrc:/bigclassImage/lsmr.png"
                    }
                }
            }
        }
    }

    // 添加自己的用户信息
    function addSelfBaseInfo(userId, dataObject){
        var j = 0;
        var userOnline = dataObject.userOnline;//用户在线状态
        var userAuth = dataObject.userAuth;//用户权限
        var isVideo = dataObject.isVideo;//是否为视频
        var userAudio = dataObject.userAudio//麦克风状态
        var userVideo = dataObject.userVideo;//视频状态
        var imagePath = dataObject.imagePath;//视频路径
        var isteacher = dataObject.isteacher;//老师状态
        var supplier = dataObject.supplier;//用户通道
        var headPicture = dataObject.headPicture; //用户头像
        var userMute = dataObject.mute;
        var uid = dataObject.uid;
        var userUp = dataObject.userUp;
        var rewardNum = dataObject.rewardNum;
        listModel.append(
                    {
                        "uid": uid,
                        "makeIndex": j + 1,
                        "userId": userId,
                        "userMute": userMute,
                        "userUp": userUp,
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
                        "prizeNumber": rewardNum,
                    }
                    );
    }

    function updateVolume(volumes){
        if(listModel.count == 0)
        {
            return;
        }
        listModel.get(0).volumes = volumes;
    }

    // 更新用户状态
    function updateUserState(userId, up){
        /*
        if(up == "0"){
            for(var i  = 0; i < listModel.count; i ++){
                if(listModel.get(i).userId == userId){
                    listModel.remove(i, 1);
                }
            }
        }
        else if(up == "1"){
            addUserInfo(userId)
        }
        */
        for(var i  = 0; i < listModel.count; i ++){
            if(listModel.get(i).userId == userId){
                if(up == "0"){
                    listModel.get(i).userVideo = 0;
                }
                else if(up == "1"){
                    listModel.get(i).userVideo = 1;
                }
            }
        }
    }
}

