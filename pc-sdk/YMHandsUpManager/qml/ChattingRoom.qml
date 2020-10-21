import QtQuick 2.0
import QtWebEngine 1.4
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0
import QtQuick.Window 2.0
import QtWebChannel 1.0
import QtQuick.Layouts 1.0

Rectangle {
    id: chatting

    width: parent.width
    height: parent.height

    signal sigWebLoadFinished();// 聊天室加载完成通知信号, 收到此信号后设置聊天室传初始化所需信息

    QtObject {
        id: webEngineObject
        WebChannel.id: "yimiNative"

        // H5通知客户端接口
        function webLoadFinished(){
            console.log("=====webLoadFinished=====")
            sigWebLoadFinished();
        }
    }

    WebChannel {
        id: webEngineChannel
        registeredObjects: [webEngineObject]
    }

    WebEngineView {
        id: webEngineView
        anchors.fill: parent
        webChannel: webEngineChannel
        settings.pluginsEnabled: true
        settings.autoLoadImages: true
        settings.javascriptEnabled: true
        settings.errorPageEnabled: true
        settings.fullScreenSupportEnabled: true
        settings.autoLoadIconsForPage: true
        settings.touchIconsEnabled: true
        settings.screenCaptureEnabled: true
        settings.spatialNavigationEnabled: true
        settings.focusOnNavigationEnabled: true
        KeyNavigation.priority: KeyNavigation.BeforeItem

        onUrlChanged: {

        }
        onFeaturePermissionRequested:
        {
            webEngineView.grantFeaturePermission(securityOrigin, feature, true);
        }
        onNewViewRequested: {
            request.openIn(webEngineView);
        }
        onContextMenuRequested: function(request) {
            request.accepted = true;
        }
        onContentsSizeChanged: {
            console.log("=====onContentsSizeChanged=====")

        }
        onLoadingChanged: {
            console.log("=========onLoadingChanged============")

        }

        onJavaScriptConsoleMessage:
        {
            if(message.indexOf("webLoadFinshed") > -1){

            }
        }

        Component.onCompleted: {
            webEngineView.profile.clearHttpCache();
            console.log("=========webEngineView.profile.cachePath====",webEngineView.profile.cachePath)
            reloadPage();
        }
    }

    // 加载进度条
    ProgressBar {
        id: progressBar
        height: 5
        width: parent.width
        style: ProgressBarStyle {
            background: Item {}
        }
        minimumValue: 0
        maximumValue: 100
        value: (webEngineView && webEngineView.loadProgress < 100) ? webEngineView.loadProgress : 0
    }

    // 运行JavaScript接口
    function runJavaScriptInterface(queryStr){
        webEngineView.runJavaScript(queryStr);
    }

    // 刷新页面
    function reloadPage(){
        webEngineView.reload();
    }

    // 停止加载
    function stopLoadPage(){
        webEngineView.stop();
    }

    // 设置聊天室Url
    function setChattingRoomUrl(urls, token){
        if(!urls.endsWith("/")){
            urls += "/";
        }
        webEngineView.url = urls + "?token=" + token;
        webEngineView.visible = true;
        console.log("==== setChattingRoomUrl ==", webEngineView.url);
    }

    // 设置聊天室的可见性
    function setChattingRoomVisible(visibles){
        webEngineView.visible = visibles;
    }

    // 清除聊天室url
    function removeChattingRoomUrl(){
        webEngineView.url = "";
    }

    // 客户端H5聊天室初始化
    // identifierNick: '登录者昵称', //聊天显示的发言昵称
    // headurl: "http://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTJh6NN0AEmiajjbI9B9vH1gjiaSz5ZhyK53cTamycfYOe8LTg8piacj2WSjBsEnSicjDS0bDJ9rNfpdsw/132", //头像
    // userId: '用户id', //用于给中台获取身份标示usersign
    // role: '用户身份',  //"stu"(学生)、"tea"(老师)、"assistant"(助教)
    // myClass: '班级号', //用于分组，老师传个‘all’
    // chatRoomId: '聊天室Id',  //格式类似 @TGS#3AECYHAGS
    function pcSetInfo(identifierNick, headurl, userId, role, myClass, chatRoomId){
        var initParams = {};
        initParams["identifierNick"] = identifierNick;
        initParams["headurl"] = headurl;
        initParams["userId"] = userId;
        initParams["role"] = role;
        initParams["myClass"] = myClass;
        initParams["chatRoomId"] = chatRoomId;
        var initStr ="window.yimiNative.pcSetInfo(" + JSON.stringify(initParams) + ")";

        console.log("=====pcSetInfo(initjson)====", initStr);

        runJavaScriptInterface(initStr);
    }

    // 客户端通知H5有人进入聊天室
    function pcSetOnline(identifierNick, headurl, userId, role){
        var onlineStr = "window.yimiNative.pcSetOnline(" +
                "{\"identifierNick\":" + "\"" + identifierNick + "\"" +
                ",\"headurl\":" + "\"" + headurl + "\"" +
                ",\"userId\":" + "\""+ userId + "\"" +
                ",\"role\":" + "\"" +  role + "\"" +
                "})" ;
        runJavaScriptInterface(onlineStr);
    }

    // 客户端通知H5有人离开聊天室
    function pcSetOffline(identifierNick, headurl, userId, role){
        var offlineStr = "window.yimiNative.pcSetOffline(" +
                "{\"identifierNick\":" + "\"" + identifierNick + "\"" +
                ",\"headurl\":" + "\"" + headurl + "\"" +
                ",\"userId\":" + "\""+ userId + "\"" +
                ",\"role\":" + "\"" +  role + "\"" +
                "})" ;
        runJavaScriptInterface(offlineStr);
    }

    // 客户端通知H5禁言
    function pcBanTalk(identifierNick, headurl, userId, role, type){
        var banTalkStr = "window.yimiNative.pcBanTalk(" +
                "{\"identifierNick\":" + "\"" + identifierNick + "\"" +
                ",\"headurl\":" + "\"" + headurl + "\"" +
                ",\"userId\":" + "\""+ userId + "\"" +
                ",\"role\":" + "\"" +  role + "\"" +
                ",\"type\":" + "\"" +  type + "\"" +
                "})" ;
        runJavaScriptInterface(banTalkStr);
    }

    // 客户端通知H5解禁言
    function pcAllowTalk(identifierNick, headurl, userId, role, type){
        var allowTalkStr = "window.yimiNative.pcAllowTalk(" +
                "{\"identifierNick\":" + "\"" + identifierNick + "\"" +
                ",\"headurl\":" + "\"" + headurl + "\"" +
                ",\"userId\":" + "\""+ userId + "\"" +
                ",\"role\":" + "\"" +  role + "\"" +
                ",\"type\":" + "\"" +  type + "\"" +
                "})" ;
        runJavaScriptInterface(allowTalkStr);
    }
}
