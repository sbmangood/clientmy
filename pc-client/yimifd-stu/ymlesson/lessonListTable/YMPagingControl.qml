import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "../../Configuration.js" as Cfg

Rectangle {
    width: parent.width
    height: Cfg.BOTTOM_HEIGHT
    color: "#e0e0e0"
    property int totalPage: 1;
    property int currentPage: 1;

    signal pageChanged(var page);
    signal nextPage();
    signal pervPage();


    Row{
        width: 200
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter

        MouseArea{
            width: 80
            height: parent.height
            Image{
                width: 20
                height: 20
                anchors.centerIn: parent
                source: "qrc:/images/cr_btn_lastpage.png"
            }
            onClicked: {
                if(currentPage - 1 >= 1){
                    pervPage();
                }
            }
        }

        Item{
            width: 80
            height: parent.height

            TextField{
                id: inputTextField
                width: 60
                height: 30
                text: currentPage == -1 ? "" : currentPage

                onAccepted: {
                    pageChanged(text);
                    console.log("====onAccepted=====");
                }
                style: TextFieldStyle{
                    background: Rectangle{
                        border.width: 1
                        border.color: "gray"
                        radius: 6
                        color: "white"
                    }
                }
                font.pixelSize: 16                
                validator: IntValidator{bottom: 1;top: totalPage}

                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter

            }

            Label{
                text: "/" + totalPage
                anchors.left: inputTextField.right
                anchors.leftMargin: 6
                font.bold: true
                font.pixelSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea{
            width: 80
            height: parent.height
            Image{
                width: 20
                height: 20
                anchors.centerIn: parent
                source: "qrc:/images/cr_btn_nextpage.png"
            }
            onClicked: {
                if(currentPage + 1 <= totalPage){
                    nextPage();
                }
            }
        }
    }
}

