import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "../../Configuration.js" as Cfg

Item {
    width: parent.width
    height: Cfg.BOTTOM_HEIGHT * widthRate
    property int totalPage: 1;
    property int currentPage: 1;

    signal pageChanged(var page);
    signal nextPage();
    signal pervPage();


    Row{
        width: 200 * widthRate
        height: parent.height
        anchors.centerIn: parent
        spacing: 5 * widthRate

        MouseArea{
            width: parent.height * 0.5
            height: parent.height
            cursorShape: Qt.PointingHandCursor
            anchors.verticalCenter: parent.verticalCenter

            Image{
                width: 18 * heightRate
                height: 18 * heightRate
                anchors.centerIn: parent
                source: "qrc:/images/cr_btn_lastpage.png"
                fillMode: Image.PreserveAspectFit
            }
            onClicked: {
                if(currentPage - 1 >= 1){
                    pervPage();
                }
            }
        }

        Text{
            id:totalpageLabel
            //width: 40 * widthRate
            text: totalPage == 0 ? "0/0" : currentPage + "/" + totalPage
            font.family: Cfg.PAGE_FAMILY
            font.pixelSize: Cfg.PAGE_FONTSIZE * heightRate
            color: "#666666"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        MouseArea{
            width: parent.height * 0.5
            height: parent.height * 0.5
            cursorShape: Qt.PointingHandCursor
            anchors.verticalCenter: parent.verticalCenter


            Image{
                width: 18 * heightRate
                height: 18 * heightRate
                source: "qrc:/images/cr_btn_nextpage.png"
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
            }
            onClicked: {
                if(currentPage + 1 <= totalPage){
                    nextPage();
                }
            }
        }

        Label{
            text: "到第"
            font.family: Cfg.PAGE_FAMILY
            font.pixelSize: Cfg.PAGE_FONTSIZE * heightRate
            anchors.verticalCenter: parent.verticalCenter
        }

        TextField{
            id: inputTextField
            width: text.length > 2 ? 42 * widthRate : 24 * widthRate
            implicitHeight: parent.height * 0.6
            text: totalPage == 0 ? "0" :  currentPage == -1 ? "" : currentPage

            onAccepted: {
                pageChanged(text);
            }

            style: TextFieldStyle{
                background: Rectangle{
                    anchors.fill: parent
                    border.width: 1
                    border.color: "#808080"
                    radius: 2 * heightRate
                    color: "#ffffff"
                }
                padding.bottom: 5 * heightRate
            }

            menu:null
            font.family: Cfg.PAGE_FAMILY
            font.pixelSize: Cfg.PAGE_FONTSIZE * heightRate
            validator: IntValidator{bottom: 1;top: totalPage}
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        Label{
            text: "页"
            font.family: Cfg.PAGE_FAMILY
            font.pixelSize: (Cfg.PAGE_FONTSIZE) * heightRate
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle{
            width: 30 * widthRate
            height: parent.height * 0.6
            border.width: 1
            border.color: "#808080"
            radius: 2 * heightRate
            anchors.verticalCenter: parent.verticalCenter

            Text{
                text: "确定"
                anchors.fill: parent
                font.family: Cfg.PAGE_FAMILY
                font.pixelSize: (Cfg.PAGE_FONTSIZE - 3) * heightRate
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea{
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if(inputTextField.text == "0"){
                        return;
                    }
                    pageChanged(inputTextField.text);
                }
            }
        }
    }
}

