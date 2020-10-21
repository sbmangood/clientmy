import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQml.Models 2.2
import QtGraphicalEffects 1.0
import "Configuration.js" as Cfg
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Item {
    width: 80 * widthRate
    height: parent.height
    signal showCurrentClickView(var currentView);
    property int currentSlectIndex: 0;

    MouseArea
    {
        anchors.fill: parent
        onClicked:
        {
            return;
        }
    }

    ListModel {
        id: viewListModel
    }

    ListView {
        id: navigationBarArea
        width: parent.width
        height: parent.height
        clip: true
        boundsBehavior: ListView.StopAtBounds
        model: viewListModel
        delegate: navigationItemDelegate
    }

    Component {
        id: navigationItemDelegate
        ListView {
            id: navigationListView
            width: parent.width
            //设置左侧导航收起和被显示的时候的高度
            height: textArray.count == 1 ? 60 * heightRate : 45 * widthRate * (textArray.count)//selected ? (textArray.count == 1 ? 60 * heightRate : 45 * heightRate * (textArray.count)) : 50 * heightRate
            interactive: false
            clip: true
            model: textArray

            property int currentModelIndex: index;
            header: MouseArea {
                width: parent.width
                height: 30 * heightRate
                hoverEnabled:  true
                cursorShape: Qt.PointingHandCursor
                visible: false
                x: (parent.width - width) * 0.5

                //                onClicked:
                //                {
                //                    selected = !selected;
                //                    updateSelectIndex(index);
                //                }

                Image{
                    id: collapsedImage
                    width:  16 * heightRate
                    height:   16 * heightRate
                    anchors.top:parent.top
                    anchors.topMargin: 5 * heightRate
                    anchors.left: parent.left
                    anchors.leftMargin: 15 * heightRate
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    source: selected ? selectedIcon  : icon
                }

                Text {
                    id: headText
                    height: 25 * heightRate
                    anchors.left:collapsedImage.right
                    anchors.leftMargin: 10 * heightRate
                    anchors.top:parent.top
                    anchors.topMargin: 3 * heightRate
                    font.bold: Cfg.Menu_bold
                    font.family: Cfg.Menu_family
                    font.pixelSize: Cfg.Menu_pixelSize * heightRate
                    color:  selected ? "#666666" : "#999999"
                    text: mainTitle
                }
            }

            delegate: Text
            {
                //visible: selected
                height: 40 * widthRate
                font.family: Cfg.Menu_family
                font.pixelSize: 16 * widthRate
                color: currentSlectIndex == index ? "#333333" : "#BDBDBD"
                anchors.left:parent.left
                anchors.leftMargin: 23 * heightRate
                text: indexTitle

                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                    {
                        console.log("outIndex",outIndex)
                        currentSlectIndex = index;
                        showCurrentClickView(outIndex);
                        selected = true;
                        updateSelectIndex(currentModelIndex);
                    }
                }
            }


        }
    }


    function addView(title,icons,selectedIcon,textArray,selected){
        viewListModel.append(
                    {
                        "mainTitle": title,
                        "textArray": textArray,
                        "icon": icons,
                        "selectedIcon": selectedIcon,
                        "selected": selected
                    });
    }

    function updateSelectIndex(currentIndex)
    {
        for(var i = 0; i < viewListModel.count;i++){
            if(i === currentIndex){
                viewListModel.get(i).selected = true;
            }else{
                viewListModel.get(i).selected = false;
            }
        }
    }

}
