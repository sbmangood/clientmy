import QtQuick 2.0
import "./Configuuration.js" as Cfg

/**
*@brief 问题反馈页面
*@date      2019-04-24
*/

Item {
    id: feedbackItem
    width: 220 * heightRate
    height: 280 * heightRate

    signal sigFeedbackInfo(var feedbackTest);

    Image{
        anchors.fill: parent
        source: "qrc:/miniClassImage/feedbg.png"
    }

    ListView{
        id: feedListview
        width: parent.width - 60 * heightRate
        height: parent.height - 40 * heightRate
        anchors.centerIn: parent
        model: feedmodel
        delegate: feedComponent
    }

    ListModel{
        id: feedmodel
    }

    Component{
        id: feedComponent
        Item{
            width: feedListview.width
            height: 24 * heightRate

            MouseArea{
                id: checkMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    sigFeedbackInfo(feedbackText);
                    feedbackItem.visible = false;
                }
            }

            Text {
                text: feedbackText
                color: checkMouseArea.containsMouse ? "#ff5500" : "#666666"
                anchors.verticalCenter: parent.verticalCenter
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 14 * heightRate
            }
        }
    }

    Component.onCompleted: {
        feedmodel.append({ "id":1, "feedbackText": "耳机有杂音" });
        feedmodel.append({ "id":2, "feedbackText": "听不见学生声音" });
        feedmodel.append({ "id":3, "feedbackText": "学生听不见我的声音" });
        feedmodel.append({ "id":4, "feedbackText": "摄像头有异常,看不到画面" });
        feedmodel.append({ "id":5, "feedbackText": "翻不动课件" });
        feedmodel.append({ "id":6, "feedbackText": "严重卡顿" });
        feedmodel.append({ "id":7, "feedbackText": "有延迟" });
        feedmodel.append({ "id":8, "feedbackText": "学生卡进卡出教室" });
        feedmodel.append({ "id":9, "feedbackText": "请IT人员立刻与我联系" });
        feedmodel.append({ "id":10, "feedbackText": "请课后与我联系" });
    }
}
