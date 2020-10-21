import QtQuick 2.0

/*
*星级评价
*/

Item {
    width: 40 * 5 * heightRate
    height: 28 * heightRate

    property int starsValue: 5;
    signal sigUpdateAssess();//修改星级信号

    ListView{
        id: starsView
        anchors.fill: parent
        model: starsModel
        delegate: starsDelegate
        orientation: ListView.Horizontal
        clip: true
    }

    ListModel{
        id: starsModel
    }

    Component{
        id: starsDelegate
        Rectangle{
            width: 40 * heightRate
            height: 28 * heightRate

            MouseArea{
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    updateSelectedStatus(index);
                    sigUpdateAssess();
                }

                Image{
                    width: 28 * heightRate
                    height: 28 * heightRate
//                    source:  selected ? "qrc:/images/xingxing_xuanzhong.png" : "qrc:/images/xingxing_weixuanzhong.png"
                }
            }
        }
    }

    Component.onCompleted: {
        for(var i = 1; i <= 5; i++){
            starsModel.append(
                        {
                            "selectedIndex": i,
                            "selected": true,
                        })
        }
    }

    function updateSelectedStatus(index){
        for(var k = 0; k < starsModel.count; k++){
            if(k <= index){
                starsModel.get(k).selected = true;
                continue;
            }
            starsModel.get(k).selected = false;
        }
        starsValue = index + 1;
    }
}
