import QtQuick 2.7
import HandlPingInfor 1.0
import QtGraphicalEffects 1.0

/*
 * 检测网络
 */
Rectangle {
    id:bakcGround
    color: "#00000000"

    property double widthRates: bakcGround.width / 240.0
    property double heightRates: bakcGround.height / 250.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

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
    signal sigChangeOldIpToNews();

    //当前网络状态
    signal sigCurrentNetStatus(var netStatus,var netValue);

    //    Image {
    //        id: bakcGroundImage
    //        anchors.left: parent.left
    //        anchors.top: parent.top
    //        width: parent.width
    //        height: parent.height
    //        source: "qrc:/images/rectanglenetwork.png"
    //    }

    //主体窗口
    Item {
        id: container;
        anchors.centerIn: parent;
        width: parent.width;
        height: parent.height;

        Rectangle {
            id: mainRect
            width: container.width - ( 2*rectShadow.radius);
            height: container.height - ( 2*rectShadow.radius);
            radius: rectShadow.radius;
            anchors.centerIn: parent;
            color: "#ffffff"
            //网络优化
            Rectangle{
                id:uploadPicture
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin:  15 * heightRates
                anchors.leftMargin: 15 * widthRates
                width: parent.width  - 30 * widthRates
                height: 20 * heightRates
                color: "#00000000"

                Text {
                    id: uploadPictureText
                    anchors.left: parent.left
                    anchors.top: parent.top
                    height: parent.height
                    width:parent.width
                    font.pixelSize:18 *  heightRates
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    color: "#3c3c3e"
                    wrapMode:Text.WordWrap
                    font.family: "Microsoft YaHei"
                    text: qsTr("网络优化")
                }
            }


            ListView{
                id:listView
                anchors.left: parent.left
                anchors.top: uploadPicture.bottom
                anchors.topMargin: 5 * heightRates
                anchors.leftMargin: 15 * widthRates
                width: parent.width  - 30 * widthRates
                height: 160 * heightRates
                model:listModel
                delegate: delegateItem
                clip: true
                z:2
            }

            ListModel{
                id:listModel
            }

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
                        font.pixelSize:14 *  heightRates
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
                        color: ipInfor == "差" ? "#ffd200" : (ipInfor == "良" ? "#ff3e00" : "#99cc33");
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
            Rectangle{
                id:refreshBtn
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width: parent.width
                height: 50 * heightRates
                color: "#00000000"
                z:2
                // anchors.leftMargin: 15 * widthRates

                Text {
                    id: refreshBtnText
                    anchors.left: parent.left
                    anchors.top: parent.top
                    height: 20 * heightRates
                    width: 56  * widthRates
                    anchors.leftMargin: 101 * widthRates
                    anchors.topMargin: refreshBtn.height / 2 - 5 * heightRates
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


            //关闭按钮
            Rectangle{
                id:closeBtn
                width: 20  * bakcGround.ratesRates
                height: 20 * bakcGround.ratesRates
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin:10 * bakcGround.ratesRates
                anchors.rightMargin: 10 * bakcGround.ratesRates
                color: "#00000000"
                z: 3
                Image {
                    width: parent.width
                    height: parent.height
                    source: "qrc:/images/cr_btn_quittwo.png"
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        bakcGround.visible = false;
                    }
                }
            }

            MouseArea{
                anchors.fill: parent
                z:1
                onClicked: {

                }
            }

            //处理数据
            HandlPingInfor {
                id:handlPingInfor
                onSigSendAddressLostDelayStatues:{
                    listModel.clear();
                    playbannera.stop();
                    refreshBtnImage.rotation = 0;
                    for(var i = 0 ; i < list.length ; i++) {
                        var str = list[i];
                        var strs= new Array();
                        strs = str.split("=");
                        listModel.append({ "ipItem":strs[0],
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
                    bakcGround.sigChangeOldIpToNews();
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
        interval: 30000//300000
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
        radius: 6.0 *  leftMidWidth / 66.0
        samples: 16;
        color: "#60000000";
        smooth: true;
        source: container;
    }

    Component.onCompleted: {
        if(loadDataStatus) {
            return;
        }
        loadDataStatus = true;
        handlPingInfor.getAllItemInfor();
    }
}

