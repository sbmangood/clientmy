import QtQuick 2.2
import QtQuick.Controls 1.1
import QtWebView 1.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.2
import QtWebEngine 1.4
import QtQuick.Window 2.0

Item {
    id:cloudRoom
    anchors.fill: parent
    property bool isClickBack: false;
    signal sigReBack();

    onVisibleChanged:
    {
        if(!visible && isClickBack)
        {
            webView.visible = false;
        }
        if(visible)
        {
            isClickBack = false;
        }
    }
    function resetWebViewUrl(url)
    {
        webView.url = url;
        webView.update();
    }
    MouseArea{
        anchors.fill: parent
        onClicked:
        {
            return;
        }
    }
    Rectangle
    {
        width: 20 * heightRate//parent.width * 0.024
        height: 20 * heightRate//width
        anchors.top: parent.top
        anchors.left: parent.left
        z:1001
        color: "transparent"
        Image {
            anchors.fill: parent
            source: "qrc:/miniClassImg/tky_btn_back@2x.png"
        }
        MouseArea
        {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked:
            {
                console.log("=======sigReBack========")
                sigReBack();
            }
        }

    }

    WebEngineView {
        id: webView
        //        profile: WebEngineProfile.cachePath
        anchors.fill: parent
        enabled: parent.visible
        activeFocusOnPress: true
        visible: false
        //url: "https://global.talk-cloud.net/WebAPI/entry/domain/ymfd/serial/1590576288/username/%E6%B5%8B%E8%AF%95%E8%80%85/usertype/2/pid/57/ts/1536824019147/auth/f5f63d563e7ad8cc2381d315de4616f0"
        onLoadingChanged:
        {
            if(loadRequest.status == 3){
                visible = false;
            }

            if(loadRequest.status == 2&& parent.visible)
            {
                visible = true;
            }

        }
        //系统请求权限的事件, 从这个事件传来参数: securityOrigin, feature
        //函数的申明: featurePermissionRequested(url securityOrigin, Feature feature)
        onFeaturePermissionRequested:
        {
            //            webView.grantFeaturePermission(securityOrigin, WebEngineView.Geolocation, true);
            //if(feature == WebEngineView.MediaVideoCapture || feature == WebEngineView.MediaAudioCapture || feature == WebEngineView.MediaAudioVideoCapture)
            {
                //需要以上权限的时候, 使用下面的函数, 给它
                webView.grantFeaturePermission(securityOrigin, feature, true);
                console.log("grantFeaturePermission ",securityOrigin);
            }
        }

        onFullScreenRequested:
        {
            console.log("********message***222**********", request, webView.isFullScreen, request.toggleOn)

            if (request.toggleOn)
            {
//                console.log("********message***333**********", windowView.FullScreen, windowView.visibility, Window.Maximized, Window.Windowed)
                if (windowView.visibility === Window.Windowed){
                    windowView.showFullScreen();
                    windowView.visibility = Window.Maximized;
                    console.log("********message***555**********", windowView.FullScreen, windowView.visibility, Window.Maximized, Window.Windowed)
                }
            }

            request.accept()

            console.log("********message***333**********", request, webView.isFullScreen, request.toggleOn)
        }

        //打印javascript消息
        onJavaScriptConsoleMessage:
        {
            //            console.log("********message*************", message)
        }
    }

    function reBack(){
        isClickBack = true;
        cloudRoom.visible = false;
        webView.url = "1";
        webView.update();
    }
}
