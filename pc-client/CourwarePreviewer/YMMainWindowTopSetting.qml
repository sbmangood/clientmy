import QtQuick 2.0
import QtQuick.Window 2.2
//top
Rectangle {
    property var window: null
    signal showcoursewareListViewRectangle();
    width: parent.width
    property  double  zoomWidthRate: Screen.width*0.7/966.0;
    property bool isOpenedStates: true
    color: "transparent"
    Rectangle{//窗体移动
        width: parent.width
        height: parent.height
        color: "transparent"
        MouseArea {
            id: dragRegion
            anchors.fill: parent
            property point clickPos: "0,0"
            onPressed: {
                clickPos  = Qt.point(mouse.x,mouse.y)
            }
            onPositionChanged: {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
                window.setX(window.x+delta.x)
                window.setY(window.y+delta.y)
            }
            onDoubleClicked:
            {
                window.visibility = Window.Windowed;
            }
        }
    }
    Column
    {
        width: parent.width
        height: parent.height
        Rectangle
        {
            width: parent.width
            height: parent.height
            //color: "#FF7E00";
            Rectangle
            {
                anchors.fill: parent
                //anchors.top: parent.top
                width: parent.height
                height: parent.width
                color:"#f9fafc"
            }
            Image{
                anchors.left: parent.left
                anchors.leftMargin: 15*zoomWidthRate
                anchors.top: parent.top
                anchors.topMargin: 13 * zoomWidthRate

                id: logoImage
                width: 100 * zoomWidthRate
                height: width / 5
                source: "qrc:/images/mainlogoHdpi.png"
                // anchors.verticalCenter: parent.verticalCenter
            }


            MouseArea {
                id:shoeCourseButton
                anchors.right:parent.right
                anchors.rightMargin: 130*widthRate

                width: 158*widthRate
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                Text{
                    id:showCourseText
                    height: parent.height
                    text:""
                    //font.bold: true
                    anchors.right: showCourseTextPhoto.left
                    anchors.rightMargin: 3 * widthRate
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14 * zoomWidthRate
                    color: "#222222"
                    font.family: "Microsoft YaHei"
                }
                Image {
                    id:showCourseTextPhoto
                    width: 10*widthRate
                    height: parent.height
                    anchors.right:parent.right
                    source: !isOpenedStates ? "qrc:/images/th_btn_close@2x.png" :　"qrc:/images/th_btn_openwhite@2x.png"

                    fillMode: Image.PreserveAspectFit

                }
                Rectangle
                {
                    id:partingLine
                    width: 1
                    height: parent.height
                    color: "#e3e6e9"
                    anchors.left: showCourseTextPhoto.right
                    anchors.leftMargin: 15*widthRate
                }
                onClicked: {
                    //console.log("test","weq");
                    //emit: showcoursewareListViewRectangle();
                    isOpenedStates = !isOpenedStates;
                }
            }

            //min button
            MouseArea {
                id: minButton
                width: 30*widthRate
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: shoeCourseButton.right
                anchors.leftMargin: 25*widthRate
                cursorShape: Qt.PointingHandCursor
                //                hoverEnabled: true
                Image {
                    width: 14*widthRate
                    height: 14*widthRate

                    source: "qrc:/images/bar_btn_smallmain.png"
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                }

                onClicked: {
                    window.visibility = Window.Minimized;
                }
            }
            //maxbutton
            MouseArea {
                id: maxButton
                width: 30*widthRate
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: minButton.right
                anchors.leftMargin:2*widthRate
                //                anchors.verticalCenter: parent.verticalCenter
                //                hoverEnabled: true

                cursorShape: Qt.PointingHandCursor
                Image {
                    width: 14*widthRate
                    height: 14*widthRate
                    source: !fullScreenType ? "qrc:/images/btn_max@2x.png" : "qrc:/images/bar_btn_fullscreen@2x.png"
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                }

                onClicked: {
                    fullScreenBtn.focus = true;
                    fullScreenType = !fullScreenType;
                    setFullScrreen(fullScreenType);


                    console.log("onClicked: {",fullScreenType)


                    //                    if (window.visibility === Window.Maximized){
                    //                        window.visibility = Window.Windowed;
                    //                        //                        mainwindow.x = (1366.0-width)/2
                    //                        //                        mainwindow.y = (768.0-height)/2
                    //                        //                        mainImageView.width=mainwindow.width;
                    //                        //                        mainImageView.height=mianwi
                    //                    }else if (mainwindow.visibility === Window.Windowed){
                    //                        window.showMaximized();
                    //                        window.x = 0
                    //                        window.y = 0
                    //                    }
                }
            }
            //closeButton
            MouseArea {
                id: closeButton
                width: 30*widthRate
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: maxButton.right
                anchors.leftMargin:2*widthRate
                cursorShape: Qt.PointingHandCursor
                //                hoverEnabled: true
                Image {
                    width: 14*widthRate
                    height: 14*widthRate
                    source: "qrc:/images/cr_btn_quit@2x.png"
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                }

                onClicked: {
                    popupWidget.sigExitProject();
                    Qt.quit();
                }
            }

        }
    }
    function changeCurrentTitle( name)
    {
        showCourseText.text=name;
        isOpenedStates = !isOpenedStates;
    }
}
