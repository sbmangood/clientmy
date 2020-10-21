import QtQuick 2.7
import EllipsePanel 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

/*
 * 圆
 */

Item {
    id:bvackground
    width: parent.width
    height: parent.height

    property double widthRates: bvackground.width / 1118.0
    property double heightRates: bvackground.height / 698.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    signal sigClearItemPolygonPanelFrame();
    signal sigOkItemPolygonPanelFrame(string contents);

    function setPolygonPanelType(boardId,dockId,itemId,pageId) {
        ellipsePanel.setInitWindowType(boardId,dockId,itemId,pageId,"0.000977");
    }
    //圆
    EllipsePanel {
        id:ellipsePanel
        width: parent.width
        height: parent.height
        onSigAmplificationFactor:{
            if(factors == 1) {
                sliders.value += 0.002;
            }else {
                sliders.value -= 0.002;
            }
        }
    }

    //确定按钮
    MouseArea{
        id:okBtn
        width: 34 * heightRate
        height: 34 * heightRate
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80 * heightRate
        anchors.leftMargin: parent.width / 2 + 30 /2
        hoverEnabled: true

        Image{
            anchors.fill: parent
            source: parent.containsMouse ? "qrc:/geometricImage/btn_graph_right_pressed@2x.png" :"qrc:/geometricImage/btn_graph_right_focused@2x.png"
        }

        onReleased: {
            cancelBtn.visible = false;
            sliders.visible = false;
            slidersTop.visible = false;
            slidersBottom.visible = false;
            okBtn.visible = false;
            sigOkItemPolygonPanelFrame(ellipsePanel.doneBtnClicked );
        }
    }

    //取消按钮
    MouseArea{
        id:cancelBtn
        width: 34 * heightRate
        height: 34 * heightRate
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80 * heightRate
        anchors.leftMargin: parent.width /2 - 30 * 3/2
        hoverEnabled: true

        Image{
            anchors.fill: parent
            source: parent.containsMouse ? "qrc:/geometricImage/btn_graph_wrong_pressed@2x.png" : "qrc:/geometricImage/btn_graph_wrong_normal@2x.png"
        }

        onReleased: {
            sigClearItemPolygonPanelFrame();
            //mainView.doEnableDisableControls(true); //enable 部分控件
        }

    }

    //放大的滚动条
    Slider{
        id:sliders
        width: 8 * widthRate
        height: 160 * heightRate
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin:  42 * widthRate
        anchors.bottomMargin: 30 * heightRate
        value: 0.001
        maximumValue: 0.17
        minimumValue:0.001
        stepSize: 0.002
        z:2

        orientation: Qt.Vertical
        style:SliderStyle{
            groove:Rectangle{
                implicitHeight: sliders.width;
                implicitWidth: sliders.width;
                color: "#393A49";
                radius: 100
            }
            handle: Rectangle{
                color: "#39C5A8";
                radius: 100
                width: sliders.width;
                height: sliders.width;
            }
        }

        onValueChanged: {
            console.log("====onValueChanged====",value)
            ellipsePanel.setAmplificationFactor(parseInt( value * 1000));
        }

    }
    //标识符号+
    Text {
        id: slidersTop
        anchors.left: sliders.right
        anchors.top: sliders.top
        anchors.leftMargin:  5 * widthRate
        anchors.topMargin:  5 * heightRate
        width: 10 * ratesRates
        height: 10 * ratesRates
        font.pixelSize: 10 * ratesRates
        color: "#96999c"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        text: qsTr("+")
    }
    //标识符号-
    Text {
        id: slidersBottom
        anchors.left: sliders.right
        anchors.bottom:  sliders.bottom
        anchors.leftMargin:  5 * widthRate
        anchors.bottomMargin:   5 * heightRate
        width: 10 * ratesRates
        height: 10 * ratesRates
        font.pixelSize: 10 * ratesRates
        color: "#96999c"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        text: qsTr("-")
    }

    Component.onCompleted: {
        sliders.value = 0.001;
        //mainView.doEnableDisableControls(false); //disable 部分控件
        //console.log("********Component.onCompleted121*************" )
    }

}

