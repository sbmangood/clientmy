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
    //开始练习禁用按钮
    property bool disableButton: true;

    //设置画笔按钮的颜色
    property int  brushColor: -1

    //设置橡皮按钮的颜色
    property int  eraserColor: -1


    //用于检测的信息显示图片
    property int networkIcon: -1

    //发送功能键
    signal sigSendFunctionKey(int keys);


    onTeacherEmpowermentChanged: {
        if(teacherEmpowerment) {
            // brushImage.source =  "qrc:/images/cr_btn_pen.png";
            handlBrushImageColor(brushColor);
            eraserImage.source =  "qrc:/images/cr_btn_clear.png";
            magicfaceImage.source =  "qrc:/images/cr_btn_emoji.png";
            pictureImage.source =  "qrc:/images/cr_btn_pic.png";
            graphicImage.source =  "qrc:/images/cr_btn_shape.png";
            pointerImage.source = "qrc:/images/cr_btn.png"

        }else {
            brushImage.source =  "qrc:/images/cr_btn_pen_none.png";
            eraserImage.source =  "qrc:/images/cr_btn_clear_none.png";
            magicfaceImage.source =  "qrc:/images/cr_btn_emoji_none.png";
            pictureImage.source =  "qrc:/images/cr_btn_pic_none.png";
            graphicImage.source =  "qrc:/images/cr_btn_shape_none.png";

        }
    }

    //处理橡皮的背景图片
    function handlEraserImageColor(eraserColors){
        handlBrushImageColor(-1);
        eraserColor = eraserColors;
        switch (eraserColors) {
        case 1:
            eraserImage.source =  "qrc:/images/cr_btn_clear_s_sed.png";
            break;
        case 2:
            eraserImage.source =  "qrc:/images/cr_btn_clear_clicked.png";
            break;
        default:
            eraserImage.source =  "qrc:/images/cr_btn_clear.png";
            break;
        }
        pointerImage.source = "qrc:/images/cr_btn.png";
    }
    //处理画笔的颜色的背景图片
    function handlBrushImageColor(brushColors){
        brushColor = brushColors;
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

            radius: rectShadow.radius;
            anchors.centerIn: parent;

            //logo图标
            Image {
                id: logIcon
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 20 *   leftMidWidths- rectShadow.radius;
                anchors.leftMargin: 10 *   leftMidWidths;
                width: parent.width - 20  *  leftMidWidths;
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
                anchors.leftMargin: 20 * leftMidWidths
                width: 28 * leftMidWidths
                height:  28 * leftMidWidths
                hoverEnabled: true
                enabled: disableButton

                Image {
                    id: brushImage
                    anchors.fill: parent
                    source: teacherEmpowerment ?  "qrc:/images/cr_btn_pen.png" : "qrc:/images/cr_btn_pen_none.png"
                }

                onReleased: {
                    if(toobarWidget.teacherEmpowerment) {
                        handlBrushImageColor(brushColor);
                        if(eraserColor != -1){
                            handlEraserImageColor(-1);
                        }
                        toobarWidget.sigSendFunctionKey(1);
                    }else {
                        brushImage.source =  "qrc:/images/cr_btn_pen_none.png";
                    }
                }
                onContainsMouseChanged:
                {
                    if(containsMouse)
                    {
                        if(brushColor == -1){
                            brushImage.source =  "qrc:/images/cr_btn_pen_sed.png";
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
                anchors.topMargin: 30 * leftMidWidths
                anchors.leftMargin: 20 * leftMidWidths
                width: 28 * leftMidWidths
                height:  28 * leftMidWidths
                hoverEnabled: true
                enabled: disableButton

                Image{
                    id: pointerImage
                    anchors.fill: parent
                    source:  "qrc:/images/cr_btn.png"
                }
                onReleased: {
                    pointerImage.source = 'qrc:/images/cr_btn_hand_selected.png'
                }
                onPressed: {
                    pointerImage.source = 'qrc:/images/cr_btn_hand_hover.png'
                    toobarWidget.sigSendFunctionKey(7);
                    handlBrushImageColor(-1);
                    handlEraserImageColor(-1);
                }
                onContainsMouseChanged: {
                    if(containsMouse){
                        pointerImage.source = 'qrc:/images/cr_btn_hand_hover.png'
                    }else{
                        pointerImage.source = 'qrc:/images/cr_btn.png'
                    }
                }
            }

            //橡皮按钮
            MouseArea{
                id:eraser
                anchors.left: parent.left
                anchors.top: pointersButton.bottom
                anchors.topMargin: 30 * leftMidWidths
                anchors.leftMargin: 20 * leftMidWidths
                width: 28 * leftMidWidths
                height:  28 *  leftMidWidths
                hoverEnabled: true
                enabled: disableButton

                Image {
                    id: eraserImage
                    anchors.fill: parent
                    source: teacherEmpowerment  ?   "qrc:/images/cr_btn_clear.png" : "qrc:/images/cr_btn_clear_none.png"
                }

                onPressed: {
                    if(eraserColor == -1){
                        eraserImage.source = "qrc:/images/cr_btn_clear_clicked.png";
                    }
                }

                onReleased: {
                    if(eraserColor == -1){
                        eraserImage.source = "qrc:/images/cr_btn_clear.png";
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
                                eraserImage.source = "qrc:/images/cr_btn_clear_clicked.png";
                            }
                        }else {
                            eraserImage.source =  "qrc:/images/cr_btn_clear_none.png";
                        }
                    }else
                    {
                        if(toobarWidget.teacherEmpowerment) {
                            if(eraserColor == -1){
                                eraserImage.source = "qrc:/images/cr_btn_clear.png";
                            }
                        }else {
                            eraserImage.source =  "qrc:/images/cr_btn_clear_none.png";
                        }
                    }
                }
            }

            //回撤
            MouseArea{
                id: audoButton
                anchors.left: parent.left
                anchors.top: eraser.bottom
                anchors.topMargin: 30 * leftMidWidths
                anchors.leftMargin: 20 * leftMidWidths
                width: 28 * leftMidWidths
                height:  28 * leftMidWidths
                hoverEnabled: true
                enabled: disableButton

                Image{
                    id: audoImage
                    anchors.fill: parent
                    source:  "qrc:/images/cr_btn_back.png"
                }
                onReleased: {
                    audoImage.source = "qrc:/images/cr_btn_back.png";
                }

                onPressed: {
                    audoImage.source = "qrc:/images/cr_btn_back_click.png";
                    sigSendFunctionKey(8);
                }
                onContainsMouseChanged: {
                    if(containsMouse){
                        audoImage.source = "qrc:/images/cr_btn_back_hover.png";
                    }else{
                        audoImage.source = "qrc:/images/cr_btn_back.png";
                    }
                }
            }

            //表情按钮
            MouseArea{
                id:magicface
                anchors.left: parent.left
                anchors.top: audoButton.bottom
                anchors.topMargin: 30 * leftMidWidths
                anchors.leftMargin: 20 * leftMidWidths
                width: 28 * leftMidWidths
                height:  28 * leftMidWidths
                enabled: disableButton
                Image {
                    id: magicfaceImage
                    anchors.fill: parent
                    source: teacherEmpowerment ? "qrc:/images/cr_btn_emoji.png" :"qrc:/images/cr_btn_emoji_none.png"
                }
                hoverEnabled: true
                onPressed: {
                    if(toobarWidget.teacherEmpowerment) {
                        magicfaceImage.source =  "qrc:/images/cr_btn_emoji_sed.png";
                        toobarWidget.sigSendFunctionKey(3);
                    }else {
                        magicfaceImage.source =  "qrc:/images/cr_btn_emoji_none.png";
                    }
                }
                onReleased: {
                    if(toobarWidget.teacherEmpowerment) {
                        magicfaceImage.source =  "qrc:/images/cr_btn_emoji.png";
                    }else {
                        magicfaceImage.source =  "qrc:/images/cr_btn_emoji_none.png";
                    }
                }
                onContainsMouseChanged: {
                    if(containsMouse){
                        magicfaceImage.source =  "qrc:/images/cr_btn_emoji_sed.png";

                    }else {
                        magicfaceImage.source =  "qrc:/images/cr_btn_emoji.png";
                    }
                }

            }

            //截图按钮
            MouseArea{
                id:picture
                anchors.left: parent.left
                anchors.top: magicface.bottom
                anchors.topMargin: 30 * leftMidWidths
                anchors.leftMargin: 20 * leftMidWidths
                width: 28 *  leftMidWidths
                height:  28 * leftMidWidths
                enabled: disableButton
                Image {
                    id: pictureImage
                    anchors.fill: parent
                    source: teacherEmpowerment ? "qrc:/images/cr_btn_pic.png" : "qrc:/images/cr_btn_pic_none.png"
                }
                hoverEnabled: true
                onPressed: {
                    if(toobarWidget.teacherEmpowerment) {
                        pictureImage.source =  "qrc:/images/cr_btn_pic_sed.png";
                    }else {
                        pictureImage.source =  "qrc:/images/cr_btn_pic_none.png";
                    }
                }
                onReleased: {
                    if(toobarWidget.teacherEmpowerment) {
                        pictureImage.source =  "qrc:/images/cr_btn_pic.png";
                        toobarWidget.sigSendFunctionKey(4);
                    }else {
                        pictureImage.source =  "qrc:/images/cr_btn_pic_none.png";
                    }
                }
                onContainsMouseChanged: {
                    if(containsMouse){
                        pictureImage.source =  "qrc:/images/cr_btn_pic_sed.png";
                    }else  {
                        pictureImage.source =  "qrc:/images/cr_btn_pic.png";
                    }
                }
            }

            //几何按钮
            MouseArea{
                id:graphic
                anchors.left: parent.left
                anchors.top: picture.bottom
                anchors.topMargin: 30 * leftMidWidths
                anchors.leftMargin: 20 * leftMidWidths
                width: 28 * leftMidWidths
                height:  28 *leftMidWidths
                enabled: disableButton
                Image {
                    id: graphicImage
                    anchors.fill: parent
                    source: teacherEmpowerment ? "qrc:/images/cr_btn_shape.png" : "qrc:/images/cr_btn_shape_none.png"
                }
                hoverEnabled: true
                onPressed: {
                    if(toobarWidget.teacherEmpowerment) {
                        graphicImage.source =  "qrc:/images/cr_btn_shape_sed.png";
                    }else {
                        graphicImage.source =  "qrc:/images/cr_btn_shape_none.png";
                    }
                }
                onReleased: {
                    if(toobarWidget.teacherEmpowerment) {
                        graphicImage.source =  "qrc:/images/cr_btn_shape.png";
                        toobarWidget.sigSendFunctionKey(5);
                    }else {
                        graphicImage.source =  "qrc:/images/cr_btn_shape_none.png";
                    }
                }
                onContainsMouseChanged: {
                    if(containsMouse) {
                        graphicImage.source =  "qrc:/images/cr_btn_shape_sed.png";
                    }else{
                        graphicImage.source =  "qrc:/images/cr_btn_shape.png";
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
                        width: 16 * heightRate
                        height: 16 * heightRate
                        anchors.leftMargin: parent.width * 0.5 - 8 * heightRate
                        source: networkIcon == 1 ? "qrc:/images/icon_good.png" : (networkIcon == 2 ? "qrc:/images/icon_ok.png" : "qrc:/images/icon_bad.png")
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
                        width: 16 * heightRate
                        height: 16 * heightRate
                        anchors.leftMargin: parent.width * 0.5 - 8 * heightRate
                        source: parent.containsMouse ? "qrc:/images/workImage.png" : "qrc:/images/th_icon_jishugongdan@2x.png"
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

