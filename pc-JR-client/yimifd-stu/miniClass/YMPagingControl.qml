import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "../Configuration.js" as Cfg

Item {
    width: parent.width
    height: Cfg.BOTTOM_HEIGHT * heightRate
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
            height: parent.height * 0.5
            cursorShape: Qt.PointingHandCursor
            anchors.verticalCenter: parent.verticalCenter

//            Rectangle{
//                anchors.fill: parent
//                border.width: 1
//                border.color: "#e0e0e0"
//                radius: 4 * heightRate
//            }

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
            text:   totalPage == 0 ? "0/0" : currentPage + "/" + totalPage
            font.family: Cfg.PAGE_FAMAILY
            font.pixelSize: Cfg.PAGE_FONTSIZE * heightRate
            color: Cfg.PAGE_FONT_COLOR
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        MouseArea{
            width: parent.height * 0.5
            height: parent.height * 0.5
            cursorShape: Qt.PointingHandCursor
            anchors.verticalCenter: parent.verticalCenter

//            Rectangle{
//                border.width: 1
//                border.color: "#e0e0e0"
//                anchors.fill: parent
//                radius: 4 * heightRate
//            }

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
            font.family: Cfg.PAGE_FAMAILY
            font.pixelSize: Cfg.PAGE_FONTSIZE * heightRate
            anchors.verticalCenter: parent.verticalCenter
        }

        TextField{
            id: inputTextField
            width: 28 * widthRate
            height: parent.height * 0.7
            text: totalPage == 0 ? "0" :  currentPage == -1 ? "" : currentPage
            menu:null
            onAccepted: {
                pageChanged(text);
            }
            style: TextFieldStyle{
                background: Rectangle{
                    border.width: 1
                    border.color: "gray"
                    radius: 2 * heightRate
                    color: "#ffffff"
                }
            }
            font.family: Cfg.PAGE_FAMAILY
            font.pixelSize: (Cfg.PAGE_FONTSIZE -2) * heightRate
            validator: IntValidator{bottom: 1;top: totalPage}
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        Label{
            text: "页"
            font.family: Cfg.PAGE_FAMAILY
            font.pixelSize: Cfg.PAGE_FONTSIZE * heightRate
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle{
            width: 30 * widthRate
            height: parent.height * 0.7
            border.width: 1
            border.color: "gray"
            radius: 2 * heightRate
            anchors.verticalCenter: parent.verticalCenter

            Text{
                text: "确定"
                font.family: Cfg.PAGE_FAMAILY
                font.pixelSize: (Cfg.PAGE_FONTSIZE - 3 ) * heightRate
                anchors.fill: parent
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

