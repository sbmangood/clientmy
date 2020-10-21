import QtQuick 2.0
import QtWebEngine 1.4
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0
import QtQuick.Window 2.0
import QtWebChannel 1.0

Item {
    id: h5EngineView
    anchors.fill: parent

    property int gotoPageIndex: 0;
    property int pageStep: 0;
    property bool loadingStatus: false;
    property var jsonObject: [];

    signal sigAnimationNotification(var animationIndex);

    QtObject {
        id: webEngineObject
        WebChannel.id: "yimiNative"

        // 动画步骤
        function animationNotification(step){
            sigAnimationNotification(step);
            //stepClick(step);
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

        onUrlChanged: {
            console.log("====onUrlChanged=====",url);
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
            
        }

        onLoadingChanged: {
            //console.log("===onLoadingChanged=====",loading);
        }
        onJavaScriptConsoleMessage:
        {
            if(message.indexOf("webLoadFinshed") > -1){
                setPlanInfo(jsonObject);
            }
        }

        Component.onCompleted: {
            webEngineView.profile.clearHttpCache();
            reloadPage();
            console.log("===cachePath===", webEngineView.profile.cachePath);
        }
    }

    //    WebSocket {
    //        id: webSocket
    //        url: webEngineView.url
    //    }

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

    // 停止加载
    function stopLoadPage(){
        webEngineView.stop();
    }

    // 设置h5课件url
    function setBeShowedH5CourseWareUrl(urls, token){
        webEngineView.url = urls + "&token=" + token;
        webEngineView.visible = true;
    }

    // 设置WebEngine的可见性
    function setWebEngineViewVisible(visibles){
        webEngineView.visible = visibles;
    }

    // 清除h5课件url
    function removeWebEngineViewUrl(){
        webEngineView.url = "";
    }

    // 运行JavaScript接口
    function runJavaScriptInterface(queryStr){
        webEngineView.runJavaScript(queryStr);
        console.log("===runJavaScriptInterface===",queryStr,webEngineView.url)
    }

    // 刷新页面
    function reloadPage(){
        webEngineView.reload();
    }

    // 上一页
    function goBackPage(){
        var prePageStr = "window.yimiNative.appPrevPage()";
        runJavaScriptInterface(prePageStr);
    }

    // 下一页
    function goNextPage(){
        var nextPageStr = "window.yimiNative.appNextPage()";
        runJavaScriptInterface(nextPageStr);
    }

    // 增加页
    function addPage(){
        var addStr = "window.yimiNative.appNewPage()";
        runJavaScriptInterface(addStr);
    }

    // 删除页
    function deletePage(){
        var delStr = "window.yimiNative.appDelPage()";
        runJavaScriptInterface(delStr);
    }

    // 跳转页
    function goNewPage(page){
        gotoPageIndex = page;
        var goStr = "window.yimiNative.appGoToPage(" + page.toString() + ")";
        runJavaScriptInterface(goStr);
    }

    /***********************************************************************************************
    * 功能：鼠标点击事件通知web端播放动画
    * 参数：step 动画播放步骤
    * 说明：如果H5判断当前动画的步骤小于播放的动画，需要把之前的动画全部播放完毕直到和传递step相等
    *       如果传递的step小于当前的动画，需要回退到目前的动画步骤，不传step调用方法默认当前页step+1
    ***********************************************************************************************/
    function stepClick(step){
        if(step == undefined){
            return;
        }
        var stepClickStr;
        pageStep = step;
        stepClickStr = "window.yimiNative.appStepClick(" + step.toString() + ")";
        runJavaScriptInterface(stepClickStr);
    }

    function setPlanInfodata(jsonObj){
        jsonObject =jsonObj;
    }

    // H5课件加载同步信息设置
    function setPlanInfo(json){
        var jsonStr = "window.yimiNative.appSetPlanInfo(" + JSON.stringify(json)+ ")";
        runJavaScriptInterface(jsonStr);
    }
}
