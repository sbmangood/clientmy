import QtQuick 2.5

/*
 * 几何图形
 */
MouseArea {
    id:bakcGround
    width: parent.width
    height: parent.height

    property bool isSelected1: false;
    property bool isSelected2: false;
    property bool isSelected3: false;
    property bool isSelected4: false;

    signal sigPolygon( int polygons);

    Image {
        id: bakcGroundImage
        anchors.fill: parent
        source: "qrc:/geometricImage/bg_pop_graph.png"
    }

    Row{
        width: parent.width - 50 * heightRate
        height: parent.height - 10 * heightRate
        anchors.centerIn: parent
        spacing: 10 * heightRate

        //直线
        MouseArea{
            id:line
            width: 42 * heightRate
            height: 42 * heightRate
            hoverEnabled: true
            z: 5

            Image {
                id: lineImage
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: isSelected4 ? "qrc:/geometricImage/but_menu_line_pressed@2x.png" : parent.containsMouse ? "qrc:/geometricImage/but_menu_line_focused@2x.png" : "qrc:/geometricImage/but_menu_line_normal@2x.png"
            }

            onClicked: {
                updateSeleted(2);
                sigPolygon(2);
            }
        }
        //圆形
        MouseArea{
            id:circular
            width: 42 * heightRate
            height: 42 * heightRate
            hoverEnabled: true
            z:5
            Image {
                id: circularImage
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: isSelected3 ? "qrc:/geometricImage/but_menu_circle_pressed@2x.png" : parent.containsMouse ? "qrc:/geometricImage/but_menu_circle_focused@2x.png" : "qrc:/geometricImage/but_menu_circle_normal@2x.png"
            }
            onClicked: {
                updateSeleted(1);
                sigPolygon(1);
            }

        }
        //三角形
        MouseArea{
            id:triangle
            width: 42 * heightRate
            height: 42 * heightRate
            hoverEnabled: true
            z:5
            Image {
                id: triangleImage
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: isSelected2 ? "qrc:/geometricImage/but_menu_triangle_pressed@2x.png" : parent.containsMouse ? "qrc:/geometricImage/but_menu_triangle_focused@2x.png" :"qrc:/geometricImage/but_menu_triangle_normal@2x.png"
            }
            onClicked: {
                updateSeleted(3);
                sigPolygon(3);
            }
        }
        //正方形
        MouseArea{
            id:square
            width: 42 * heightRate
            height: 42 * heightRate
            hoverEnabled: true
            z:5
            Image {
                id: squareImage
                anchors.fill: parent
                clip: true
                fillMode: Image.PreserveAspectFit
                smooth:true
                source: isSelected1 ? "qrc:/geometricImage/but_menu_rectangle_pressed@2x.png" : parent.containsMouse ? "qrc:/geometricImage/but_menu_rectangle_focused@2x.png" : "qrc:/geometricImage/but_menu_rectangle_normal@2x.png"
            }

            onClicked: {
                updateSeleted(4);
                sigPolygon(4);
            }

        }
    }

    function updateSeleted(indexs){
        isSelected1 = false;
        isSelected2 = false;
        isSelected3 = false;
        isSelected4 = false;
        switch(indexs){
        case 1:
            isSelected3 = true;
            break;
        case 2:
            isSelected4 = true;
            break;
        case 3:
            isSelected2 = true;
            break;
        case 4:
            isSelected1 = true;
            break;
        default :
            break;
        }
    }
}
