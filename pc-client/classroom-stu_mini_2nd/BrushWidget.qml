import QtQuick 2.7
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Private 1.0

/*
 *画笔操作
 */
Item {
    id:bakcGround

    property double widthRates: bakcGround.width / 245.0
    property double heightRates: bakcGround.height / 186.0
    property double ratesRates: widthRates > heightRates? heightRates : widthRates

    property int penColor: 0
    property int penWidth: 1

    property double brushWidth:0.000977;

    //发送画笔颜色
    signal sendPenColor(int penColors);
    //发送画笔宽度
    signal sendPenWidth(double penWidths);

    function setPenWidth(){
        switch (penColor) {
        case 0: {
            if(penWidth == 1) {
                penMinGroundImage.source = "qrc:/images/black1.png";
                penMidGroundImage.source = "qrc:/images/black2 copy.png";
                penMaxGroundImage.source = "qrc:/images/black3 copy.png";
            }else if (penWidth == 2){
                penMinGroundImage.source = "qrc:/images/black1 copy.png";
                penMidGroundImage.source = "qrc:/images/black2.png";
                penMaxGroundImage.source = "qrc:/images/black3 copy.png";
            }else {
                penMinGroundImage.source = "qrc:/images/black1 copy.png";
                penMidGroundImage.source = "qrc:/images/black2 copy.png";
                penMaxGroundImage.source = "qrc:/images/black3.png";
            }

            break;
        }
        case 1: {
            if(penWidth == 1) {
                penMinGroundImage.source = "qrc:/images/red1.png";
                penMidGroundImage.source = "qrc:/images/red2 copy.png";
                penMaxGroundImage.source = "qrc:/images/red3 copy.png";
            }else if (penWidth == 2){
                penMinGroundImage.source = "qrc:/images/red1 copy.png";
                penMidGroundImage.source = "qrc:/images/red2.png";
                penMaxGroundImage.source = "qrc:/images/red3 copy.png";
            }else {
                penMinGroundImage.source = "qrc:/images/red1 copy.png";
                penMidGroundImage.source = "qrc:/images/red2 copy.png";
                penMaxGroundImage.source = "qrc:/images/red3.png";
            }

            break;
        }
        case 2: {
            if(penWidth == 1) {
                penMinGroundImage.source = "qrc:/images/yellow1.png";
                penMidGroundImage.source = "qrc:/images/yellow2 copy.png";
                penMaxGroundImage.source = "qrc:/images/yellow3 copy.png";
            }else if (penWidth == 2){
                penMinGroundImage.source = "qrc:/images/yellow1 copy.png";
                penMidGroundImage.source = "qrc:/images/yellow2.png";
                penMaxGroundImage.source = "qrc:/images/yellow3 copy.png";
            }else {
                penMinGroundImage.source = "qrc:/images/yellow1 copy.png";
                penMidGroundImage.source = "qrc:/images/yellow2 copy.png";
                penMaxGroundImage.source = "qrc:/images/yellow3.png";
            }

            break;
        }
        case 3: {
            if(penWidth == 1) {
                penMinGroundImage.source = "qrc:/images/blue1.png";
                penMidGroundImage.source = "qrc:/images/blue2 copy.png";
                penMaxGroundImage.source = "qrc:/images/blue3 copy.png";
            }else if (penWidth == 2){
                penMinGroundImage.source = "qrc:/images/blue1 copy.png";
                penMidGroundImage.source = "qrc:/images/blue2.png";
                penMaxGroundImage.source = "qrc:/images/blue3 copy.png";
            }else {
                penMinGroundImage.source = "qrc:/images/blue1 copy.png";
                penMidGroundImage.source = "qrc:/images/blue2 copy.png";
                penMaxGroundImage.source = "qrc:/images/blue3.png";
            }

            break;
        }
        case 4: {

            if(penWidth == 1) {
                penMinGroundImage.source = "qrc:/images/grey1.png";
                penMidGroundImage.source = "qrc:/images/grey2 copy.png";
                penMaxGroundImage.source = "qrc:/images/grey3 copy.png";
            }else if (penWidth == 2){
                penMinGroundImage.source = "qrc:/images/grey1 copy.png";
                penMidGroundImage.source = "qrc:/images/grey2.png";
                penMaxGroundImage.source = "qrc:/images/grey3 copy.png";;
            }else {
                penMinGroundImage.source = "qrc:/images/grey1 copy.png";
                penMidGroundImage.source = "qrc:/images/grey2 copy.png";
                penMaxGroundImage.source = "qrc:/images/grey3.png";
            }

            break;
        }
        case 5: {
            if(penWidth == 1) {
                penMinGroundImage.source = "qrc:/images/cinerous1.png";
                penMidGroundImage.source = "qrc:/images/cinerous2 copy.png";
                penMaxGroundImage.source = "qrc:/images/cinerous3 copy.png";
            }else if (penWidth == 2){
                penMinGroundImage.source = "qrc:/images/cinerous1 copy.png";
                penMidGroundImage.source = "qrc:/images/cinerous2.png";
                penMaxGroundImage.source = "qrc:/images/cinerous3 copy.png";
            }else {
                penMinGroundImage.source = "qrc:/images/cinerous1 copy.png";
                penMidGroundImage.source = "qrc:/images/cinerous2 copy.png";
                penMaxGroundImage.source = "qrc:/images/cinerous3.png";
            }

            break;
        }
        case 6:{
            if(penWidth == 1) {
                penMinGroundImage.source = "qrc:/images/green1.png";
                penMidGroundImage.source = "qrc:/images/green2 copy.png";
                penMaxGroundImage.source = "qrc:/images/green3 copy.png";
            }else if (penWidth == 2){
                penMinGroundImage.source = "qrc:/images/green1 copy.png";
                penMidGroundImage.source = "qrc:/images/green2.png";
                penMaxGroundImage.source = "qrc:/images/green3 copy.png";
            }else {
                penMinGroundImage.source = "qrc:/images/green1 copy.png";
                penMidGroundImage.source = "qrc:/images/green2 copy.png";
                penMaxGroundImage.source = "qrc:/images/green3.png";
            }

            break;
        }
        case 7:{
            if(penWidth == 1) {
                penMinGroundImage.source = "qrc:/images/roseo1.png";
                penMidGroundImage.source = "qrc:/images/roseo2 copy.png";
                penMaxGroundImage.source = "qrc:/images/roseo3 copy.png";
            }else if (penWidth == 2){
                penMinGroundImage.source = "qrc:/images/roseo1 copy.png";
                penMidGroundImage.source = "qrc:/images/roseo2.png";
                penMaxGroundImage.source = "qrc:/images/roseo3 copy.png";
            }else {
                penMinGroundImage.source = "qrc:/images/roseo1 copy.png";
                penMidGroundImage.source = "qrc:/images/roseo2 copy.png";
                penMaxGroundImage.source = "qrc:/images/roseo3.png";
            }

            break;
        }
        default:
            break;
        }
//        if(penWidth == 1) {
//            brushWidth = 0.000977;
//        }else if(penWidth == 2) {
//            brushWidth = 0.003906;
//        }else {
//            brushWidth = 0.007812;
//        }
//        sendPenWidth(brushWidth);
    }

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
            cinerousGroundImage.source  ="qrc:/images/cinerous_sed.png";
            round.color = "#363AEE";
            break;
        case 6:
            greenGroundImage.source  ="qrc:/images/green_sed.png";
            round.color = "#80C000";
            break;
        case 7:
            roseoGroundImage.source  ="qrc:/images/roseo_sed.png";
            round.color = "#FF00FF";
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
            color: "#000000"
            anchors.centerIn: parent
        }
    }

    Slider{
        z: 5
        id: colorSlider
        width: parent.width - 40 * heightRate
        height: 18  * heightRate
        anchors.top: roundView.bottom
        anchors.topMargin: 10 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
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
            //console.log("====colorSlider=====",value,currentPenValue,currentPenValue.toFixed(7))
        }

        style: SliderStyle{
            groove:  Image{
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

            panel:  Item{
                anchors.fill: parent
                Rectangle{
                    width: control.value * grooveLoader.width
                    height: parent.height
                    color: round.color
                }

                Loader{
                    id: grooveLoader;
                    anchors.centerIn: parent;
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
                setPenWidth();
                //bakcGround.focus = false;
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
                setPenWidth();
                //bakcGround.focus = false;
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
                setPenWidth();
                //bakcGround.focus = false;
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
                setPenWidth();
                //bakcGround.focus = false;
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
                setPenWidth();
                //bakcGround.focus = false;
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
                setPenWidth();
                //bakcGround.focus = false;
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
                setPenWidth();
                //bakcGround.focus = false;
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
                setPenWidth();
                //bakcGround.focus = false;
            }
        }

    }

    Rectangle{
        id:line
        width: parent.width - 50 * widthRates
        height: 1
        color: "#e3e6e9"
        anchors.left: parent.left
        anchors.top:parent.top
        anchors.leftMargin: 30 * widthRates
        anchors.topMargin: 114 * heightRates
        visible: false
    }

    Rectangle{
        id:penMinGround
        width: 30 * ratesRates
        height:  30 * ratesRates
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 43 * widthRates
        anchors.topMargin:131 * heightRates
        color: "#00000000"
        visible: false
        z:5
        Image {
            id: penMinGroundImage
            anchors.left: parent.left
            anchors.top: parent.top
            width: 28 * ratesRates
            height: 28 * ratesRates
            //   fillMode:Image.PreserveAspectFit
            source: "qrc:/images/black1.png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                penWidth= 1;
                setPenColor();
                setPenWidth();
                bakcGround.focus = false;

            }
        }

    }

    Rectangle{
        id:penMidGround
        width: 30 * ratesRates
        height:  30 * ratesRates
        anchors.left: penMinGround.right
        anchors.top: parent.top
        anchors.leftMargin: 40 * widthRates
        anchors.topMargin:131 * heightRates
        color: "#00000000"
        visible: false
        z:5
        Image {
            id: penMidGroundImage
            anchors.left: parent.left
            anchors.top: parent.top
            width: 28 * ratesRates
            height: 28 * ratesRates
            //   fillMode:Image.PreserveAspectFit
            source: "qrc:/images/black2 copy.png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                penWidth = 2;
                setPenColor();
                setPenWidth();
                bakcGround.focus = false;

            }
        }

    }

    Rectangle{
        id:penMaxGround
        width: 30 * ratesRates
        height:  30 * ratesRates
        anchors.left: penMidGround.right
        anchors.top: parent.top
        anchors.leftMargin: 40 * widthRates
        anchors.topMargin:131 * heightRates
        color: "#00000000"
        z:5
        visible: false
        Image {
            id: penMaxGroundImage
            anchors.left: parent.left
            anchors.top: parent.top
            width: 28 * ratesRates
            height: 28 * ratesRates
            //   fillMode:Image.PreserveAspectFit
            source: "qrc:/images/black3 copy.png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                penWidth = 3;
                setPenColor();
                setPenWidth();
                bakcGround.focus = false;

            }

        }

    }

    MouseArea{
        anchors.fill: parent
        onClicked: {

        }
    }

}

