import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

MouseArea {
    id: calendarMouseArea
    width: 360
    height: 310
    hoverEnabled: true

    signal dateTimeconfirm(var dateTime);

    Image {
        id: backImage
        anchors.fill: parent
        source: "qrc:/images/accountMa.png"
    }

    Calendar{
        id: calendar
        width: parent.width - 4
        height: 290
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter
        onPressed: {
            var year = date.getFullYear();
            var month = addZero(date.getMonth() + 1);
            var day = addZero(date.getDate());
            dateTimeconfirm(year + "-" + month + "-" + day);
            calendarMouseArea.visible = false;
        }
    }

    onExited: {
        calendarMouseArea.visible = false;
    }

    function addZero(tmp){
        var fomartData;
        if(tmp < 10){
            fomartData = "0" + tmp;
        }else{
            fomartData = tmp;
        }
        return fomartData;
    }
}

