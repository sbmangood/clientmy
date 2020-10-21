
var TB_HEIGHT = 60;
var TB_CLR = "#ff5000";

var DEFAULT_FONT = "Microsoft YaHei";//"宋体"
//菜单栏字体配置
var Menu_MinPixelSize = 13;
var Menu_pixelSize = 14;
var Menu_family = "Microsoft YaHei";
var Menu_bold = false;
var Menu_selecteColor = "#338FFF";
var Menu_defaultColor = "#666666";

var NAV_WIDTH = 126;
var NAV_LINE_HEIGHT = 100;
var NAV_BK_CLR = "#ffffff";
var NAV_SELECTED_CLR = "#FF6633";
var NAV_HOVERED_CLR = "#ffffff";
var NAV_INDICATOR_CLR = "#088BD2";
var NAV_FONT = DEFAULT_FONT;
var NAV_FONT_SIZE1 = 16;
var NAV_FONT_SIZE2 = 16;
var NAV_TEXT_CLR1 = "#3c3c3e";
var NAV_TEXT_CLR2 = "#646464";

var BOTTOM_HEIGHT = 30

//课程表字体设置
var LESSON_FONT_SIZE = 14//
var LESSON_2FONTSIZE = 16//
var LESSON_MAX_FONTSIZE = 26;//课程表三个字大小
var LESSON_FONT_BOLD = false
var LESSON_FONT_FAMILY = DEFAULT_FONT;
var LESSON_FONT_COLOR = "#3a80cd"
var LESSON_HEAD_FONT_SIZE = 18
var LESSON_HEAD_FONT_BOLD = true
var LESSON_HEAD_FONT_COLOR = "#999999"
var LESSONINFO_FAMILY = DEFAULT_FONT;

//加载页面字体配置
var LODING_FONTSIZE = 12;
var LODING_FAMILY = DEFAULT_FONT;

//课程表详细信息
var LESSON_INFO_FONTSIZE = 15;//默认大小字体
var LESSON_INFO_FAMILY = DEFAULT_FONT;
var LESSON_INFO_2FONTSIZE = 18; //大号字体
var LESSON_INFO_3FONTSIZE = 14; //第三行字体
var LESSON_MARGIN = 16;//间距

//课程列表字体配置
var LESSON_LIST_FONTSIZE = 16;
var LESSON_LIST_FAMILY = DEFAULT_FONT;
//星期字体配置
var WEEK_FAMILY = DEFAULT_FONT;
var WEEK_FONTSIZE = 18;
var WEEK_HIGHLIGHTCOLOR = "#7DBDFE";
var WEEK_BACKGROUND_COLOR = "black"

//星期字体设置
var WEEK_FONT_SIZE = 16;
var WEEK_FONT_BOLD = false;
var WEEK_FONT_FAMILY = DEFAULT_FONT
var WEEK_BRIGHT_COLOR = "#ff9000";//高亮颜色
var WEEK_DEFAULT_COLOR = "black";//默认颜色

//加载页面字体配置
var LOADING_FONTSIZE = 14;
var LOADING_FAMILY = DEFAULT_FONT;

//日历字体配置
var CALENDAR_FONTSIZE =12;
var CALENDAR_FAMILY = DEFAULT_FONT;

//设置字体配置
var SETTING_FONTSIZE =18;
var SETTING_FAMILY = DEFAULT_FONT;

//登陆页面字体配置
var LOGIN_FONTSIZE = 14;
var LOGIN_FAMILY = DEFAULT_FONT;

//分页字体配置
var PAGE_FONTSIZE = 16;
var PAGE_FAMILY =DEFAULT_FONT;

//退出提醒字体配置
var EXIT_FONTSIZE = 22;
var EXIT_FAMILY =DEFAULT_FONT;
var EXIT_BUTTON_FONTSIZE = 16;

//进入教室字体配置
var CLASSROOM_FONTSIZE = 12;
var CLASSROOM_FAMILY = DEFAULT_FONT;

//录播下载页面字体配置
var RECORD_FONTSIEZ = 12;
var RECORD_FAMILY =DEFAULT_FONT;

var liveView_gradefont=13

//下拉框字体配置
var COMBOX_FONTSIZIE = 16;
var COMBOX_FAMILY = DEFAULT_FONT;
var COMBOX_BACK_COLOR = "white"//背景颜色
var COMBOX_BODER_COLOR = "#d3d8dc" //边框颜色
var COMBOX_FONT_COLOR = "black"; //默认颜色
var COMBOX_FONT_HOVER ="#ff5000"//高亮颜色

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
            "05:55-06:35",
            "06:40-07:20",
            "07:30-08:10",
            "08:15-08:55",
            "09:00-09:40",
            "09:50-10:30",
            "10:35-11:15",
            "11:20-12:00",
            "12:45-13:25",
            "13:30-14:10",
            "14:15-14:55",
            "15:05-15:45",
            "15:50-16:30",
            "16:35-17:15",
            "18:00-18:40",
            "18:45-19:25",
            "19:30-20:10",
            "20:20-21:00",
            "21:05-21:45",
            "21:50-22:30",
            "22:35-23:15",
            "23:20-24:00"
        ]


function addZero(tmp){
    var fomartData;
    if(tmp < 10){
        fomartData = "0" + tmp;
    }else{
        fomartData = tmp;
    }
    return fomartData;
}

function getCurrentDates(){
    var date = new Date();
    var year = date.getFullYear();
    var month = Cfg.addZero(date.getMonth() + 1);
    var day = Cfg.addZero(date.getDate());
    return year + "-" + month + "-" + day ;
}
