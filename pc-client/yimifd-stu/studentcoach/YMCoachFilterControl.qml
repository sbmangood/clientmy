import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "../Configuration.js" as Cfg

Rectangle{
    id: seacheItem
    width: parent.width
    height: parent.height
    border.color: "#e3e6e9"
    border.width: 1
    color: "white"
    radius: 5 * heightRate

    property string displayerText: "";
    property string currentText: "";
    signal filterChange(var text);

    Image{
        id: searchImage
        width: 14*widthRate
        height: 14*widthRate
        anchors.left: parent.left
        anchors.leftMargin: 10*widthRate
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: "qrc:/images/th_icon_search@2x.png"
    }

    TextField{
        id: filterText
        text:  displayerText
        width: parent.width - 40 * widthRate
        height: parent.height
        anchors.left: searchImage.right
        anchors.leftMargin: 2 * widthRate
        anchors.verticalCenter: parent.verticalCenter
        menu:null
        font.family: Cfg.LESSON_ALL_FAMILY
        font.pixelSize: Cfg.LESSON_ALL_FONTSIZE * heightRate
        placeholderText: "请输入老师姓名或课程编号"
        style: TextFieldStyle{
            background: Item{
                anchors.fill: parent
            }
            placeholderTextColor: "#999999"
        }
        onTextChanged: {
            currentText = text;
        }

        onAccepted: {
            filterChange(filterText.text);
        }
    }
}

