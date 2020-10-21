import QtQuick 2.7
import QtQuick.Controls 2.0

Rectangle {
    id:block;
    width: parent.width
    height: parent.width
    color: "#00000000"

    property int step: 10;   //鼠标的检测区域尺寸
    property var mouseOld;   //鼠标按下时的坐标
    property var mouseNew;   //鼠标移动时的坐标
    property string imageSource: "";
    property string boardId: "";
    property string itemId: "";
    property int type: 5;

    //是否点击
    property bool isclicked: false;
    property bool isSelected: false;
    property bool operaStatus: false;
    //鼠标状态
    property int mouseState: 0;

    signal sigMoveLocation(var itemIt,var type,var locationArray);
    signal sigOperating(var opera,var boardId,var itemId);//删除面板信号 opear 1:选中 2:删除

    border.width: 1;
    border.color: isSelected ? "#ffffff" : "#30313D"
    focus: isclicked

    MouseArea{
        z: 1
        width: 30
        height: 30
        anchors.right: parent.right
        anchors.rightMargin: -15
        anchors.top: parent.top
        anchors.topMargin: -15
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        visible: isSelected

        Image{
            anchors.fill: parent
            source: "qrc:/geometricImage/btn_graph_wrong_normal@2x.png"
        }

        onClicked: {
            sigOperating(2,boardId,itemId);
        }
    }

    Image{
        width: parent.width - 4
        height: parent.height - 4
        anchors.centerIn: parent
        source: imageSource
        asynchronous: true
        mipmap: true
        smooth: true
        sourceSize: Qt.size(1024,680)
        onSourceSizeChanged: {
            if(sourceSize.width > 1920 || sourceSize.height > 1080){
                sourceSize.width = parent.width - 4
                sourceSize.height = parent.height - 4
            }
        }
    }

    //绘制4个角
    Canvas{
        id:can2d;
        contextType: "2d";
        anchors.fill: parent;
        visible: isSelected
        onPaint: {
            context.fillStyle = "#ffffff";
            context.fillRect(0,0,step,step);
            context.fillRect(0,block.height-step,step,step);
            context.fillRect(block.width-step,0,step,step);
            context.fillRect(block.width-step,block.height-step,step,step);
        }
    }

    MouseArea {
        id:mouse_area;
        hoverEnabled: true
        anchors.fill: block
        cursorShape: Qt.PointingHandCursor
        enabled: isclicked

        property point clickPos: "0,0"

        onPressed:{
            block.focus = true;
            operaStatus = true;
            isSelected = true;
            sigOperating(1,boardId,itemId);
            mouseOld = parent.mapToItem(parent.parent,mouseX,mouseY);
            clickPos  = Qt.point(mouse.x,mouse.y)
            mouse.accepted=true;
        }
        onReleased:{
            mouse.accepted = true;
            operaStatus = false;
            var factor = 1000000.0;
            var locationArray = {
                "itemId": itemId,
                "url": imageSource,
                "w": Math.floor((block.width  / block.parent.width).toFixed(6) * factor),
                "h": Math.floor((block.height  / block.parent.height).toFixed(6) * factor),
                "recX": Math.floor((block.x  / block.parent.width).toFixed(6) * factor),
                "recY": Math.floor((block.y   / block.parent.height).toFixed(6) * factor),
            }
            sigMoveLocation(itemId,type,locationArray)
        }
        onPositionChanged: {
            if(block.operaStatus){
                mouseNew = parent.mapToItem(parent.parent,mouseX,mouseY);
                if(mouseNew.x > block.parent.width || mouseNew.y > block.parent.height || mouseNew.x < 0 || mouseNew.y < 0 ){
                    return;
                }
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
                var moveX = block.x + delta.x;
                var moveY = block.y + delta.y;
                var moveWidth = block.parent.width - block.width;
                var moveHeight = block.parent.height - block.height;
                var locationX,locationY;
                if( moveX > 0 && moveX < moveWidth) {
                    locationX = block.x + delta.x;
                }else{
                    var loactionX = moveX < 0 ? 0 : (moveX > moveWidth ? moveWidth : moveX);
                    locationX = loactionX;
                }

                if(moveY  > 0 && moveY < moveHeight){
                    locationY = block.y + delta.y;
                }
                else{
                    locationY = moveY < 0 ? 0 : (moveY > moveHeight ? moveHeight : moveY);
                }

                switch(mouseState) //判断鼠标当前状态，0代表，在无焦点的情况下，直接点击就可以拖动。
                {
                case 0:
                case 5:
                    block.x= locationX
                    block.y= locationY;
                    break;
                case 1:
                    block.width=block.width- mouseNew.x+mouseOld.x;
                    block.height=block.height - mouseNew.y+mouseOld.y;
                    if(block.width>25)
                        block.x= locationX
                    if(block.height>25)
                        block.y= locationY;
                    break;
                case 2:
                    block.width = block.width -mouseNew.x+mouseOld.x;
                    if(block.width>25)
                        block.x= locationX;
                    break;
                case 3:
                    block.width=block.width -mouseNew.x+mouseOld.x;
                    block.height=block.height +mouseNew.y-mouseOld.y;
                    if(block.width>25)
                        block.x= locationX
                    break;
                case 4:
                    block.height=block.height -mouseNew.y+mouseOld.y;
                    if(block.height>25)
                        block.y= locationY;
                    break;
                case 6:
                    block.height=block.height+mouseNew.y-mouseOld.y;
                    break;
                case 7:
                    block.height=block.height-mouseNew.y+mouseOld.y;
                    block.width=block.width+mouseNew.x-mouseOld.x;
                    if(block.height>25)
                        block.y= locationY;
                    break;
                case 8:
                    block.width=block.width+mouseNew.x-mouseOld.x;
                    break;
                case 9:
                    block.width=block.width + mouseNew.x - mouseOld.x;
                    block.height=block.height + mouseNew.y - mouseOld.y;
                    break;
                default:
                }
                //这里的两个if是限制block的最小尺寸，防止缩小到看不见。
                if(block.width<=25)
                    block.width=25;

                if(block.height<=25)
                    block.height=25;

                mouseOld = mouseNew;
            }
            else{
                if(mouseX<block.step&&mouseX>=0)
                {
                    if(0<=mouseY&&mouseY<block.step){
                        mouseState=1;
                        mouse_area.cursorShape= Qt.SizeFDiagCursor;
                    }
                    else if((block.height-block.step)<mouseY&&mouseY<=block.height){
                        mouseState=3;
                        mouse_area.cursorShape= Qt.SizeBDiagCursor;
                    }
                    else if(block.step<=mouseY&&mouseY<=block.height-block.step){
                        mouseState=2;
                        mouse_area.cursorShape= Qt.SizeHorCursor;
                    }
                }
                else if(block.width-block.step<mouseX&&mouseX<=block.width)
                {
                    if(0<=mouseY&&mouseY<block.step){
                        mouseState=7;
                        mouse_area.cursorShape= Qt.SizeBDiagCursor;
                    }
                    else if((block.height-block.step)<mouseY&&mouseY<=block.height){
                        mouseState=9;
                        mouse_area.cursorShape= Qt.SizeFDiagCursor;
                    }
                    else if(block.step<=mouseY&&mouseY<=block.height-block.step){
                        mouseState=8;
                        mouse_area.cursorShape= Qt.SizeHorCursor;
                    }
                }
                else if(block.width-block.step>=mouseX&&mouseX>=block.step)
                {
                    if(0<=mouseY&&mouseY<block.step){
                        mouseState=4;
                        //mouse_area.cursorShape= Qt.SizeVerCursor;
                    }
                    else if((block.height-block.step)<mouseY&&mouseY<=block.height){
                        mouseState=6;
                        mouse_area.cursorShape= Qt.SizeVerCursor;
                    }
                    else if(block.step<=mouseY&&mouseY<=block.height-block.step){
                        mouseState=5;
                        mouse_area.cursorShape=Qt.ArrowCursor;
                    }
                }
            }
            mouse.accepted=true;
        }
    }


    //失去焦点时改变鼠标形状，且将鼠标状态重置为0，（不然在使用中达不到理想效果）
    onFocusChanged: {
        console.log("====onFocusChanged====",focus)
        if(!block.focus){
            mouse_area.cursorShape = Qt.ArrowCursor;
            mouseState = 0;
        }
    }
}
