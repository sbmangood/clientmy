import QtQuick 2.0
//身份选择时弹窗  学生身份 家长身份
import "Configuration.js" as Cfg
Rectangle {
    property bool isStudentBeselect: true;
    id:mainBackGroundRectangle
    visible: true
    color:Qt.rgba(0,0,0,0.60)
    //
    Rectangle{//背景
        anchors.centerIn: parent
        width: parent.width*0.25
        height:parent.height/3
        color:"#ffffff"
        radius: 12*heightRate

        Rectangle//身份 说明图片
        {
            id:photoRectangle
            width: parent.width
            height: 120*heightRate
            color:"transparent"
            //x:parent.width/4
            Image{
                anchors.fill: parent
                source: "qrc:/images/dialog_familylogin_head@2x.png"
            }
        }


        Rectangle//旁听说明字体
        {
            width:parent.width
            height:20*heightRate
            anchors.top:photoRectangle.bottom
            anchors.topMargin:25*heightRate

            Text {
                anchors.centerIn: parent
                text: qsTr("在孩子上课时，您可以进入教室旁听")
                color:"#3c3c3e"
                font.pixelSize: 20*heightRate
                font.family: Cfg.DEFAULT_FONT
            }
        }
        Rectangle//知道了按钮
        {
            width:parent.width*0.9
            height:52*heightRate
            anchors.bottom:parent.bottom
            anchors.bottomMargin:18*heightRate
            radius:5*heightRate
            anchors.left:parent.left
            anchors.leftMargin:12*widthRate
            color:"#ff5000"
            Text {
                anchors.centerIn: parent
                text: qsTr("知道了")
                color:"#ffffff"
                font.pixelSize: 22*heightRate
                font.family: Cfg.DEFAULT_FONT
            }
            MouseArea
            {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked:
                {
                    mainBackGroundRectangle.visible=false;
                    var nowUserSettingData=accountMgr.getUserLoginInfo();
                    console.log("get",nowUserSettingData);
                    // var role=isStudentUser ? 1 : 0;
                    //  var parentbeshowed=isParentRemindHadShowed ? 1 :0;
                    isParentRemindHadShowed=true;
                    accountMgr.saveUserInfo(nowUserSettingData[0],nowUserSettingData[1],nowUserSettingData[2],nowUserSettingData[3],nowUserSettingData[4],1,nowUserSettingData[6]);

                }
            }

        }

    }
}

