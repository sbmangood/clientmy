import QtQuick 2.7
import HandlPingInfor 1.0
import QtGraphicalEffects 1.0
import "./Configuuration.js" as Cfg

/*
 * 检测网络
 */
Item {
    id:bakcGround

    property double widthRates: bakcGround.width / 240.0
    property double heightRates: bakcGround.height / 250.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    //当前通道
    property string currentAisle: "-1";
    property string onLine: "";//当前账号是否在线
    //是否加载数据
    property bool  loadDataStatus: false

    //网络优化
    signal sigNetworkOptimization();
    //设备检测
    signal sigEquipmentTesting();
    //发送当前网络状态
    signal sigSendCurrentNetworks(string status);
    //发送延迟的信息
    signal sigSendIpLostDelays(string strList);

    //切换ip
    signal sigChangeOldIpToNews(string currentAisle);

    //切换通道
    signal sigChangeAisle(string aisle);

    signal sigCurrentNetStatus(var netStatus,var netValue);

    //当前要被切换到的通道
    property var currenBeChangeAisle ;

    Rectangle{
        id: backView
        anchors.fill: parent
        anchors.centerIn: parent
        radius: 12 * heightRate
    }

    //主体窗口
    MouseArea {
        id: container
        z: 2
        anchors.centerIn: parent
        anchors.fill: parent

        Rectangle {
            id: mainRect
            width: 270 * widthRates * 1.1
            height: 234 * widthRates * 1.1
            radius: 12 * heightRate
            anchors.centerIn: parent;
            color: "#ffffff"
            Text {
                id: uploadPictureText
                anchors.fill: parent
                font.pixelSize: 16 *  heightRate
                anchors.left: parent.left
                anchors.leftMargin: 15 * heightRate
                anchors.top:parent.top
                anchors.topMargin: 20 * heightRate
                color: "#111111"
                font.family: "Microsoft YaHei"
                text: qsTr("通道")
            }

            //关闭按钮
            MouseArea{
                id:closeBtn
                width: 20  * heightRate
                height: 20 * heightRate
                anchors.right: parent.right
                anchors.rightMargin: 5 * heightRate
                anchors.top: parent.top
                anchors.topMargin: 5 * heightRate
                cursorShape: Qt.PointingHandCursor
                z: 3
                Image {
                    width: parent.width
                    height: parent.height
                    source: "qrc:/images/cr_btn_quittwo.png"
                }

                onClicked: {
                    bakcGround.visible = false;
                }
            }
            //通道、网络优化按钮
            Row{
                id: buttonItem
                z: 8
                width: parent.width - 35 * widthRates
                height: 35 * heightRates
                //anchors.top: uploadPicture.bottom
                anchors.topMargin: 10 * heightRates
                anchors.left: parent.left
                anchors.leftMargin: 15 * widthRates
                spacing: 3 * heightRates
                visible: false

                MouseArea{
                    width: parent.width
                    height: parent.height
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    Rectangle{
                        anchors.fill: parent
                        color: "#f6f6f6"
                    }

                    Text {
                        id: aisleText
                        text: qsTr("通道")
                        color: "#ff5000"
                        font.pixelSize: 14 * heightRate
                        font.family: "Microsoft YaHei"
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        listView.visible = false;
                        refreshBtn.visible = false;
                        //networkText.color = "black"
                        aisleText.color = "#ff5000"
                        aisleView.visible = true;
                        uploadPictureText.text = "通道";
                    }
                }

                /*MouseArea{
                    width: parent.width * 0.5
                    height: 35 * heightRates
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    Rectangle{
                        anchors.fill: parent
                        color:  "#f6f6f6"
                    }

                    Text {
                        id: networkText
                        text: qsTr("网络优化")
                        font.pixelSize: 14 * heightRate
                        font.family: "Microsoft YaHei"
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        listView.visible = true;
                        refreshBtn.visible = true;
                        aisleView.visible = false;
                        networkText.color = "#ff5000";
                        aisleText.color = "black";
                        uploadPictureText.text = "网络";
                    }
                }*/

            }

            //通道ListView
            ListView{
                id: aisleView
                anchors.left: parent.left
                anchors.top: buttonItem.bottom
                anchors.topMargin: 25 * heightRates
                anchors.leftMargin: 15 * widthRates
                width: parent.width  - 28 * widthRates
                height: 160 * heightRates - 16 * heightRates
                model:aisleModel
                delegate: aisleDelegate
                clip: true
                z: 2
            }

            MouseArea{
                id: commitButton
                width: 238 * widthRates * 1.1
                height: 34 * widthRates * 1.1
                cursorShape: Qt.PointingHandCursor
                anchors.top: aisleView.bottom
                anchors.topMargin: 20 * heightRates
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle{
                    anchors.fill: parent
                    radius: 4 * widthRate
                    color: "#ff5000"
                }

                Text {
                    text: qsTr("确定")
                    color: "white"
                    font.family: Cfg.DEFAULT_FONT
                    font.pixelSize: 14 * heightRate
                    anchors.centerIn: parent
                }

                onClicked: {
                    bakcGround.visible = false;
                    sigChangeAisle(currenBeChangeAisle);
                }
            }

            //网络优化ListView
            ListView{
                id:listView
                visible: false
                anchors.left: parent.left
                anchors.top: buttonItem.bottom
                anchors.topMargin: 5 * heightRates
                anchors.leftMargin: 15 * widthRates
                width: parent.width  - 30 * widthRates
                height: 160 * heightRates - 40 * heightRates
                model:listModel
                delegate: delegateItem
                clip: true
                z: 2
            }

            ListModel{
                id: aisleModel
            }

            ListModel{
                id:listModel
            }
            //通道delegate
            Component{
                id: aisleDelegate
                MouseArea{
                    width: aisleView.width
                    height: 45 * heightRates
                    enabled: enable

                    Row{
                        height: parent.height - 2 * heightRates
                        width: parent.width - 10 * heightRates
                        Text{
                            text: enable ? aisleText : aisleText + qsTr("(此通道暂不可用)")
                            width: parent.width - 16 * widthRates
                            height: parent.height
                            font.pixelSize: 13 * heightRate
                            font.family: "Microsoft YaHei"
                            verticalAlignment: Text.AlignVCenter
                            color: enable ? (selected ? "#FF5000" : "#333333") : "gray"
                        }

                        Image{
                            width: 18 * heightRates
                            height: 18 * heightRates
                            anchors.verticalCenter: parent.verticalCenter
                            z:5
                            //visible: selected
                            source: selected ? "qrc:/newStyleImg/select@2x.png" : "qrc:/newStyleImg/unselect@2x.png"
                        }
                    }

                    Rectangle{
                        width: parent.width
                        height: 1
                        anchors.bottom: parent.bottom
                        color: "#e3e6e9"
                    }
                    onClicked: {
                        for(var i = 0; i < aisleModel.count; i ++){
                            if(index == i){
                                aisleModel.get(i).selected = true;
                            }else{
                                aisleModel.get(i).selected = false;
                            }
                        }
                        //bakcGround.visible = false;
                        currenBeChangeAisle = aisle;
                        //sigChangeAisle(aisle);
                    }
                }
            }

            //网络优化delegate
            Component{
                id:delegateItem
                Rectangle{
                    id:delegateItems
                    width: listView.width
                    height: 40 * heightRates
                    color: "#ffffff"

                    Rectangle{
                        width: parent.width
                        height: 1
                        color: "#e3e6e9"
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                    }
                    Text {
                        id: delegateItemsOne
                        anchors.left: parent.left
                        anchors.top: parent.top
                        height: parent.height
                        width:70  * widthRates
                        font.pixelSize: 14 * heightRate
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        color: "#333333"
                        wrapMode:Text.WordWrap
                        font.family: "Microsoft YaHei"
                        text: ipName
                    }
                    Text {
                        id: delegateItemsTwo
                        anchors.left: delegateItemsOne.right
                        anchors.top: parent.top
                        height: parent.height
                        width:30  * widthRates
                        font.pixelSize:14 *  heightRates
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        color: ipInfor == "差" ? "#ffd200" : (ipInfor == "良" ? "#ff3e00" : "#99cc33")
                        wrapMode:Text.WordWrap
                        font.family: "Microsoft YaHei"
                        text: ipInfor
                    }
                    Image {
                        id: delegateItemsImage
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: 15 * heightRates
                        width: 11 * widthRates
                        height: 9 * heightRates
                        visible: ipSelect == ipItem ? true : false
                        source: "qrc:/images/checkTwoList.png"
                    }

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            for(var i = 0 ; i < listModel.count ; i++) {
                                listModel.setProperty(i,"ipSelect","0.0.0.0");
                            }

                            listModel.setProperty(index,"ipSelect",ipItem);
                            handlPingInfor.setSelectItemIp(ipItem);
                        }
                    }
                }
            }

            //刷新按钮
            Item{
                id:refreshBtn
                visible: false
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width: parent.width
                height: 40 * heightRates
                z:2

                Text {
                    id: refreshBtnText
                    anchors.centerIn: parent
                    font.pixelSize:14 *  heightRates
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    color: "#333333"
                    wrapMode:Text.WordWrap
                    font.family: "Microsoft YaHei"
                    text: qsTr("刷新路线")
                }
                Image {
                    id: refreshBtnImage
                    anchors.right:  refreshBtnText.left
                    anchors.top: refreshBtnText.top
                    height: 20 * heightRates
                    width: 20  * widthRates
                    fillMode: Image.PreserveAspectFit
                    rotation: 0
                    source: "qrc:/images/headbtnrefresh.png"
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        playbannera.start();
                        handlPingInfor.requestSeverAddress();
                    }
                }

            }

            SequentialAnimation {
                id: playbannera
                running: false
                loops:  Animation.Infinite
                NumberAnimation { target: refreshBtnImage; property: "rotation";from: 0; to: 360; duration: 3000}
            }

            //处理数据
            HandlPingInfor {
                id:handlPingInfor
                onSigSendAddressLostDelayStatues:{
                    listModel.clear();
                    playbannera.stop();
                    refreshBtnImage.rotation = 0;
                    //console.log("====listnet=====",list)
                    for(var i = 0 ; i < list.length ; i++) {
                        var str = list[i];
                        var strs= new Array();
                        strs = str.split("=");
                        listModel.append(
                                    { "ipItem":strs[0],
                                        "ipName":strs[1],
                                        "ipInfor":strs[2],
                                        "ipSelect":strs[3],
                                    });
                    }
                }

                onSigSendCurrentNetwork:{
                    bakcGround.sigSendCurrentNetworks( status);
                }

                onSigChangeOldIpToNew:{
                    bakcGround.sigChangeOldIpToNews(currentAisle);
                    bakcGround.visible = false;
                }

                onSigSendIpLostDelay:{
                    bakcGround.sigSendIpLostDelays(strList);
                }
                onSigCurrentNetworkStatus: {
                    sigCurrentNetStatus(netStatus,netValue);
                }
            }

        }
    }

    //定时器
    Timer{
        id:timer
        repeat: true
        interval: 300000
        running: true
        onTriggered: {
            handlPingInfor.requestSeverPing();
        }

    }
    Timer{
        repeat: true
        interval: 60000
        running: true
        onTriggered: {
            handlPingInfor.getCurrentConnectServerDelay();
        }

    }

    //绘制阴影
    DropShadow {
        id: rectShadow;
        anchors.fill: source
        cached: true;
        horizontalOffset: 0;
        verticalOffset: 0;
        radius: 12 * heightRate
        samples: 22
        color: "#60000000"
        smooth: true;
        source: backView;
    }

    Component.onCompleted: {
        if(loadDataStatus) {
            return;
        }
        loadDataStatus = true;
        handlPingInfor.getAllItemInfor();

        //        aisleModel.append({"aisleText":"通道A","aisle": "1","selected":true});
        //        aisleModel.append({"aisleText":"通道B","aisle": "2","selected":false});
        //        aisleModel.append({"aisleText":"通道C","aisle": "3","selected":false});

        aisleModel.clear();
        //A通道为默认通道
        aisleModel.append({"aisleText":"通道A","aisle": "1","selected":true,"enable":true});

        if(handlPingInfor.getChannelSwitch("2"))
        {
            aisleModel.append({"aisleText":"通道B","aisle": "2","selected":false,"enable":true});
        }

        if(handlPingInfor.getChannelSwitch("3"))
        {
            aisleModel.append({"aisleText":"通道C","aisle": "3","selected":false,"enable":true});
        }

    }

    onCurrentAisleChanged: {
        //console.log("===currentAisle===",currentAisle)
        //        if(currentAisle == "1"){
        //            aisleModel.get(0).selected = true;
        //            aisleModel.get(1).selected = false;
        //            aisleModel.get(2).selected = false;
        //        }else if(currentAisle == "2"){
        //            aisleModel.get(0).selected = false;
        //            aisleModel.get(1).selected = true;
        //            aisleModel.get(2).selected = false;
        //        }else if(currentAisle == "3"){
        //            aisleModel.get(0).selected = false;
        //            aisleModel.get(1).selected = false;
        //            aisleModel.get(2).selected = true;
        //        }
        for(var a = 0; a < aisleModel.count; a++)
        {
            aisleModel.get(a).selected = false;
        }
        aisleModel.get( currentAisle - 1 ).selected = true;
    }

    //学生端以新 老版本变化 进入教室时做以下兼容 老版本时禁用c通道 退出之前如果是 c通道 自动切换至a通道
    function resetAisleModelForCAisle(isOlderVersion)
    {
        for(var i = 0; i < aisleModel.count; i++)
        {
            if(aisleModel.get(i).aisle == "3")
            {
                if(isOlderVersion)
                {
                    aisleModel.get(i).enable = false

                    if(currentAisle == 3)
                    {
                        currentAisle = 1;
                        sigChangeAisle("1");
                    }
                }else
                {
                    aisleModel.get(i).enable = true;
                }

            }

        }
    }

}

