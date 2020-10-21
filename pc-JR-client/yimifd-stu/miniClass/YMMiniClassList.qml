import QtQuick 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import QtWebEngine 1.4
import "./../Configuration.js" as Cfg
import YMMiniLessonManager 1.0

//我的课程
Item {
    id: myLessonView
    anchors.fill: parent
    signal sigCourseCatalog(var id,var dataJson);
    signal sigRoback();
    property int pageIndex: 1;//当前页
    property int pageSize: 6;//每页显示多少条数据
    property var widthRates: widthRate
    property bool bWebEngineViewNotGoBack: false; //控制: 在访问H5的部分页面的时候, 点击"返回"按钮, WebEngineView 不返回(即: 不goBack)
    property int iBtnIndex: 0; //记录当前选择的index (0: 首页, 1: 订单, 2: 我的)
    property bool bIsHomePage: false; //记录当前是否在首页,且不是首页中的子页面, 用来控制: "最近的课程快要开始上课了，立即 进入教室" 是否显示, 在"首页"中的子页, 也不要显示

    onVisibleChanged:{
        if(!visible)
        {
            myMiniClassList.resetPageView();
            myMiniClassList.visible = false;
        }
        else
        {
            //为了解决 JIRA BUG-1117, 这里需要reload以下
            webView.visible = false;
            webView.reload();
        }
    }

    property var tipDatas:({
                               isShow:false,       //控制"进入教室"按钮, 是否显示
                               executionPlanId:"",
                               handleStatus:""
                           });

    //翻页的底部工具栏
    YMPagingControl{
        id: pageView
        z: 2
        anchors.bottom: parent.bottom
        visible: false
        onPageChanged: {
            pageIndex = page;
            currentPage = pageIndex;
            refreshPage();
        }
        onPervPage: {
            pageIndex -= 1;
            currentPage = pageIndex;
            refreshPage();
        }
        onNextPage: {
            pageIndex += 1;
            currentPage = pageIndex;
            refreshPage();
        }
    }

    YMMiniLessonManager{
        id:miniLessonManager

        onSigJoinroomfail: {
            lodingView.visible = false;
            massgeTips.visible = true;
            massgeTips.tips = "进入教室失败!"
        }

        onSetDownValue: {
            progressbar.min = min;
            progressbar.max = max;
            progressbar.visible = true;
        }
        onDownloadChanged: {
            progressbar.currentValue = currentValue;
        }
        onDownloadFinished: {
            progressbar.visible = false;
        }

        onStudentLessonInfoChanged:
        {
            if(lessonInfo == null || lessonInfo.data == null || lessonInfo.data == undefined)
            {
                console.log("onStudentLessonInfoChanged lessonInfo == null")
                return;
            }

            talkCloudModel.clear();
            var objs = lessonInfo.data;
            var tArry = objs.list;

            var totalNumber = lessonInfo.data.total;//总多少条数据
            pageView.totalPage = Math.ceil(totalNumber / pageSize);

            console.log("totalNumbertotalNumber",totalNumber,pageView.totalPage)

            for(var i = 0; i < tArry.length; i++){
                talkCloudModel.append(
                            {
                                id: (i + 1).toString(),
                                courseId:tArry[i].courseId,
                                gradText: tArry[i].name,
                                price: tArry[i].price,
                                lessonImage: tArry[i].bigCoverUrl
                            });
            }
        }

        onStudentLesonListInfoChanged: {
            lessonItemDetail.resetDataModel(lessonInfo);
        }

        onMyMiniLessonInfoChanged: {
            lodingView.visible = false;
            myMiniClassList.resetDataModel(lessonInfo);
        }

        onEnterClassTips: {
            tipDatas = tipsData;
            //只有在"首页"的时候, 才显示"最近的课程快要开始上课了，立即 进入教室", 其它地方, 则隐藏掉
            if(iBtnIndex === 0 && bIsHomePage)
            {
                startClassText.visible = tipDatas.isShow;
                enterRoomText.visible = tipDatas.isShow;
            }

            console.log("dsdddddddd33333333", tipDatas.isShow, tipDatas.executionPlanId, tipsData.handleStatus)
        }
        onSigJoinClassroom: {
            if(status == "startClassroom"){
                lodingView.visible = true;
                lodingView.tips = "正在进入教室,请稍候..."
            }
            if(status == "finshClassroom"){
                lodingView.visible = false;
            }
        }
        onLessonlistRenewSignal: {
            requestData();
        }
    }

    YMMiniClassCloudRoom
    {
        id:coludWebviewT
        anchors.fill: parent
        z:1002
        visible: false
        onSigReBack: {
            console.log("====sigReBack=====")
            tipsExitClassroomView.visible = true;
        }
    }

    Connections{
        target: windowView
        onSigMiniClassReback:
        {
            coludWebviewT.visible = false;
            coludWebviewT.reBack();
            console.log("111组件点击信号发出1111111111")
        }
    }

    YMMiniClassDetail {
        id:lessonItemDetail
        anchors.fill: parent
        visible: false
        z:10
    }

//    YMMiniClassCloudRoom{
//        id: coludWebviewT
//        anchors.fill: parent
//        z:100
//        visible: false
//        onSigReBack: {
//            myMiniClassList.visible = true;
//            coludWebviewT.visible = false;
//            coludWebviewT.resetWebViewUrl("");
//        }
//    }


    //rowbar的背景色
    Rectangle{
        id: backgroudRec
        width: parent.width
        height: 30 * widthRates
        color:"#F9F9F9"
        radius: 10 * widthRate
        visible: rowBar.visible
        Rectangle{
            visible: !backArea.visible
            color: "#f9f9f9"
            width: parent.width
            height: 10
            anchors.bottom: parent.bottom
        }
    }

    Item{
        id: rowBar
        width: parent.width// * 0.855
        height: 30 * widthRates
        anchors.top: parent.top

        //返回按钮
        MouseArea{
            id: backArea
            visible: false
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked:
            {
                if(iBtnIndex != 2) //不是点击了"我的"按钮
                {
                    //"首页", "订单", 使用的是WebView
                    if(bWebEngineViewNotGoBack)
                    {
                        webView.runJavaScript("yimiNative_disableBack()"); //调用JS中的函数: yimiNative_disableBack()
                    }
                    else
                    {
                        webView.goBack();
                    }
                }
                else
                {
                    //点击了"我的"按钮
                    myMiniClassList.goBack();
                }
                console.log("=======================webView.goBack============", bWebEngineViewNotGoBack, webView.url, 5 * widthRates, tipDatas.isShow);
            }

            Image {
                width: 24 * widthRates
                height: 24 * widthRates
                anchors.top: parent.top
                anchors.topMargin: 5 * widthRates
                anchors.left: parent.left
                anchors.leftMargin: 5 * widthRates
                source: "qrc:/miniClassImg/xb_pc_btn_back@2x.png"
            }
        }

        Text {
            id:startClassText
            color:"#333333"
            anchors.top: parent.top
            anchors.topMargin: 8 * widthRates
            anchors.left: parent.left
            anchors.leftMargin: 30 * widthRates
            font.family: Cfg.LEAVE_FAMILY
            font.pixelSize: 11 * widthRates
            visible: tipDatas.isShow
            text: tipDatas.handleStatus == 1 ? qsTr("最近的课程快要开始上课了，立即") : tipDatas.handleStatus == 20 ? qsTr("有作业等待作答哦，立即") : "考试快要开始了，立即"
        }

        Text {
            id:enterRoomText
            color:"#338FFF"
            font.family: Cfg.LEAVE_FAMILY
            font.pixelSize: 11 * widthRates
            anchors.top: parent.top
            anchors.topMargin: 8 * widthRates
            anchors.left: startClassText.right
            anchors.leftMargin: 10 * widthRates
            text:tipDatas.handleStatus == 1 ? qsTr("进入教室 ->") : tipDatas.handleStatus == 20 ? "做答" : "去考试"
            font.underline: true
            visible: tipDatas.isShow

            MouseArea
            {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked:
                {
                    console.log("dsddddddddddddd111",tipDatas.executionPlanId,tipDatas.handleStatus)
                    if(tipDatas.handleStatus != 1)
                    {
                        coludWebviewT.resetWebViewUrl(miniLessonManager.getH5Url(tipDatas.executionPlanId,Number(tipDatas.handleStatus),"",""));
                        coludWebviewT.visible = true;

                    }else
                    {
                        //获取进入教室的Url
                        if(windowView.isPlatform == false){
                            var jsondataObj = miniLessonManager.getTalkEnterClass(tipDatas.executionPlanId,tipDatas.handleStatus)
                            var paths = jsondataObj.data[0].path;
                            windowView.isMiniClassroom = true;
                            coludWebviewT.resetWebViewUrl(paths);
                            coludWebviewT.visible = true;
                            return;
                        }

                        var tData = miniLessonManager.getEnterClass(tipDatas.executionPlanId);
                        if(tData.path == "" || tData.path == undefined)
                        {
                            return;
                        }

                        windowView.isMiniClassroom = true;
                        coludWebviewT.resetWebViewUrl(tData.path);
                        coludWebviewT.visible = true;

                    }
                }
            }
        }


        //==========================
        //"首页"图标+ 按钮
        MouseArea{
            id: homeArea
            width: 40 * widthRates
            height: ordTxt.height
            anchors.top: parent.top
            anchors.topMargin: 10 * widthRates
            anchors.right: lineRec_First.left
            anchors.rightMargin: 18 * widthRates
            visible: true

            Image {
                id: homeImg
                width: 12 * widthRates
                height: 12 * widthRates
                anchors.top: parent.top
                source: "qrc:/miniClassImg/xb_pc_btn_home_sed@2x.png"
            }

            Text{
                id: homeTxt
                anchors.left: homeImg.right
                anchors.leftMargin: 3 * widthRates
                anchors.top: parent.top
                anchors.topMargin: -2 * widthRates

                color:"#333333"
                font.family: Cfg.LEAVE_FAMILY
                font.pixelSize: 11 * widthRates
                text: "首页"
            }

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked:
            {
                setButtonColor(0);                
            }
        }

        //==========================
        //第一条竖线  |
        Rectangle{
            id: lineRec_First
            width: 2 * widthRates
            anchors.top: parent.top
            anchors.topMargin: 8 * widthRates
            anchors.right: orderArea.left
            anchors.rightMargin: 20 * widthRates
            color:"#F9F9F9"
            visible: true

            z: 666
            Text{
                anchors.fill: parent
                font.family: Cfg.LEAVE_FAMILY
                font.pixelSize: 11 * widthRates
                color:"#CCCCCC"
                text: "|"
            }
        }

        //==========================
        //"订单"图标+ 按钮
        MouseArea{
            id: orderArea
            width: 40 * widthRates
            height: ordTxt.height
            anchors.top: parent.top
            anchors.topMargin: 10 * widthRates
            anchors.right: lineRec_Second.left
            anchors.rightMargin: 18 * widthRates
            visible: true

            Image {
                id: orderImg
                width: 12 * widthRates
                height: 12 * widthRates
                anchors.top: parent.top
                source: "qrc:/miniClassImg/xb_pc_btn_order@2x.png"
            }

            Text{
                id: ordTxt
                anchors.left: orderImg.right
                anchors.leftMargin: 3 * widthRates
                anchors.top: parent.top
                anchors.topMargin: -2 * widthRates

                color:"#333333"
                font.family: Cfg.LEAVE_FAMILY
                font.pixelSize: 11 * widthRates
                text: "订单"
            }

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked:
            {
                setClickOrderButton();
            }
        }

        //==========================
        //第二条竖线  |
        Rectangle{
            id: lineRec_Second
            width: 2 * widthRates
            anchors.top: parent.top
            anchors.topMargin: 8 * widthRates
            anchors.right: mineArea.left
            anchors.rightMargin: 20 * widthRates
            color:"#F9F9F9"
            visible: true

            z: 666
            Text{
                anchors.fill: parent
                font.family: Cfg.LEAVE_FAMILY
                font.pixelSize: 11 * widthRates
                color:"#CCCCCC"
                text: "|"
            }
        }

        //==========================
        //"我的"图标+ 按钮
        MouseArea{
            id: mineArea
            width: 40 * widthRates
            height: mineTxt.height
            anchors.top: parent.top
            anchors.topMargin: 10 * widthRates
            anchors.right: parent.right
            anchors.rightMargin: 40 * widthRates

            Image {
                id: mineImg
                width: 12 * widthRates
                height: 12 * widthRates
                anchors.top: parent.top
                source: "qrc:/miniClassImg/xb_pc_btn_mine@2x.png"
            }

            Text{
                id: mineTxt
                width: 20 * widthRates
                anchors.left: mineImg.right
                anchors.leftMargin: 5 * widthRates
                anchors.top: parent.top
                anchors.topMargin: -2 * widthRates
                visible: true
                color:"#333333"
                font.family: Cfg.LEAVE_FAMILY
                font.pixelSize: 11 * widthRates
                text: "我的"
            }

            hoverEnabled: true
            z: 8888
            cursorShape: Qt.PointingHandCursor
            onClicked:
            {
                setButtonColor(2);
                miniLessonManager.getMiniLessonMyLesson("1","-1"); //获取: "我的"服务器的返回信息
            }
        }

    }


    Item{
        width: parent.width
        height: parent.height - rowBar.height - 10
        anchors.top: parent.top
        anchors.topMargin: rowBar.height//25
        anchors.horizontalCenter:parent.horizontalCenter

        onHeightChanged:{
            //webView.reload(); //为了控制在应用程序, 最大化, 还原的时候, webView的高度问题, 所以这里reload了一下
            //console.log("********message height*************", webView.url)
        }

        WebEngineView {
            id: webView
            height: parent.height
            width: parent.width
            clip: true

            //isShowTab=1 的时候, 才显示"订单", "我的"按钮, 并隐藏返回按钮, 相反
            //isShowTab=0, 或者没有的时候,隐藏"订单", "我的"按钮, 并显示返回按钮
            //url: "http://stage2-ymxb.yimifudao.com.cn/#/home?isShowTab=1"
            url:  URL_MiniClassHomePage + token + "&sp_userId=" + userId + "&sp_nickName=" + nickName + "&sp_mobileNo=" + mobileNo + "&sp_headPicture=" + windowView.headPicture + "&sp_userName=" + userName;

            //打印javascript消息
            onJavaScriptConsoleMessage:
            {
                //console.log("********message*************", message)
            }

            //右键的时候, 不弹出右键菜单
            onContextMenuRequested: function(request) {
                request.accepted = true;
            }

            onUrlChanged:
            {
                console.log("********onUrlChanged*************", url)
                if(myMiniClassList.visible) //如果当前, 选中的是"我的"(即: 不是"首页", 不是"订单"), 则直接返回
                {
                    return;
                }

                setOrderMineBarStatus(url);
            }

            onLoadingChanged: {
                //页面加载完成以后, 才显示出来, 避免因为reload的时候, 引起页面闪烁
                if(loadRequest.status == 2 && parent.visible) {
                    visible = true;
                }
            }
        }

        //"我的" view
        YMMyMiniClassList{
            id:myMiniClassList
            height: parent.height
            width: parent.width
            z:100
            visible: false
        }
    }

    ListModel{
        id: talkCloudModel
    }

    Component.onCompleted: {
        miniLessonManager.getMiniLessonList(pageIndex,pageSize);
        miniLessonManager.getEnterClassTips();
    }

    function refreshPage(){
        webView.reload();
        requestData();
    }

    function requestData(){
        if(iBtnIndex == 2){
            lodingView.visible = true;
            lodingView.tips = "页面加载中"
            if(backArea.visible){
                myMiniClassList.refreshPage();
            }else{
                miniLessonManager.getMiniLessonMyLesson("1","-1");
            }
        }
    }

    //菜单栏中继承的参数
    function queryData(){
        pageIndex = 1;
        pageView.currentPage = 1;
        miniLessonManager.getMiniLessonList(pageIndex,pageSize);
        miniLessonManager.getEnterClassTips();        
        setButtonColor(0);
        if(myMiniClassList.visible)
        {
            myMiniClassList.resetPageView();
            myMiniClassList.visible = false;
        }

        lessonItemDetail.visible = false;
    }

    //设置"订单", "我的"这一行的状态
    function setOrderMineBarStatus(url)
    {
        myMiniClassList.visible = false; //隐藏"我的"view
        bWebEngineViewNotGoBack = false;

        url = url.toString().replace(" ", ""); //删除空格
        var i = url.toString().match("isShowTab=1")
        console.log("********setOrderMineBarStatus*************", i, iBtnIndex, url)
        bIsHomePage = false;

        if(i === null)
        {
            console.log("********setOrderMineBarStatus*************11", i)
            //url中, 不存在字符串: "isShowTab=1"
            //则隐藏"订单", "我的"按钮等, 显示返回按钮, 修改背景色
            startClassText.visible = false;
            enterRoomText.visible = false;
            orderArea.visible = false;
            lineRec_Second.visible = false;
            lineRec_First.visible = false;
            homeArea.visible = false;
            mineArea.visible = false;
            backArea.visible = true; //返回按钮
            backgroudRec.color = "white";

            //==========================
            //如果URL中, 有这个字段: disableBack=1
            //那么点击返回按钮的时候, 就不返回了, 权限交给H5
            i = url.toString().match("disableBack=1")
            console.log("********setOrderMineBarStatus*************33", url, i)
            if(i !== null)
            {
                bWebEngineViewNotGoBack = true;
            }
        }
        else
        {
            console.log("********setOrderMineBarStatus22*************", i, tipDatas.isShow)
            //当前没有可以开始的课的时候, 就不需要显示了
            //miniLessonManager.getEnterClassTips(); //因为有个定时器, 在间断地调用, 所以这里就不调用了这个函数
            if(iBtnIndex === 0)
            {
                bIsHomePage = true;
                startClassText.visible = tipDatas.isShow;
                enterRoomText.visible = tipDatas.isShow;
            }
            else
            {
                startClassText.visible = false;
                enterRoomText.visible = false;
            }

            homeArea.visible = true;
            orderArea.visible = true;
            lineRec_Second.visible = true;
            lineRec_First.visible = true;
            mineArea.visible = true;
            backArea.visible = false; //返回按钮
            backgroudRec.color = "#F9F9F9";

            if(url.toString().match("orderList") !== null)
            {
                //从首页里面, 一步一步操作(扫描二维码, 完成支付, 点击"查看我的订单"), 这个时候, 应该选中"订单"按钮, 而不是停留在"首页"
                if(iBtnIndex == 0) //当前选中的是"首页"
                {
                    console.log("********setOrderMineBarStatus*************443")
                    setClickOrderButton();
                }
            }
        }
    }

    //设置"首页", "订单", "我的"按钮的状态
    function setButtonColor(iIndex)
    {
        console.log("============================setButtonColor", iIndex);

        iBtnIndex = iIndex;
        //=================================
        //初始状态
        homeTxt.color = "#333333";
        ordTxt.color = "#333333";
        mineTxt.color = "#333333";

        homeImg.source = "qrc:/miniClassImg/xb_pc_btn_home@2x.png";
        orderImg.source = "qrc:/miniClassImg/xb_pc_btn_order@2x.png";
        mineImg.source = "qrc:/miniClassImg/xb_pc_btn_mine@2x.png";

        //=================================
        //选中后的状态
        var showBtn = false; //只有在"首页"的时候, 才显示"最近的课程快要开始上课了，立即 进入教室", 其它地方, 则隐藏掉, jira BUG-658
        if(iIndex == 0) //首页
        {
            showBtn = true;
            coludWebviewT.visible = false;
            coludWebviewT.reBack();
            myMiniClassList.visible = false;
            webView.visible = true;
            homeTxt.color = "#FF5000";
            homeImg.source = "qrc:/miniClassImg/xb_pc_btn_home_sed@2x.png";
            webView.url = URL_MiniClassHomePage + token + "&sp_userId=" + userId + "&sp_nickName=" + nickName + "&sp_mobileNo=" + mobileNo + "&sp_headPicture=" + windowView.headPicture + "&sp_userName=" + userName;
        }
        else if(iIndex === 1) //订单
        {
            showBtn = false;
            myMiniClassList.visible = false;
            webView.visible = true;
            ordTxt.color = "#FF5000";
            orderImg.source = "qrc:/miniClassImg/xb_pc_btn_order_sed@2x.png";

        }
        else if(iIndex === 2) //我的
        {
            showBtn = false;
            myMiniClassList.visible = true;
            webView.visible = false;
            mineTxt.color = "#FF5000";
            mineImg.source = "qrc:/miniClassImg/xb_pc_btn_mine_sed@2x.png";
        }
        else
        {
            console.log("********setButtonColor*************", iIndex)
        }

        //只有在"首页"的时候, 才显示"最近的课程快要开始上课了，立即 进入教室", 其它地方, 则隐藏掉
        startClassText.visible = showBtn;
        enterRoomText.visible = showBtn;
    }

    //点击"订单"按钮后的操作
    //一个是用户点击"订单"按钮
    //一个是在"首页"里面点击"查看我的订单"以后, 需要切换至"订单"按钮
    function setClickOrderButton()
    {
        setButtonColor(1);
        webView.url = URL_MiniClassOrderList + token + "&sp_userId=" + userId + "&sp_nickName=" + nickName + "&sp_mobileNo=" + mobileNo + "&sp_headPicture=" + windowView.headPicture + "&sp_userName=" + userName;
    }
}
