import QtQuick 2.0
import "Configuuration.js" as Cfg
/*填写试听课报告时 接收到老师交麦时的提示窗*/
MouseArea {
    property string tips: "您即将开始填写试听课报告，检测到CC(协作CC、CR)在线，是否将麦交给CC(旁听协作CC、旁听CR)？";
    property string waitTips: "正在等待CC（协作CC、CR）同意"

    signal cancelConfirm();
    signal whetherHandMic(var handMic);//是否交出麦  1 交  0 不交

    property int currentViewType: 1;//当前显示的界面类型 1 非等待  2 等待页面

    hoverEnabled: true
    onWheel: {
        return;
    }

    onVisibleChanged:
    {
        if(visible)
        {
            currentViewType = 1;
        }
    }

    Rectangle{
        width: 250 * widthRate
        height: 180 * heightRate
        color: "#ffffff"
        radius: 8*heightRate
        anchors.centerIn: parent

        Column{
            width: parent.width - 40 * heightRate
            height: 40 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 30 * heightRate
            spacing: 15 * widthRate
            anchors.horizontalCenter: parent.horizontalCenter
            visible: currentViewType == 1
            Text{
                text: "您开始填写试听课报告，是否交麦给课程顾问？交"
                font.family: "Microsoft YaHei"
                font.pixelSize: 13 * tipDropClassroom.ratesRates
                color:"#222222"
            }

            Text{
                text: "麦后由课程顾问开始与学生沟通"
                font.family: "Microsoft YaHei"
                font.pixelSize: 13 * tipDropClassroom.ratesRates
                color:"#222222"
            }
        }

        Row{
            width: parent.width*0.9
            height: 40*heightRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 12*widthRate
            visible: currentViewType == 1
            MouseArea{
                width: parent.width * 0.5
                height: parent.height
                cursorShape: Qt.PointingHandCursor
                Rectangle{
                    id: cancelItem
                    width: 92*widthRate
                    height: 43*heightRate
                    border.color: "#96999c"
                    border.width: 1
                    anchors.centerIn: parent
                    radius:4*heightRate
                    Text{
                        text: "不交麦"
                        anchors.centerIn: parent
                        font.family: "Microsoft YaHei"
                        font.pixelSize: 18 * tipDropClassroom.ratesRates
                        color:"#96999c"
                    }
                }
                onClicked: {
                    whetherHandMic(0);
                }
            }

            MouseArea{
                width: parent.width * 0.5
                height: parent.height
                cursorShape: Qt.PointingHandCursor
                Rectangle{
                    id: confirmItem
                    width: 92*widthRate
                    height: 43*heightRate
                    color: "#ff5000"

                    anchors.centerIn: parent
                    radius:4*heightRate
                    Text{
                        text: "交麦"
                        anchors.centerIn: parent
                        font.family: "Microsoft YaHei"
                        font.pixelSize: 18 * tipDropClassroom.ratesRates
                        color: "#ffffff"
                    }
                }
                onClicked: {
                    whetherHandMic(1);
                    currentViewType = 2;
                }
            }
        }
        Text{
            height: 43*heightRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50 * widthRate
            anchors.horizontalCenter: parent.horizontalCenter
            text: "正在等待CC（协作CC、CR）同意"
            font.family: "Microsoft YaHei"
            font.pixelSize: 14 * tipDropClassroom.ratesRates
            color:"#222222"
            visible: currentViewType == 2
        }
        Rectangle{
            width: 92*widthRate
            height: 43*heightRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15 * widthRate
            anchors.horizontalCenter: parent.horizontalCenter
            border.color: "#96999c"
            border.width: 1
            radius:4*heightRate
            visible: currentViewType == 2
            Text{
                text: "取消"
                anchors.centerIn: parent
                font.family: "Microsoft YaHei"
                font.pixelSize: 18 * tipDropClassroom.ratesRates
                color:"#96999c"
            }

            MouseArea{
                id: cancelRect
                width: parent.width * 0.5
                height: parent.height
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: {
                    cancelConfirm();
                    currentViewType = 1;
                }
            }
        }

    }
}
