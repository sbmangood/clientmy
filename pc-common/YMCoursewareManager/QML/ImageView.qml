import QtQuick 2.7
import QtQuick.Controls 2.0


Rectangle {
    property double widthRates: fullWidths / 1440.0
    property double heightRates: fullHeights / 900.0
    property double trailBoardBackgroundWidth: midWidth
    property double trailBoardBackgroundHeight: midWidth * 10 / 16

    property double ratesRates: widthRates > heightRates? heightRates : widthRates
    property bool isLoading: false;

    signal sigImageLoadReady();// 图像加载状态未ready
    signal sigChangeScoreBarVisible(var visibles);// 设置滚动条的显示状态
    signal sigUploadLoadingImgFailLog(var tempString);// 课件加载失败信号

    Timer {
        id: loadingTimer
        interval: 10000
        repeat: false
        onTriggered: {
            imageSourceChageRectangle.visible= false;
        }
    }

    //背景图片显示
    Image {
        id: bmgImages
        width: parent.width
        height: parent.height
        smooth: true
        mipmap: true
        clip: true
        onVisibleChanged: {

        }

        onProgressChanged: {
            if(source == ""){
                return;
            }

            imageSourceChageRectangle.visible = true;
            loadingTimer.restart();
            if(bmgImages.progress < 1) {
                parent.isLoading = true;
            }
            else {
                loadingTimer.stop();
                imageSourceChageRectangle.visible= false;
                if(progress == 1 && parent.isLoading){
                    parent.isLoading = false;
                }
            }
        }

        onStatusChanged: {
            if(status == Image.Error) {
                var tempString = "{\"domain\":\"system\",\"command\":\"statistics\",\"content\":{\"type\":\"exception\",\"coursewareException\":{ \"url\":\"";
                if(tempString.indexOf(".jpg") == -1 && tempString.indexOf(".png") == -1)
                {
                    tempString +=  bmgImages.source + "\",\"error\":\"Image Loading Error\",\"status\": \"" +status+"\"}}}";
                }
                else {
                    tempString += bmgImages.source + "\",\"error\":\"Image Path Cannot Open\",\"status\": \"" +status+"\"}}}";
                }
                imageSourceChageRectangle.visible= false;
                sigUploadLoadingImgFailLog(tempString); // 课件资源加载失败 发信号传到服务端
            }
            else if(status == Image.Ready){
                imageSourceChageRectangle.visible= false;
                sigImageLoadReady(); // 图像加载状态未ready
            }
            if(source == "") {
                sigChangeScoreBarVisible(false);
                bmgImages.width = trailBoardBackgroundWidth ;
                bmgImages.height = trailBoardBackgroundHeight;
                return;
            }
            if(bmgImages.sourceSize.height < trailBoardBackgroundHeight) {
                bmgImages.width = bmgImages.sourceSize.width;
                bmgImages.height = bmgImages.sourceSize.height;
                sigChangeScoreBarVisible(false);// 设置滚动条的显示状态为不显示
                return;
            }
            bmgImages.width = trailBoardBackgroundWidth;
            bmgImages.height = bmgImages.sourceSize.height;
            sigChangeScoreBarVisible(true);// 设置滚动条的显示状态为显示
        }
    }

    //加载、上传图片等待动画
    AnimatedImage {
        id: imageSourceChageRectangle
        width: 35 * ratesRates
        height: 35 * ratesRates
        source: "qrc:/images/loading.gif"
        anchors.centerIn: parent
        z: 500
        visible: false
    }

    function setBeShowImgUrl(urls,widths,heights)
    {
        bmgImages.source = "";
        bmgImages.width = widths;
        bmgImages.height = heights;
        bmgImages.source = urls;
        bmgImages.visible = true;
    }

    function setImgViewWidthHeght(width,height)
    {

    }

    function setImgViewVisible(visibles)
    {
        bmgImages.visible = visibles;
        bmgImages.parent.visible = true;
    }

    function removeImgViewUrl()
    {
        bmgImages.source = "";
    }
}
