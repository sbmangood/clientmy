import QtQuick 2.7
import QtGraphicalEffects 1.0


/*
  * 工具栏
  */
Rectangle {
    id:toobarWidget


    //比例系数
    property int rateMidWidth: 1
    //老师授权状态
    property bool teacherEmpowerment: true
    color: "#00000000"

    //设置画笔按钮的颜色
    property int  brushColor: -1

    //设置橡皮按钮的颜色
    property int  eraserColor: -1


    //用于检测的信息显示图片
    property int networkIcon: -1

    //发送功能键
    signal sigSendFunctionKey(int keys);

    //发送暂未权限操作提示
    signal noSelectPower();


    onTeacherEmpowermentChanged: {
        console.log("teacherEmpowerment",teacherEmpowerment)
        if(teacherEmpowerment) {
            // brushImage.source =  "qrc:/images/cr_btn_pen.png";
            handlBrushImageColor(brushColor);
            eraserImage.source =  "qrc:/images/cr_btn_clear.png";
            magicfaceImage.source =  "qrc:/images/cr_btn_emoji.png";
            pictureImage.source =  "qrc:/images/cr_btn_pic.png";
            graphicImage.source =  "qrc:/images/cr_btn_shape.png";

        }else {
            brushImage.source =  "qrc:/images/cr_btn_pen_none.png";
            eraserImage.source =  "qrc:/images/cr_btn_clear_none.png";
            magicfaceImage.source =  "qrc:/images/cr_btn_emoji_none.png";
            pictureImage.source =  "qrc:/images/cr_btn_pic_none.png";
            graphicImage.source =  "qrc:/images/cr_btn_shape_none.png";

        }
    }

    //处理画笔的颜色的背景图片
    function handlEraserImageColor(eraserColors){
        handlBrushImageColor(-1);
        eraserColor = eraserColors;
        switch (eraserColors) {
        case 1:
            eraserImage.source =  "qrc:/images/cr_btn_clearsmall_selected.png";
            break;
        case 2:
            eraserImage.source =  "qrc:/images/cr_btn_clearbig_selected.png";
            break;
        default:
            eraserImage.source =  "qrc:/images/cr_btn_clear.png";
            break;
        }

    }
    //处理画笔的颜色的背景图片
    function handlBrushImageColor(brushColors){
        if(teacherEmpowerment == false)
        {
            return;
        }

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
            width: container.width - ( 2*rectShadow.radius);
            height: container.height - ( 2*rectShadow.radius);

            radius: rectShadow.radius;
            anchors.centerIn: parent;

            //图标
            Image {
                id: logIcon
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 20 *   leftMidWidth / 66.0- rectShadow.radius;
                anchors.leftMargin: 10 *   leftMidWidth / 66.0;
                width: parent.width - 20  *    leftMidWidth / 66.0;
                height: parent.width
                fillMode:Image.PreserveAspectFit
                source: "qrc:/images/cr_logotwox.png"
            }

            //画刷按钮
            Rectangle{
                id:brush
                anchors.left: parent.left
                anchors.top: logIcon.bottom
                anchors.topMargin: 30 *  leftMidWidth / 66.0
                anchors.leftMargin: 20 *  leftMidWidth / 66.0
                width: 28 *  leftMidWidth / 66.0
                height:  28 *  leftMidWidth / 66.0
                color: "#00000000"
                Image {
                    id: brushImage
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: parent.width
                    height: parent.height
                    source: teacherEmpowerment ?  "qrc:/images/cr_btn_pen.png" : "qrc:/images/cr_btn_pen_none.png"
                }
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
//                    onPressed: {
//                        if(toobarWidget.teacherEmpowerment) {
//                            brushImage.source =  "qrc:/images/cr_btn_pen_sed.png";
//                        }else {
//                            brushImage.source =  "qrc:/images/cr_btn_pen_none.png";

//                        }


//                    }
                    onReleased: {
                        if(toobarWidget.teacherEmpowerment) {
                            //  brushImage.source =  "qrc:/images/cr_btn_pen.png";
                            handlBrushImageColor(brushColor);
                            if(eraserColor != -1){
                                handlEraserImageColor(-1);
                            }
                            toobarWidget.sigSendFunctionKey(1);
                        }else {

                            brushImage.source =  "qrc:/images/cr_btn_pen_none.png";
                            noSelectPower();
                        }

                    }
                    onContainsMouseChanged:
                    {
                        if(containsMouse)
                        {
                            if(toobarWidget.teacherEmpowerment) {
                                if(brushColor == -1)
                                {
                                    brushImage.source =  "qrc:/images/cr_btn_pen_sed.png";
                                }else
                                {
                                    handlBrushImageColor(brushColor);
                                }
                            }else {
                                brushImage.source =  "qrc:/images/cr_btn_pen_none.png";

                            }

                        }else
                        {
                            if(toobarWidget.teacherEmpowerment) {
                                //  brushImage.source =  "qrc:/images/cr_btn_pen.png";
                                handlBrushImageColor(brushColor);
                                if(eraserColor != -1){
                                    handlEraserImageColor(eraserColor);
                                }
                                //toobarWidget.sigSendFunctionKey(1);
                            }else {

                                brushImage.source =  "qrc:/images/cr_btn_pen_none.png";
                                //noSelectPower();
                            }
                        }
                    }

                }

            }

            //橡皮按钮
            Rectangle{
                id:eraser
                anchors.left: parent.left
                anchors.top: brush.bottom
                anchors.topMargin: 30 * leftMidWidth / 66.0
                anchors.leftMargin: 20 *  leftMidWidth / 66.0
                width: 28 *  leftMidWidth / 66.0
                height:  28 *  leftMidWidth / 66.0
                color: "#00000000"

                Image {
                    id: eraserImage
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: parent.width
                    height: parent.height
                    source: teacherEmpowerment ? "qrc:/images/cr_btn_clear.png" : "qrc:/images/cr_btn_clear_none.png"
                }
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onPressed: {
                        if(toobarWidget.teacherEmpowerment) {
                            if(eraserColor == -1){
                                eraserImage.source = "qrc:/images/cr_btn_clear_clicked.png";
                            }
                        }else {
                            eraserImage.source =  "qrc:/images/cr_btn_clear_none.png";

                        }

                    }
                    onReleased: {
                        if(toobarWidget.teacherEmpowerment) {
                            if(eraserColor == -1){
                                eraserImage.source = "qrc:/images/cr_btn_clear.png";
                            }
                            toobarWidget.sigSendFunctionKey(2);
                        }else {
                            eraserImage.source =  "qrc:/images/cr_btn_clear_none.png";
                            noSelectPower();
                        }


                    }
                    onContainsMouseChanged:
                    {
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
                                //toobarWidget.sigSendFunctionKey(2);
                            }else {
                                eraserImage.source =  "qrc:/images/cr_btn_clear_none.png";
                                //noSelectPower();
                            }
                        }
                    }


                }

            }



            //表情按钮
            Rectangle{
                id:magicface
                anchors.left: parent.left
                anchors.top: eraser.bottom
                anchors.topMargin: 30 *  leftMidWidth / 66.0
                anchors.leftMargin: 20 *  leftMidWidth / 66.0
                width: 28 *  leftMidWidth / 66.0
                height:  28 *  leftMidWidth / 66.0
                color: "#00000000"
                Image {
                    id: magicfaceImage
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: parent.width
                    height: parent.height
                    source: teacherEmpowerment ? "qrc:/images/cr_btn_emoji.png" :"qrc:/images/cr_btn_emoji_none.png"
                }
                MouseArea{
                    anchors.fill: parent
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
                            noSelectPower();
                        }
                    }
                    onContainsMouseChanged:
                    {
                        if(containsMouse)
                        {
                            if(toobarWidget.teacherEmpowerment) {
                                magicfaceImage.source =  "qrc:/images/cr_btn_emoji_sed.png";
                                //toobarWidget.sigSendFunctionKey(3);
                            }else {
                                magicfaceImage.source =  "qrc:/images/cr_btn_emoji_none.png";
                            }
                        }else
                        {
                            if(toobarWidget.teacherEmpowerment) {
                                magicfaceImage.source =  "qrc:/images/cr_btn_emoji.png";
                            }else {
                                magicfaceImage.source =  "qrc:/images/cr_btn_emoji_none.png";
                                // noSelectPower();
                            }
                        }
                    }

                }
            }



            //截图按钮
            Rectangle{
                id:picture
                anchors.left: parent.left
                anchors.top: magicface.bottom
                anchors.topMargin: 30 *  leftMidWidth / 66.0
                anchors.leftMargin: 20 * leftMidWidth / 66.0
                width: 28 *  leftMidWidth / 66.0
                height:  28 *  leftMidWidth / 66.0
                color: "#00000000"
                Image {
                    id: pictureImage
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: parent.width
                    height: parent.height
                    source: teacherEmpowerment ? "qrc:/images/cr_btn_pic.png" : "qrc:/images/cr_btn_pic_none.png"
                }
                MouseArea{
                    anchors.fill: parent
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
                            noSelectPower();
                        }
                    }
                    onContainsMouseChanged:
                    {
                        if(containsMouse)
                        {
                            if(toobarWidget.teacherEmpowerment) {
                                pictureImage.source =  "qrc:/images/cr_btn_pic_sed.png";
                            }else {
                                pictureImage.source =  "qrc:/images/cr_btn_pic_none.png";
                            }
                        }else
                        {
                            if(toobarWidget.teacherEmpowerment) {
                                pictureImage.source =  "qrc:/images/cr_btn_pic.png";
                                //  toobarWidget.sigSendFunctionKey(4);
                            }else {
                                pictureImage.source =  "qrc:/images/cr_btn_pic_none.png";
                                //noSelectPower();
                            }
                        }
                    }

                }
            }



            //几何按钮
            Rectangle{
                id:graphic
                anchors.left: parent.left
                anchors.top: picture.bottom
                anchors.topMargin: 30 * leftMidWidth / 66.0
                anchors.leftMargin: 20 * leftMidWidth / 66.0
                width: 28 * leftMidWidth / 66.0
                height:  28 * leftMidWidth / 66.0
                color: "#00000000"
                Image {
                    id: graphicImage
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: parent.width
                    height: parent.height
                    source: teacherEmpowerment ? "qrc:/images/cr_btn_shape.png" : "qrc:/images/cr_btn_shape_none.png"
                }
                MouseArea{
                    anchors.fill: parent
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
                            noSelectPower();
                        }
                    }
                    onContainsMouseChanged:
                    {
                        if(containsMouse)
                        {
                            if(toobarWidget.teacherEmpowerment) {
                                graphicImage.source =  "qrc:/images/cr_btn_shape_sed.png";
                            }else {
                                graphicImage.source =  "qrc:/images/cr_btn_shape_none.png";
                            }
                        }else
                        {
                            if(toobarWidget.teacherEmpowerment) {
                                graphicImage.source =  "qrc:/images/cr_btn_shape.png";
                                //toobarWidget.sigSendFunctionKey(5);
                            }else {
                                graphicImage.source =  "qrc:/images/cr_btn_shape_none.png";
                                //noSelectPower();
                            }
                        }
                    }
                }
            }


            //网络优化
            Rectangle{
                id:netWorkInfor
                anchors.left: parent.left
                anchors.bottom:  testBtn.top
                width: parent.width
                height: 67 * fullHeights / 900
                color: "#00000000"
                visible: false
                focus: false
                Image {
                    anchors.left: parent.left
                    anchors.top:  parent.top
                    width: parent.width
                    height: parent.height
                    source: "qrc:/images/rectangleone.png"
                }
                Image {
                    id: netWorkInforImage
                    anchors.left: parent.left
                    anchors.bottom:  parent.bottom
                    anchors.bottomMargin: 36 * fullHeights / 900
                    width: 16 * fullHeights / 900
                    height: 16 * fullHeights / 900
                    anchors.leftMargin: parent.width / 2 - 8 * fullHeights / 900
                    source: networkIcon == 1 ? "qrc:/images/icon_good.png" : (networkIcon == 2 ? "qrc:/images/icon_ok.png" : "qrc:/images/icon_bad.png")
                }

                onFocusChanged: {
                    if(focus) {
                        netWorkInfor.visible = true;
                    }else {
                        netWorkInfor.visible = false;
                    }
                }


                Text {
                    id: netWorkInforText
                    anchors.left: parent.left
                    anchors.bottom:  parent.bottom
                    anchors.bottomMargin: 17 * fullHeights / 900
                    width: parent.width
                    height:  14 * fullHeights / 900
                    font.pixelSize: 12 * fullHeights / 900
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Microsoft YaHei"
                    color: "#666673"
                    text: qsTr("网络优化")
                }
                MouseArea{
                    anchors.fill: parent
                    onPressed: {
                        netWorkInforText.color = "#ff6633"
                    }
                    onReleased: {
                        netWorkInforText.color = "#666673"
                        toobarWidget.sigSendFunctionKey(6);
                    }
                }

            }


            //检测按键
            Rectangle{
                id:testBtn
                anchors.left: parent.left
                anchors.bottom:  parent.bottom
                width: parent.width
                height: parent.width
                color: "#00000000"
                Image {
                    id: testBtnImage
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: parent.width
                    height: parent.height
                    fillMode:Image.PreserveAspectFit
                    source: "qrc:/images/cr_btn_more.png"
                }
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onPressed: {
                        testBtnImage.source =  "qrc:/images/cr_btn_more_sed.png";
                    }
                    onReleased: {
                        testBtnImage.source =  "qrc:/images/cr_btn_more.png";
                        // toobarWidget.sigSendFunctionKey(6);
//                        if(netWorkInfor.focus == true) {
//                            netWorkInfor.focus = false;
//                        }else {
//                            netWorkInfor.focus = true;
//                        }

                    }

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
        radius: 6.0 *  leftMidWidth / 66.0
        samples: 16;
        color: "#60000000";
        smooth: true;
        source: container;
    }


}

