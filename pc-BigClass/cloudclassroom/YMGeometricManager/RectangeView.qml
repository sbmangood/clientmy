import QtQuick 2.7
import QtQuick.Controls 2.0

Item {
    id:block
    width: parent.width
    height: parent.height
    focus: true

    property string boardId: "";
    property string itemId: "";
    property int step: 10;   //鼠标的检测区域尺寸
    property var mouseOld;   //鼠标按下时的坐标
    property var mouseNew;   //鼠标移动时的坐标
    property bool isclicked: false; //是否点击
    property int mouseState: 0;//鼠标状态
    property int rectangeType: 1;//1圆 2线条 3三角形 4矩形
    property bool isSelected: false;

    property double rundRotation: 0;//圆旋转的角度
    property double rundWidth: 0;
    property double rundHeight: 0;
    property double rundCenterX: 0;//圆的中心点
    property double rundCenterY: 0;//圆的中心点
    property color grapColor: "#3ED7B7"

    rotation: rectangeType == 1 ? rundRotation : 0

    property int x1: 0;
    property int y1: 0;
    property int x2: 0;
    property int y2: 0;
    property int x3: 0;
    property int y3: 0;
    property int x4: 0;
    property int y4: 0;

    signal sigOperating(var opera,var boardId,var itemId);//删除面板信号 opear 1:选中 2:删除
    signal sigMoveLocation(var itemId,var graphType,var locationArray);

    MouseArea{
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

    Canvas{//三角形
        anchors.fill: parent
        contextType: "2d";
        visible: rectangeType == 3 ? true : false
        onPaint: {
            context.lineWidth = 2;
            context.strokeStyle = grapColor;
            context.beginPath();

            context.moveTo(x1,y1)
            context.lineTo(x2,y2);
            context.lineTo(x3,y3);

            context.closePath();
            context.stroke();
            console.log("====sanjiaoxing====",x1,y1,x2,y2,x3,y3,rectangeType);
        }
    }

    Canvas{//矩形
        anchors.fill: parent
        contextType: "2d";
        visible: rectangeType == 4 ? true : false
        onPaint: {
            context.lineWidth = 2;
            context.strokeStyle = grapColor;
            context.beginPath();

            context.moveTo(x1,y1)
            context.lineTo(x2,y2);
            context.lineTo(x3,y3);
            context.lineTo(x4,y4);

            context.closePath();
            context.stroke();
            console.log("====draw::rectange===",rectangeType);
        }
    }

    Canvas{//圆形
        id : canvas
        anchors.fill: parent
        visible: rectangeType == 1 ? true : false

        onPaint: {
            var ctx = getContext("2d");
            ctx.save();
            var a = rundWidth - 2;
            var b = rundHeight - 2;
            var centX = rundCenterX  ;
            var centY = rundCenterY;
            ctx.lineWidth = 2;
            ctx.strokeStyle = grapColor;
            ctx.translate(canvas.width / 2,canvas.height / 2);
            var rotate = 0;
            ctx.rotate(rotate);
            if( a / b > 1){
                ctx.scale(1, b / a); //缩放函数, 圆的中点坐标会改变，a/b:长轴/短轴的一半
            }else{
                ctx.scale(a / b , 1); //缩放函数, 圆的中点坐标会改变，a/b:长轴/短轴的一半
            }
            ctx.beginPath();
            var radius = a > b  ? a / 2 : b / 2;
            if(radius < 0 && a < 0 && b < 0){
                radius = 0;
            }
            ctx.arc(0,0, radius, 0, 2 * Math.PI, false);
            ctx.stroke()
        }
    }

    Canvas{//画线
        width: parent.width - 2
        height: parent.height - 2
        anchors.centerIn: parent
        contextType: "2d";
        visible: rectangeType == 2 ? true : false
        onPaint: {
            context.lineWidth = 2;
            context.strokeStyle = grapColor;
            context.beginPath();

            context.moveTo(x1,y1)
            context.lineTo(x2,y2);

            context.closePath();
            context.stroke();
            console.log("====draw::line===",rectangeType);
        }
    }

    MouseArea {
        id:mouse_area
        hoverEnabled: block.focus
        anchors.fill: block
        cursorShape: Qt.PointingHandCursor

        property point clickPos: "0,0"

        onPressed:{
            isSelected = true;
            sigOperating(1,boardId,itemId);
            clickPos  = Qt.point(mouse.x,mouse.y)
        }

        onReleased:{
            mouse.accepted = true;
            var locationArray = [];
            var factor = 1000000.0;
            if(rectangeType == 1){
                locationArray.push(
                            {
                                "angle": rundRotation.toString(),
                                "rectWidth": ((rundWidth) / block.parent.width).toFixed(6) * factor,
                                "rundHeight": ((rundHeight) / block.parent.height).toFixed(6) * factor,
                                "rectX": (block.x / block.parent.width).toFixed(6) * factor,
                                "rectY": (block.y / block.parent.height).toFixed(6) * factor,
                            })
            }else{
                var vx1 = Math.floor((block.x + x1) / (block.parent.width)  * factor);
                var vy1 = Math.floor((block.y + y1) / (block.parent.height)  * factor);

                var vx2 = Math.floor((block.x + x2) / (block.parent.width)  * factor);
                var vy2 = Math.floor((block.y + y2)/ (block.parent.height)  * factor);

                var vx3 = Math.floor((block.x +x3)/ (block.parent.width)  * factor);
                var vy3 = Math.floor((block.y +y3) / (block.parent.height)  * factor);

                var vx4 = Math.floor((block.x + x4 )/ (block.parent.width)  * factor)
                var vy4 = Math.floor((block.y + y4) / (block.parent.height)  * factor);

                if(rectangeType == 2){
                    locationArray.push(
                                vx1,vy1,
                                vx2, vy2
                                );
                }
                if(rectangeType == 3){
                    locationArray.push(
                                vx1,vy1,
                                vx2, vy2,
                                vx3, vy3
                                );
                }
                if(rectangeType == 4){
                    locationArray.push(
                                vx1,vy1,
                                vx2, vy2,
                                vx3, vy3,
                                vx4, vy4
                                );
                }
            }

            sigMoveLocation(itemId,rectangeType,locationArray);
        }

        onPositionChanged: {
            if(block.isclicked === false){
                return;
            }
            var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y);
            var moveX = block.x + delta.x;
            var moveY = block.y + delta.y;
            var moveWidth = block.parent.width - block.width;
            var moveHeight = block.parent.height - block.height;

            if( moveX > 0 && moveX < moveWidth) {
                block.x = block.x + delta.x;
            }else{
                var loactionX = moveX < 0 ? 0 : (moveX > moveWidth ? moveWidth : moveX);
                block.x = loactionX;
            }

            if(moveY  > 0 && moveY < moveHeight){
                block.y = block.y + delta.y;
            }
            else{
                block.y = moveY < 0 ? 0 : (moveY > moveHeight ? moveHeight : moveY);
            }
        }
    }

    //失去焦点时改变鼠标形状，且将鼠标状态重置为0
    onFocusChanged: {
        if(!block.focus){
            mouse_area.cursorShape = Qt.ArrowCursor;
            mouseState = 0;
        }
    }
}
