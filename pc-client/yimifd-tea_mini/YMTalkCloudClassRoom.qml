import QtQuick 2.2
import QtWebView 1.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.2
import QtWebEngine 1.4
import QtQuick.Window 2.0
import QtQuick.Controls 1.4

Item {
    id:cloudRoom
    width: parent.width
    height: parent.height

    property bool isClickBack: false;
    signal sigReback();//返回信号

    MouseArea{
        anchors.fill: parent
        onClicked:
        {
            return;
        }
    }

    onVisibleChanged:{
        if(!visible && isClickBack)
        {
            webView.visible = false;
            return;
        }
        if(visible && isClickBack){
            webView.visible = false;
        }
        if(visible){
            isClickBack = false;
        }

    }

    MouseArea{
        cursorShape: Qt.PointingHandCursor
        width: 20 * heightRate
        height: 20 * heightRate
        z:1001

        Image {
            anchors.fill: parent
            source: "qrc:/talkcloudImage/tky_btn_back@2x.png"
        }

        onClicked: {
            sigReback();

//            isClickBack = true;
//            cloudRoom.visible = false;
//            webView.url = "1";
//            webView.update();
        }
    }

    WebEngineView {
        id: webView
        //        profile: WebEngineProfile.cachePath
        anchors.fill: parent
        //url: "https://global.talk-cloud.net/WebAPI/entry/domain/ymfd/serial/1590576288/username/%E6%B5%8B%E8%AF%95%E8%80%85/usertype/2/pid/57/ts/1536824019147/auth/f5f63d563e7ad8cc2381d315de4616f0"
        activeFocusOnPress: false
        visible: true
        z: 999
        onFullScreenRequested:
        {
//            console.log("********message***222**********", request, webView.isFullScreen, request.toggleOn)

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
//            console.log("********message***333**********", request, webView.isFullScreen, request.toggleOn)
        }

        //系统请求权限的事件, 从这个事件传来参数: securityOrigin, feature
        //函数的申明: featurePermissionRequested(url securityOrigin, Feature feature)
        onFeaturePermissionRequested:
        {
            //            webView.grantFeaturePermission(securityOrigin, WebEngineView.Geolocation, true);
            //if(feature == WebEngineView.MediaVideoCapture || feature == WebEngineView.MediaAudioCapture || feature == WebEngineView.MediaAudioVideoCapture)
            //{
            //需要以上权限的时候, 使用下面的函数, 给它
            webView.grantFeaturePermission(securityOrigin, feature, true);
            console.log("grantFeaturePermission ",securityOrigin);
            //}
        }

        //打印javascript消息
        onJavaScriptConsoleMessage:
        {
            //            console.log("********message*************", message)
        }

        onLoadingChanged: {
            if(loadRequest.status == 2 && parent.visible) {
                visible = true;
                webView.settings.pluginsEnabled = true;
            }

        }
    }

    function reBack(){
        isClickBack = true;
        cloudRoom.visible = false;
        webView.url = "1";
        webView.update();
    }

    function resetWebViewUrl(url){
        if(url == "1"){
            isClickBack = true;
        }
        webView.url = url;
        webView.update();
    }

}
