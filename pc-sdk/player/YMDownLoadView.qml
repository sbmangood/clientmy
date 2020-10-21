import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import"./Configuuration.js" as Cfg

Item {
    width: parent.width
    height: parent.height

    property int minValue: 0;
    property int maxValue: 0;
    property int currentValue: 0;

    signal sigResetDownload();//重新下载

    onCurrentValueChanged: {
        progressBar3.value = maxValue / currentValue;
    }

    //下载中
    Rectangle{
        id: downloadingView
        width: 490 * heightRate
        height: 140 * heightRate
        radius: 12 * heightRate
        color: "#3D3F4E"
        anchors.centerIn: parent

        Text {
            id: text1
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 24 * heightRate
            color: "#ffffff"
            text: qsTr("正在下载录播")
            anchors.top: parent.top
            anchors.topMargin: 30 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ProgressBar{
            id: progressBar3
            width: parent.width * 0.8
            height: 6 * widthRate
            anchors.top: text1.bottom
            anchors.topMargin: 22 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
            style: ProgressBarStyle{
                id:progressBar3Style;
                background: Rectangle{
                    color:"#44485D";
                }
                progress: Rectangle{
                    color: "#44485D"
                    clip: true
                    radius: 12 * heightRate
                    LinearGradient{
                            anchors.fill: parent;
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.00
                                    color: "#4D56FF"
                                }
                                GradientStop {
                                    position: 1.00;
                                    color: "#4EFEDA"
                                }
                            }
                            start:Qt.point(0, 0);
                            end: Qt.point(parent.width, 0);
                        }

                }
                panel: Item{
                    implicitWidth: progressBar3.width
                    implicitHeight: progressBar3.height

                    Loader{
                        anchors.fill: parent;
                        sourceComponent: background;
                    }

                    Loader{
                        height: parent.height
                        width: currentProgress * (parent.width - 4 )
                        anchors.verticalCenter: parent.verticalCenter
                        sourceComponent: progressBar3Style.progress;
                    }
                }
            }
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: (parent.width - progressBar3.width) * 0.5
            anchors.top: progressBar3.bottom
            anchors.topMargin: 10 * heightRate
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 14 * heightRate
            color: "#ffffff"
            text:  (progressBar3.value * 100).toString() + "%"
        }
    }

    //下载失败
    Rectangle{
        id: downloadingFailView
        width: 490 * heightRate
        height: 140 * heightRate
        radius: 12 * heightRate
        color: "#3D3F4E"
        visible: false
        anchors.centerIn: parent

        Text {
            font.family: Cfg.DEFAULT_FONT
            font.pixelSize: 24 * heightRate
            color: "#ffffff"
            text: qsTr("下载失败!")
            anchors.top: parent.top
            anchors.topMargin: 30 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter
        }

        MouseArea{
            width: 252 * heightRate
            height: 44 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16 * heightRate
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle{
                anchors.fill: parent
                color: "#618AEB"
            }

            Text {
                font.pixelSize: 16 * heightRate
                font.family: Cfg.DEFAULT_FONT
                color: "#ffffff"
                text: qsTr("重新下载")
                anchors.centerIn: parent
            }

            onClicked: {
                sigResetDownload();
            }
        }
    }

    function resetDownload(){
        minValue = 0;
        maxValue = 0;
        currentValue = 0;
        downloadingFailView.visible = true;
        downloadingView.visible = false;
    }
}
