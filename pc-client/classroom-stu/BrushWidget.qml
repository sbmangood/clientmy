import QtQuick 2.7

/*
 *画笔操作
 */
Rectangle {
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
        if(penWidth == 1) {
            brushWidth = 0.000977;

        }else if(penWidth == 2) {
            brushWidth = 0.003906;

        }else {
            brushWidth = 0.007812;

        }

        sendPenWidth(brushWidth);
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
            blackGroundImage.source = "qrc:/images/black_sed.png";
            break;
        case 1:
            redGroundImage.source ="qrc:/images/red_sed.png";

            break;
        case 2:
            yellowGroundImage.source  ="qrc:/images/yellow_sed.png";

            break;
        case 3:
            blueGroundImage.source  ="qrc:/images/blue_sed.png";

            break;
        case 4:
            greyGroundImage.source  ="qrc:/images/grey_sed.png";

            break;
        case 5:
            cinerousGroundImage.source  ="qrc:/images/cinerous_sed.png";

            break;
        case 6:
            greenGroundImage.source  ="qrc:/images/green_sed.png";

            break;
        case 7:
            roseoGroundImage.source  ="qrc:/images/roseo_sed.png";

            break;
        default:
            break;
        }

        sendPenColor(penColor);
    }

    color: "#00000000"

    Image {
        id: bakcGroundImage
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        source: "qrc:/newStyleImg/popwindow_pen@2x.png"
    }


    Rectangle{
        id:blackGround
        width: 22 * ratesRates
        height:  22 * ratesRates
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 40 * widthRates
        anchors.topMargin:24 * heightRates
        color: "#00000000"
        z:5
        Image {
            id: blackGroundImage
            anchors.left: parent.left
            anchors.top: parent.top
            width: 23 * ratesRates
            height: 23 * ratesRates
            // fillMode:Image.PreserveAspectFit
            source: "qrc:/images/black_sed.png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                penColor = 0;
                setPenColor();
                setPenWidth();
                bakcGround.focus = false;

            }
        }

    }


    Rectangle{
        id:redGround
        width: 22 * ratesRates
        height:  22 * ratesRates
        anchors.left: blackGround.right
        anchors.top: parent.top
        anchors.leftMargin: 30 * widthRates
        anchors.topMargin:24 * heightRates
        color: "#00000000"
        z:5
        Image {
            id: redGroundImage
            anchors.left: parent.left
            anchors.top: parent.top
            width: 23 * ratesRates
            height: 23 * ratesRates
            // fillMode:Image.PreserveAspectFit
            source: "qrc:/images/red.png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                penColor = 1;
                setPenColor();
                setPenWidth();
                bakcGround.focus = false;

            }
        }

    }



    Rectangle{
        id:yellowGround
        width: 22 * ratesRates
        height:  22 * ratesRates
        anchors.left: redGround.right
        anchors.top: parent.top
        anchors.leftMargin: 30 * widthRates
        anchors.topMargin:24 * heightRates
        color: "#00000000"
        z:5
        Image {
            id: yellowGroundImage
            width: 23 * ratesRates
            height: 23 * ratesRates
            //  fillMode:Image.PreserveAspectFit
            source: "qrc:/images/yellow.png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                penColor = 2;
                setPenColor();
                setPenWidth();
                bakcGround.focus = false;

            }
        }

    }




    Rectangle{
        id:blueGround
        width: 22 * ratesRates
        height:  22 * ratesRates
        anchors.left: yellowGround.right
        anchors.top: parent.top
        anchors.leftMargin: 30 * widthRates
        anchors.topMargin:24 * heightRates
        color: "#00000000"
        z:5
        Image {
            id: blueGroundImage
            width: 23 * ratesRates
            height: 23 * ratesRates
            //   fillMode:Image.PreserveAspectFit
            source: "qrc:/images/blue.png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                penColor = 3;
                setPenColor();
                setPenWidth();
                bakcGround.focus = false;

            }
        }

    }


    Rectangle{
        id:greyGround
        width: 22 * ratesRates
        height:  22 * ratesRates
        anchors.left: blackGround.left
        anchors.top: blackGround.bottom
        anchors.topMargin:24 * heightRates
        color: "#00000000"
        z:5
        Image {
            id: greyGroundImage
            width: 23 * ratesRates
            height: 23 * ratesRates
            //  fillMode:Image.PreserveAspectFit
            source: "qrc:/images/grey.png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                penColor = 4;
                setPenColor();
                setPenWidth();
                bakcGround.focus = false;

            }
        }

    }



    Rectangle{
        id:cinerousGround
        width: 22 * ratesRates
        height:  22 * ratesRates
        anchors.left: greyGround.right
        anchors.top: blackGround.bottom
        anchors.leftMargin: 30 * widthRates
        anchors.topMargin:24 * heightRates
        color: "#00000000"
        z:5
        Image {
            id: cinerousGroundImage
            width: 23 * ratesRates
            height: 23 * ratesRates
            //   fillMode:Image.PreserveAspectFit
            source: "qrc:/images/cinerous.png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                penColor = 5;
                setPenColor();
                setPenWidth();
                bakcGround.focus = false;

            }
        }

    }




    Rectangle{
        id:greenGround
        width: 22 * ratesRates
        height:  22 * ratesRates
        anchors.left: cinerousGround.right
        anchors.top: blackGround.bottom
        anchors.leftMargin: 30 * widthRates
        anchors.topMargin:24 * heightRates
        color: "#00000000"
        z:5
        Image {
            id: greenGroundImage
            anchors.left: parent.left
            anchors.top: parent.top
            width: 23 * ratesRates
            height: 23 * ratesRates
            //  fillMode:Image.PreserveAspectFit
            source: "qrc:/images/green.png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                penColor = 6;
                setPenColor();
                setPenWidth();
                bakcGround.focus = false;

            }
        }

    }




    Rectangle{
        id:roseoGround
        width: 22 * ratesRates
        height:  22 * ratesRates
        anchors.left: greenGround.right
        anchors.top: blackGround.bottom
        anchors.leftMargin: 30 * widthRates
        anchors.topMargin:24 * heightRates
        color: "#00000000"
        z:5
        Image {
            id: roseoGroundImage
            width: 23 * ratesRates
            height: 23 * ratesRates
            //  fillMode:Image.PreserveAspectFit
            source: "qrc:/images/roseo.png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                penColor = 7;
                setPenColor();
                setPenWidth();
                bakcGround.focus = false;

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
    }

    Rectangle{
        id:penMinGround
        width: 30 * ratesRates
        height:  30 * ratesRates
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 38 * widthRates
        anchors.topMargin:131 * heightRates
        color: "#00000000"
        z:5
        Image {
            id: penMinGroundImage
            width: 30 * ratesRates
            height: 30 * ratesRates
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
        z:5
        Image {
            id: penMidGroundImage
            width: 30 * ratesRates
            height: 30 * ratesRates
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

        Image {
            id: penMaxGroundImage
            width: 30 * ratesRates
            height: 30 * ratesRates
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

