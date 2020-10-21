import QtQuick 2.0

Item {
    //直播直接跳转页面
    Component.onCompleted: {
        //直播课
        var url = URL_LiveLesson;
        console.log(url);
        Qt.openUrlExternally(url);
    }
}

