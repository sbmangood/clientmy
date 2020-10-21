import QtQuick 2.0

Item {
    id: geometricFigureBakcground
    //几何图形
    property var itemPolygonPanelFrame: null;

    property int polygonType: 0;
    property string dockId: "";
    property int pageId: 0;
    property string boardId: "";
    property string itemId: "";

    signal sigGraphicsData(var graphicData,var graphicType);

    //设置几何图形
    function setDrawPolygon(polygons) {
        console.log("====setDrawPolygon====",polygons)
        polygonType = polygons;
        var component;
        if(polygons == 1){
            component = Qt.createComponent("qrc:/EllipsePanelWidget.qml")
            itemPolygonPanelFrame = component.createObject(geometricFigureBakcground);
            itemPolygonPanelFrame.setPolygonPanelType(boardId,dockId,itemId,pageId);
            itemPolygonPanelFrame.sigClearItemPolygonPanelFrame.connect(clearItemPolygonPanelFrame);
            itemPolygonPanelFrame.sigOkItemPolygonPanelFrame.connect(okItemPolygonPanelFrame);
        }else{
            component = Qt.createComponent("qrc:/PolygonPanelWidget.qml")
            itemPolygonPanelFrame = component.createObject(geometricFigureBakcground);
            itemPolygonPanelFrame.setPolygonPanelType(polygons,boardId,dockId,itemId,pageId);
            itemPolygonPanelFrame.sigClearItemPolygonPanelFrame.connect(clearItemPolygonPanelFrame);
            itemPolygonPanelFrame.sigOkItemPolygonPanelFrame.connect(okItemPolygonPanelFrame);
        }
    }

    //清除几何图形的指针
    function clearItemPolygonPanelFrame() {
        if(itemPolygonPanelFrame != null) {
            itemPolygonPanelFrame.destroy();
            itemPolygonPanelFrame = null;
            geometricFigureBakcground.visible = false;
        }
    }

    //确定几何图形的指针
    function okItemPolygonPanelFrame(contents ) {
        console.log("===okItemPolygonPanelFrame===",contents)
        if(itemPolygonPanelFrame != null) {
            //trailBoard.drawLocalGraphic(contents,height,topicListView.y);
            itemPolygonPanelFrame.destroy();
            itemPolygonPanelFrame = null;
            geometricFigureBakcground.visible = false;
            sigGraphicsData(JSON.parse(contents),polygonType);
        }
    }

}
