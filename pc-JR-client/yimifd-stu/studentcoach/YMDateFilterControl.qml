﻿import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "../Configuration.js" as Cfg

Item{
    width: parent.width
    height: parent.height

    property int subjectMark: -1;
    property int lessonMark: -1;
    property int selecteLessonIndex:  -1;
    property int selecteSubjectIndex: -1;

    onSelecteLessonIndexChanged: {
         comboBox.currentIndex = selecteLessonIndex;
    }

    onSelecteSubjectIndexChanged: {
        comboBoxSubject.currentIndex = selecteSubjectIndex;
    }

    signal lessonChanged(var index);
    signal subjectChanged(var key);
    signal clearChanged();


    Text{
        width: 89 * widthRates
        height: parent.height
        text:"筛选课程状态"
        verticalAlignment: Text.AlignVCenter
        anchors.left: parent.left
//        anchors.leftMargin: 18 * widthRates
        font.family: Cfg.LESSON_ALL_FAMILY
        font.pixelSize: 14 * widthRates
        color: "#666666"
    }
    YMComboBoxControl {
        id: comboBox
        height: 32 * widthRates
        width: 159 * widthRates
        anchors.left: parent.left
        anchors.leftMargin: 109 * widthRates
        anchors.verticalCenter: parent.verticalCenter
        model: ["全部课程","预排课程","旷课课程","请假课程","已完成课程"]
        onCurrentTextChanged: {
            if(lessonMark != -1){
                lessonChanged(currentIndex);
            }
            lessonMark = 0;
        }
    }
    Text{
        width: 89 * widthRates
        height: parent.height
        text:"学科"
        verticalAlignment: Text.AlignVCenter
        anchors.left: parent.left
        anchors.leftMargin: 317 * widthRates
        font.family: Cfg.LESSON_ALL_FAMILY
        font.pixelSize: 14 * widthRates
        color: "#666666"
    }

    YMComboBoxControl{
        id: comboBoxSubject
        height: 32 * widthRates
        width: 159 * widthRates
        anchors.left: parent.left
        anchors.leftMargin: 356 * widthRates
        anchors.verticalCenter: parent.verticalCenter
        model: subjectModel
        onCurrentTextChanged: {
            if(subjectMark != -1){
                subjectIndex = currentIndex;
               subjectChanged(getSubject(currentText));
            }
            subjectMark = 0;
        }
    }

    Row{
        width: 290 * widthRates
        height: 32 * widthRates
        anchors.left: parent.left
        anchors.leftMargin: 564 * widthRates
        spacing: 10*widthRate
        Text{
            height: parent.height
            text:"选择课程开始时间"
            verticalAlignment: Text.AlignVCenter
            font.family: Cfg.LESSON_ALL_FAMILY
            font.pixelSize: 14 * widthRates
            color: "#666666"
        }

        Rectangle{
            id: startItem
            width: 153*widthRate
            height: parent.height
            border.color: "#d3d8dc"
            border.width: 1 * widthRates
            anchors.verticalCenter: parent.verticalCenter
            radius: 4 * heightRate
            TextField{
                id: startTimeText
                text: currentDate
                anchors.fill: parent
                placeholderText:  "年/月/日"
                readOnly :true
                style: TextFieldStyle{
                    background: Rectangle{
                        color: "transparent"
                    }
                    placeholderTextColor: "#999999"
                }
                menu:null
                font.family: Cfg.LESSON_ALL_FAMILY
                font.pixelSize: 14 * widthRates
                textColor: "#666666"
                onTextChanged:{
                    endTimeText.text.length>0||startTimeText.length>0?clearTimeText.color="#222222":clearTimeText.color="#aaaaaa"
                }
            }
            MouseArea{
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    mark = 0;
                    var location = contentItem.mapFromItem(startItem,0,0);
                    calendarControl.x = location.x - 265 * widthRate;
                    calendarControl.y = location.y - 30 * heightRate;
                    calendarControl.open();
                }
            }
        }

        Text{
            height: parent.height
            text: "至"
            verticalAlignment: Text.AlignVCenter
            font.family: Cfg.LESSON_ALL_FAMILY
            font.pixelSize: Cfg.LESSON_ALL_FONTSIZE * heightRate
            color: "#aaaaaa"
            visible: false
        }

        Rectangle{
            id: endTimeItem
            width: 100 * widthRate
            height: parent.height
            border.color: "#d3d8dc"
            border.width: 1 * widthRates
            anchors.verticalCenter: parent.verticalCenter
            radius: 4 * heightRate
            visible: false
            enabled: false
            TextField{
                id: endTimeText
                text: currentEndDate
                placeholderText: "年/月/日"
                anchors.fill: parent
                readOnly :true
                style: TextFieldStyle{
                    background: Rectangle{
                        color: "transparent"
                    }
                    placeholderTextColor: "#999999"
                }
                menu:null
                font.family: Cfg.LESSON_ALL_FAMILY
                font.pixelSize: Cfg.LESSON_ALL_FONTSIZE * heightRate
                onTextChanged:{
                    endTimeText.text.length>0||startTimeText.length>0?clearTimeText.color="#222222":clearTimeText.color="#aaaaaa"
                }
            }
            MouseArea{
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    mark = 1;
                    var location = contentItem.mapFromItem(endTimeItem,0,0);
                    calendarControl.x = location.x - 265 * widthRate;
                    calendarControl.y = location.y - 30 * heightRate;
                    calendarControl.open();
                }
            }
        }

        Rectangle{
            width: 60 * widthRate
            height: parent.height
            border.color: "#d3d8dc"
            border.width: 1 * widthRates
            anchors.verticalCenter: parent.verticalCenter
            radius: 4 * heightRate
            visible: false
            enabled: false
            Text{
                id:clearTimeText
                text: "清空时间"
               anchors.centerIn: parent
                font.family: Cfg.LESSON_ALL_FAMILY
                font.pixelSize: Cfg.LESSON_ALL_FONTSIZE * heightRate
                color: "#aaaaaa"
            }
            MouseArea{
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: {
                    clearChanged();
                }
            }
        }

        Rectangle {
            width: 155*widthRate
            height: parent.height
            color:"transparent"
        }
    }

    ListModel{
        id: subjectModel
        ListElement { text: "全部科目"; key: "-1" }
        ListElement { text: "语文"; key: "1" }
        ListElement { text: "数学"; key: "2" }
        ListElement { text: "英语"; key: "3" }
        ListElement { text: "政治"; key: "4" }
        ListElement { text: "历史"; key: "5" }
        ListElement { text: "地理"; key: "6" }
        ListElement { text: "物理"; key: "7" }
        ListElement { text: "化学"; key: "8" }
        ListElement { text: "生物"; key: "9" }
        ListElement { text: "科学"; key: "16" }
    }

    //获取科目索引
    function getSubject(subject){
        for(var i = 0; i < subjectModel.count;i++){
            if(subjectModel.get(i).text == subject){
                return subjectModel.get(i).key;
            }
        }
    }
}
