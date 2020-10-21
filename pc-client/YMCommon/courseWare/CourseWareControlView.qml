import QtQuick 2.7
import QtQuick.Controls 2.0
//课件显示层控制中心  图片课件 结构化课件 h5课件
Rectangle {
    id:courseControl
    color: "#ffffff"

    property int currentBeshowViewType: 1;//当前被显示的界面类型 1空白界面 2图片课件界面 3 结构化课件 4 h5课件
    signal sigImageLoadReadys();//图像加载状态未ready
    signal sigChangeScoreBarVisibles(var visibles);//设置滚动条的显示状态
    //图片课件界面
    ImageView
    {
        id:imageView
        anchors.fill: parent
        onSigImageLoadReady:
        {
            sigImageLoadReadys();
        }
        onSigChangeScoreBarVisible:
        {
            sigChangeScoreBarVisibles(visibles);
        }

    }


    //显示图片课件
    function setBeShowedImg(imgUrl,widths,heights)
    {
        currentBeshowViewType = 2;
        imageView.setBeShowImgUrl(imgUrl,widths,heights);
    }

    function setImgViewVisible(visbles)
    {
        if(visbles)
        {
            courseControl.visible = visbles;
        }
        console.log("setImgViewVisible",visbles);
        imageView.setImgViewVisible(visbles);
    }

    function removeImgViewUrl()
    {
        imageView.removeImgViewUrl();
    }

    //显示h5课件
    function setBeShowedH5Url(h5Url)
    {
        currentBeshowViewType = 3;
    }

    //显示结构化课件  //需要区分用户类型 对练习模式 和 预览模式做限制
    function setBeShowedQuestionData(questinData)
    {
        currentBeshowViewType = 4;
    }
}
