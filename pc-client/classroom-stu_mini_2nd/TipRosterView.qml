import QtQuick 2.0
import QtQuick.Controls 2.0
import "./Configuration.js" as Cfg

//花名册
Item {
    id: rosterView
    width: 600 * heightRate
    height: rosterModel.count == 0 ? 300 * heightRate : rosterModel.count * 72 * heightRate + 300 * heightRate

    property string teacherName: "测试花名册老师";//老师

    MouseArea{
        anchors.fill: parent
    }

    Image{
        anchors.fill: parent
        source: "qrc:/miniClassImage/huamingce.png"
    }

    //head部分
    Item{
        id: headView
        width: parent.width
        height: 60 * heightRate

        Text {
            text: qsTr("花名册")
            font.pixelSize: 16 * heightRate
            font.family: Cfg.DEFAULT_FONT
            anchors.left: parent.left
            anchors.leftMargin: 25 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 22 * heightRate
            anchors.verticalCenter: parent.verticalCenter
        }

        MouseArea{
            width: 14 * widthRate
            height: 14 * widthRate
            hoverEnabled: true
            anchors.right: parent.right
            anchors.rightMargin: 24 * heightRate
            cursorShape: Qt.PointingHandCursor
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: qsTr("×")
                anchors.centerIn: parent
                font.pixelSize: 24 * heightRate
                font.family: Cfg.DEFAULT_FONT
            }

            onClicked: {
                rosterView.visible = false;
            }
        }

        Rectangle{
            width: parent.width - 30 * heightRate
            height: 2 * heightRate
            anchors.bottom: parent.bottom
            color: "#eeeeee"
            anchors.horizontalCenter: parent.horizontalCenter
        }

    }

    Rectangle{
        id: teacherNameView
        width: parent.width - 60 * heightRate
        height: 42 * heightRate
        color: "#FFF3ED"
        anchors.top: headView.bottom
        anchors.topMargin: 10 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter

        Image {
            id: logoImg
            width: 28 * heightRate
            height: 28 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 12 *  heightRate
            source: "qrc:/miniClassImage/xb_laoshu_xiao.png"
            anchors.verticalCenter: parent.verticalCenter
        }

        Text{
            color: "#FF5500"
            text: teacherName
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: logoImg.right
            anchors.leftMargin: 10 * heightRate
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 16 * heightRate
        }

    }

    property int columnWidth1: 135;
    property int columnWidth2: (teacherNameView.width - 135)  / 5;
    property int columnWidth3: (teacherNameView.width - 135)  / 5;
    property int columnWidth4: (teacherNameView.width - 135)  / 5;
    property int columnWidth5: (teacherNameView.width - 135)  / 5;
    property int columnWidth6: (teacherNameView.width - 135)  / 5;

    //列表名称
    Rectangle{
        id: columnName
        width: parent.width - 60 * heightRate
        height:  46 * heightRate
        color: "#f9f9f9"
        border.width: 1
        border.color: "#dddddd"
        anchors.top: teacherNameView.bottom
        anchors.topMargin: 10 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        Row{
            width: parent.width - 2
            height: parent.height
            anchors.centerIn: parent
            spacing: 0
            Item{
                width:columnWidth1
                height: parent.height

                Text {
                    text: qsTr("学生姓名")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10 * heightRate
                    font.pixelSize: 15 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                }

                Rectangle{
                    width: 1 * heightRate
                    height: parent.height
                    anchors.right: parent.right
                    color: "#dddddd"
                }
            }

            Item{
                width:columnWidth2
                height: parent.height

                Text {
                    text: qsTr("上下台")
                    anchors.centerIn: parent
                    font.pixelSize: 15 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                }

                Rectangle{
                    width: 1 * heightRate
                    height: parent.height
                    anchors.right: parent.right
                    color: "#dddddd"
                }
            }

            Item{
                width:columnWidth3
                height: parent.height

                Text {
                    text: qsTr("授权")
                    anchors.centerIn: parent
                    font.pixelSize: 15 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                }

                Rectangle{
                    width: 1 * heightRate
                    height: parent.height
                    anchors.right: parent.right
                    color: "#dddddd"
                }
            }

            Item{
                width:columnWidth4
                height: parent.height

                Text {
                    text: qsTr("麦克风")
                    anchors.centerIn: parent
                    font.pixelSize: 15 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                }

                Rectangle{
                    width: 1 * heightRate
                    height: parent.height
                    anchors.right: parent.right
                    color: "#dddddd"
                }
            }

            Item{
                width:columnWidth5
                height: parent.height

                Text {
                    text: qsTr("摄像头")
                    anchors.centerIn: parent
                    font.pixelSize: 15 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                }

                Rectangle{
                    width: 1 * heightRate
                    height: parent.height
                    anchors.right: parent.right
                    color: "#dddddd"
                }
            }

            Item{
                width:columnWidth6
                height: parent.height

                Text {
                    text: qsTr("奖励")
                    anchors.centerIn: parent
                    font.pixelSize: 15 * heightRate
                    font.family: Cfg.DEFAULT_FONT
                }
            }

        }
    }

    ListView{
        id: rosterListView
        clip: true
        height: parent.height - 200 * heightRate
        width: parent.width - 60 * heightRate
        anchors.top: columnName.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        delegate: rosterDelegate
        model: rosterModel
    }

    Rectangle{
        height: parent.height - 180 * heightRate
        width: parent.width - 60 * heightRate
        anchors.top: columnName.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        border.color: "#dddddd"
        border.width: 1
        visible: rosterModel.count == 0 ? true : false

        Image {
            id: mouseImg
            width: 70 * heightRate
            height: 66 * heightRate
            anchors.top: parent.top
            anchors.topMargin: (parent.height - height -tpsText.height) * 0.5
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/miniClassImage/xb_laoshu_da.png"
        }
        Text {
            id: tpsText
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 15 * heightRate
            anchors.top: mouseImg.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("暂时还没有学生进入教室哦～")
        }
    }

    ListModel{
        id: rosterModel
    }

    Component{
        id: rosterDelegate
        Rectangle{
            width: rosterListView.width
            height: rosterModel.count == 0 ? 137 * heightRate : 72 * heightRate
            border.color: "#dddddd"
            border.width: 1

            Row{
                width: parent.width - 2
                height: parent.height - 1
                anchors.centerIn: parent

                Rectangle{
                    width:columnWidth1
                    height: parent.height
                    color: "#ffffff"

                    Text {
                        text: studentName
                        width: parent.width -  20 * heightRate
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10 * heightRate
                        font.pixelSize: 15 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        wrapMode: Text.WordWrap
                    }

                    Rectangle{
                        width: 1 * heightRate
                        height: parent.height
                        anchors.right: parent.right
                        color: "#dddddd"
                    }
                }

                Rectangle{
                    width:columnWidth2
                    height: parent.height
                    color: "#ffffff"

                    MouseArea{
                        width:  33 * heightRate
                        height:  25 * heightRate
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor                        
                        anchors.centerIn: parent
                        enabled: false

                        Image {
                            source: online == 1 ? (downStatus == 1 ? "qrc:/miniClassImage/xbk_hmc_shangtai.png" : "qrc:/miniClassImage/xbk_hmc_xiatai.png") : "qrc:/miniClassImage/xbk_hmc_wushangtai.png"
                            anchors.fill: parent
                        }

                        onClicked: {

                        }
                    }

                    Rectangle{
                        width: 1 * heightRate
                        height: parent.height
                        anchors.right: parent.right
                        color: "#dddddd"
                    }
                }

                Rectangle{
                    width:columnWidth3
                    height: parent.height
                    color: "#ffffff"

                    MouseArea{
                        width:  33 * heightRate
                        height:  25 * heightRate
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        anchors.centerIn: parent
                        enabled: false

                        Image {
                            anchors.fill: parent
                            source: online == 1 ? (authorize == 1 ? "qrc:/miniClassImage/xb_hmc_shouquan.png" : "qrc:/miniClassImage/xb_hmc_weishouquan.png") : "qrc:/miniClassImage/xb_hmc_wushouquan.png"
                        }

                        onClicked: {

                        }
                    }

                    Rectangle{
                        width: 1 * heightRate
                        height: parent.height
                        anchors.right: parent.right
                        color: "#dddddd"
                    }
                }

                Rectangle{
                    width:columnWidth4
                    height: parent.height
                    color: "#ffffff"

                    MouseArea{
                        width:  33 * heightRate
                        height:  25 * heightRate
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        anchors.centerIn: parent
                        enabled: false

                        Image {
                            anchors.fill: parent
                            source: online == 1 ? (mircphon == 1 ? "qrc:/miniClassImage/xb_hmc_on.png" : "qrc:/miniClassImage/xb_hmc_off.png") : "qrc:/miniClassImage/xb_hmc_forbid.png"
                        }

                        onClicked: {

                        }
                    }

                    Rectangle{
                        width: 1 * heightRate
                        height: parent.height
                        anchors.right: parent.right
                        color: "#dddddd"
                    }
                }

                Rectangle{
                    width:columnWidth5
                    height: parent.height
                    color: "#ffffff"

                    MouseArea{
                        width:  33 * heightRate
                        height:  25 * heightRate
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor                        
                        anchors.centerIn: parent
                        enabled: false

                        Image {
                            anchors.fill: parent
                            source: online == 1 ? (camera == 1 ? "qrc:/miniClassImage/xb_hmc_shexiang_lv.png": "qrc:/miniClassImage/xb_hmc_shexiang_hong.png") : "qrc:/miniClassImage/xb_hmc_shexiang_hui.png"
                        }

                        onClicked: {

                        }
                    }

                    Rectangle{
                        width: 1 * heightRate
                        height: parent.height
                        anchors.right: parent.right
                        color: "#dddddd"
                    }
                }

                Rectangle{
                    width:columnWidth6
                    height: parent.height
                    color: "#ffffff"

                    Image {
                        id: rewardImg
                        anchors.left: parent.left
                        anchors.leftMargin: 10 * heightRate
                        width:  33 * heightRate
                        height:  25 * heightRate
                        source: "qrc:/miniClassImage/xb_hmc_jiangli.png"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: reward
                        color: "#FFCC33"
                        font.pixelSize: 15 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: rewardImg.right
                        anchors.leftMargin: 6 * heightRate
                    }
                }

            }
        }
    }

    //添加花名册数据
    function addRosterData(dataArray){
        rosterModel.clear();
        for(var i = 0; i < dataArray.length; i++){
            teacherName = dataArray[i].teacherName;
            rosterModel.append(
                        {
                            "userId": dataArray[i].userId,
                            "studentName": dataArray[i].userName,
                            "downStatus": dataArray[i].userUp,
                            "authorize": dataArray[i].userAuth,
                            "mircphon": dataArray[i].userAudio,
                            "camera": dataArray[i].userVideo,
                            "reward": dataArray[i].userReward,
                            "online": dataArray[i].userOnline,
                        })
        }
    }

    function updateUserAuth(userId,up,trail,audio,video){
        for(var i = 0; i < rosterModel.count; i++){
            if(userId == rosterModel.get(i).userId){
                rosterModel.get(i).downStatus = up.toString();
                rosterModel.get(i).authorize = trail.toString();
                rosterModel.get(i).mircphon = audio.toString();
                rosterModel.get(i).camera = video.toString();
                break;
            }
        }
    }

    function updateOnline(userId,status){
        for(var i = 0; i < rosterModel.count; i++){
            if(userId == rosterModel.get(i).userId){
                rosterModel.get(i).online = status;
                break;
            }
        }
    }

    function updateReward(userId){
        for(var i = 0; i < rosterModel.count; i++){
            if(userId == rosterModel.get(i).userId){
                rosterModel.get(i).reward += 1;
                break;
            }
        }
    }

    //麦克风全部静音
    function updateMircphonStatus(audio){
        for(var i = 0; i < rosterModel.count; i++){
            if(rosterModel.get(i).downStatus == "1"){
                rosterModel.get(i).mircphon = audio.toString();
            }
        }
    }

    //花名册重置所有状态
    function resetStatus(){
        for(var i = 0; i < rosterModel.count; i++){
            rosterModel.get(i).reward = 0;
            rosterModel.get(i).downStatus = "1";
            rosterModel.get(i).authorize = "0"
            rosterModel.get(i).mircphon = "1";
            rosterModel.get(i).camera = "1";
        }
    }
}
