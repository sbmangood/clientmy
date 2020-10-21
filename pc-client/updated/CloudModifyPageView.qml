import QtQuick 2.0
import "Configuration.js" as Cfg

/*
*批改、答题解析导航栏
*/

Rectangle {
    id:mainViewItem
    width: 300 * heightRate
    height: 105 * heightRate
    color: "transparent"
    signal sigModify();//批改信号
    signal sigAnswer();//答题信号
    property  int currentType: cloudRoomMenu.currenItemType;
    property bool fullScreenBtnVisible: fullScreenBtn.visible

    property bool modifyIsOpen : false;//当前
    property bool answerIsOpen : false;

    //    onCurrentTypeChanged:
    //    {
    //        console.log("fdsaaaaaaaaaaa",currentType);
    //        answerDetailButtons.visible = false;
    //        teacherCheckButtons.visible = false;

    //        if(cloudRoomMenu.visible == false){return;}
    //        if(currentType == 1 )
    //        {
    //            answerDetailButtons.visible = true;
    //        }
    //        if(currentType == 2)
    //        {
    //            answerDetailButtons.visible = true;
    //            teacherCheckButtons.visible = true;
    //        }
    //    }
    //    onFullScreenBtnVisibleChanged:
    //    {
    //        console.log("fdsaaaaaa111111aaaaa",currentType);
    //        if(fullScreenBtnVisible)
    //        {
    //            if(currentType == 1 )
    //            {
    //                answerDetailButtons.visible = true;
    //            }
    //            if(currentType == 2)
    //            {
    //                answerDetailButtons.visible = true;
    //                teacherCheckButtons.visible = true;
    //            }
    //        }else
    //        {
    //            answerDetailButtons.visible = false;
    //            teacherCheckButtons.visible = false;
    //        }
    //    }


    //答案解析
    MouseArea {
        id:answerDetailButtons
        hoverEnabled: true
        width: 115 * heightRate
        height: width / 3
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        cursorShape: Qt.PointingHandCursor
        // enabled: bottomToolbars.whetherAllowedClick
        visible: false
        onVisibleChanged:
        {
            if(fullScreenType)
            {
                visible = false;
            }
        }

        //visible: cloudRoomMenu.visible ? (currentType == 1 ? true : false ) : false
        Image {
            id:analyButtonImage
            width: parent.width
            height: width / 2.1
            anchors.centerIn: parent
            source: toobarWidget.teacherEmpowerment ? ( parent.containsMouse ? "qrc:/cloudImage/btn_daanjiexi_sed@2x.png" : "qrc:/cloudImage/btn_daanjiexi@2x.png" ) : "qrc:/cloudImage/btn_daanjiexi_disable@2x.png";
        }

        onPressed: {
            if(toobarWidget.teacherEmpowerment)
            {
                if(answerIsOpen)
                {
                    if(knowledgesView.visible == false)
                    {
                        sigAnswer();
                        return;
                    }
                    answerIsOpen = !answerIsOpen;
                    return;
                }

                console.log("toobarWidget.teacherEmpowerment",answerIsOpen,knowledgesView.visible);
                if(!answerIsOpen)
                {
                    sigAnswer();
                }

                answerIsOpen = !answerIsOpen;
            }else
            {
                //cloudTipView.setNoPowerTip();
                popupWidget.setPopupWidget("noselectpower");
            }

        }

    }

    //老师批改
    MouseArea{
        id:teacherCheckButtons
        hoverEnabled: true
        width: 105 * heightRate
        height: width / 3
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        cursorShape: Qt.PointingHandCursor
        //enabled: bottomToolbars.whetherAllowedClick
        visible: false
        onVisibleChanged:
        {
            if(fullScreenType)
            {
                visible = false;
            }
        }

        // visible: cloudRoomMenu.visible ? (currentType == 2 ? true : false) : false
        Image{
            width: parent.width
            height: width / 1.9
            anchors.centerIn: parent
            source:toobarWidget.teacherEmpowerment ? (  parent.containsMouse ? "qrc:/cloudImage/btn_sd_pigai_Sed@2x.png" : "qrc:/cloudImage/btn_sd_pigai@2x.png" ) : "qrc:/cloudImage/btn_sd_pigai_disable@2x.png"
        }

        onPressed: {
            if(toobarWidget.teacherEmpowerment)
            {
                if(modifyIsOpen)
                {
                    if(modifyHomework.visible == false)
                    {
                        sigModify();
                        return;
                    }
                    modifyIsOpen = !modifyIsOpen;
                    return;
                }

                if(!modifyIsOpen)
                {
                    sigModify();
                }
                modifyIsOpen = !modifyIsOpen;
            }else
            {
                //cloudTipView.setNoPowerTip();
                popupWidget.setPopupWidget("noselectpower");
            }
        }
    }
    //判断是否显示 答案解析 和 批改按钮  如果是 空白页就不显示
    function resetAllItemView()
    {
        mainViewItem.visible = true;
        answerDetailButtons.visible = false;
        teacherCheckButtons.visible = false;

        if( currentType == 1 )
        {
            //新需求对应: 学生端"答案解析", 隐藏掉, "答案解析"查看的权限, 由老师控制20180907_wuneng
//            answerDetailButtons.visible = true;
        }
        if( currentType == 2 )
        {
            //新需求对应: 学生端"答案解析", 隐藏掉, "答案解析"查看的权限, 由老师控制20180907_wuneng
//            answerDetailButtons.visible = true;
            teacherCheckButtons.visible = true;
        }

    }
}

