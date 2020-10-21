import QtQuick 2.5

/*
 * 几何图形
 */
Rectangle {
    id:bakcGround
    color: "#00000000"

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
        source: "qrc:/images/tan_tuxingtwox.png"
    }

    //正方形
    Rectangle{
        id:square
        width: 20 * ratesRates
        height: 20 * ratesRates
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin:  31 * widthRates
        anchors.topMargin: 20 * heightRates
        color: "#00000000"
        //  border.width: 1
        //  border.color: "#3c3c3e"
        z:5
        Image {
            id: squareImage
            width: 20 * ratesRates
            height:20 * ratesRates
            anchors.left: parent.left
            anchors.top: parent.top
            clip: true
            fillMode: Image.PreserveAspectFit
            smooth:true
            source: "qrc:/images/cr_btn_square.png"
        }
        MouseArea{
            anchors.fill: parent
            onPressed: {
                //    square.border.color = "#ff5000"

                squareImage.source = "qrc:/images/cr_btn_square_click.png"
            }
            onReleased: {
                //   square.border.color = "#3c3c3e"
                squareImage.source = "qrc:/images/cr_btn_square.png"
                sigPolygon(4);

            }
        }
    }


    //三角形
    Rectangle{
        id:triangle
        width: 20 * ratesRates
        height: 20 * ratesRates
        anchors.left: square.right
        anchors.top: square.top
        anchors.leftMargin:  20 * widthRates
        color: "#00000000"
        z:5
        Image {
            id: triangleImage
            width: parent.width
            height: parent.height
            anchors.left: parent.left
            anchors.top: parent.top
            fillMode: Image.PreserveAspectFit
            source: "qrc:/images/cr_btn_triangle.png"
        }
        MouseArea{
            anchors.fill: parent
            onPressed: {
                triangleImage.source = "qrc:/images/cr_triangle_click.png"
            }
            onReleased: {
                triangleImage.source = "qrc:/images/cr_btn_triangle.png"
                sigPolygon(3);

            }
        }
    }


    //圆形
    Rectangle{
        id:circular
        width: 20 * ratesRates
        height: 20 * ratesRates
        anchors.left: triangle.right
        anchors.top: triangle.top
        anchors.leftMargin:  20 * widthRates
        color: "#00000000"
        z:5
        Image {
            id: circularImage
            width: parent.width
            height: parent.height
            anchors.left: parent.left
            anchors.top: parent.top
            fillMode: Image.PreserveAspectFit
            source: "qrc:/images/cr_btn_circle.png"
        }
        MouseArea{
            anchors.fill: parent
            onPressed: {
                circularImage.source = "qrc:/images/cr_btn_circle_click.png"
            }
            onReleased: {
                circularImage.source = "qrc:/images/cr_btn_circle.png"
                sigPolygon(1);

            }
        }
    }


    //直线
    Rectangle{
        id:line
        width: 20 * ratesRates
        height: 20 * ratesRates
        anchors.left: circular.right
        anchors.top: circular.top
        anchors.leftMargin:  20 * widthRates
        color: "#00000000"
        z:5
        Image {
            id: lineImage
            width: parent.width
            height:  2
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: parent.height / 2 - 1
            fillMode: Image.PreserveAspectFit
            source: "qrc:/images/cr_btn_line.png"
        }
        MouseArea{
            anchors.fill: parent
            onPressed: {
                lineImage.source = "qrc:/images/cr_btn_line_click.png"
            }
            onReleased: {
                lineImage.source = "qrc:/images/cr_btn_line.png"
                sigPolygon(2);

            }
        }
    }


    MouseArea{
        anchors.fill: parent
        onClicked: {

        }
    }

}

