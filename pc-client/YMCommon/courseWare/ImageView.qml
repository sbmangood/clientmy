import QtQuick 2.7
import QtQuick.Controls 2.0


Rectangle {
    width: 100
    height: 100
    color: "#ffffff"
    property double widthRates: fullWidths / 1440.0
    property double heightRates: fullHeights / 900.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates
    property bool isLoading: false;

    signal sigImageLoadReady();//图像加载状态未ready
    signal sigChangeScoreBarVisible(var visibles);//设置滚动条的显示状态

    //for test
    Rectangle
    {
        z:20
        width: 30
        height: 30
        color: "red"
        visible: false
    }

    Timer{
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
        z: 10
        onVisibleChanged:
        {
            console.log("id: bmgImages onVisibleChanged" ,visible)
        }

        onProgressChanged: {
            if(source == ""){
                return;
            }

            imageSourceChageRectangle.visible = true;
            loadingTimer.restart();
            if(bmgImages.progress < 1) {
                parent.isLoading = true;
            }else {
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
                }else {
                    tempString += bmgImages.source + "\",\"error\":\"Image Path Cannot Open\",\"status\": \"" +status+"\"}}}";
                }
                //console.log("status == Image.Error",tempString)
                imageSourceChageRectangle.visible= false;
                showMessageTips("加载失败,请重新操作...");
            }
            if(status == Image.Ready){
                imageSourceChageRectangle.visible= false;
            }

            if(status == Image.Ready ){
                sigImageLoadReady();
            }

            //                console.log("*******current::pland:height********",currentImageHeight,trailBoardBackground.height,loadImgWidth,loadImgHeight,bmgImages.sourceSize);

            if(source == ""){
                sigChangeScoreBarVisible(false);
                bmgImages.width = trailBoardBackground.width ;
                bmgImages.height = trailBoardBackground.height;
                return;
            }

            if(bmgImages.sourceSize.height < trailBoardBackground.height){
                bmgImages.width =  bmgImages.sourceSize.width;
                bmgImages.height =  bmgImages.sourceSize.height;
                sigChangeScoreBarVisible(false);
                return;
            }

            bmgImages.width = trailBoardBackground.width;
            bmgImages.height = bmgImages.sourceSize.height;
            sigChangeScoreBarVisible(true);

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
