var TB_HEIGHT = 60;
var TB_CLR = "#ff5000"
var DEFAULT_FONT = "Microsoft YaHei";//"宋体";//

var NAV_WIDTH = 126;
var NAV_LINE_HEIGHT = 100;
var BOTTOM_HEIGHT = 40

//菜单栏字体配置
var Menu_MinPixelSize = 13;
var Menu_pixelSize = 14;
var Menu_family = "Microsoft YaHei";
var Menu_bold = false;
var Menu_selecteColor = "#338FFF";
var Menu_defaultColor = "#666666";

//课程表字体配置
var LESSON_FONT_SIZE = 16;
var LESSON_FONT_BOLD = false;
var LESSON_FONT_FAMILY = DEFAULT_FONT
var LESSON_HEAD_FONT_SIZE = 26;
var LESSON_HEAD_FONT_BOLD = false;
var LESSON_HEAD_FONT_COLOR = "gray";
var LESSON_MARGIN = 20;

//课程表详细信息字体配置
var LESSONINFO_FONTSIZE = 14;
var LESSONINFO_FONTBOLD = false;
var LESSONINFO_FAMILY = DEFAULT_FONT;
var LESSONINFO_BUTTON_SIZE = 14; //按钮和内容字体

//菜单栏消息提醒字体配置
var MASSGE_FONTSIZE = 16;
var MASSGE_FAMILY = DEFAULT_FONT;
var MASSGE_FONT_COLOR = "#C89000"//字体颜色
var MASSGE_LINK_COLOR = "#338fff";// 查看字体颜色
var MASSGE_BORDER_COLOR ="#eeca6f"// 边框颜色

//消息提醒页面字体设置
var TIPS_FONT_SIZE = 16;//全部默认字体大小
var TIPS_HEAD_FONTSIZE = 24;//head字体大小
var TIPS_FONT_BOLD = false;
var TIPS_FONT_FAMILY = DEFAULT_FONT
var TIPS_FONT_COLOR = "#333333";//默认颜色
var TIPS_FONT_HOVER = "#666666";//已读颜色
var TIPS_LINK_COLOR ="#FF5000";//请查看颜色
var TIPS_HEAD_FONT_COLOR = "#96999c";//列表头字体颜色

//全部课程字体设置
var LESSON_ALL_FONTSIZE = 16;
var LESSON_ALL_FONTBOLD = false;
var LESSON_ALL_FAMILY = DEFAULT_FONT;

//星期字体设置
var WEEK_FONT_SIZE = 16;
var WEEK_FONT_BOLD = false;
var WEEK_FONT_FAMILY = DEFAULT_FONT
var WEEK_BRIGHT_COLOR = "#ff9000";//高亮颜色
var WEEK_DEFAULT_COLOR = "black";//默认颜色

//下拉框字体配置
var COMBOX_FONTSIZIE = 16;
var COMBOX_FAMILY = DEFAULT_FONT;
var COMBOX_BACK_COLOR = "white"//背景颜色
var COMBOX_BODER_COLOR = "#d3d8dc" //边框颜色
var COMBOX_FONT_COLOR = "black"; //默认颜色
var COMBOX_FONT_HOVER ="#ff5000"//高亮颜色

//课程表内容信息
var LESSON_FONT_BODY_SIZE = 14
//登陆页面字体配置
var LOGIN_FONTSIZE = 14;//显示字体
var LOGIN_INPUT_FONTSIZE = 15;//输入框字体大小
var LOGIN_FAMILY = DEFAULT_FONT;

//点击头像弹框字体配置
var HEAD_FONTSIZE = 18;
var HEAD_FAMILY = DEFAULT_FONT;

//修改密码页面字体配置
var PASSWORD_FONTSIZE = 14;
var PASSWORD_FAMILY = DEFAULT_FONT;

//加载页面字体配置
var LODING_FONTSIZE = 12;
var LODING_FAMILY = DEFAULT_FONT;

//点击设置菜单字体配置
var MENU_SETTING_FONTSIZE =16
var MENU_SETTING_FAMILY = DEFAULT_FONT;
var MENU_SETTING_COLOR  = "#222222";//默认颜色
var MENU_SETTING_HOVECOLOR= "#ff5000";//高亮颜色

//分页字体配置
var PAGE_FONTSIZE = 16;
var PAGE_FAMAILY =DEFAULT_FONT;
var PAGE_FONT_COLOR = "#666666";
//退出字体配置
var EXIT_FONTSIZE = 18;
var EXIT_FAMILY = DEFAULT_FONT;
var EXIT_FONT_COLOR = "#222222";
//日历字体配置
var CALENDAR_FONTSIZE = 16;
var CALENDAR_FAMILY =DEFAULT_FONT;

//录播下载页面字体配置
var RECORD_FONTSIEZ = 12;
var RECORD_FAMILY =DEFAULT_FONT;

//进入教室字体配置
var CLASSROOM_FONTSIZE = 12;
var CLASSROOM_FAMILY = DEFAULT_FONT;

//请假页面字体配置
var LEAVE_FONTSIZE = 17;//常规字体
var LEAVE_HEAD_FONTSIZE = 26;//头提醒字体
var LEAVE_FAMILY = DEFAULT_FONT;

//设备检测
var DEVICE_FONTSIZE = 14; //常规字体大小
var DEVICE_HEADFONTSIZE = 25;//头字体大小
var DEVICE_MUEN_FONTSIZE = 20;//选项卡字体大小
var DEVICE_BUTTON_FONTSIZE = 13;//按钮字体大小
var DEVICE_FAMILY =DEFAULT_FONT;

var dateOfWeek = [
            "2017-08-26",
            "2017-08-27",
            "2017-08-28",
            "2017-08-29",
            "2017-08-30",
            "2017-08-31",
            "2017-09-01"
        ]
var timeSchedule = [
            "05:55 - 06:35",
            "06:40 - 07:20",
            "07:30 - 08:10",
            "08:15 - 08:55",
            "09:00 - 09:40",
            "09:50 - 10:30",
            "10:35 - 11:15",
            "11:20 - 12:00",
            "12:45 - 13:25",
            "13:30 - 14:10",
            "14:15 - 14:55",
            "15:05 - 15:45",
            "15:50 - 16:30",
            "16:35 - 17:15",
            "18:00 - 18:40",
            "18:45 - 19:25",
            "19:30 - 20:10",
            "20:20 - 21:00",
            "21:05 - 21:45",
            "21:50 - 22:30",
            "22:35 - 23:15",
            "23:20 - 24:00"
        ]
var timeRule = {
    "morning": "05:55-12:00",
    "afternoon": "12:45-17:15",
    "night": "18:00-24:00",
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

function analysisDate(startTime){
    var currentStartDate = new Date(startTime);
    var year = currentStartDate.getFullYear();
    var month = addZero(currentStartDate.getMonth() + 1);
    var day = addZero(currentStartDate.getDate());

    return year + "-" + month + "-" + day;
}

function getCurrentDate(){
    var date = new Date();
    var year = date.getFullYear();
    var month = Cfg.addZero(date.getMonth() + 1);
    var day = Cfg.addZero(date.getDate());
    return year + "/" + month + "/" + day ;
}

function getCurrentDates(){
    var date = new Date();
    var year = date.getFullYear();
    var month = Cfg.addZero(date.getMonth() + 1);
    var day = Cfg.addZero(date.getDate());
    return year + "-" + month + "-" + day ;
}

function updatehtml(){

}
