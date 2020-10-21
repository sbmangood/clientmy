import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
Rectangle {
    z: 56565

    property bool isUpdate: true;
    //    property double widthRate: Screen.width*0.8 / 966.0;
    //    property double heightRate: Screen.height*0.8 / 833.0;
    property string title: ""

    signal appClosed();
    signal updateChanged(var updateStatus);

    Column{
        anchors.fill: parent
        spacing: 0

        Rectangle{
            width: parent.width
            height: parent.height * 0.6
            Image{
                anchors.fill: parent
                source: "qrc:/JrImage/bg_img@2x.png"
            }
            Row{
                width: parent.width
                height: 20 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: 10 *widthRate
                anchors.top: parent.top
                anchors.topMargin: 5 * heightRate
                spacing: 10 *widthRate
                Image{
                    width: 60 * widthRate
                    height: parent.height
                    source: "qrc:/JrImage/logo_heng@2x.png"
                }

                Rectangle{
                    height: parent.height - 4 * heightRate
                    width: 1
                    color: "#949494"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text{
                    height: parent.height
                    text: "学生端v" + title
                    color: "#949494"
                    font.pixelSize: 11 * widthRate
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Image{
                id: logoImg
                width: 70 * widthRate
                height: 70 * widthRate
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: (parent.height - height) * 0.3
                source: "qrc:/JrImage/logo_fang@2x.png"
            }
            Text{
                text: updataRectangle.visible ? "软件有新版本！" : "软件更新中..."
                color: "#FF5500"
                font.pixelSize: 30 * widthRate
                anchors.top: logoImg.bottom
                anchors.topMargin: 28 *heightRate
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Rectangle{
            width: parent.width
            height: parent.height * 0.4
            color: "white"
            id:updataRectangle
            visible: true
            Rectangle{
                width: parent.width * 0.5
                height: 55 * heightRate
                radius: 6 * heightRate
                color: "#FF5500"
                anchors.centerIn: parent
                MouseArea{
                    id: updateButton
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                }

                Text{
                    text: "立即更新"
                    color: updateButton.containsMouse ? "black" : "white"
                    font.pixelSize: 18 * widthRate
                    anchors.centerIn: parent
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        updataRectangle.visible=false;
                        updateChanged(true);
                    }
                }
            }
            MouseArea{
                width: 50 * widthRate
                height: 40 * heightRate
                enabled: isUpdate
                hoverEnabled: isUpdate
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10 * widthRate
                anchors.horizontalCenter: parent.horizontalCenter
                cursorShape: Qt.PointingHandCursor
                Text{
                    text: "暂不更新"
                    color: isUpdate ? "#FF5500" : "gray"
                    font.pixelSize: 13 * widthRate
                    anchors.centerIn: parent
                }
                onClicked: {                    
                    updateChanged(false);
                }
            }
        }
        Rectangle{
            width: parent.width
            height: parent.height * 0.4
            color: "white"
            visible: !updataRectangle.visible
            Column{
                width: parent.width
                anchors.centerIn: parent
                height: parent.height * 0.4
                spacing: 15 * heightRate

                ProgressBar
                {
                    id:progressbar
                    width: parent.width
                    height: 8 * heightRate
                    minimumValue: 0
                    maximumValue: 100
                    style: ProgressBarStyle{
                        background: Rectangle{
                            radius: 6 * heightRate
                            anchors.fill: parent
                            color:"#e3e6e9"
                        }


                        progress: Rectangle{
                            radius: 6 * heightRate
                            anchors.fill: parent
                            color: "#ff5000"
                        }

                    }
                }

                Text{
                    text: "正在更新..."
                    color: "gray"
                    font.pixelSize: 12 * widthRate
                    height: 10 * heightRate
                }
            }

        }
    }

    MouseArea{
        width:  30 * widthRate
        height: 30 * widthRate
        anchors.top: parent.top
        anchors.topMargin: 5 * widthRate
        anchors.right: parent.right
        anchors.rightMargin: 5* widthRate
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        Image{
            anchors.fill: parent
            source: parent.containsMouse?"qrc:/JrImage/btn_upgrade_close_pressed@2x.png":"qrc:/JrImage/btn_upgrade_close_normal@2x.png"
        }

        onClicked: {
            appClosed();
        }
    }

    function updateProgressBarValue(currentValues,maxValue)
    {
        progressbar.value =currentValues/maxValue * 100;

    }

}

