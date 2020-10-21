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
            anchors.fill: parent
            radius: 12 * heightRate
            anchors.centerIn: parent;
            color: "#ffffff"
            //网络优化
            Item{
                id:uploadPicture
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin:  10 * heightRates
                anchors.leftMargin: 15 * widthRates
                width: parent.width  - 30 * widthRates
                height: 20 * heightRates

                Text {
                    id: uploadPictureText
                    anchors.fill: parent
                    font.pixelSize: 17 *  heightRate
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    color: "#3c3c3e"
                    font.family: "Microsoft YaHei"
                    text: qsTr("通道")
                }

                //关闭按钮
                MouseArea{
                    id:closeBtn
                    width: 20  * bakcGround.ratesRates
                    height: 20 * bakcGround.ratesRates
                    anchors.right: parent.right
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
            }
            //通道、网络优化按钮
            Row{
                id: buttonItem
                z: 8
                width: parent.width - 35 * widthRates
                height: 35 * heightRates
                anchors.top: uploadPicture.bottom
                anchors.topMargin: 10 * heightRates
                anchors.left: parent.left
                anchors.leftMargin: 15 * widthRates
                spacing: 1 * heightRates

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
                anchors.topMargin: 5 * heightRates
                anchors.leftMargin: 15 * widthRates
                width: parent.width  - 30 * widthRates
                height: 160 * heightRates - 50 * heightRates
                model:aisleModel
                delegate: aisleDelegate
                clip: true
                z: 2
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
                    height: 40 * heightRates

                    Row{
                        anchors.fill: parent
                        Text{
                            text: aisleText
                            width: parent.width - 11 * widthRates
                            height: parent.height
                            font.pixelSize:14 * heightRate
                            font.family: "Microsoft YaHei"
                            verticalAlignment: Text.AlignVCenter
                        }

                        Image{
                            width: 11 * widthRates
                            height: 9 * heightRates
                            anchors.verticalCenter: parent.verticalCenter
                            visible: selected
                            source: "qrc:/images/checkTwoList.png"
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
                        bakcGround.visible = false;
                        sigChangeAisle(aisle);
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

        aisleModel.append({"aisleText":"通道A","aisle": "1","selected":true});
        aisleModel.append({"aisleText":"通道B","aisle": "2","selected":false});
    }

    onCurrentAisleChanged: {
        //console.log("===currentAisle===",currentAisle)
        if(currentAisle == "1"){
            aisleModel.get(0).selected = true;
            aisleModel.get(1).selected = false;
        }else{
            aisleModel.get(0).selected = false;
            aisleModel.get(1).selected = true;
        }
    }

}

