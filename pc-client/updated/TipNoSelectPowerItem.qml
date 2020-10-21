import QtQuick 2.0
//没有操作权限时的提示
    Rectangle
    {
        id: noSelectPower
        width: 400 * trailBoardBackground.ratesRates
        height: 40 * trailBoardBackground.ratesRates
        anchors.centerIn: parent
        radius: 5 * trailBoardBackground.heightRates
        color: "#3C3C3E"
        opacity: 0.6
        onVisibleChanged: {
            toopBracundTimer.stop();
            if(visible){
                toopBracundTimer.start();
            }
        }

        Timer {
            id:toopBracundTimer
            interval: 3000;
            running: false;
            repeat: false
            onTriggered: {
                noSelectPower.visible = false;
            }
        }
        Image {
            id: toopBracundImage
            anchors.top: parent.top
            anchors.left: parent.left
            width: 20 * trailBoardBackground.ratesRates
            height: 20 * trailBoardBackground.ratesRates
            anchors.leftMargin: 20 * trailBoardBackground.heightRates
            anchors.topMargin:   20 * trailBoardBackground.heightRates  - 10 * trailBoardBackground.ratesRates
            source: "qrc:/images/progessbar_logo.png"
        }
        Text {
            width: 350 * trailBoardBackground.ratesRates
            height: 20 * trailBoardBackground.ratesRates
            anchors.left: toopBracundImage.right
            anchors.top: toopBracundImage.top
            font.pixelSize: 14 * trailBoardBackground.ratesRates
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            color: "#ffffff"
            text: qsTr("没有操作权限，暂不能操作啦")
        }
    }

