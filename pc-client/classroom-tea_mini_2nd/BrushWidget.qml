import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

/*
 *画笔操作
 */
Item {
    id:bakcGround

    property double widthRates: bakcGround.width / 245.0
    property double heightRates: bakcGround.height / 186.0
    property double ratesRates: widthRates > heightRates ? heightRates : widthRates

    property int penColor: 0
    property int penWidth: 1

    property double brushWidth:0.000977;

    //发送画笔颜色
    signal sendPenColor(int penColors);
    //发送画笔宽度
    signal sendPenWidth(double penWidths);

    function setPenColor(){
        blackGroundImage.source = "qrc:/images/black.png";
        redGroundImage.source ="qrc:/images/red.png";
        yellowGroundImage.source  ="qrc:/images/yellow.png";
        blueGroundImage.source  ="qrc:/images/blue.png";
        greyGroundImage.source  ="qrc:/images/grey.png";
        cinerousGroundImage.source  ="qrc:/images/cinerous.png";
        greenGroundImage.source  ="qrc:/images/green.png";
        roseoGroundImage.source  ="qrc:/images/roseo.png";
        switch (penColor) {
        case 0:
            round.color = "black";
            blackGroundImage.source = "qrc:/images/black_sed.png";
            break;
        case 1:
            round.color = "red";
            redGroundImage.source ="qrc:/images/red_sed.png";
            break;
        case 2:
            round.color = "#F2BB4B";
            yellowGroundImage.source  ="qrc:/images/yellow_sed.png";
            break;
        case 3:
            round.color = "#00AEFF";
            blueGroundImage.source  ="qrc:/images/blue_sed.png";
            break;
        case 4:
            round.color = "grey";
            greyGroundImage.source  ="qrc:/images/grey_sed.png";
            break;
        case 5:
            round.color = "#363AEE";
            cinerousGroundImage.source  ="qrc:/images/cinerous_sed.png";
            break;
        case 6:
            round.color = "#80C000";
            greenGroundImage.source  ="qrc:/images/green_sed.png";
            break;
        case 7:
            round.color = "#FF00FF";
            roseoGroundImage.source  ="qrc:/images/roseo_sed.png";
            break;
        default:
            break;
        }
        sendPenColor(penColor);
    }

    Image {
        id: bakcGroundImage
        anchors.fill: parent
        source: "qrc:/miniClassImage/huabi.png"
    }

    Rectangle{
        id: roundView
        width: 46 * ratesRates
        height: 46 * ratesRates
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 22 * heightRate

        Image{
            anchors.fill: parent
            source: "qrc:/miniClassImage/xb_gongju_huabi_huan.png"
        }

        Rectangle{
            id: round
            width: 6 * heightRate
            height: 6 * heightRate
            radius: 100
            color: "#ffffff"
            anchors.centerIn: parent
        }
    }

    Slider{
        z: 5
        id: colorSlider
        width: parent.width - 40 * heightRate
        height: 18  * heightRate
        anchors.top: roundView.bottom
        anchors.topMargin: 15 * heightRate
        anchors.left: parent.left
        anchors.leftMargin: (parent.width - width) * 0.5 - 4 * heightRate
        onPressedChanged: {
            bakcGround.visible = true;
            if(pressed == false){
                sendPenWidth(brushWidth);
            }
        }

        onValueChanged: {
            if(value <= 0.18){
                round.width = 6 * heightRate
                round.height = 6 * heightRate
                brushWidth = 0.000977;
                return
            }
            round.width = 7.0 * value * 6 * ratesRates;
            round.height = 7.0 * value * 6 * ratesRates;
            var currentPenValue = value / 100;
            brushWidth = currentPenValue.toFixed(7);
            console.log("====colorSlider=====",brushWidth,value,currentPenValue,currentPenValue.toFixed(7))
        }

        style: SliderStyle{
            groove: Image{
                width: colorSlider.width
                height: colorSlider.height
                source: "qrc:/miniClassImage/xb_lashentiao.png"
            }

            handle: Rectangle{
                width: 10 * heightRate
                height: 14 * heightRate
                color: "#bababa"
                radius: 2 * heightRate
            }
            panel: Item{
                anchors.fill: parent

                Rectangle{
                    width: control.value * grooveLoader.width
                    height: parent.height
                    color: round.color
                }

                Loader{
                    id: grooveLoader
                    anchors.centerIn: parent
                    sourceComponent: groove
                }

                Loader{
                    id: handleLoader;
                    anchors.verticalCenter: grooveLoader.verticalCenter
                    x: Math.min(grooveLoader.x + (control.value * grooveLoader.width)/(control.maximumValue - control.minimumValue) , grooveLoader.width - item.width)
                    sourceComponent: handle
                }
            }
        }
    }

    Row{
        z: 6
        width: parent.width - 40 * heightRate
        height: 40 * heightRate
        anchors.bottom: rowTow.top
        anchors.bottomMargin: 10 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 12 * heightRate
        MouseArea{
            id:blackGround
            width: 36 * ratesRates
            height:  36 * ratesRates
            z:5
            Image {
                id: blackGroundImage
                anchors.fill: parent
                source: "qrc:/images/black_sed.png"
            }

            onClicked: {
                penColor = 0;
                setPenColor();
            }
        }

        MouseArea{
            id:redGround
            width: 36 * ratesRates
            height:  36 * ratesRates
            z:5
            Image {
                id: redGroundImage
                anchors.fill: parent
                // fillMode:Image.PreserveAspectFit
                source: "qrc:/images/red.png"
            }

            onClicked: {
                penColor = 1;
                setPenColor();
            }
        }

        MouseArea{
            id:yellowGround
            width: 36 * ratesRates
            height:  36 * ratesRates
            z:5
            Image {
                id: yellowGroundImage
                anchors.fill: parent
                //  fillMode:Image.PreserveAspectFit
                source: "qrc:/images/yellow.png"
            }

            onClicked: {
                penColor = 2;
                setPenColor();
            }

        }

        MouseArea{
            id:blueGround
            width: 36 * ratesRates
            height:  36 * ratesRates
            z:5
            Image {
                id: blueGroundImage
                anchors.fill: parent
                //   fillMode:Image.PreserveAspectFit
                source: "qrc:/images/blue.png"
            }
            onClicked: {
                penColor = 3;
                setPenColor();
            }

        }

    }

    Row{
        id: rowTow
        z: 5
        width: parent.width - 40 * heightRate
        height: 40 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20 * heightRate
        spacing: 12 * heightRate
        MouseArea{
            id:greyGround
            width: 36 * ratesRates
            height:  36 * ratesRates
            z:5
            Image {
                id: greyGroundImage
                anchors.fill: parent
                source: "qrc:/images/grey.png"
            }

            onClicked: {
                penColor = 4;
                setPenColor();
            }
        }

        MouseArea{
            id:cinerousGround
            width: 36 * ratesRates
            height:  36 * ratesRates
            z:5
            Image {
                id: cinerousGroundImage
                anchors.fill: parent
                source: "qrc:/images/cinerous.png"
            }

            onClicked: {
                penColor = 5;
                setPenColor();
            }
        }

        MouseArea{
            id:greenGround
            width: 36 * ratesRates
            height:  36 * ratesRates
            z:5
            Image {
                id: greenGroundImage
                anchors.fill: parent
                source: "qrc:/images/green.png"
            }

            onClicked: {
                penColor = 6;
                setPenColor();
            }
        }

        MouseArea{
            id:roseoGround
            width: 36 * ratesRates
            height:  36 * ratesRates
            z:5
            Image {
                id: roseoGroundImage
                anchors.fill: parent
                source: "qrc:/images/roseo.png"
            }

            onClicked: {
                penColor = 7;
                setPenColor();
            }
        }
    }

}

