import QtQuick 2.0
import QtQuick.Controls 1.4
import "./Configuuration.js" as Cfg
import QtQuick 2.5
/*随机选人*/
Item {
    id:randomView
    width: 762 * widthRates * 0.35
    height: 764 * widthRates * 0.35

    property var  widthRates : widthRate * 0.7;

    property var allStuArryData: ;//当前在线人的所有数据

    property var stuUserNameBufferList: [];//所有学生的用户名list
    property int timerRunTimes: 0;//随机次数
    property var randomUserName: "" ;//随机选人的结果
    property bool currentUserCanOperation: false;//当前使用者是否有操作权限 控制是否可以操作开始随机选人


    signal closeRandomView();//关闭随机选人界面
    signal startRandom(var userId);//开始随机选人


    MouseArea{
        anchors.fill: parent
        onClicked:
        {

        }
    }

    //背景
    Image {
        width:  376 * heightRate
        height: 269 * heightRate
        source: "qrc:/images/xbk_popwindow_bg_xuanren.png"
    }

    //关闭按钮
    Image {
        width: 52 * widthRates * 0.7
        height: 40 * widthRates * 0.7
        visible: currentUserCanOperation
        source: "qrc:/images/xb_button_close1@2x.png"
        anchors.left: parent.left
        anchors.leftMargin: -3 * widthRates
        anchors.bottom:parent.bottom
        anchors.bottomMargin: -3 * widthRates
        z:15
        MouseArea
        {
            anchors.fill:parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onPressed:
            {
                parent.source = "qrc:/images/xb_button_close2@2x.png";
            }

            onReleased:
            {
                parent.source = "qrc:/images/xb_button_close1@2x.png";
            }
            onClicked:
            {
                randomView.visible = false;
                closeRandomView();
            }
        }
    }


    Image {
        id: startButton
        width: 538 * widthRates * 0.3
        height: 130 * widthRates * 0.3
        visible: currentUserCanOperation
        source: "qrc:/images/xb_button_lijikaishi1@2x.png"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8 * widthRates
        anchors.horizontalCenter: parent.horizontalCenter

        MouseArea
        {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onPressed:
            {
                startButton.source = "qrc:/images/xb_button_lijikaishi2@2x.png";
            }

            onReleased:
            {
                startButton.source = "qrc:/images/xb_button_lijikaishi1@2x.png";
            }

            onClicked:
            {
                if(stuUserNameBufferList.length > 0)
                {
                    var tNum = stuUserNameBufferList.length - 1;
                    var randomNum = Math.floor(Math.random() * tNum + 1);
                    randomUserName = stuUserNameBufferList[randomNum];

                    startRandom(getUserIdByName(randomUserName));

                    runTimer.start();
                    startButton.enabled = false;
                }
            }

        }
    }

    Text{
        id: randomText
        anchors.top: parent.top
        anchors.topMargin: 130 * widthRates
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.5 - (randomText.width *  0.4)
        font.pixelSize: 22 * widthRates
        font.family: Cfg.font_family
        color: "#E33737"
    }
    Timer
    {
        id:runTimer
        interval: 200
        running: false
        repeat: true
        onTriggered: {
            var randomNum = Math.ceil(Math.random() * (stuUserNameBufferList.length));
            randomText.text = stuUserNameBufferList[randomNum - 1];
            ++timerRunTimes;

            if(timerRunTimes == 29)
            {
                runTimer.stop();
                randomText.text = randomUserName;
                timerRunTimes = 0;
                startButton.enabled = true;
            }
        }
    }


    //重设随机选人数据 有操作权限者 每次显示的时候重置数据用
    function resetRandomModel(stuDataArry)
    {

        allStuArryData = stuDataArry;

        stuUserNameBufferList = [];
        //for test
        //        stuUserNameBufferList.push("12345678901");
        //        stuUserNameBufferList.push("12345678903");
        //        stuUserNameBufferList.push("12345678902");
        //        stuUserNameBufferList.push("12345678904");
        //        stuUserNameBufferList.push("12345678905");

        for(var a = 0; a < stuDataArry.length; a++)
        {
            stuUserNameBufferList.push(stuDataArry[a].userName);
        }
        if(stuUserNameBufferList.length > 0 )
        {
            randomText.text = stuUserNameBufferList[0];
        }else
        {
            randomText.text = "学生不在线~~"
        }
    }

    //根据提供的数据显示对应的结果
    function randomByGiveData(userName)//stuDataArry,userId)
    {
        randomView.visible = true;
//        allStuArryData = stuDataArry;
//        console.log("randomByGiveData(stuDataArry,userId)",stuDataArry,userId);
//        stuUserNameBufferList = [];
//        for(var a = 0; a < stuDataArry.length; a++)
//        {
//            if(("1" == stuDataArry[a].userOnline))
//            {
//                stuUserNameBufferList.push(stuDataArry[a].userName);
//            }
//        }
        randomText.text = userName;
        randomUserName = userName;//getUserNameById(userId);
//        runTimer.start();
    }

    function getUserNameById(userId)
    {
        for(var a = 0; a < allStuArryData.length; a++)
        {
            if(allStuArryData[a].userId == userId)
            {
                return allStuArryData[a].userName
            }
        }
    }

    function getUserIdByName(userName)
    {
        for(var a = 0; a < allStuArryData.length; a++)
        {
            if(allStuArryData[a].userName == userName)
            {
                return allStuArryData[a].userId
            }
        }
    }



}
