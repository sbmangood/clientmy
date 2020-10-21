import QtQuick 2.5

/*
 * 几何图形
 */
MouseArea {
    id:bakcGround

    property double widthRates: bakcGround.width / 206.0
    property double heightRates: bakcGround.height / 63.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    signal sigPolygon( int polygons);

    Image {
        id: bakcGroundImage
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        source: "qrc:/newStyleImg/popwindow_shape@2x.png"
    }

    //正方形
    MouseArea{
        id:square
        width: 35 * ratesRates
        height: 35 * ratesRates
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin:  25 * widthRates
        anchors.topMargin: 12 * heightRates
        z:5
        Image {
            id: squareImage
            width: 35 * ratesRates
            height: 35 * ratesRates
            clip: true
            fillMode: Image.PreserveAspectFit
            smooth:true
            source: "qrc:/newStyleImg/pc_shape_square@2x.png"
        }

        onPressed: {
            //    square.border.color = "#ff5000"
            squareImage.source = "qrc:/newStyleImg/pc_shape_square@2x.png"
        }
        onReleased: {
            //   square.border.color = "#3c3c3e"
            squareImage.source = "qrc:/newStyleImg/pc_shape_square@2x.png"
            sigPolygon(4);
        }

    }

    //三角形
    MouseArea{
        id:triangle
        width: 35 * ratesRates
        height: 35 * ratesRates
        anchors.left: square.right
        anchors.top: square.top
        anchors.leftMargin:  20 * widthRates
        z:5
        Image {
            id: triangleImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            source: "qrc:/newStyleImg/pc_shape_triangle@2x.png"
        }
        onPressed: {
            triangleImage.source = "qrc:/newStyleImg/pc_shape_triangle@2x.png"
        }
        onReleased: {
            triangleImage.source = "qrc:/newStyleImg/pc_shape_triangle@2x.png"
            sigPolygon(3);
        }
    }


    //圆形
    MouseArea{
        id:circular
        width: 35 * ratesRates
        height: 35 * ratesRates
        anchors.left: triangle.right
        anchors.top: triangle.top
        anchors.leftMargin:  20 * widthRates
        z:5
        Image {
            id: circularImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            source: "qrc:/newStyleImg/pc_shape_circle@2x.png"
        }
        onPressed: {
            circularImage.source = "qrc:/newStyleImg/pc_shape_circle@2x.png"
        }
        onReleased: {
            circularImage.source = "qrc:/newStyleImg/pc_shape_circle@2x.png"
            sigPolygon(1);

        }

    }


    //直线
    MouseArea{
        id:line
        width: 35 * ratesRates
        height: 35 * ratesRates
        anchors.left: circular.right
        anchors.top: circular.top
        anchors.leftMargin:  20 * widthRates
        z: 5

        Image {
            id: lineImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            source: "qrc:/newStyleImg/pc_shape_line@2x.png"
        }

        onPressed: {
            lineImage.source = "qrc:/newStyleImg/pc_shape_line@2x.png"
        }

        onReleased: {
            lineImage.source = "qrc:/newStyleImg/pc_shape_line@2x.png"
            sigPolygon(2);
        }
    }

}

