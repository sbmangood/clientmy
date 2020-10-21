import QtQuick 2.0
import "./Configuration.js" as Cfg

/*
*红包排行
*/

Item {
    id: rankingView
    width: parent.width
    height: parent.height

    Image{
        id: bgImg
        width: 400 * heightRate
        height: 400 * heightRate
        source: "qrc:/redPackge/phb-1.png"
        anchors.left: parent.left
        anchors.leftMargin: (parent.width - width) * 0.5
        anchors.top: parent.top
        anchors.topMargin: (parent.height - height) * 0.5

        MouseArea{
            width: 48 * heightRate
            height: 48 * heightRate
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            anchors.right: parent.right
            anchors.rightMargin: 66 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 16 * heightRate

            Image{
                anchors.fill: parent
                source: "qrc:/redPackge/close.png"
            }

            onClicked: {
                rankingView.visible = false;
            }
        }

        ListView{
            id: redPackgeListview
            width: 212 * heightRate
            height: 200 * heightRate
            model: redPackgeModel
            delegate: redPackgeComponent
            anchors.left: parent.left
            anchors.leftMargin: 95 * heightRate
            anchors.top: parent.top
            anchors.topMargin: 170 * heightRate
            boundsBehavior: ListView.StopAtBounds
        }
    }

    ListModel{
        id: redPackgeModel
    }

    Component{
        id: redPackgeComponent
        Item{
            width: redPackgeListview.width
            height: 38 * heightRate

            Image {
               width: parent.width
               height: 28 * heightRate
               anchors.verticalCenter: parent.verticalCenter
               source: "qrc:/redPackge/jbj.png"
            }

            Image{
                width: 22 * heightRate
                height: 22 * heightRate
                anchors.left: parent.left
                anchors.leftMargin: 12 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                source: {
                    if(index == 0){
                        return "qrc:/redPackge/j1.png";
                    }
                    if(index == 1){
                        return "qrc:/redPackge/j2.png";
                    }
                    if(index == 2){
                        return "qrc:/redPackge/j3.png";
                    }
                    if(index == 3){
                        return "qrc:/redPackge/j4.png";
                    }
                    if(index == 4){
                        return "qrc:/redPackge/j5.png";
                    }
                }
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 58 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 16 * heightRate
                color: "#ff6e59"
                text: userName
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 176 * heightRate
                anchors.verticalCenter: parent.verticalCenter
                font.family: Cfg.DEFAULT_FONT
                font.pixelSize: 16 * heightRate
                color: "#ff6e59"
                text: userIntegral
            }

        }

    }

    Component.onCompleted: {
        for(var i = 0; i < 5;i++){
            redPackgeModel.append(
                        {
                            "userName": "",
                            "userIntegral": ""
                        });
        }
    }

    function updateRankingData(objData){
        console.log("===updateRankingData====",JSON.stringify(objData));
        for(var i = 0; i < redPackgeModel.count; i++){
            redPackgeModel.get(i).userName = "";
            redPackgeModel.get(i).userIntegral = "";
        }

        if(objData.redData == null){
            return;
        }
        headView.stuIntegral = objData.historyCredit;
        for(var k = 0; k < objData.redData.length; k++){
            var redData = objData.redData[k];
            var groupId = objData.redData[k].groupId;

            if(redData.list == undefined || redData.list.length == 0){
                return;
            }

            for(var z = 0; z < redData.list.length;z++){
                var listData = redData.list[z];
                for(var items in listData){
                    redPackgeModel.get(z).userName = items;
                    redPackgeModel.get(z).userIntegral = listData[items].toString();
                }
            }

        }

    }

}
