import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "./Configuration.js" as Cfg

//设备检测
Rectangle{
    id: deviceView
    color: "#3D3F4E"
    radius: 8 * heightRate

    property int interNetStatus: 3;//3:无线 4:有线
    property int interNetGrade: 3;
    property int interNetValue: 3;
    property int routingPing: 3;
    property int wifiDevice: 0;
    property int routingGrade: 3;
    property int deviceSelecteIndex: 1;//1:语音 2: 摄像头 3:网络
    property int currentVolumeIndex: 0;

    property bool isNotFirstTest: false;
    property int countNumber: 0;

    signal sigFinishedTest();
    signal sigFirstStartTest();

    onVisibleChanged: {
        if(visible){
            deviceTestRectView.visible = visible;
            //重置状态            
            countNumber = 3;
            deviceSelecteIndex = 1;
            soundTestView.visible=true;
            cameraTestView.visible=false;
            netTestView.visible=false;
            resetItem.visible = false;
            nextItem.visible = false;
            networkColumn.visible = false;
            animationTimer.stop();
            startTestButton.visible=true;
            networkImg.visible = true;
            toolbar.startOrStopVideoTest(false);
            volumeList.splice(0,volumeList.length);

            var allCarmerDeviceList= toolbar.getUserDeviceList(2);
            playerComboBox.model=  allCarmerDeviceList;

            allCarmerDeviceList= toolbar.getUserDeviceList(3);
            recorderComboBox.model=  allCarmerDeviceList;
        }
    }

    MouseArea{
        z: 6
        width: parent.width
        height: 60 * heightRate
        cursorShape: Qt.PointingHandCursor

        property point pressPos: "0,0"

        onPressed: {
            pressPos = Qt.point(mouse.x, mouse.y);
        }

        onPositionChanged: {
            var delta = Qt.point(mouse.x-pressPos.x, mouse.y-pressPos.y);
            var moveX = deviceView.x + delta.x;
            var moveY = deviceView.y + delta.y;
            var moveWidth = deviceView.parent.width - deviceView.width;
            var moveHeight = deviceView.parent.height - deviceView.height;

            if( moveX > 0 && moveX < moveWidth) {
                deviceView.x = deviceView.x + delta.x;
            }else{
                var loactionX = moveX < 0 ? 0 : (moveX > moveWidth ? moveWidth : moveX);
                deviceView.x = loactionX;
            }

            if(moveY  > 0 && moveY < moveHeight){
                deviceView.y = deviceView.y + delta.y;
            }else{
                deviceView.y = moveY < 0 ? 0 : (moveY > moveHeight ? moveHeight : moveY);
            }
        }

        MouseArea{
            z: 7
            width: 40 * heightRate
            height: 40 * heightRate
            anchors.right: parent.right
            anchors.rightMargin: 6 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Image{
               width: 32 * widthRate
               height: 32 * widthRate
               anchors.centerIn: parent
               source: "qrc:/bigclassImage/close.png"
            }

            onClicked: {
                deviceView.visible = false;
                deviceTestRectView.visible = false;
                toolbar.releaseDevice();
                sigFinishedTest();
            }
        }

    }

    MouseArea{
        anchors.fill: parent
        onClicked: {

        }
    }

    property int timersRunTimes: 0;
    property var volumeList: [];
    property int countNum: 12;

    //检测项目
    Item {
        z: 8
        width: 390 * heightRate
        height: 40 * heightRate
        anchors.top: parent.top
        anchors.topMargin: 14 * widthRate
        anchors.horizontalCenter: parent.horizontalCenter

        Row {
            anchors.fill: parent
            Item {
                id:testOne
                width: parent.width / 3
                height: parent.height
                Rectangle{
                    radius: 6 * heightRate
                    color: deviceSelecteIndex == 1 ? "#4D90FF" : "#3D3F4E"
                    anchors.fill: parent
                }
                Rectangle{
                    width: 10 * heightRate
                    height: parent.height
                    anchors.right: parent.right
                    color: deviceSelecteIndex == 1 ? "#4D90FF" : "#3D3F4E"
                }
                Text {
                    text: qsTr("语音检测")
                    anchors.centerIn: parent
                    color: deviceSelecteIndex == 1 ? "white" : "#4D90FF"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEVICE_FAMILY
                }
            }
            Rectangle {
                id: testTwo
                width: parent.width / 3
                height: parent.height
                color: deviceSelecteIndex == 2 ? "#4D90FF" : "transparent"
                Text {
                    text: qsTr("摄像头检测")
                    anchors.centerIn: parent
                    color: deviceSelecteIndex == 2 ? "white" : "#4D90FF"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEVICE_FAMILY
                }
            }
            Rectangle{
                width: parent.width / 3
                height: parent.height
                id:testThree
                radius: 5 * heightRate
                color: deviceSelecteIndex == 3 ? "#4D90FF" : "transparent"

                Rectangle{
                    width: 10 * heightRate
                    height: parent.height
                    color: deviceSelecteIndex == 3 ? "#4D90FF" : "transparent"
                }

                Text {
                    text: qsTr("网络检测")
                    anchors.centerIn: parent
                    color: deviceSelecteIndex == 3 ? "white" : "#4D90FF"
                    font.pixelSize: 16 * heightRate
                    font.family: Cfg.DEVICE_FAMILY
                }
            }
        }

        Rectangle{
            anchors.fill: parent
            radius: 6 * heightRate
            color: "transparent"
            border.color: "#4D90FF"
            border.width: 1
        }
    }

    Item {
        id: deviceTestRectView
        z: 7
        width: parent.width - 40 * heightRate
        height: parent.height - 80 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin:  70 * heightRate

        //语音检测
        Item{
            id:soundTestView
            anchors.fill: parent
            visible: true

            Image{
                id: mrcImg
                width: 130 * heightRate
                height: 130 * heightRate
                source: "qrc:/bigclassImage/yuyin3@2x.png"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: tipsText
                visible: false
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: mrcImg.bottom
                anchors.topMargin: 8 * heightRate
                font.pixelSize: 16 * heightRate
                font.family: Cfg.DEFAULT_FONT
                text: qsTr("请大声说话"+ countNum.toString() +"秒后播放说话声音")
                color: "#ffffff"
            }

            YMComboBoxControl {
                id: playerComboBox//播放器combobox
                height: 38 * heightRate
                width: parent.width * 0.45
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 70 * heightRate
                clip: true
                model: ["选择播放设备"]
                onCurrentTextChanged: {
                    if(visible){
                        toolbar.setPlayerDevice(playerComboBox.currentText);
                    }
                }
            }

            YMComboBoxControl {
                id: recorderComboBox//播放器combobox
                height: 38 * heightRate
                width: parent.width * 0.45
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 70 * heightRate
                anchors.left: playerComboBox.right
                anchors.leftMargin: 12 * widthRate
                clip: true
                model: ["选择录音设备"]
                onCurrentTextChanged: {
                    if(visible)
                    {
                        toolbar.setRecorderDevice(recorderComboBox.currentText);
                    }
                }
            }

            Timer{
                id: mrcTimer
                interval: 1000
                running: false
                repeat: true
                onTriggered: {
                    countNum--;
                    if(countNum <= 1){
                        mrcTimer.stop();
                        tipsText.visible = false;
                        resetItem.visible = true;
                        nextItem.visible = true;
                    }
                }
            }

            Row{
                width:  parent.width
                height: 44 * heightRate
                spacing: startTestButton.visible ? 0 : 30 * heightRate
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10 * heightRate
                //开始测试
                Rectangle{
                    id:startTestButton
                    width: parent.width
                    height: 44 * heightRate
                    color: "#618AEB"
                    radius: 4 * heightRate

                    Text{
                        id:startTestButtonText
                        anchors.centerIn: parent
                        font.pixelSize: 16 * widthRate
                        text: qsTr("开始检测")
                        font.family: Cfg.DEVICE_FAMILY
                        color: "#ffffff"
                    }

                    MouseArea{
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            countNum = 12;
                            mrcTimer.restart();
                            tipsText.visible = true;
                            startTestButton.visible = false;
                            toolbar.setPlayerDevice(playerComboBox.currentText); //指定使用哪一个设备, 进行检测
                            toolbar.setRecorderDevice(recorderComboBox.currentText); //指定使用哪一个设备, 进行检测
                            toolbar.startOrStopAudioTest(true);
                        }
                    }
                }

                Rectangle{
                    id: resetItem
                    width: 188 * heightRate
                    height: 44 * heightRate
                    border.width: 1
                    border.color: "#6189EB"
                    radius: 4 * heightRate
                    visible: false
                    color:"#00000000"
                    Text {
                        anchors.centerIn: parent
                        font.pixelSize: 16 * widthRate
                        text: qsTr("听不到")
                        color: "#6189EB"
                        font.family: Cfg.DEVICE_FAMILY
                    }

                    MouseArea{
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked:{
                            console.log("重新开始音频测试")
                            startTestButton.visible= true;
                            toolbar.startOrStopAudioTest(false);
                            timersRunTimes = 0;

                            volumeList.splice(0,volumeList.length);

                        }
                    }
                }
                Rectangle{
                    id: nextItem
                    width: 252 * heightRate
                    height: 44 * heightRate
                    radius: 4 * heightRate
                    visible: false
                    color:"#618AEB"

                    Text {
                        anchors.centerIn: parent
                        font.pixelSize: 16 * widthRate
                        font.family: Cfg.DEVICE_FAMILY
                        text: qsTr("可以听到 进行下一步")
                        color: "#ffffff"
                    }

                    MouseArea{
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked:{
                            toolbar.setPlayerDevice(playerComboBox.currentText);
                            toolbar.setRecorderDevice(recorderComboBox.currentText);
                            toolbar.startOrStopAudioTest(false);
                            deviceSelecteIndex = 2;
                            soundTestView.visible=false;
                            cameraTestView.visible= true;

                            volumeList.splice(0,volumeList.length);
                            toolbar.startOrStopVideoTest(false);
                            camerImageView.visible=false;

                            toolbar.startOrStopAudioTest(false);
                            soundTestView.visible=false;
                            timersRunTimes=0;
                            resetItem.visible = true;
                            nextItem.visible = true;
                            noCarmerDeviceView.visible=false;
                            //获取摄像头列表
                            var allCarmerDeviceList= toolbar.getUserDeviceList(1);
                            cameraComboBox.model=  allCarmerDeviceList;

                            toolbar.setCarmerDevice(cameraComboBox.currentText); //设置使用哪一个摄像头
                            if(isNotFirstTest){
                                toolbar.releaseDevice();
                                isNotFirstTest = true;
                            }
                            else {
                                sigFirstStartTest();
                            }
                            toolbar.startOrStopVideoTest(true);
                        }
                    }
                }
            }
        }

        //摄像头检测
        Item {
            id:cameraTestView
            anchors.fill: parent
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false

            Column{
                anchors.fill: parent
                spacing: 8 * heightRate

                Rectangle{
                    width: 450 * widthRate
                    height: 176 * heightRate
                    color: "#46495E"

                    Image {
                        id: camerImageView
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        source: ""
                        visible: false
                    }
                    Image {
                        anchors.centerIn: parent
                        width: 51 * heightRate
                        height: 64 * heightRate
                        visible: !camerImageView.visible
                        source: "qrc:/bigclassImage/shexiangtou.png"

                    }
                    Image {
                        id: noCarmerDeviceView
                        anchors.centerIn: parent
                        width: 79 * widthRate
                        height: 40 * widthRate
                        visible: !camerImageView.visible
                        source: "qrc:/networkImage/meiyou.png"
                    }
                }

                YMComboBoxControl {
                    id: cameraComboBox//播放器combobox
                    height: 38 * heightRate
                    width: parent.width * 0.8
                    model: ["选择摄像设备"]
                    clip: true
                    onCurrentTextChanged: {
                        if(visible){
                            toolbar.setCarmerDevice(cameraComboBox.currentText);
                        }
                    }
                }

                Row{
                    width:  parent.width
                    height: 44 * heightRate
                    spacing: 10 * heightRate

                    Rectangle{
                        width: 188 * heightRate
                        height: 44 * heightRate
                        border.width: 1
                        border.color: "#6189EB"
                        radius: 4 * heightRate
                        color:"#3D3F4E"

                        Text {
                            anchors.centerIn: parent
                            font.pixelSize: 16 * heightRate
                            font.family: Cfg.DEVICE_FAMILY
                            text: qsTr("无法看到")
                            color: "#6189EB"
                        }

                        MouseArea{
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked:{
                                console.log("看不到，重新检测")
                                toolbar.startOrStopVideoTest(false);
                                camerImageView.visible=false;
                                noCarmerDeviceView.visible=false;
                            }
                        }
                    }

                    Rectangle{
                        width: 252 * widthRate
                        height: 44 * heightRate
                        radius: 4 * heightRate
                        color: "#618AEB"
                        Text {
                            anchors.centerIn: parent
                            font.pixelSize: 16 * heightRate
                            font.family: Cfg.DEVICE_FAMILY
                            text: qsTr("可以看到 进行下一步")
                            color: "#ffffff"

                        }
                        MouseArea{
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked:{
                                console.log("看到了，下一步")
                                toolbar.setCarmerDevice(cameraComboBox.currentText);
                                toolbar.startOrStopVideoTest(false);

                                soundTestView.visible=false;
                                cameraTestView.visible=false;
                                netTestView.visible = true;

                                deviceSelecteIndex = 3;
                                countNumber = 0;
                                networkColumn.visible = false;
                                networkMgr.getRoutingNetwork();
                                animationTimer.restart();
                            }
                        }
                    }

                }
            }
        }

        //网络检测
        Item {
            id:netTestView
            anchors.fill: parent
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false

            Timer{
                id: animationTimer
                interval: 1000
                repeat: true
                running: false
                onTriggered: {
                    if(countNumber >=3){
                        countNumber = 0;
                    }
                    countNumber++;
                }
            }

            Image{
                id: networkImg
                width: 130 * widthRate
                height: 130 * widthRate
                source: {
                    if(countNumber == 3){
                        return "qrc:/bigclassImage/wangluo3.png"
                    }
                    if(countNumber == 2){
                        return "qrc:/bigclassImage/wangluo2.png"
                    }
                    if(countNumber == 1){
                        return "qrc:/bigclassImage/wangluo1.png"
                    }
                    return "qrc:/bigclassImage/wangluo3.png"
                }
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 20 * heightRate
            }

            Text {
                font.pixelSize: 22 * heightRate
                font.family: Cfg.DEFAULT_FONT
                color: "#ffffff"
                text: qsTr("网络检测中...")
                anchors.top: networkImg.bottom
                anchors.topMargin: 10 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                visible: networkImg.visible
            }

            Item{
                width: parent.width
                height: 160 * widthRate
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 20 * heightRate

                Column{
                    id: networkColumn
                    visible: false
                    anchors.fill: parent
                    spacing: 10 * heightRate

                    Row{
                        anchors.horizontalCenter: parent.horizontalCenter

                        YMInterControlView{
                            wifiValue: interNetValue.toString() + "ms"
                            colorGrade: interNetGrade
                            networkTips: "互联网延迟"
                            networkStatus: {
                                if(interNetGrade == 3)
                                    return qsTr("当前网络状态很好");
                                if(interNetGrade == 2)
                                    return "当前网络状态一般";
                                if(interNetGrade == 1)
                                    return "当前网络状态较差";
                                if(interNetGrade == 0)
                                    return "当前无网络，请检查网络连接是否正常";
                            }
                        }
                    }
                }
            }

            Row{
                width:   parent.width
                height: 44 * heightRate
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 16 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10 * heightRate

                Rectangle{
                    width: 188 * heightRate
                    height: 44 * heightRate
                    radius: 4 * heightRate
                    border.width: 1
                    border.color: "#6189EB"
                    color:"#3D3F4E"
                    Text {
                        anchors.centerIn: parent
                        font.pixelSize: 16 * widthRate
                        font.family: Cfg.DEVICE_FAMILY
                        text: qsTr("检测完成")
                        color: "#618AEB"
                    }

                    MouseArea{
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked:{
                            deviceTestRectView.visible= false;
                            deviceView.visible = false;
                            toolbar.releaseDevice();
                            sigFinishedTest();
                        }
                    }
                }

                MouseArea{
                    width: 252 * heightRate
                    height: parent.height
                    cursorShape: Qt.PointingHandCursor

                    Rectangle{
                        anchors.fill: parent
                        color: "#618AEB"
                        radius: 4 * heightRate
                    }

                    Text {
                        font.family: Cfg.DEFAULT_FONT
                        font.pixelSize: 16 * heightRate
                        text: qsTr("重新检测")
                        color: "#ffffff"
                        anchors.centerIn: parent
                    }

                    onClicked: {
                        networkMgr.getRoutingNetwork();
                        countNumber = 0;
                        networkColumn.visible = false;
                        networkImg.visible = true;
                        animationTimer.restart();
                    }
                }
            }

        }

    }

    function setVisibleNetwork(){
        networkColumn.visible = true;
        networkImg.visible = false;
    }

    function updateCareme(fileName){
        camerImageView.cache=false;
        camerImageView.visible=true;
        camerImageView.source= "file:///"+fileName
    }

}
