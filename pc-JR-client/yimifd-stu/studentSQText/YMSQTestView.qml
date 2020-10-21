import QtQuick 2.0
import YMAccountManagerAdapter 1.0

MouseArea {
    hoverEnabled: true
    onWheel: {
        return
    }

    Rectangle{
        radius: 12 * widthRate
        anchors.fill: parent
    }
    YMAccountManagerAdapter{
        id:accountMgr
    }

    property bool hasFinisedSQTest: true;//是否已经完成测评 true 为已完成
    property bool hasPublishSQResult : true//是否已经发布测评报告 true 为已发布

    Image{
        id: img
        width: hasFinisedSQTest ? 200 * widthRate : 200 * heightRate
        height: hasFinisedSQTest ? 210 * heightRate :  210 * heightRate
        visible: !hasPublishSQResult
        source: hasFinisedSQTest ? "qrc:/images/pic_sussed@2x.png" : "qrc:/images/sorryceping.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        smooth: true
        anchors.leftMargin: (parent.width - width) * 0.5
    }

//    WebEngineView{
//        id:webview
//        visible: hasPublishSQResult
//        width: parent.width
//        height: parent.height - 20

//        anchors.centerIn: parent
//    }

    Row{
        anchors.top: img.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        Text{
            id: sqTestStatusText
            color: "#666666"
            font.pixelSize:  20 * heightRate
        }
        Text{
            id: lookText
            color: "blue"
            font.underline: true
            font.pixelSize:  20 * heightRate
            MouseArea{
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    //SQ学商
                    var sqId = accountMgr.getUserId();
                    var url = URL_SqReport + parseInt(sqId);
                    console.log(url);
                    Qt.openUrlExternally(url);
                }
            }
        }
        Text{
            id: msgText
            color: "#666666"
            font.pixelSize:  20 * heightRate
        }
    }

    function queryData(){
        var sqValue = accountMgr.getValuationResult();
        if(sqValue == 0 || sqValue ==1 || sqValue == 2){
            hasFinisedSQTest = false;
            hasPublishSQResult = false;
            sqTestStatusText.text = "";
            lookText.text = ""
            msgText.text = "";
            return
        }
        if(sqValue  == 3){
            hasFinisedSQTest = true;
            hasPublishSQResult = false;
            sqTestStatusText.text = "您已完成测试，请联系课程顾问咨询测评结果！"
            lookText.text = ""
            msgText.text = "";
            return;
        }
        if(sqValue == 4){
            hasFinisedSQTest = true;
            hasPublishSQResult = false;
            sqTestStatusText.text = "您的测试已完成,";
            lookText.text = "请点击查看"
            msgText.text = ",您的测评结果!";
//            var sqId = accountMgr.getUserId();
//            webview.url = URL_SqReport + parseInt(sqId);
//            webview.reload();
            return;
        }
    }

    function refreshPage(){
        //queryData();
    }
}

