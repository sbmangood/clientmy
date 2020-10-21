import QtQuick 2.7
import PolygonPanel 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

/*
 * 几何图形
 */

Item {
    id:bvackground
    width: parent.width
    height: parent.height

    signal sigClearItemPolygonPanelFrame();
    signal sigOkItemPolygonPanelFrame(string contents);
    signal sigPolygonHover(var isSelecte);

    function setPolygonPanelType (tppes,boardId,dockId,itemId,pageId) {
        console.log("===setPolygonPanelType===",tppes,boardId,dockId,itemId,pageId);
        polygonPanel.setInitWindowType(tppes,boardId,dockId,itemId,pageId,0.000977);
    }

    //几何图形
    PolygonPanel {
        id:polygonPanel
        width: parent.width
        height: parent.height
        onSigAmplificationFactor:{
            if(factors == 1) {
                sliders.value += 0.002
            }else {
                sliders.value -= 0.002
            }
        }
        onSigHover: {
            sigPolygonHover(selected);
        }
    }

    //确定按钮
    MouseArea{
        id:okBtn
        hoverEnabled: true
        width: 34 * heightRate
        height: 34 * heightRate
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80 * heightRate
        anchors.leftMargin: parent.width / 2 + 15
        Image{
            anchors.fill: parent
            source: parent.containsMouse ? "qrc:/geometricImage/btn_graph_right_pressed@2x.png" :"qrc:/geometricImage/btn_graph_right_focused@2x.png"
        }

        onReleased: {
            okBtn.visible = false;
            cancelBtn.visible = false;
            sliders.visible = false;
            slidersTop.visible = false;
            slidersBottom.visible = false;
            sigOkItemPolygonPanelFrame(polygonPanel.doneBtnClicked);
        }
    }

    //取消按钮
    MouseArea{
        id:cancelBtn
        width: 34 * heightRate
        height: 34 * heightRate
        hoverEnabled: true
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80 * heightRate
        anchors.leftMargin: parent.width / 2 - 45

        Image{
            anchors.fill: parent
            source: parent.containsMouse ? "qrc:/geometricImage/btn_graph_wrong_pressed@2x.png" : "qrc:/geometricImage/btn_graph_wrong_normal@2x.png"
        }

        onReleased: {
            sigClearItemPolygonPanelFrame();
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
        maximumValue: 0.21
        minimumValue:0.001
        stepSize: 0.002
        z:2

        orientation: Qt.Vertical
        style:SliderStyle{
            groove:Rectangle{
                implicitHeight: sliders.width;
                implicitWidth: sliders.width;
                color: "#393A49";
                radius: sliders.width / 2;
            }
            handle: Rectangle{
                color: "#39C5A8";
                radius: sliders.width / 2;
                width: sliders.width;
                height: sliders.width;

            }
        }

        onValueChanged: {
            polygonPanel.setAmplificationFactor(parseInt( value * 1000));
        }

    }
    //标识符号+
    Text {
        id: slidersTop
        anchors.left: sliders.right
        anchors.top: sliders.top
        anchors.leftMargin:  5 * widthRate
        anchors.topMargin:  5 * heightRate
        width: 10 * heightRate
        height: 10 * heightRate
        font.pixelSize: 10 * heightRate
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
        width: 10 * heightRate
        height: 10 * heightRate
        font.pixelSize: 10 * heightRate
        color: "#96999c"
        wrapMode:Text.WordWrap
        font.family: "Microsoft YaHei"
        text: qsTr("-")
    }

    Component.onCompleted: {
        sliders.value = 0.001;
    }
}

