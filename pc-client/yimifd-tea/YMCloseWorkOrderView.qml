import QtQuick 2.0
import QtQuick.Controls 2.0
import "Configuration.js" as Cfg
import YMWorkOrderways 1.0
MouseArea {
    id: cWOView
    anchors.fill: parent
    hoverEnabled: true
    property int likeType: 1;

    property int showViewType: 2;//当前显示的模式 1 为关闭工单的 输入模式 2 为是否确认提交的提示 3 关闭是否成功提示窗口
    property var orderId: ;

    signal closeWorkerOrderSuccess();

    onWheel: {
        return;
    }
    onVisibleChanged:
    {
        if(visible )
        {
            showViewType = 2;
            likeType = 1;
            reasonTextEdit.text = "";
            detailView.visible = true;
        }
    }

    YMWorkOrderways
    {
        id:workOrderway
    }

    Rectangle{
        color: "black"
        opacity: 0.4
        anchors.fill: parent
    }

    Rectangle{
        id: detailView
        width: 410 * widthRate
        height: showViewType == 1 ? 352 * widthRate : 225 * widthRate
        color: "#ffffff"
        radius: 8 * heightRate
        anchors.centerIn: parent
        Rectangle{
            width: parent.width
            height: 50 * heightRate
            anchors.top: parent.top
            anchors.topMargin: -1

            anchors.left: parent.left
            anchors.leftMargin: 0
            color: "#f3f3f3"
            radius: 7 * heightRate
            Rectangle{
                width: parent.width
                height: parent.height / 2
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                color: "#f3f3f3"
            }

            Text{
                text: "关闭工单"
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 10 * heightRate
                anchors.leftMargin: 25 * heightRate
                font.family: Cfg.EXIT_FAMILY
                font.pixelSize: 20 * heightRate
                color:"#222222"
            }

            Rectangle
            {
                width: 40 * heightRate
                height: 30 * heightRate
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: -5 * heightRate
                color: "transparent"

                Text {
                    anchors.fill: parent
                    font.family: Cfg.EXIT_FAMILY
                    font.pixelSize: 40 * heightRate
                    text: qsTr("×")
                }
                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        cWOView.visible = false
                    }
                }
            }

        }

        Rectangle{
            id: reasonTextrectangle
            width: parent.width * 0.9
            height: 120 * widthRate
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true
            // border.color: reasonTextEdit.text.length < 50 ? "#c3c6c9" : "#ff3e00"
            border.color:"#c3c6c9"
            border.width: 1
            anchors.top: parent.top
            anchors.topMargin: 90 * heightRate
            radius: 8 * heightRate
            visible: showViewType == 1 ? true : false
            TextArea  {
                id: reasonTextEdit
                font.family: Cfg.EXIT_FAMILY
                font.pixelSize: 17 * heightRate
                height: parent.height - 30 * widthRate
                width: parent.width - 10 * widthRate
                anchors.centerIn: parent
                placeholderText:  qsTr("请您对遇到的问题进行评价（必填）")
                selectByMouse: true
                // color: reasonTextEdit.text.length < 50 ? "#222222" : "#666666" // #222222
                color: "#222222"
                wrapMode: TextEdit.Wrap
                selectedTextColor: "white"
                selectionColor: "#3a80cd"

                //                onTextChanged: {
                //                    if(reasonTextEdit.text.length > 50)
                //                    {
                //                        reasonTextEdit.text = reasonTextEdit.getText(0,49);
                //                    }
                //                }
            }
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 30 * heightRate
            anchors.top: reasonTextrectangle.bottom
            anchors.topMargin: 30 *heightRate
            text: qsTr("评价")
            font.family: Cfg.EXIT_FAMILY
            font.pixelSize: 20 * heightRate
            visible: showViewType == 1 ? true : false
        }

        Row
        {
            width: parent.width
            height: 50 * heightRate
            spacing: 20 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 30 * heightRate
            anchors.top: reasonTextrectangle.bottom
            anchors.topMargin: 80 * heightRate
            visible: showViewType == 1 ? true : false

            CheckBox {
                text: qsTr("满意")
                checked: likeType == 1 ? true : false
                font.family: Cfg.EXIT_FAMILY
                font.pixelSize: 16 * heightRate
                onClicked:
                {
                    likeType = 1;
                }
            }
            CheckBox {
                text: qsTr("一般")
                font.family: Cfg.EXIT_FAMILY
                font.pixelSize: 16 * heightRate
                checked: likeType == 2 ? true : false
                onClicked:
                {
                    likeType = 2;
                }
            }
            CheckBox {
                text: qsTr("不满意")
                font.family: Cfg.EXIT_FAMILY
                font.pixelSize: 16 * heightRate
                checked: likeType == 3 ? true : false
                onClicked:
                {
                    likeType = 3;
                }
            }
        }

        Rectangle
        {
            width: parent.width * 0.6
            height: 50 * heightRate
            visible: showViewType == 2 ? true : false
            anchors.centerIn: parent
            Text {
                anchors.fill: parent
                text: qsTr("是否确认关闭当前工单？关闭后代表本工单所述问题已解决且工单状态无法逆转")
                wrapMode: Text.WordWrap
                font.family: Cfg.EXIT_FAMILY
                font.pixelSize: 22 * heightRate
                color: "#999999"

            }
        }

        Row{
            width: parent.width * 0.9
            height: 40 * heightRate
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 92 * widthRate
            MouseArea{
                width: parent.width * 0.3
                height: parent.height
                cursorShape: Qt.PointingHandCursor
                Rectangle{
                    id: cancelItem
                    width: 82 * widthRate
                    height: 48 * heightRate
                    border.color: "#96999c"
                    border.width: 1
                    anchors.centerIn: parent
                    radius:4 * heightRate
                    Text{
                        text: "取消"
                        anchors.centerIn: parent
                        font.family: Cfg.EXIT_FAMILY
                        font.pixelSize: Cfg.EXIT_BUTTON_FONTSIZE * heightRate
                        color:"#96999c"
                    }
                }
                onClicked: {
                    cWOView.visible = false;
                }
            }

            MouseArea{
                width: parent.width * 0.3
                height: parent.height
                cursorShape: Qt.PointingHandCursor
                enabled:  showViewType == 1 ? reasonTextEdit.text.length > 0 ? true : false : true
                Rectangle{
                    id: confirmItem
                    width: 82 * widthRate
                    height: 48 * heightRate
                    color: showViewType == 1 ? reasonTextEdit.text.length > 0 ? "#ff5000" : "#f3f3f3": "#ff5000"

                    anchors.centerIn: parent
                    radius:4 * heightRate
                    Text{
                        text: showViewType == 1 ? "提交" : "确定"
                        anchors.centerIn: parent
                        font.family: Cfg.EXIT_FAMILY
                        font.pixelSize: Cfg.EXIT_BUTTON_FONTSIZE * heightRate
                        color: showViewType == 1 ? reasonTextEdit.text.length > 0 ? "#ffffff" : "#96999c" :"#ffffff"
                    }
                }
                onClicked: {
                    if(showViewType == 1)
                    {
                        var tempLike ;
                        if(likeType == 1)
                        {
                            tempLike = "满意";
                        }
                        if(likeType == 2)
                        {
                            tempLike = "一般";
                        }
                        if(likeType == 3)
                        {
                            tempLike = "不满意";
                        }

                        if(  workOrderway.closeWorkOrder(orderId,reasonTextEdit.text,tempLike) )
                        {
                            detailView.visible = false;
                            showCloseResultView.visible = true;

                        }
                    }
                    console.log("clickssssss",showViewType)
                    showViewType = 1;

                }
            }
        }
    }
    Rectangle{
        id:showCloseResultView
        width: 300 * widthRate
        height: 150* widthRate
        color: "#ffffff"
        radius: 8 * heightRate
        anchors.centerIn: parent
        visible: false

        Rectangle{
            width: parent.width
            height: 50 * heightRate
            anchors.top: parent.top
            anchors.topMargin: -1

            anchors.left: parent.left
            anchors.leftMargin: 0
            color: "#f3f3f3"
            radius: 7 * heightRate
            Rectangle{
                width: parent.width
                height: parent.height / 2
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                color: "#f3f3f3"
            }

            Text{
                text: "关闭工单"
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 10 * heightRate
                anchors.leftMargin: 25 * heightRate
                font.family: Cfg.EXIT_FAMILY
                font.pixelSize: 20 * heightRate
                color:"#222222"
            }

            Rectangle
            {
                width: 40 * heightRate
                height: 30 * heightRate
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: -5 * heightRate
                color: "transparent"

                Text {
                    anchors.fill: parent
                    font.family: Cfg.EXIT_FAMILY
                    font.pixelSize: 40 * heightRate
                    text: qsTr("×")
                }
                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        cWOView.visible = false
                        showCloseResultView.visible = false;
                        closeWorkerOrderSuccess();
                    }
                }
            }

        }
        Text {
            anchors.centerIn: parent
            text: qsTr("关闭工单成功")
            font.family: Cfg.EXIT_FAMILY
            font.pixelSize: 22 * heightRate
            color: "#999999"

        }
        MouseArea{
            width: 82 * widthRate
            height: 48 * heightRate
            cursorShape: Qt.PointingHandCursor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5 * heightRate
            Rectangle{
                width: 82 * widthRate
                height: 48 * heightRate
                border.color: "#96999c"
                border.width: 1
                anchors.centerIn: parent
                radius:4 * heightRate
                Text{
                    text: "确定"
                    anchors.centerIn: parent
                    font.family: Cfg.EXIT_FAMILY
                    font.pixelSize: Cfg.EXIT_BUTTON_FONTSIZE * heightRate
                    color:"#96999c"
                }
            }
            onClicked: {
                cWOView.visible = false;
                showCloseResultView.visible = false;
                closeWorkerOrderSuccess();
            }
        }
    }
    function showCloseWorkOrderView(id)
    {
        orderId = id;
    }
}

