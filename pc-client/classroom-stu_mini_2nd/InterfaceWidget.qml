import QtQuick 2.7
import QtQuick.Controls 1.4
import NetworkAccessManagerInfor 1.0

/*
 *表情
 */
Rectangle {
    id:bakcGround

    property double widthRates: bakcGround.width / 297.0
    property double heightRates: bakcGround.height / 261.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    property var modelArrys: new Array()

    color: "#00000000"

    //发送按压的网址
    signal sigSendHttpsUrl(string urls)

    function setInterfaceItem(items){
        listView.currentIndex = items
    }

    Image {
        id: bakcGroundImage
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        source: "qrc:/images/tan_biaoqingtwox.png"
    }


    Rectangle{
        id:stackViewsBackGround
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20 * widthRates
        anchors.topMargin: 15 * heightRates
        width: 268 * widthRates
        height: 195  * heightRates
        color: "#00000000"
        z:5

        ListView{
            id:listView
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            orientation:ListView.Horizontal
            clip: true
            snapMode:ListView.SnapToItem
            model: listViewModel
            delegate: page
        }
    }

    ListView{
        id:topView
        width: parent.width
        height: 40 * heightRates
        anchors.left: parent.left
        anchors.top: stackViewsBackGround.bottom
        anchors.leftMargin:  20 * widthRates
        anchors.topMargin: 5 * heightRates
        model:topViewModel
        orientation:ListView.Horizontal
        clip: true
        snapMode:ListView.SnapToItem
        z:5
        delegate: Rectangle{
            width: 40 * heightRates
            height: 40 * heightRates
            color: "#00000000"
            Image {
                anchors.fill: parent
                source: httpsUrl
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    setInterfaceItem(index)
                }
            }
        }
    }

    ListModel{
        id:topViewModel
    }

    ListModel{
        id:listViewModel
    }

    Component {
        id: page

        Rectangle {
            id:itemPage
            color: "#00000000"
            width: listView.width
            height: listView.height


            GridView{
                id:gridView
                anchors.left: parent.left
                anchors.top: parent.top
                width: parent.width
                height: parent.height
                cellHeight:gridView.width / 4
                cellWidth: gridView.width / 4
                clip:true
                snapMode:ListView.SnapToItem

                model: modelArrys[index]
                delegate: Rectangle{
                    width: gridView.width / 4
                    height: gridView.width / 4
                    border.color: "#e3e6e9"
                    border.width: 1
                    property string sendHttpsUrl: httpsUrl

                    Image {
                        width: parent.width
                        height: parent.height
                        source: httpsUrl + ".png"
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            sigSendHttpsUrl(sendHttpsUrl);
                        }
                    }

                }

            }
        }

    }


    NetworkAccessManagerInfor {
        id:networkAccessManagerInfor
        onSigSenGroundNum:{
            topViewModel.clear();
            listViewModel.clear();
            modelArrys.length = 0;
            for(var i = 0 ;i < nums;i++) {
                var objectas = Qt.createQmlObject('import QtQml.Models 2.2; ListModel{}',bakcGround);
                var ipAllSelectConts = networkAccessManagerInfor.getGifUrlPath(i);
                for(var j = 0 ;j < ipAllSelectConts.length ;j++){
                    var ipAllSelectContss = "";
                    ipAllSelectContss = ipAllSelectConts[j];
                    //ipAllSelectContss += ".png"
                    if(j == 0) {
                        topViewModel.append({ "httpsUrl": ipAllSelectContss +".png"});
                    }

                    objectas.append({ "httpsUrl": ipAllSelectContss});
                }
                modelArrys[i] = objectas;
                listViewModel.append({"nodeIndex":i});
            }

        }
    }

    MouseArea{
        anchors.fill: parent
        onClicked: {

        }
    }

    Component.onCompleted: {
        var currentVersions = "currentVersion=1";
        networkAccessManagerInfor.getGifName(currentVersions);
    }


}
