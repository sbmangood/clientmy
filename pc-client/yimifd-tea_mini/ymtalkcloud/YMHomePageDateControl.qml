import QtQuick 2.0
import "../Configuration.js" as Cfg

Item{
    id: dataView
    width: parent.width
    height: parent.height

    property string year: "2017";
    property string week1: "";
    property string week2: "";
    property string week3: "";
    property string week4: "";
    property string week5: "";
    property string week6: "";
    property string week7: "";

    property int currentIndex: -1;

    property int contentWidth: 0;
    property int oneColumnWidth: 0;//第一列宽
    property var dateOfWeek: [];


    onDateOfWeekChanged: {
        if(dateOfWeek.length == 0|| dateOfWeek == undefined ){
            return
        }
        updateWeek(dateOfWeek);
        getWeekIndex(dateOfWeek);
    }

    Row{
        anchors.fill: parent

        Text{
            width: oneColumnWidth
            height: parent.height
            text:  year
            font.bold: Cfg.WEEK_FONT_BOLD
            font.family: Cfg.WEEK_FONT_FAMILY
            font.pixelSize: Cfg.WEEK_FONT_SIZE*heightRate
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        Text{
            width: dataView.contentWidth
            height: parent.height
            text: "周一 " +    week1
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.RichText
            font.bold: Cfg.WEEK_FONT_BOLD
            font.family: Cfg.WEEK_FONT_FAMILY
            font.pixelSize: Cfg.WEEK_FONT_SIZE*heightRate
            color: currentIndex == 1 ? Cfg.WEEK_BRIGHT_COLOR : Cfg.WEEK_DEFAULT_COLOR
        }
        Text{
            width: dataView.contentWidth
            height: parent.height
            text: "周二 " +   week2
            font.bold: Cfg.WEEK_FONT_BOLD
            font.family: Cfg.WEEK_FONT_FAMILY
            font.pixelSize: Cfg.WEEK_FONT_SIZE*heightRate
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: currentIndex == 2 ? Cfg.WEEK_BRIGHT_COLOR : Cfg.WEEK_DEFAULT_COLOR
        }
        Text{
            width: dataView.contentWidth
            height: parent.height
            text: "周三 " +   week3
            font.bold: Cfg.WEEK_FONT_BOLD
            font.family: Cfg.WEEK_FONT_FAMILY
            font.pixelSize: Cfg.WEEK_FONT_SIZE*heightRate
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: currentIndex == 3 ? Cfg.WEEK_BRIGHT_COLOR : Cfg.WEEK_DEFAULT_COLOR
        }
        Text{
            width: dataView.contentWidth
            height: parent.height
            text: "周四 " +   week4
            font.bold: Cfg.WEEK_FONT_BOLD
            font.family: Cfg.WEEK_FONT_FAMILY
            font.pixelSize: Cfg.WEEK_FONT_SIZE*heightRate
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: currentIndex == 4 ? Cfg.WEEK_BRIGHT_COLOR : Cfg.WEEK_DEFAULT_COLOR
        }
        Text{
            width: dataView.contentWidth
            height: parent.height
            text: "周五 " +  week5
            font.bold: Cfg.WEEK_FONT_BOLD
            font.family: Cfg.WEEK_FONT_FAMILY
            font.pixelSize: Cfg.WEEK_FONT_SIZE*heightRate
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: currentIndex == 5 ? Cfg.WEEK_BRIGHT_COLOR : Cfg.WEEK_DEFAULT_COLOR
        }
        Text{
            width: dataView.contentWidth
            height: parent.height
            text: "周六 " +   week6
            font.bold: Cfg.WEEK_FONT_BOLD
            font.family: Cfg.WEEK_FONT_FAMILY
            font.pixelSize: Cfg.WEEK_FONT_SIZE*heightRate
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: currentIndex == 6 ? Cfg.WEEK_BRIGHT_COLOR : Cfg.WEEK_DEFAULT_COLOR
        }
        Text{
            width: dataView.contentWidth
            height: parent.height
            text: "周日 " + week7
            font.bold: Cfg.WEEK_FONT_BOLD
            font.family: Cfg.WEEK_FONT_FAMILY
            font.pixelSize: Cfg.WEEK_FONT_SIZE*heightRate
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: currentIndex == 0 ? Cfg.WEEK_BRIGHT_COLOR : Cfg.WEEK_DEFAULT_COLOR
        }
    }

    function updateWeek(dateOfWeek){
        var yearArray = dateOfWeek[0].split("-");
        var yearArray1 = dateOfWeek[1].split("-");
        var yearArray2 = dateOfWeek[2].split("-");
        var yearArray3 = dateOfWeek[3].split("-");
        var yearArray4 = dateOfWeek[4].split("-");
        var yearArray5 = dateOfWeek[5].split("-");
        var yearArray6 = dateOfWeek[6].split("-");

        //一年最后一周的时候, yearArray[0] 可能是2018年, yearArray6[0]可能就是2019年了, 所以这里修改为: yearArray6[0],
        //不然, 当前是2018/12/28, 点击按钮: >, 再点击按钮: < 的以后, 请求API接口: getTeacherLessonSchedule的时候, 就变成2017年了, 即:
        //void YMLessonManagerAdapter::getTeachLessonInfo(QString dateTime) 这个参数dateTime是2017年
        year = yearArray6[0]; //修改当前文件全局的变量: year

        week1 = yearArray[1] + "-" + yearArray[2];
        week2 = yearArray1[1] + "-" + yearArray1[2];
        week3 = yearArray2[1] + "-" + yearArray2[2];
        week4 = yearArray3[1] + "-" + yearArray3[2];
        week5 = yearArray4[1] + "-" + yearArray4[2];
        week6 = yearArray5[1] + "-" + yearArray5[2];
        week7 = yearArray6[1] + "-" + yearArray6[2];
    }

    function getWeekIndex(dateOfWeek){
        currentIndex = -1;
        for(var i = 0; i < dateOfWeek.length;i++){
            var date2 = new Date(dateOfWeek[i]);
            var date = new Date();
            var year = date.getFullYear();
            var month = Cfg.addZero(date.getMonth() + 1);
            var day = Cfg.addZero(date.getDate());
            var date3 = new Date(year + "-" + month + "-" + day)
            if(date2.getTime() - date3.getTime() == 0 && date2.getDate() ==date3.getDate() ){
                currentIndex  = date3.getDay();
                //console.log("getWeekIndex========",currentIndex);
                return;

            }
        }
    }
}
