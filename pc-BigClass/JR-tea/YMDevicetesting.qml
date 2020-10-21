import QtQuick 2.0
import QtQuick.Controls 1.4
import YMdevicetesting 1.1
import QtQuick.Controls.Styles 1.4
import "./Configuration.js" as Cfg

//设备检测
MouseArea{
    id: deviceView
    hoverEnabled: true
    onWheel: {
        return
    }

    onVisibleChanged: {
        if(visible){
            deviceTestRectView.visible = visible;
            //重置状态
            testOne.color="#999999"
            testThree.color="transparent"
            testTwo.color="transparent"
            soundTestView.visible=true;
            cameraTestView.visible=false;
            netTestView.visible=false;
            networkColumn.visible = false;
            startTestButton.visible=true;
            startTestButton.enabled=true;
            deviceTestClass.startOrStopVideoTest(false);
            volumeList.splice(0,volumeList.length);
            currentVolumeIndex = 0 ;

            var allCarmerDeviceList= deviceTestClass.getUserDeviceList(2);
            playerComboBox.model=  allCarmerDeviceList;

            allCarmerDeviceList= deviceTestClass.getUserDeviceList(3);
            recorderComboBox.model=  allCarmerDeviceList;
        }
    }

    Rectangle{
        id: backView
        anchors.fill: parent
        color: "black"
        opacity: 0.4
        radius: 12 * widthRate
    }

    property int timersRunTimes: 0;
    property var volumeList: [];
    property int currentVolumeIndex: 0;

    YMdevicetesting {
        id: deviceTestClass
        onNetQuailty: {
            //console.log("网络质量",quality);
            deviceTestClass.startOrStopNetTest(false);
            startTesNetButton.visible = false;
            netTestTextItem.text="开始测试";
            if(interNetStatus !=3 ){
                networkColumn.visible = true;
            }
            //判断网络质量
            if(quality==1 || quality==2 ) {
                interNetGrade = 3;
                return;
            }
            if(quality==3 || quality==4) {
                interNetGrade = 2;
                return;
            }
            if( quality==5 ) {
                interNetGrade = 1;
                return;
            }
            if(quality==6 || quality==0 ){
                interNetGrade = 0;
                return;
            }
        }

        onImageChange: {
            //console.log(fileName)
            camerImageView.cache=false;
            camerImageView.visible=true;
            camerImageView.source= "file:///"+fileName
        }
        onCarmerReady: {
            startTesCameraButton.visible=false;
        }
        onNoCarmerDevices: {
            startTesCameraButton.visible=false;
            camerImageView.visible=false;
            noCarmerDeviceView.visible=true;
        }
        onSpeakerVolume:{
            volumeList.push(volume);
            if(!startTestButton.visible) {
                if(speakerId!=0) {
                    currentVolumeIndex=volume / 255 * 28 ;
                }
            }else {
                if(speakerId==0){
                    currentVolumeIndex=volume / 255 * 28;
                }
            }
        }
    }

    Rectangle {
        id: deviceTestRectView
        width: 550 * widthRate
        height: width / 1.30
        border.color: "#F5F5F5"
        border.width: 2
        anchors.centerIn: backView
        radius: 10 * heightRate

        //top标题栏
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 2
            anchors.top:parent.top
            height: 60 * heightRate - 2
            color: "#F5F5F5"
            radius: 10 * heightRate
            Text {
                text: qsTr("设备检测")
                anchors.centerIn: parent
                color: "#333333"
                font.family: Cfg.DEVICE_FAMILY
                font.pixelSize: Cfg.DEVICE_HEADFONTSIZE * heightRate
                font.bold: true
            }
            MouseArea{
                width: 35 * widthRate
                height: 35 * widthRate
                anchors.right: parent.right
                anchors.rightMargin: 1 * widthRate
                anchors.top: parent.top
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                Text{
                    text: "×"
                    font.bold: true
                    font.pixelSize: 16 * widthRate
                    color: parent.containsMouse ? "red" : "#3c3c3e"
                    anchors.centerIn: parent
                }

                onClicked: {
                    deviceView.visible = false;
                    deviceTestClass.releaseDevice();
                    deviceTestRectView.visible = false;
                }
            }
            Rectangle {
                height: 1
                width: parent.width
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                color:"#CCCCCC"
            }
        }

        //检测项目
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 360 * widthRate
            height: 40 * widthRate
            anchors.top: parent.top
            anchors.topMargin: 80 * heightRate
            radius: 5 * heightRate

            Row {
                anchors.fill: parent
                Rectangle {
                    width: parent.width / 3
                    height: parent.height
                    id:testOne
                    radius: 5 * heightRate
                    color: "#999999"
                    Text {
                        text: qsTr("语音检测")
                        anchors.centerIn: parent
                        color: testOne.color=="#999999" ? "white" : "black"
                        font.bold:  testOne.color=="#999999" ? true : false
                        font.pixelSize: Cfg.DEVICE_MUEN_FONTSIZE * heightRate
                        font.family: Cfg.DEVICE_FAMILY
                    }
                    MouseArea {
                        id: soundButton
                        anchors.fill: parent
                        onClicked: {
                            if(soundTestView.visible == false){
                                testOne.color="#999999"
                                testThree.color="transparent"
                                testTwo.color="transparent"
                                soundTestView.visible=true;
                                cameraTestView.visible=false;
                                netTestView.visible = false;
                                networkColumn.visible = false;
                                startTestButton.visible=true;
                                startTestButton.enabled=true;
                                deviceTestClass.startOrStopVideoTest(false);
                                volumeList.splice(0,volumeList.length);
                                currentVolumeIndex = 0 ;

                                var allCarmerDeviceList= deviceTestClass.getUserDeviceList(2);
                                playerComboBox.model=  allCarmerDeviceList;

                                allCarmerDeviceList= deviceTestClass.getUserDeviceList(3);
                                recorderComboBox.model=  allCarmerDeviceList;


                            }
                        }
                    }
                }
                Rectangle {
                    id: testTwo
                    width: parent.width / 3
                    height: parent.height
                    Text {
                        text: qsTr("摄像头检测")
                        anchors.centerIn: parent
                        color: testTwo.color=="#999999" ? "white" : "black"
                        font.bold:  testTwo.color=="#999999" ? true : false
                        font.pixelSize: Cfg.DEVICE_MUEN_FONTSIZE * heightRate
                        font.family: Cfg.DEVICE_FAMILY
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(cameraTestView.visible == false){
                                testOne.color="transparent"
                                testThree.color="transparent"
                                testTwo.color="#999999"
                                soundTestView.visible=false;
                                cameraTestView.visible=true;
                                netTestView.visible=false;
                                networkColumn.visible = false;

                                startTesCameraButton.visible=true;
                                startTestCarmerText.text="开始测试";
                                deviceTestClass.startOrStopVideoTest(false);
                                camerImageView.visible=false;

                                deviceTestClass.startOrStopAudioTest(false);
                                soundTestView.visible=false;
                                timersRunTimes=0;
                                startTestButtonText.text="开始测试（10s）"
                                testAudioTimer.stop();;

                                noCarmerDeviceView.visible=false;
                                //获取摄像头列表
                                var allCarmerDeviceList= deviceTestClass.getUserDeviceList(1);
                                cameraComboBox.model=  allCarmerDeviceList;

                            }
                        }
                    }
                }
                Rectangle
                {
                    width: parent.width / 3
                    height: parent.height
                    id:testThree
                    radius: 5 * heightRate
                    Text {
                        text: qsTr("网络检测")
                        anchors.centerIn: parent
                        font.bold:  testThree.color=="#999999" ? true : false
                        color: testThree.color=="#999999" ? "white" : "black"
                        font.pixelSize: Cfg.DEVICE_MUEN_FONTSIZE * heightRate
                        font.family: Cfg.DEVICE_FAMILY
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(netTestView.visible == false){
                                testOne.color="transparent"
                                testThree.color="#999999"
                                testTwo.color="transparent"
                                soundTestView.visible=false;
                                cameraTestView.visible=false;
                                netTestView.visible=true;

                                startTesNetButton.visible=true;
                                netTestTextItem.text="开始测试";

                                deviceTestClass.startOrStopVideoTest(false);

                                deviceTestClass.startOrStopAudioTest(false);
                                soundTestView.visible=false;
                                timersRunTimes=0;
                                startTestButtonText.text="开始测试（10s）"
                                testAudioTimer.stop();
                            }
                        }
                    }
                }
            }
            Rectangle {
                anchors.fill: parent
                border.width: 0.5
                border.color: "#CCCCCC"
                color:"transparent"
                radius: 5
                opacity: 0.6
            }
        }

        //语音检测
        Rectangle
        {
            id:soundTestView
            width: parent.width
            height: parent.height * 0.75
            color: "transparent"
            anchors.bottom:parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            visible: true

            YMComboBoxControl {
                id: playerComboBox//播放器combobox
                height: 35 * heightRate
                width: 98 * widthRate
                anchors.right: parent.right
                anchors.rightMargin: 15 * widthRate
                clip: true
                model: ["选择播放设备"]
                onCurrentTextChanged: {
                    if(visible)
                    {
                        // deviceTestClass.setPlayerDevice(playerComboBox.currentText);
                    }
                }
            }
            YMComboBoxControl {
                id: recorderComboBox//播放器combobox
                height: 35 * heightRate
                width: 98 * widthRate
                anchors.top: playerComboBox.bottom
                anchors.topMargin: 10 * widthRate
                anchors.right: parent.right
                anchors.rightMargin: 15 * widthRate
                clip: true
                model: ["选择录音设备"]
                onCurrentTextChanged: {
                    if(visible)
                    {
                        // deviceTestClass.setRecorderDevice(recorderComboBox.currentText);
                    }
                }
            }
            Timer
            {
                id:testAudioTimer
                interval: 1000
                running: false
                repeat: false
                onTriggered:
                {
                    if(timersRunTimes<10)
                    {
                        timersRunTimes ++;
                        console.log(timersRunTimes);
                        testAudioTimer.restart();
                        startTestButtonText.text= "开始测试（" +(10-timersRunTimes) + "s）"
                    }
                    else
                    {
                        startTestButton.enabled= true;
                        startTestButton.visible=false;

                    }
                }
            }

            Column
            {
                anchors.fill: parent
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 35 * heightRate
                Image {
                    width: 55 * widthRate
                    height:  width
                    source: "qrc:/images/yuyin@3x.png"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Rectangle
                {
                    width: 287 * widthRate
                    height: 28 * widthRate
                    anchors.horizontalCenter: parent.horizontalCenter
                    ProgressBar {
                        id: volumeProgressBar
                        width: parent.width
                        height: parent.height
                        value: 0
                        maximumValue: 500 //255
                        minimumValue: 0
                        anchors.centerIn: parent
                        style: ProgressBarStyle {
                            background: Rectangle {
                                clip:true
                                radius: 2
                                color: "transparent"
                                Row{
                                    spacing: 5 * widthRate
                                    Repeater{
                                        id:rep
                                        model :28
                                        Rectangle{
                                            height: volumeProgressBar.height
                                            width: 7 * widthRate
                                            radius: 1
                                            color: "#E8E8E8"
                                            border.color: "#D5D6D7"
                                            border.width: 1
                                        }
                                    }

                                }
                                Row{
                                    spacing: 5 * widthRate
                                    Repeater{

                                        model:currentVolumeIndex
                                        Rectangle{
                                            height: volumeProgressBar.height
                                            width: 7 * widthRate
                                            radius: 1
                                            color: "#90E7F5"
                                        }
                                    }

                                }
                            }
                            progress: Rectangle {
                                color: "transparent"

                            }
                        }


                    }
                }

                Text {
                    width:startTestButton.visible ? 435 * widthRate : 120 * widthRate
                    height: 15 * widthRate
                    text: startTestButton.visible ?  qsTr("请点击开始检测，并对准麦克风大声说话，系统在10秒后播放您的声音") : "请确认是否能听到说话"
                    font.pixelSize: Cfg.DEVICE_FONTSIZE * widthRate
                    font.family: Cfg.DEVICE_FAMILY
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#333333"
                }

                Row
                {
                    width:  startTestButton.visible ? 118 * widthRate : 236 * widthRate
                    height: 33 * widthRate
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: startTestButton.visible ? 0 : 30 * heightRate
                    //开始测试
                    Rectangle
                    {
                        id:startTestButton
                        width: 118 * widthRate
                        height: 33 * widthRate
                        border.width: 1
                        border.color: "#C2BEBE"
                        color:"#f4f4f4"
                        // anchors.horizontalCenter: parent.horizontalCenter
                        radius:5 * heightRate
                        visible: true
                        Text {
                            id:startTestButtonText
                            anchors.centerIn: parent
                            font.pixelSize: Cfg.DEVICE_BUTTON_FONTSIZE * widthRate
                            text: qsTr("开始测试（10s）")
                            font.family: Cfg.DEVICE_FAMILY
                            color: "#333333"

                        }
                        MouseArea
                        {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                            {
                                startTestButton.enabled= false;
                                deviceTestClass.setPlayerDevice(playerComboBox.currentText); //指定使用哪一个设备, 进行检测
                                deviceTestClass.setRecorderDevice(recorderComboBox.currentText); //指定使用哪一个设备, 进行检测
                                deviceTestClass.startOrStopAudioTest(true);
                                testAudioTimer.restart();
                            }
                        }
                    }
                    Rectangle
                    {
                        width: 118 * widthRate
                        height: 33 * widthRate
                        border.width: 1
                        border.color: "#C2BEBE"
                        // anchors.horizontalCenter: parent.horizontalCenter
                        radius:5 * heightRate
                        visible: !startTestButton.visible
                        color:"#f4f4f4"
                        Text {
                            anchors.centerIn: parent
                            font.pixelSize: Cfg.DEVICE_BUTTON_FONTSIZE * widthRate
                            font.family: Cfg.DEVICE_FAMILY
                            text: qsTr("听到了，下一步")
                            color: "#333333"

                        }
                        MouseArea
                        {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                            {
                                console.log("完成音频测试，进行下一步")

                                deviceTestClass.setPlayerDevice(playerComboBox.currentText);
                                deviceTestClass.setRecorderDevice(recorderComboBox.currentText);

                                deviceTestClass.startOrStopAudioTest(false);
                                testOne.color="transparent"
                                testThree.color="transparent"
                                testTwo.color="#999999"
                                soundTestView.visible=false;
                                cameraTestView.visible= true;

                                volumeList.splice(0,volumeList.length);
                                startTesCameraButton.visible=true;
                                startTestCarmerText.text="开始测试";
                                deviceTestClass.startOrStopVideoTest(false);
                                camerImageView.visible=false;

                                deviceTestClass.startOrStopAudioTest(false);
                                soundTestView.visible=false;
                                timersRunTimes=0;
                                startTestButtonText.text="开始测试（10s）"
                                testAudioTimer.stop();;

                                noCarmerDeviceView.visible=false;
                                //获取摄像头列表
                                var allCarmerDeviceList= deviceTestClass.getUserDeviceList(1);
                                cameraComboBox.model=  allCarmerDeviceList;

                            }
                        }
                    }
                    Rectangle
                    {
                        width: 118 * widthRate
                        height: 33 * widthRate
                        border.width: 1
                        border.color: "#C2BEBE"
                        // anchors.horizontalCenter: parent.horizontalCenter
                        radius:5 * heightRate
                        visible: !startTestButton.visible
                        color:"#f4f4f4"
                        Text {
                            anchors.centerIn: parent
                            font.pixelSize: Cfg.DEVICE_BUTTON_FONTSIZE * widthRate
                            text: qsTr("听不到，重新检测")
                            color: "#333333"
                            font.family: Cfg.DEVICE_FAMILY

                        }
                        MouseArea
                        {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                            {
                                console.log("重新开始音频测试")
                                startTestButton.visible= true;
                                deviceTestClass.startOrStopAudioTest(false);
                                timersRunTimes=0;
                                startTestButtonText.text="开始测试（10s）"
                                testOne.color="#999999"
                                testThree.color="transparent"
                                testTwo.color="transparent"

                                volumeList.splice(0,volumeList.length);
                                currentVolumeIndex = 0 ;

                            }
                        }
                    }

                }

            }
            //检测说明
            Rectangle
            {
                width: parent.width - 85 * widthRate
                height: parent.width * 0.18
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: 55 * widthRate

                Column
                {
                    anchors.fill: parent
                    spacing: 13 * heightRate

                    Text {
                        font.pixelSize: Cfg.DEVICE_FONTSIZE * widthRate
                        font.family: Cfg.DEVICE_FAMILY
                        text: qsTr("1、检测时尽量靠近麦克风说话，点击右侧按钮可进行设备切换；")
                        color:"#999999"
                    }
                    Text {
                        font.pixelSize: Cfg.DEVICE_FONTSIZE * widthRate
                        font.family: Cfg.DEVICE_FAMILY
                        text: qsTr("2、如果上课需要使用耳机，在检测时请插入耳机；")
                        color:"#999999"
                    }
                    Text {
                        font.pixelSize: Cfg.DEVICE_FONTSIZE * widthRate
                        font.family: Cfg.DEVICE_FAMILY
                        text: qsTr("3、能听到自己的说话声音表示语音功能正常。")
                        color:"#999999"
                    }
                }
            }
        }
        //摄像头检测
        Rectangle {
            id:cameraTestView
            width: parent.width
            height: parent.height * 0.77
            color: "transparent"
            anchors.bottom:parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false

            YMComboBoxControl {
                id: cameraComboBox//播放器combobox
                height: 35 * heightRate
                width: 98 * widthRate
                anchors.right: parent.right
                anchors.rightMargin: 15 * widthRate
                anchors.top: parent.top
                anchors.topMargin: 15 * heightRate
                model: ["选择摄像设备"]
                clip: true
                onCurrentTextChanged: {
                    if(visible)
                    {
                        // deviceTestClass.setCarmerDevice(cameraComboBox.currentText);
                    }
                }
            }
            Column
            {
                anchors.fill: parent
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 25 * heightRate

                Text {
                    width:startTesCameraButton.visible ? 280 * widthRate : 160 * widthRate
                    height: 30 * widthRate
                    text: startTesCameraButton.visible ?  qsTr("请点击开始测试按钮，查看视频画面是否正常") : "请确认视频画面是否正常"
                    font.pixelSize: Cfg.DEVICE_FONTSIZE * widthRate
                    font.family: Cfg.DEVICE_FAMILY
                    verticalAlignment: Text.AlignBottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#333333"
                }

                Rectangle
                {
                    width: 230 * widthRate
                    height: 138 * widthRate
                    color: "#E9E9E9"
                    anchors.horizontalCenter: parent.horizontalCenter

                    Image {
                        id: camerImageView
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        source: ""
                        visible: false
                    }
                    AnimatedImage {
                        anchors.centerIn: parent
                        width: 69 * widthRate
                        height: 46 * widthRate
                        visible: !camerImageView.visible
                        source: "qrc:/images/shexiangtou@3x.png"

                    }
                    Image {
                        id: noCarmerDeviceView
                        anchors.centerIn: parent
                        width: 79 * widthRate
                        height: 40 * widthRate
                        visible: !camerImageView.visible
                        source: "qrc:/images/meiyou.png"
                    }
                }

                Row
                {
                    width:  startTesCameraButton.visible ? 118 * widthRate : 236 * widthRate
                    height: 33 * widthRate
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: startTesCameraButton.visible ? 0 : 30 * heightRate
                    //开始测试
                    Rectangle
                    {
                        id:startTesCameraButton
                        width: 118 * widthRate
                        height: 33 * widthRate
                        border.width: 1
                        border.color: "#C2BEBE"
                        color:"#f4f4f4"
                        // anchors.horizontalCenter: parent.horizontalCenter
                        radius:5 * heightRate
                        visible: true
                        Text {
                            id:startTestCarmerText
                            anchors.centerIn: parent
                            font.pixelSize: Cfg.DEVICE_BUTTON_FONTSIZE * widthRate
                            font.family: Cfg.DEVICE_FAMILY
                            text: qsTr("开始测试")
                            color: "#333333"

                        }
                        MouseArea
                        {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                            {
                                console.log("开始测试摄像头")
                                deviceTestClass.setCarmerDevice(cameraComboBox.currentText); //设置使用哪一个摄像头
                                deviceTestClass.startOrStopVideoTest(true);
                                startTestCarmerText.text="设备检测中..."
                                //startTesCameraButton.visible=false;
                            }
                        }
                    }
                    Rectangle
                    {
                        width: 118 * widthRate
                        height: 33 * widthRate
                        border.width: 1
                        border.color: "#C2BEBE"
                        // anchors.horizontalCenter: parent.horizontalCenter
                        radius:5 * heightRate
                        visible: !startTesCameraButton.visible
                        color:"#f4f4f4"
                        Text {
                            anchors.centerIn: parent
                            font.pixelSize: Cfg.DEVICE_BUTTON_FONTSIZE * widthRate
                            font.family: Cfg.DEVICE_FAMILY
                            text: qsTr("看到了，下一步")
                            color: "#333333"

                        }
                        MouseArea
                        {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                            {
                                console.log("看到了，下一步")
                                deviceTestClass.setCarmerDevice(cameraComboBox.currentText);
                                deviceTestClass.startOrStopVideoTest(false);
                                testOne.color="transparent"
                                testThree.color="#999999"
                                testTwo.color="transparent"
                                soundTestView.visible=false;
                                cameraTestView.visible=false;
                                netTestView.visible=true;

                                startTesNetButton.visible=true;
                                netTestTextItem.text="开始测试";

                            }
                        }
                    }
                    Rectangle
                    {
                        width: 118 * widthRate
                        height: 33 * widthRate
                        border.width: 1
                        border.color: "#C2BEBE"
                        // anchors.horizontalCenter: parent.horizontalCenter
                        radius:5 * heightRate
                        visible: !startTesCameraButton.visible
                        color:"#f4f4f4"
                        Text {
                            anchors.centerIn: parent
                            font.pixelSize: Cfg.DEVICE_BUTTON_FONTSIZE * widthRate
                            font.family: Cfg.DEVICE_FAMILY
                            text: qsTr("看不到，重新检测")
                            color: "#333333"

                        }
                        MouseArea
                        {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                            {
                                console.log("看不到，重新检测")
                                startTesCameraButton.visible=true;
                                startTestCarmerText.text="开始测试";
                                deviceTestClass.startOrStopVideoTest(false);
                                camerImageView.visible=false;
                                noCarmerDeviceView.visible=false;
                            }
                        }
                    }

                }

            }
            //检测说明
            Rectangle
            {
                width: parent.width - 85 * widthRate
                height: parent.width * 0.15
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: 55 * widthRate
                Column
                {
                    anchors.fill: parent
                    spacing: 13 * heightRate

                    Text {
                        font.pixelSize: Cfg.DEVICE_FONTSIZE * widthRate
                        font.family: Cfg.DEVICE_FAMILY
                        text: qsTr("如果您看不到自己的视频:")
                        color:"#999999"
                    }
                    Text {
                        font.pixelSize: Cfg.DEVICE_FONTSIZE * widthRate
                        font.family: Cfg.DEVICE_FAMILY
                        text: qsTr("1、请确认系统是否禁用了摄像头，点击右侧按钮可进行设备切换；")
                        color:"#999999"
                    }
                    Text {
                        font.pixelSize: Cfg.DEVICE_FONTSIZE * widthRate
                        font.family: Cfg.DEVICE_FAMILY
                        text: qsTr("2、请确认摄像头是否插入正确的插孔；")
                        color:"#999999"
                    }
                }
            }
        }

        //网络检测
        Rectangle {
            id:netTestView
            width: parent.width
            height: parent.height * 0.75
            color: "transparent"
            anchors.bottom:parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false
            Column {
                anchors.fill: parent
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 35 * heightRate

                Text {
                    width:startTesNetButton.visible ? 360 * widthRate : 160 * widthRate
                    height: 18 * widthRate
                    text: startTesNetButton.visible ?  qsTr("网络状况：") : ""
                    font.family: Cfg.DEVICE_FAMILY
                    font.pixelSize: 16 * widthRate
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#666666"

                }

                Rectangle {
                    width: 380 * widthRate
                    height: 160 * widthRate
                    color: "transparent"
                    anchors.horizontalCenter: parent.horizontalCenter

                    Column{
                        id: networkColumn
                        visible: false
                        anchors.fill: parent
                        spacing: 10 * heightRate

                        Text {
                            width: parent.width
                            font.family: Cfg.DEFAULT_FONT
                            font.pixelSize: 20 * heightRate
                            horizontalAlignment: Text.AlignHCenter
                            text: "当前网络：" + (interNetStatus == 3 ? "WIFI"  : "有线宽带")
                        }

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

                            YMInterControlView{
                                visible: interNetStatus == 3 ? (interNetGrade == 0 ? false : true) : false
                                wifiValue: routingPing.toString() + "ms"
                                colorGrade: routingGrade
                                networkTips: "路由器延迟"
                                networkStatus: {
                                    if(routingGrade == 3)
                                        return qsTr("当前网络状态很好");
                                    if(routingGrade == 2)
                                        return "当前网络状态一般";
                                    if(routingGrade == 1)
                                        return "当前网络状态较差";
                                    if(routingGrade == 0)
                                        return "当前无网络，请检查网络连接是否正常";
                                }
                            }

                            YMInterControlView{
                                visible: interNetStatus == 3 ?  (interNetGrade == 0 ? false : true) : false
                                wifiValue: wifiDevice.toString() + "台"
                                colorGrade: {
                                    if(wifiDevice <= 3)
                                        return 3;
                                    if(wifiDevice > 3 && wifiGrade > 2)
                                        return 1;
                                }
                                networkTips: "共享wifi设备"
                                networkStatus: {
                                    if(wifiDevice <= 3)
                                        return qsTr("当前设备数量合适");
                                    if(wifiDevice > 3 && wifiGrade > 2)
                                        return "当前设备连接较多，为保证上课质量建议关闭其它联网设备";
                                }

                            }
                        }
                    }
                }

                Text {
                    width:startTesNetButton.visible ? 250 * widthRate : 160 * widthRate
                    height: 15 * widthRate
                    text: startTesNetButton.visible ?  qsTr("请点击开始测试按钮，测试网络是否正常") : ""
                    font.pixelSize: Cfg.DEVICE_FONTSIZE * widthRate
                    font.family: Cfg.DEVICE_FAMILY
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#333333"
                }

                Row{
                    width:   85 * widthRate
                    height: 33 * widthRate
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: startTesNetButton.visible ? 0 : 30 * heightRate
                    //开始测试
                    Rectangle
                    {
                        id:startTesNetButton
                        width: 85 * widthRate
                        height: 33 * widthRate
                        border.width: 1
                        border.color: "#C2BEBE"
                        // anchors.horizontalCenter: parent.horizontalCenter
                        radius:5 * heightRate
                        visible: true
                        color:"#f4f4f4"
                        Text {
                            id:netTestTextItem
                            anchors.centerIn: parent
                            font.pixelSize: Cfg.DEVICE_BUTTON_FONTSIZE * widthRate
                            text: qsTr("开始测试")
                            font.family: Cfg.DEVICE_FAMILY
                            color: "#333333"
                        }
                        MouseArea
                        {
                            id: startButNet
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                            {
                                console.log("开始网络测试")
                                netTestTextItem.text="测试中.."
                                if(interNetStatus == 3){
                                    startButNet.enabled = false;
                                    pingMgr.getRoutingDeviceNumber();
                                    return;
                                }
                                deviceTestClass.startOrStopNetTest(true);
                            }
                        }
                    }
                    Rectangle
                    {
                        width: 85 * widthRate
                        height: 33 * widthRate
                        border.width: 1
                        border.color: "#C2BEBE"
                        // anchors.horizontalCenter: parent.horizontalCenter
                        radius:5 * heightRate
                        visible: !startTesNetButton.visible
                        color:"#f4f4f4"
                        Text {
                            anchors.centerIn: parent
                            font.pixelSize: Cfg.DEVICE_BUTTON_FONTSIZE * widthRate
                            font.family: Cfg.DEVICE_FAMILY
                            text: qsTr("完成测试")
                            color: "#333333"

                        }
                        MouseArea
                        {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                            {
                                console.log("完成测试")
                                deviceTestRectView.visible= false;
                                deviceView.visible = false;
                                deviceTestClass.releaseDevice();
                            }
                        }
                    }
                }

            }

        }
    }

    Connections{
        target: windowView
        onCheckInterNetSuccess:{
            startTesNetButton.visible = false;
            networkColumn.visible = true;
            startButNet.enabled = true;
            console.log("======onCheckInterNetSuccess=======");
        }
    }
}
