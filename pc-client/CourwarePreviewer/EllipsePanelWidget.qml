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

    function setPolygonPanelType() {
        ellipsePanel.setInitWindowType();

    }
    //圆
    EllipsePanel {
        id:ellipsePanel
        width: parent.width
        height: parent.height
        onSigAmplificationFactor:{
            if(factors == 1) {
                sliders.value += 0.002

            }else {
                sliders.value -= 0.002

            }
        }
    }

    //确定按钮
    MouseArea{
        id:okBtn
        width: 30
        height: 30
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15 * heightRates
        anchors.leftMargin: parent.width / 2 + 30 /2
        Image {
            id: okBtnImage
            width: parent.width
            height: parent.height
            source: "qrc:/images/cr_btn_ok.png"
        }
        onPressed: {
            okBtnImage.source = "qrc:/images/cr_btn_ok_clicked.png";

        }
        onReleased: {
            okBtnImage.source = "qrc:/images/cr_btn_ok.png";
            sigOkItemPolygonPanelFrame(ellipsePanel.doneBtnClicked );

        }

    }

    //取消按钮
    MouseArea{
        id:cancelBtn
        width: 30
        height: 30
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15 * heightRates
        anchors.leftMargin: parent.width /2 - 30 * 3/2

        Image {
            id: cancelBtnImage
            width: parent.width
            height: parent.height
            source: "qrc:/images/cr_btn_close.png"
        }
        onPressed: {
            cancelBtnImage.source = "qrc:/images/cr_btn_close_clicked.png";

        }
        onReleased: {
            cancelBtnImage.source = "qrc:/images/cr_btn_close.png";
            sigClearItemPolygonPanelFrame();
        }

    }


    //放大的滚动条
    Slider{
        id:sliders
        width: 8 * widthRates
        height: 160 * heightRates
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin:  42 * widthRates
        anchors.bottomMargin: 15 * heightRates
        value: 0.001
        maximumValue: 0.21
        minimumValue:0.001
        stepSize: 0.002
        z:2

        orientation: Qt.Vertical
        style:SliderStyle{
            groove:Rectangle{
                implicitHeight: sliders.width;
                implicitWidth: sliders.width;
                color: "#e3e6e9";
                radius: sliders.width / 2;
            }
            handle: Rectangle{
                anchors.centerIn: parent;
                color: "#ff5000";
                radius: sliders.width / 2;
                width: sliders.width;
                height: sliders.width;

            }
        }

        onValueChanged: {
            ellipsePanel.setAmplificationFactor(parseInt( value * 1000));
        }

    }
    //标识符号+
    Text {
        id: slidersTop
        anchors.left: sliders.right
        anchors.top: sliders.top
        anchors.leftMargin:  5 * widthRates
        anchors.topMargin:  5 * heightRates
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
        anchors.leftMargin:  5 * widthRates
        anchors.bottomMargin:   5 * heightRates
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
    }

}

