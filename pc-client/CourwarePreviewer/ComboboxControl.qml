import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import "./Configuuration.js"  as Cfg

ComboBox {
    id: comboBox

    property var dataModel: []; //数据模型

    signal sigId(var lessonIdName,var mediaType,var fileUrl);//课件或者视频文件Id

    width: parent.width * widthRate
    height: parent.height * heightRate
    model: dataModel
    font.pixelSize: 14 * heightRate
    textRole: "key"
    onCurrentIndexChanged:  {
        if(dataModel.count == 0 || currentIndex ==0 || currentIndex == -1){
            return;
        }

        sigId(dataModel.get(currentIndex).key,dataModel.get(currentIndex).values,dataModel.get(currentIndex).fileUrl);
    }

    delegate: ItemDelegate {
        id: comboBoxItem
        width: comboBox.width
        height: comboBox.height
        font.weight: comboBox.currentIndex === index ? Font.DemiBold : Font.Normal
        highlighted: comboBox.highlightedIndex == index

        MouseArea {
            id: itemArea
            anchors.fill: parent
            hoverEnabled: true

            onClicked: {
                comboBox.currentIndex = index;
                comboBox.popup.close();
            }
        }

        Image{
            id: images
            width: 25 * widthRate
            height: 18 * heightRate
            anchors.left: parent.left
            anchors.leftMargin: 10 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            source: {
                if(dataModel.count < 1 || index == -1){
                    return ""
                }

                var indexs = dataModel.get(index).values

                if(indexs ==1){
                    if(itemArea.containsMouse){
                        return  'qrc:/images/icon_doc_sedtwo.png';
                    }else{
                        return  'qrc:/images/icon_doctwox.png';
                    }
                }
                if(indexs ==2){
                    if(itemArea.containsMouse){
                        return 'qrc:/images/icon_mp3_sedtwox.png';
                    }else{
                        return 'qrc:/images/icon_mp3twox.png';
                    }
                }
                if(indexs ==3){
                    if(itemArea.containsMouse){
                        return 'qrc:/images/icon_mp4_sedtwox.png';
                    }else{
                        return 'qrc:/images/icon_mp4twox.png';
                    }
                }
                if(indexs ==4){
                    if(itemArea.containsMouse){
                        return  'qrc:/images/icon_txt_sedtwox.png';
                    }else{
                        return  'qrc:/images/icon_txttwox.png';
                    }
                }
                if(indexs ==5){
                    if(itemArea.containsMouse){
                        return'qrc:/images/icon_pdf_sedtwox.png';
                    }else{
                        return'qrc:/images/icon_pdftwox.png';
                    }
                }
                if(indexs ==6){
                    if(itemArea.containsMouse){
                        return 'qrc:/images/icon_ppt_sedtwo.png'
                    }else{
                        return 'qrc:/images/icon_pptwo.png'
                    }
                }
                return ""
            }
        }

        Label{
            width: parent.width - 20
            height: parent.height
            anchors.left: images.right
            anchors.leftMargin: 10
            verticalAlignment: Text.AlignVCenter
            font.family: "Microsoft YaHei"
            font.pixelSize: 14 * heightRate
            text: key
            color: itemArea.containsMouse ?  "#ff5000" : "black"
        }

        background: Rectangle {
            anchors.fill: parent
            color: comboBox.currentIndex === index ? "#e0e0e0" : itemArea.containsMouse ? "#f3f3f3" : "white"
        }
    }    

    background: Rectangle {
        border.color: "#e0e0e0"
        border.width: 1
        radius: 6 * heightRate
        anchors.fill: comboBox
        color: "white"
    }


    indicator: Image{
        x: comboBox.width - width - comboBox.rightPadding
        y: comboBox.topPadding + (comboBox.availableHeight - height) / 2
        width: 8 * widthRates
        height: 6 * heightRates
        source: "qrc:/images/icon_selecttwosx.png"
    }

    contentItem: Item{
        Image{
            id: bgImage
            width: comboBox.currentIndex == 0 ? 0 : 20 * widthRates
            height: 18 * heightRate
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            source: {
                if(dataModel.count ==0 || comboBox.currentIndex == -1){
                    return "";
                }
                var indexs = dataModel.get(comboBox.currentIndex).values
                if(indexs ==1){
                    return  'qrc:/images/icon_doctwox.png';
                }
                if(indexs ==2){
                    return 'qrc:/images/icon_mp3twox.png';
                }
                if(indexs ==3){
                    return 'qrc:/images/icon_mp4twox.png';
                }
                if(indexs ==4){
                    return  'qrc:/images/icon_txttwox.png';
                }
                if(indexs ==5){
                    return'qrc:/images/icon_pdftwox.png';
                }
                if(indexs ==6){
                    return 'qrc:/images/icon_pptwo.png';
                }
                return "";
            }
        }
        Item{
            height: parent.height
            width: parent.width
            anchors.left: bgImage.right
            anchors.leftMargin: comboBox.currentIndex==0 ? 0 : 10
            Text{
                width: parent.width - 50 * widthRate
                height: parent.height
                font.family: Cfg.font_family
                font.pixelSize: 12 * widthRates
                verticalAlignment: Text.AlignVCenter
                text: {
                    if(dataModel.count ==0 || comboBox.currentIndex == -1){
                        return "";
                    }
                    dataModel.get(comboBox.currentIndex).key
                }
                elide: Text.ElideRight
            }
        }
    }
}

