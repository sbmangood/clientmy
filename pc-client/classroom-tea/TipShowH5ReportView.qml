import QtQuick 2.2
import QtQuick.Controls 1.1
import QtWebView 1.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.2
import QtWebEngine 1.4
import "Configuuration.js" as Cfg

Item {
    id:cloudRoom
    anchors.fill: parent
    property bool couldDirectExit: false;//是否可以直接退出 默认false
    property bool isClickBack: false;

    //关闭信号
    signal confirmClose();

    //试听课报告已生成 发送socket 通知其他人
    signal sigReportFinished();

    signal sigPushReportLoadingStatus(var status);

    onVisibleChanged:
    {
        if(!visible && isClickBack)
        {
            webView.visible = false;
            webView.profile.clearHttpCache();
        }
        if(visible)
        {
            isClickBack = false;
            webView.visible = true;
            webView.profile.clearHttpCache();
        }
    }
    function resetWebViewUrl(url)
    {
        webView.url = endLessonH5Url;
        webView.profile.clearHttpCache();
        webView.reload()
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
        anchors.topMargin: 5 * widthRates
        anchors.leftMargin: 5 * widthRates
        z:1001
        visible: false
        color: "transparent"
        //        Image {
        //            anchors.fill: parent
        //            source: "qrc:/images/red1.png"
        //        }

        Text {
            text: qsTr("×")
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 20 * heightRate
        }

        MouseArea
        {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked:
            {
                if(couldDirectExit)
                {
                    confirmClose();
                }
                isClickBack = true;
                cloudRoom.visible = false;
            }
        }

    }

    WebEngineView {
        id: webView
        //        profile: WebEngineProfile.cachePath
        anchors.fill: parent
        enabled: parent.visible
        activeFocusOnPress: false
        visible: false
        url:endLessonH5Url;

        Component.onCompleted://清除缓存
        {
            webView.profile.clearHttpCache();
        }

        onUrlChanged:
        {
            console.log("dsddddddddddddddddddddddd",url.toString())
            // url = "http://stage-h5.yimifudao.com/classAssignment?executionPlanId=229547260734607360&handleStatus=20&token=d6a4cbb5053c9239ccd6a7a5353e3c6f&className=第一课&title=第一课时啦啦啦啦"
        }

        onLoadingChanged:
        {
            if(loadRequest.status == 2 && parent.visible)
            {
                visible = true;
            }

            if(2 == loadRequest.status || 3 == loadRequest.status)
            {
                sigPushReportLoadingStatus(loadRequest.status);
            }

        }

        //右键的时候, 不弹出右键菜单
        onContextMenuRequested: function(request) {
            request.accepted = true;
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

        //打印javascript消息
        onJavaScriptConsoleMessage:
        {
            //{"moduleName":"YimiH5_Free_Trial","result":"close","messgae":""}
            // console.log("********message*************", message)
            if(message.indexOf("YimiH5_Free_Trial") != -1)
            {
                if(message.indexOf("result\":\"submit") != -1)
                {
                    hasExistListenReport =  true;
                    hasFinishListenReport = true;
                    isClickBack = true;
                    cloudRoom.visible = false;
                    sigReportFinished();
                    popupWidget.hideTimeWidget();
                    assessView.visible = false;
                    popupWidget.visible = false;
                }else if(message.indexOf("result\":\"close") != -1)
                {
                    isClickBack = true;
                    cloudRoom.visible = false;
                    tipDropClassroom.visible = true;
                    popupWidget.hideTimeWidget();
                    assessView.visible = false;
                    popupWidget.visible = false;
                }

            }

        }
    }
}
