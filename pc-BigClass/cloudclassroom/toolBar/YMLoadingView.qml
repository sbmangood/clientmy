import QtQuick 2.0
import "./Configuration.js" as Cfg

Item {
    id: loadingItem
    property string tips: "课件加载中";
    property bool isLoading: true;

    signal sigRefresh();

    Rectangle{
        width: 182 * heightRate
        height: 140 * heightRate
        radius: 8 * heightRate
        opacity: 0.69
        color: "#000000"
        anchors.centerIn: parent

        MouseArea{
            width: 64 * heightRate
            height: 64 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 18 * heightRate
            cursorShape: Qt.PointingHandCursor
            enabled: !isLoading

            Image{
                id:lodingImg
                anchors.fill: parent
                source: isLoading ? "qrc:/bigclassImage/icon_ymroom_waitting@2x.png" :  "qrc:/bigclassImage/icon_ymroom_reloading@2x.png"
            }

            onClicked: {
                loadingItem.visible = false;
                sigRefresh();
            }
        }

        Text{
            font.pixelSize: 18 * heightRate
            font.family: Cfg.DEFAULT_FONT
            color: "#ffffff"
            text: tips
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 18 * heightRate
        }
    }

    NumberAnimation {//旋转动画
        id: rateAnimation
        target: lodingImg
        property: "rotation"
        duration: 1600
        to: 360
        from: 0
        loops: Animation.Infinite
    }

    function loadingCoursewa(){
        tips ="课件加载中";
        isLoading = true;
        rateAnimation.start();
        loadingItem.visible = true;
    }

    function loadingFaill(){
        isLoading = false;
        tips ="重新加载";
        rateAnimation.stop();
        loadingItem.visible = true;
    }

    function hideView(){
        loadingItem.visible = false;
        rateAnimation.stop();
    }

}
