import QtQuick 2.0
import "Configuration.js" as Cfg

MouseArea{
    hoverEnabled: true
    anchors.fill: parent
    property int lessonId: 0;
    property var studentId;
    z:10
    onClicked:
    {
        return;
    }
    Rectangle{
        color: "black"
        opacity: 0.4
        anchors.fill: parent
    }

    Item
    {
        id: selectItem
        z: 2
        width: 270 * widthRate
        height: 180 * heightRate
        anchors.centerIn: parent
        Rectangle{
            anchors.fill: parent
            radius: 12 * widthRate
            color: "white"


            MouseArea{
                z: 2
                width: 22 * widthRate
                height: 22 * widthRate
                hoverEnabled: true
                anchors.top: parent.top
                anchors.topMargin: 5*heightRate
                anchors.right: parent.right
                anchors.rightMargin: 5*heightRate
                cursorShape: Qt.PointingHandCursor

                Image{
                    anchors.fill: parent
                    source: "qrc:/images/btn_close_normal.png"
                }

                onClicked: {
                    lessonReport.visible = false;
                }
            }

            Text{
                text: "请选择"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 32*heightRate

                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 16 * heightRate
                color: "#000000"
            }


            Column{
                width: parent.width * 0.9
                height: 80 * heightRate
                spacing: 10 * heightRate
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 80*heightRate

                MouseArea{
                    width: parent.width
                    height: parent.height * 0.5
                    cursorShape: Qt.PointingHandCursor
                    Rectangle{
                        width: parent.width
                        height: 33 * heightRate
                        color: "white"
                        border.color: "#1890FF"

                        anchors.centerIn: parent
                        radius:4*heightRate
                        Text{
                            text: "查看试听课报告"
                            anchors.centerIn: parent
                            font.family: Cfg.EXIT_FAMILY
                            font.pixelSize: Cfg.EXIT_BUTTON_FONTSIZE * heightRate
                            color: "#1890FF"
                        }
                    }
                    onClicked: {
                        var url = ListenUrl + lessonId + "&report=1";
                        console.log(url);
                        Qt.openUrlExternally(url);
                    }
                }
                MouseArea{
                    width: parent.width
                    height: parent.height * 0.5
                    cursorShape: Qt.PointingHandCursor
                    Rectangle{
                        width: parent.width
                        height: 33 * heightRate
                        color: "white"
                        border.color: "#1890FF"

                        anchors.centerIn: parent
                        radius:4*heightRate
                        Text{
                            text: "编辑试听课报告"
                            anchors.centerIn: parent
                            font.family: Cfg.EXIT_FAMILY
                            font.pixelSize: Cfg.EXIT_BUTTON_FONTSIZE * heightRate
                            color: "#1890FF"
                        }
                    }
                    onClicked: {  
                        //"https://sit01-h5.yimifudao.com.cn/hybrid/?studentId=135920&lessonId=2633925&classType=0&token=d28624b277c4114b68002acaadeed94d&appType=yimi&appDeviceType=iOS&deviceInfo=iOS13.3.1:iPad7,5:&deviceIdentity=B39D48B2-4A8D-4676-94F5-077E6A0EB992&osVersion=13.3.1&appVersion=5.4.1122&operatorType=&netType=wifi&userId=900000554/#/trial/lessonInfo"
                        var url = Write_ListenUrl + lessonId + "&userId="+ userId + "&studentId="+ studentId + "&token=" + token +  "&appType=yimi&classType=0" + "/#/trial/lessonInfo";
                        console.log("mmmmmm", url);
                        writeH5Report.visible = true;
                        writeH5Report.resetWebViewUrl(url);

                    }
                }
            }

        }

    }

    TipShowH5ReportView
    {
        id:writeH5Report
        anchors.fill: parent
        z:10
        visible: false

        onSigPushReportLoadingStatus:
        {
//            trailBoardBackground.pushReportMsgToServer(status,qsTr("系统错误"));
        }

        onSigReportFinished:
        {
        }

        onConfirmClose: {
//            sigExitProject();
        }
    }

    Rectangle
    {
        id: h5ReportEngine
        anchors.fill: parent
        radius: 12 * widthRate
        color: "#EBEFF3"


        MouseArea{
            z: 2
            width: 22 * widthRate
            height: 22 * widthRate
            hoverEnabled: true
            anchors.top: parent.top
            anchors.topMargin: 5*heightRate
            anchors.right: parent.right
            anchors.rightMargin: 5*heightRate
            cursorShape: Qt.PointingHandCursor

            Image{
                anchors.fill: parent
                source: "qrc:/images/closeBtn.png"
            }

            onClicked: {
                lessonReport.visible = false;
            }
        }

    }

    function setReportView(viewType,currentLessonId, studentIds)
    {
        selectItem.visible = false;
        h5ReportEngine.visible = false;
        lessonId = currentLessonId;
        studentId = studentIds;
        if(viewType == 1)
        {
            selectItem.visible = true;
        }else if(viewType == 2)
        {
            h5ReportEngine.visible = true;
        }
    }

}

