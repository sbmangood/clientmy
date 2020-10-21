import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "./Configuration.js" as Cfg

Rectangle {
    id: interactiveToolsView
    color: "#3A4052"

    property bool hasStudent: false// 教室内是否有学生正在发言
    property bool isFirst: true// 老师进入教室后第一次操作
    property int currentIndex: 0;
    property int setUserRole: 0;
    property int handsTotal: 0;//举手统计
    property int totalNum: 0;//在线人数统计

    signal sigProcessHandsUp(var uid, var operation);
    signal sigSetChattingRoomUrl();// 设置聊天室url信号
    signal sigChattingRoomLoadFinished();// 聊天室加载完成信号
    signal sigSetTips(var tips);// 提示语

    Row {
        id:coloumn
        width: parent.width
        height: 44 * heightRate
        MouseArea{
            width: setUserRole == 1 ? parent.width : parent.width / 2;
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Rectangle{
                color: "#2C2D39"
                anchors.fill: parent
            }

            Rectangle{
                width: parent.width
                height: 2 * heightRate
                color: currentIndex == 0 ? "#6DA4FF" : "#2C2D39"
                anchors.bottom: parent.bottom
            }

            Image{
                width: 36 * heightRate
                height: 16 * heightRate
                anchors.centerIn: parent
                source: parent.containsMouse ? "qrc:/interactiveImage/lt2@2x.png" : (currentIndex == 0 ? "qrc:/interactiveImage/lt1@2x.png" : "qrc:/interactiveImage/lt3@2x.png")
            }

            onClicked: {
                currentIndex = 0;
                handsTotal = 0;
                //sigSetChattingRoomUrl();
                //chat.setChattingRoomUrl("http://sit01-im.yimifudao.com/","865f1a705592f99ada4696d6b853c7f1")
            }
        }

        MouseArea{
            width: parent.width / 2;
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: setUserRole != 1
            visible: setUserRole != 1
            Rectangle{
                color: "#2C2D39"
                anchors.fill: parent
            }

            Rectangle{
                width: parent.width
                height: 2 * heightRate
                color: currentIndex == 1 ? "#6DA4FF" : "#2C2D39"
                anchors.bottom: parent.bottom
            }

            Image{
                width: 36 * heightRate
                height: 16 * heightRate
                anchors.centerIn: parent
                source: parent.containsMouse ? "qrc:/interactiveImage/cy2@2x.png" : (currentIndex == 1 ? "qrc:/interactiveImage/cy1@2x.png" : "qrc:/interactiveImage/cy3@2x.png")
            }

            Rectangle{
                width: 32 * heightRate
                height: 16 * heightRate
                color: "red"
                radius: 12 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: 18 * heightRate
                anchors.top: parent.top
                anchors.topMargin: 6 * heightRate
                visible: handsTotal  > 0 ? true : false

                Text {
                    text: {
                        if(handsTotal > 99){
                            return handsTotal.toString() + "+"
                        }
                        else{
                            return handsTotal.toString();
                        }
                    }
                    anchors.centerIn: parent
                    color: "#ffffff"
                }
            }

            onClicked: {
                currentIndex = 1
            }
        }
    }


    Rectangle {
        anchors.top: coloumn.bottom
        anchors.topMargin: 1
        height: parent.height - coloumn.height
        width: parent.width
        visible: currentIndex == 0 ? true : false

       ChattingRoom {
           id: chat
           z :2
           width: parent.width
           height: parent.height
           onSigWebLoadFinished: {
              sigChattingRoomLoadFinished();
           }
       }
    }

    // 举手列表
    Rectangle{
        visible: currentIndex == 1 ? true : false
        anchors.top: coloumn.bottom
        anchors.topMargin: 1
        height: parent.height - coloumn.height
        width: parent.width
        color: "#3A4052"

        Item{
            id: onlineItem
            width: parent.width
            height: 42 * heightRate
            visible: totalNum == 0 ? false : true

            Text{
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 16 * heightRate
                color: "#ffffff"
                text: totalNum.toString() + " 人在上课"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 26 * heightRate
            }
        }

        ListView {
            id: handsUpListView
            clip: true
            width: parent.width
            height: parent.height - onlineItem.height
            anchors.top: onlineItem.bottom
            delegate: handsUpDelegate
            model: handsUpModel
        }
    }

    // 整体列表模型
    ListModel {
        id: handsUpModel
    }

    Component {
        id: handsUpDelegate
        // 表格行
        Item {
            width: handsUpListView.width
            height: 48 * heightRate

            Row {
                width: parent.width - 20 * heightRate
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10 * heightRate

                Image {//系统类型
                    id: osText
                    width: 22 * heightRate
                    height: 22 * heightRate
                    anchors.verticalCenter: parent.verticalCenter
                    source: {
                        if(OS == 1){
                            return "qrc:/interactiveImage/anzhuo1@2x.png";
                        }
                        if(OS == 2){
                            return "qrc:/interactiveImage/ios1@2x.png";
                        }
                        if(OS == 3){
                            return "qrc:/interactiveImage/pc_icon.png";
                        }
                        return "qrc:/interactiveImage/pc_icon.png"
                    }
                }

                // 学生姓名
                Item{
                    width: 140 * heightRate
                    height: parent.height
                    Text {
                        width: parent.width - 10 * heightRate
                        text: userName
                        font.pixelSize: 16 * heightRate
                        font.family: Cfg.DEFAULT_FONT
                        color: "#ffffff"
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                    }
                }

                MouseArea{//举手 、 上台图标
                    width: 22 * heightRate
                    height: 22 * heightRate
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    anchors.verticalCenter: parent.verticalCenter
                    enabled: setUserRole == 0 ? (up == 0 ? false : true) : false

                    Image {
                        id: handsImg
                        anchors.fill: parent
                        visible: up == 0 ? true : (upHands == 0 ? false : true)
                        source: up == 0 ? "qrc:/bigclassImage/spz@2x.png" : (parent.containsMouse ? "qrc:/interactiveImage/djjs@2x.png" : "qrc:/interactiveImage/ctjs@2x.png");
                    }

                    onClicked: {
                        upHands = 0;
                        if(handsTotal > 0){
                            handsTotal--;
                        }
                        stuCancelData(userId);
                        sigProcessHandsUp(userId,4);
                    }
                }

                Item{
                    width: 2
                    height: 18 * heightRate
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle{
                        color: "gray"
                        anchors.fill: parent
                        visible: setUserRole == 0 ? true : false
                    }
                }

                MouseArea{//上下台
                    width: 28 * heightRate
                    height: 14 * heightRate
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    //enabled: disableUp == false ? true : false
                    anchors.verticalCenter: parent.verticalCenter
                    visible: setUserRole == 0 ? true : false

                    Image{
                        anchors.fill: parent
                        source: up == 1 ? (parent.containsMouse ? "qrc:/interactiveImage/st2@2x.png" : "qrc:/interactiveImage/st1@2x.png") : (parent.containsMouse ? "qrc:/interactiveImage/xt2@2x.png" : "qrc:/interactiveImage/xt1@2x.png") //上台
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        if(disableUp == true){
                            sigSetTips("已有学生在教室，无法邀请其他学生!");
                            return;
                        }
                        var upStatus = (up== 0 ? 1 : 0);
                        var forceStatus = up == 1 ? 1 : 2;
                        if(upHands == 1 && up == 1){
                            handsTotal--;
                        }
                        updateUpStatus(userId,upStatus);
                        sigProcessHandsUp(userId,forceStatus);
                        updateDisableStatus(userId,up == 0 ? false : true);
                    }
                }
            }

            // 分割线
            Rectangle {
                width: parent.width
                height: 1
                color: "gray"
                anchors.bottom: parent.bottom
            }
        }
    }

    Component.onCompleted: {
        sigSetChattingRoomUrl();
    }

    //上下台状态更改
    function updateUpStatus(userId,upStatus){
        for(var i = 0; i <handsUpModel.count; i++){
            if(handsUpModel.get(i).userId == userId){
                handsUpModel.get(i).up = upStatus;
                if(upStatus == 0){
                    handsUpModel.move(i,0,1);
                }else{
                    handsUpModel.get(i).upHands = 0;
                    handsUpModel.move(i,handsUpModel.count - 1,1);
                }
                break;
            }
        }
    }

    //禁止点击上下台按钮
    function updateDisableStatus(userId,disableStatus){
        console.log("===updateDisableStatus===",userId,disableStatus)
        for(var i = 0; i <handsUpModel.count; i++){
            if(handsUpModel.get(i).userId == userId){
                handsUpModel.get(i).disableUp = handsUpModel.get(i).up == 1 ? !disableStatus : disableStatus;
                continue;
            }
            handsUpModel.get(i).disableUp = !disableStatus;
        }
    }

    // 更新学生信息, state: 0未举手，1已举手未上台，2-已上台，3-已下台
    function updateStuStateData(uid, state){
        console.log("======updateStuStateData====",uid,state)
        for(var i = 0; i < handsUpModel.count; i++){
            if(handsUpModel.get(i).userId == uid){
                if(state == "0"){
                    handsUpModel.get(i).upHands = 0;
                }
                if(state == "1"){
                    handsUpModel.get(i).upHands = 1;
                }
                if(state == "2"){
                    handsUpModel.get(i).upHands  = 0;
                    handsUpModel.get(i).up = 1;
                    updateDisableStatus(uid,true);
                }
                if(state == "3"){
                    handsUpModel.get(i).up = 0;
                }
                return;
            }
        }
        var up = 2;
        var upHands = 0;
        if(state == "0"){
            upHands = 0;
        }
        if(state == "1"){
            upHands = 1;
        }
        if(state == "2"){
            up = 1;
        }
        if(state == "3"){
            up = 0;
        }
        handsUpModel.insert(0,
                    {
                        "userId": uid,
                        "userName": uid,
                        "OS": 1,//1:安卓，2:IOS，3:PC
                        "up":up,//1:上台 0:下台 2:隐藏
                        "upHands": upHands,//0未举手 1举手 2取消
                        "disableUp": false,//禁用上台按钮
                    });
    }

    // 学生进入教室
    function addStuData(uid, dataObj){
        var disableUp = false;
        for(var k = 0; k < handsUpModel.count; k++){
            if(handsUpModel.get(k).up == 0){
                disableUp = true;
                break;
            }
        }

        for(var i = 0; i < handsUpModel.count; i++){
            if(handsUpModel.get(i).userId == uid){
                if(disableUp){
                    handsUpModel.get(i).disableUp = true;
                }
                console.log("该学生已经在教室里");
                return;
            }
        }
        console.log("========uid====",uid)
        var osType = 0;
        if(dataObj.systemInfo != undefined){
            if(dataObj.systemInfo.toUpperCase().search("IOS") != -1){
                osType = 2;
            }
            if(dataObj.systemInfo.toUpperCase().search("ANDROID") != -1){
                osType = 1;
            }
            if(dataObj.systemInfo.toUpperCase().search("WINDOW") != -1){
                osType = 3;
            }
        }
        var userName = dataObj.userName == "" ? dataObj.videoId : dataObj.userName;

        totalNum++;
        console.log("====disableUp===",disableUp);
        handsUpModel.append(
                    {
                        "userId": uid,
                        "userName": userName,
                        "OS": osType,//1:安卓，2:IOS，3:PC
                        "up":1,//1:上台 0:下台
                        "upHands": 0,//0未举手 1举手 2取消
                        "disableUp": disableUp,//禁用上台按钮
                    });
    }

    // 学生申请上台
    function stuAppliedData(uid){
        for(var m = 0; m < handsUpModel.count; m++){
            if(handsUpModel.get(m).userId == uid && handsUpModel.get(m).upHands == 0){
                handsUpModel.get(m).upHands = 1;
                handsTotal++;
                handsUpModel.move(m,0,1);
                return;
            }
        }
        var isAdd = isAddStu(uid);
        if(isAdd == false){
            handsUpModel.append(
                        {
                            "userId": uid,
                            "userName": uid,
                            "OS": 1,//1:安卓，2:IOS，3:PC
                            "up":1,//1:上台 0:下台
                            "upHands": 1,//0未举手 1举手 2取消
                            "disableUp": false,//禁用上台按钮
                        });
        }
    }

    //判断学生是否存在
    function isAddStu(userId){
        for(var k = 0; k < handsUpModel.count; k++){
            if(handsUpModel.get(k).userId == userId){
                return true;
            }
        }
        return false;
    }

    // 学生取消上台
    function stuCancelData(uid){
        for(var i = 0; i < handsUpModel.count; i++){
            if(handsUpModel.get(i).userId == uid && handsUpModel.get(i).upHands == 1){
                handsUpModel.get(i).upHands = 0;
                if(handsTotal > 0){
                    handsTotal--;
                }
                handsUpModel.move(i,handsUpModel.count - 1 ,1);
                console.log("你已经上台，无法取消");
                return;
            }
        }


        for(var i = 0; i < handsUpModel.count; i++){
            if(handsUpModel.get(i).userId == uid){
                handsUpModel.get(i).upHands = 0;
                break;
            }
        }
    }

    // 学生退出教室
    function delStuData(uid){
        for(var j = 0; j < handsUpModel.count; j++){
            if(handsUpModel.get(j).userId == uid){
                updateDisableStatus(uid,true)
                if(handsUpModel.get(j).upHands == 1){
                    if(handsTotal > 0){
                        handsTotal--;
                    }
                }
                totalNum--;
                handsUpModel.remove(j, 1);
                break;
            }
        }
    }

    // 聊天室-设置聊天室url
    function setChattingRoomUrl(url, token){
        chat.setChattingRoomUrl(url, token);
    }

    // 聊天室-初始化
    function initchattingroom(identifierNick, headurl, userId, role, myClass, chatRoomId){
        chat.pcSetInfo(identifierNick, headurl, userId, role, myClass, chatRoomId);
    }

    // 聊天室-客户端通知H5有人进入聊天室
    function pcSetOnline(identifierNick, headurl, userId, role){
        chat.pcSetOnline(identifierNick, headurl, userId, role);
    }

    // 聊天室-客户端通知H5有人离开聊天室
    function pcSetOffline(identifierNick, headurl, userId, role){
        chat.pcSetOffline(identifierNick, headurl, userId, role);
    }

    //  聊天室-客户端通知H5禁言
    function pcBanTalk(identifierNick, headurl, userId, role, type){
        chat.pcBanTalk(identifierNick, headurl, userId, role, type);
    }

    //  聊天室-客户端通知H5解禁言
    function pcAllowTalk(identifierNick, headurl, userId, role, type){
        chat.pcAllowTalk(identifierNick, headurl, userId, role, type);
    }
}
