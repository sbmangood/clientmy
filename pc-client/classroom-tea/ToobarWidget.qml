import QtQuick 2.5
import QtGraphicalEffects 1.0

/*
  * 工具栏
  */
Item {
    id:toobarWidget

    property double leftMidWidths: leftMidWidth / 66.0

    //比例系数
    property int rateMidWidth: 1

    //老师授权状态
    property bool teacherEmpowerment: true;
    //禁用按钮
    property bool disableButton: false;

    //设置画笔按钮的颜色
    property int  brushColor: -1

    //设置橡皮按钮的颜色
    property int  eraserColor: -1


    //用于检测的信息显示图片
    property int networkIcon: -1

    property int currentBeSelectIndex: 0;//当前的显示工具的索引位置

    //发送功能键
    signal sigSendFunctionKey(int keys);


    onTeacherEmpowermentChanged: {
        if(teacherEmpowerment) {
            // brushImage.source =  "qrc:/images/cr_btn_pen.png";
            handlBrushImageColor(brushColor);
            eraserImage.source =  "qrc:/newStyleImg/pc_tool_eraser@2x.png";
            magicfaceImage.source =  "qrc:/newStyleImg/pc_tool_emoji@2x.png";
            pictureImage.source =  "qrc:/newStyleImg/pc_tool_photo@2x.png";
            graphicImage.source =  "qrc:/newStyleImg/pc_tool_shape@2x.png";
            //pointerImage.source = "qrc:/images/cr_btn.png"
            pointerImage.source = "qrc:/newStyleImg/pc_tool_hand@2x.png"

        }else {
            brushImage.source =  "qrc:/newStyleImg/pc_tool_pen@2x.png";
            eraserImage.source =  "qrc:/newStyleImg/pc_tool_eraser@2x.png";
            magicfaceImage.source =  "qrc:/newStyleImg/pc_tool_emoji@2x.png";
            pictureImage.source =  "qrc:/newStyleImg/pc_tool_photo@2x.png";
            graphicImage.source =  "qrc:/newStyleImg/pc_tool_shape@2x.png";

        }
    }

    //处理橡皮的背景图片
    function handlEraserImageColor(eraserColors){
        handlBrushImageColor(-1);
        eraserColor = eraserColors;
        switch (eraserColors) {
        case 1:
            eraserImage.source =  "qrc:/newStyleImg/pc_tool_eraser_small_sed@2x.png";
            break;
        case 2:
            eraserImage.source =  "qrc:/newStyleImg/pc_tool_eraser_big_sed@2x.png";
            break;
        default:
            eraserImage.source =  "qrc:/newStyleImg/pc_tool_eraser@2x.png";
            break;
        }
        //pointerImage.source = "qrc:/images/cr_btn.png";
        pointerImage.source = "qrc:/newStyleImg/pc_tool_hand@2x.png"
    }
    //处理画笔的颜色的背景图片
    function handlBrushImageColor(brushColors){
        brushColor = brushColors;
        console.log("handlBrushImageColor",brushColors);
        if(brushColors != -1)
        {
            brushImage.source =  "qrc:/newStyleImg/pc_tool_pen_sed@2x.png";
        }else
        {
            brushImage.source =  "qrc:/newStyleImg/pc_tool_pen@2x.png";
            pointerImage.source = "qrc:/newStyleImg/pc_tool_hand@2x.png"
        }
        /*
        switch (brushColors) {
        case 0:
            brushImage.source =  "qrc:/images/cr_btn_pen_black.png";
            break;
        case 1:
            brushImage.source =  "qrc:/images/cr_btn_pen_red.png";
            break;
        case 2:
            brushImage.source =  "qrc:/images/cr_btn_pen_yellow.png";
            break;
        case 3:
            brushImage.source =  "qrc:/images/cr_btn_pen_blue.png";
            break;
        case 4:
            brushImage.source =  "qrc:/images/cr_btn_pen_grey.png";
            break;
        case 5:
            brushImage.source =  "qrc:/images/cr_btn_pen_purple.png";
            break;
        case 6:
            brushImage.source =  "qrc:/images/cr_btn_pen_green.png";
            break;
        case 7:
            brushImage.source =  "qrc:/images/cr_btn_pen_pink.png";
            break;
        default:
            brushImage.source =  "qrc:/images/cr_btn_pen.png";
            pointerImage.source = "qrc:/images/cr_btn.png";
            break;
        }
        */
    }


    onCurrentBeSelectIndexChanged:
    {
        console.log("onCurrentBeSelectIndexChanged",currentBeSelectIndex);
        if(currentBeSelectIndex != 6)
        {
            graphicImage.source =  "qrc:/newStyleImg/pc_tool_shape@2x.png";
        }else if(currentBeSelectIndex != 0)
        {
            brushImage.source =  "qrc:/newStyleImg/pc_tool_pen@2x.png";
        }
    }

    //主体窗口
    Item {
        id: container;
        anchors.centerIn: parent;
        width: parent.width;
        height: parent.height;
        z:2
        Rectangle {
            id: mainRect
            width: container.width - ( 2 * rectShadow.radius);
            height: container.height - ( 2 * rectShadow.radius);
            color: "#FFFFFF"
            //radius: rectShadow.radius;
            anchors.centerIn: parent;

            //logo图标
            Image {
                id: logIcon
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 10 *   leftMidWidths- rectShadow.radius;
                anchors.leftMargin: 8 *   leftMidWidths;
                width: parent.width - 18  *  leftMidWidths;
                height: parent.width
                fillMode:Image.PreserveAspectFit
                source: "qrc:/images/cr_logotwox.png"
            }

            //画刷按钮
            MouseArea{
                id:brush
                anchors.left: parent.left
                anchors.top: logIcon.bottom
                anchors.topMargin: 30 *  leftMidWidths
                anchors.leftMargin: 8 * leftMidWidths
                width: 35 * leftMidWidths
                height: 35 * leftMidWidths
                hoverEnabled: true
                enabled: disableButton

                Image {
                    id: brushImage
                    anchors.fill: parent
                    source: "qrc:/newStyleImg/pc_tool_pen@2x.png"
                    //source: teacherEmpowerment ?  "qrc:/images/cr_btn_pen.png" : "qrc:/images/cr_btn_pen_none.png"
                }

                onReleased: {
                    currentBeSelectIndex = 0;
                    if(toobarWidget.teacherEmpowerment) {
                        handlBrushImageColor(brushColor);
                        if(eraserColor != -1){
                            handlEraserImageColor(-1);
                        }
                        toobarWidget.sigSendFunctionKey(1);
                    }else {
                        brushImage.source =  "qrc:/newStyleImg/pc_tool_pen@2x.png";
                        //brushImage.source =  "qrc:/images/cr_btn_pen_none.png";
                    }
                }
                onContainsMouseChanged:
                {
                    if(containsMouse)
                    {
                        if(brushColor == -1){
                            brushImage.source =  "qrc:/newStyleImg/pc_tool_pen_sed@2x.png";
                            //brushImage.source =  "qrc:/images/cr_btn_pen_sed.png";
                        }else{
                            handlBrushImageColor(brushColor);
                        }
                    }else {
                        handlBrushImageColor(brushColor);
                        if(eraserColor != -1){
                            handlEraserImageColor(eraserColor);
                        }
                    }
                }
            }

            //教鞭
            MouseArea{
                id: pointersButton
                anchors.left: parent.left
                anchors.top: brush.bottom
                anchors.topMargin: 20 * leftMidWidths
                anchors.leftMargin: 8 * leftMidWidths
                width: 35 * leftMidWidths
                height:  35 * leftMidWidths
                hoverEnabled: true
                enabled: disableButton

                Image{
                    id: pointerImage
                    anchors.fill: parent
                    //source:  "qrc:/images/cr_btn.png"
                    source:  "qrc:/newStyleImg/pc_tool_hand@2x.png"
                }

                onReleased: {
                    currentBeSelectIndex = 1;
                    pointerImage.source = 'qrc:/newStyleImg/pc_tool_hand_sed@2x.png'
                    //pointerImage.source = 'qrc:/images/cr_btn_hand_selected.png'
                }

                onPressed: {
                    pointerImage.source = 'qrc:/newStyleImg/pc_tool_hand_sed@2x.png'
                    //pointerImage.source = 'qrc:/images/cr_btn_hand_hover.png'
                    toobarWidget.sigSendFunctionKey(7);
                    handlBrushImageColor(-1);
                    handlEraserImageColor(-1);
                }

                onContainsMouseChanged: {
                    if(containsMouse){
                        //pointerImage.source = 'qrc:/images/cr_btn_hand_hover.png'
                        pointerImage.source = 'qrc:/newStyleImg/pc_tool_hand_sed@2x.png'
                    }else{
                        //pointerImage.source = 'qrc:/images/cr_btn.png'
                        pointerImage.source = "qrc:/newStyleImg/pc_tool_hand@2x.png"
                    }
                }
            }

            //橡皮按钮
            MouseArea{
                id:eraser
                anchors.left: parent.left
                anchors.top: pointersButton.bottom
                anchors.topMargin: 18 * leftMidWidths
                anchors.leftMargin: 8 * leftMidWidths
                width: 35 * leftMidWidths
                height:  35 *  leftMidWidths
                hoverEnabled: true
                enabled: disableButton

                Image {
                    id: eraserImage
                    anchors.fill: parent
                    source: "qrc:/newStyleImg/pc_tool_eraser@2x.png"
                }

                onPressed: {
                    if(eraserColor == -1){
                        eraserImage.source = "qrc:/newStyleImg/pc_tool_eraser_sed@2x.png";
                    }
                }

                onReleased: {
                    currentBeSelectIndex = 2;
                    if(eraserColor == -1){
                        eraserImage.source = "qrc:/newStyleImg/pc_tool_eraser@2x.png";
                    }

                    if(toobarWidget.teacherEmpowerment) {
                        toobarWidget.sigSendFunctionKey(2);
                    }
                }

                onContainsMouseChanged: {
                    if(containsMouse)
                    {
                        if(toobarWidget.teacherEmpowerment) {
                            if(eraserColor == -1){
                                eraserImage.source = "qrc:/newStyleImg/pc_tool_eraser_sed@2x.png";
                            }
                        }else {
                            eraserImage.source =  "qrc:/newStyleImg/pc_tool_eraser@2x.png";
                        }
                    }else
                    {
                        if(toobarWidget.teacherEmpowerment) {
                            if(eraserColor == -1){
                                eraserImage.source = "qrc:/newStyleImg/pc_tool_eraser@2x.png";
                            }
                        }else {
                            eraserImage.source =  "qrc:/newStyleImg/pc_tool_eraser@2x.png";
                        }
                    }
                }
            }

            //回撤
            MouseArea{
                id: audoButton
                anchors.left: parent.left
                anchors.top: eraser.bottom
                anchors.topMargin: 20 * leftMidWidths
                anchors.leftMargin: 8 * leftMidWidths
                width: 35 * leftMidWidths
                height:  35 * leftMidWidths
                hoverEnabled: true
                enabled: disableButton

                Image{
                    id: audoImage
                    anchors.fill: parent
                    source:  "qrc:/newStyleImg/pc_tool_back@2x.png"
                }
                onReleased: {
                    audoImage.source = "qrc:/newStyleImg/pc_tool_back@2x.png";
                }

                onPressed: {
                    currentBeSelectIndex = 3;
                    audoImage.source = "qrc:/newStyleImg/pc_tool_back_sed@2x.png";
                    sigSendFunctionKey(8);
                }
                onContainsMouseChanged: {
                    if(containsMouse){
                        audoImage.source = "qrc:/newStyleImg/pc_tool_back_sed@2x.png";
                    }else{
                        audoImage.source = "qrc:/newStyleImg/pc_tool_back@2x.png";
                    }
                }
            }

            //表情按钮
            MouseArea{
                id:magicface
                anchors.left: parent.left
                anchors.top: audoButton.bottom
                anchors.topMargin: 20 * leftMidWidths
                anchors.leftMargin: 8 * leftMidWidths
                width: 35 * leftMidWidths
                height:  35 * leftMidWidths
                enabled: disableButton
                Image {
                    id: magicfaceImage
                    anchors.fill: parent
                    source: "qrc:/newStyleImg/pc_tool_emoji@2x.png"
                }
                hoverEnabled: true
                onPressed: {
                    if(toobarWidget.teacherEmpowerment) {
                        magicfaceImage.source =  "qrc:/newStyleImg/pc_tool_emoji_sed@2x.png";
                        toobarWidget.sigSendFunctionKey(3);
                    }else {
                        magicfaceImage.source =  "qrc:/newStyleImg/pc_tool_emoji@2x.png";
                    }
                }
                onReleased: {
                    currentBeSelectIndex = 4;
                    magicfaceImage.source =  "qrc:/newStyleImg/pc_tool_emoji@2x.png";
                }
                onContainsMouseChanged: {
                    if(containsMouse){
                        magicfaceImage.source =  "qrc:/newStyleImg/pc_tool_emoji_sed@2x.png";

                    }else {
                        magicfaceImage.source =  "qrc:/newStyleImg/pc_tool_emoji@2x.png";
                    }
                }

            }

            //截图按钮
            MouseArea{
                id:picture
                anchors.left: parent.left
                anchors.top: magicface.bottom
                anchors.topMargin: 20 * leftMidWidths
                anchors.leftMargin: 8 * leftMidWidths
                width: 35 *  leftMidWidths
                height:  35 * leftMidWidths
                enabled: disableButton
                Image {
                    id: pictureImage
                    anchors.fill: parent
                    source: "qrc:/newStyleImg/pc_tool_photo@2x.png"
                }
                hoverEnabled: true
                onPressed: {
                    if(toobarWidget.teacherEmpowerment) {
                        pictureImage.source =  "qrc:/newStyleImg/pc_tool_photo_sed@2x.png";
                    }else {
                        pictureImage.source =  "qrc:/newStyleImg/pc_tool_photo@2x.png";
                    }
                }
                onReleased: {
                    currentBeSelectIndex = 5;
                    if(toobarWidget.teacherEmpowerment) {
                        pictureImage.source =  "qrc:/newStyleImg/pc_tool_photo@2x.png";
                        toobarWidget.sigSendFunctionKey(4);
                    }else {
                        pictureImage.source =  "qrc:/newStyleImg/pc_tool_photo@2x.png";
                    }
                }
                onContainsMouseChanged: {
                    if(containsMouse){
                        pictureImage.source =  "qrc:/newStyleImg/pc_tool_photo_sed@2x.png";
                    }else  {
                        pictureImage.source =  "qrc:/newStyleImg/pc_tool_photo@2x.png";
                    }
                }
            }

            //几何按钮
            MouseArea{
                id:graphic
                anchors.left: parent.left
                anchors.top: picture.bottom
                anchors.topMargin: 20 * leftMidWidths
                anchors.leftMargin: 8 * leftMidWidths
                width: 35 * leftMidWidths
                height:  35 *leftMidWidths
                enabled: disableButton
                Image {
                    id: graphicImage
                    anchors.fill: parent
                    source: "qrc:/newStyleImg/pc_tool_shape@2x.png"
                }
                hoverEnabled: true
                onPressed: {
                    if(toobarWidget.teacherEmpowerment) {
                        graphicImage.source =  "qrc:/newStyleImg/pc_tool_shape_sed@2x.png";
                    }else {
                        graphicImage.source =  "qrc:/newStyleImg/pc_tool_shape@2x.png";
                    }
                }
                onReleased: {
                    currentBeSelectIndex = 6;
                    if(toobarWidget.teacherEmpowerment) {
                        graphicImage.source =  "qrc:/newStyleImg/pc_tool_shape_sed@2x.png";
                        toobarWidget.sigSendFunctionKey(5);
                    }else {
                        graphicImage.source =  "qrc:/newStyleImg/pc_tool_shape@2x.png";
                    }
                }
                onContainsMouseChanged: {
                    if(containsMouse || currentBeSelectIndex == 6) {
                        graphicImage.source =  "qrc:/newStyleImg/pc_tool_shape_sed@2x.png";
                    }else
                    {
                        graphicImage.source =  "qrc:/newStyleImg/pc_tool_shape@2x.png";
                    }

                }
            }

            Item{
                id: itemView
                width: parent.width
                height: 67 * heightRate * 2
                anchors.left: parent.left
                anchors.bottom:  testBtn.top
                visible: false
                Image{
                    anchors.fill: parent
                    source: "qrc:/images/workback.png"
                }

                //网络优化
                MouseArea{
                    id:netWorkInfor
                    anchors.left: parent.left
                    anchors.bottom:  parent.bottom
                    width: parent.width
                    height: 67 * heightRate
                    hoverEnabled: true

                    Image {
                        id: netWorkInforImage
                        anchors.left: parent.left
                        anchors.bottom:  parent.bottom
                        anchors.bottomMargin: 36 * heightRate
                        width: 26 * heightRate
                        height: 26 * heightRate
                        anchors.leftMargin: parent.width * 0.5 - 13 * heightRate
                        source: networkIcon == 1 ? "qrc:/newStyleImg/pc_tool_wifigood@2x.png" : (networkIcon == 2 ? "qrc:/newStyleImg/pc_tool_wifiok@2x.png" : "qrc:/newStyleImg/pc_tool_wifibad@2x.png")
                    }

                    Text {
                        id: netWorkInforText
                        anchors.left: parent.left
                        anchors.bottom:  parent.bottom
                        anchors.bottomMargin: 17 * heightRate
                        width: parent.width
                        height:  14 * heightRate
                        font.pixelSize: 12 * heightRate
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Microsoft YaHei"
                        color: parent.containsMouse ? "#ff6633" : "#666673"
                        text: qsTr("网络优化")
                    }

                    onReleased: {
                        toobarWidget.sigSendFunctionKey(6);
                        itemView.visible = false;
                    }

                }

                //工单
                MouseArea{
                    id: workView
                    anchors.left: parent.left
                    anchors.bottom:  netWorkInfor.top
                    width: parent.width
                    height: 67 * heightRate
                    hoverEnabled: true
                    Rectangle{
                        height: 1 * heightRate
                        width: parent.width
                        color: "white"
                        anchors.bottom: parent.bottom
                    }
                    Image{
                        anchors.left: parent.left
                        anchors.bottom:  parent.bottom
                        anchors.bottomMargin: 36 * heightRate
                        width: 26 * heightRate
                        height: 26 * heightRate
                        anchors.leftMargin: parent.width * 0.5 - 13 * heightRate
                        source: parent.containsMouse ? "qrc:/newStyleImg/pc_tool_techlist_sed@2x.png" : "qrc:/newStyleImg/pc_tool_techlist@2x.png"
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.bottom:  parent.bottom
                        anchors.bottomMargin: 17 * heightRate
                        width: parent.width
                        height:  14 * heightRate
                        font.pixelSize: 12 * heightRate
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Microsoft YaHei"
                        color: parent.containsMouse ? "#ff5000" : "#666673"
                        text: qsTr("技术工单")
                    }
                    onClicked: {
                        itemView.visible = false;
                        toobarWidget.sigSendFunctionKey(9);
                    }
                }
            }

            //检测按键
            MouseArea{
                id:testBtn
                anchors.left: parent.left
                anchors.bottom:  parent.bottom
                width: parent.width
                height: parent.width
                enabled: disableButton

                Image {
                    id: testBtnImage
                    anchors.fill: parent
                    fillMode:Image.PreserveAspectFit
                    source: parent.containsMouse ?  "qrc:/images/cr_btn_more_sed.png" : "qrc:/images/cr_btn_more.png"
                }
                hoverEnabled: true
                onReleased: {
                    itemView.visible = !itemView.visible
                }
            }
        }
    }

    MouseArea{
        anchors.fill: parent
        z:1
        onClicked: {
            toobarWidget.focus = true;
        }
    }

    //绘制阴影
    DropShadow {
        id: rectShadow;
        anchors.fill: source
        cached: true;
        horizontalOffset: 0;
        verticalOffset: 0;
        radius: 6.0 * leftMidWidths
        samples: 16;
        color: "#60000000";
        smooth: true;
        source: container;
    }


}

