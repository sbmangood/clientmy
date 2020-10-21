import QtQuick 2.2
import QtQuick.Controls 1.1
import QtWebView 1.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.2
import QtWebEngine 1.1

Item {
    id:cloudRoom
    anchors.fill: parent


    property bool isClickBack: false;

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
        }
        if(visible)
        {
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
            isClickBack = true;
            cloudRoom.visible = false;
            webView.url = "1";
            webView.update();
        }
    }

    WebEngineView {
        id: webView
        //        profile: WebEngineProfile.cachePath
        anchors.fill: parent
        //url: "https://global.talk-cloud.net/WebAPI/entry/domain/ymfd/serial/1590576288/username/%E6%B5%8B%E8%AF%95%E8%80%85/usertype/2/pid/57/ts/1536824019147/auth/f5f63d563e7ad8cc2381d315de4616f0"

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

        //打印javascript消息
        onJavaScriptConsoleMessage:
        {
            //            console.log("********message*************", message)
        }

        onLoadingChanged: {
            if(loadRequest.status == 2 && parent.visible) {
                visible = true;
            }

        }
    }

    function resetWebViewUrl(url){
        webView.url = url;
        webView.update();
    }

}
