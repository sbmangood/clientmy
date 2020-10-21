import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import "./Configuuration.js" as Cfg

/*
教室内成员状态显示区
*/

Rectangle {
    width: 200 * widthRates
    height: 82 * widthRates - 22 * widthRates
    MouseArea {
        anchors.fill: parent
        onPressed: {
            return;
        }
    }

    ListView {
        id:memberStatusListView
        anchors.fill: parent
        model: showMemberStatusViewModel
        orientation: ListView.Horizontal
        clip: true
        boundsBehavior: ListView.StopAtBounds
        delegate:  MouseArea {
            height: 60 * heightRate
            width: 75 * heightRate
            hoverEnabled: true
            //cursorShape: Qt.PointingHandCursor
            Image {
                id:statusImg
                width: 65 * heightRate
                height: width
                anchors.centerIn: parent
                //source:!parent.containsMouse ? "qrc:/newStyleImg/pc_icon_teachermacrio_off@2x.png" : "qrc:/newStyleImg/pc_icon_teachermacrio_on@2x.png"
                source:{
                    if(userType == "student_A")
                    {
                        if(onlineStatus == "1")
                        {
                            return "qrc:/newStyleImg/pc_icon_sd_on@2x.png"
                        }
                        return "qrc:/newStyleImg/pc_icon_sd_off@2x.png"
                    }else
                    {
                        //判断用户类型
                        if(userName.indexOf(qsTr("老师")) != -1)
                        {                            
                            if(holdMicStatus == "1")
                            {
                                if(onlineStatus == "1")
                                {
                                    return "qrc:/newStyleImg/pc_icon_teachermacrio_on@2x.png"
                                }else
                                {
                                    return "qrc:/newStyleImg/pc_icon_teachermacrio_off@2x.png"
                                }
                            }else
                            {
                                if(onlineStatus == "1")
                                {
                                    return "qrc:/newStyleImg/pc_icon_teacher_on@2x.png"
                                }else
                                {
                                    return "qrc:/newStyleImg/pc_icon_teacher_off@2x.png"
                                }
                            }
                        }else if(userName.indexOf(qsTr("课程顾问")) != -1)
                        {//cc
                            if(holdMicStatus == "1")
                            {
                                if(onlineStatus == "1")
                                {
                                    return "qrc:/newStyleImg/pc_icon_consultant_off@2x(1).png"
                                }else
                                {
                                    return "qrc:/newStyleImg/pc_icon_consultantmacrio_off@2x.png"
                                }
                            }else
                            {
                                if(onlineStatus == "1")
                                {
                                    return "qrc:/newStyleImg/pc_icon_consultant_on@2x.png"
                                }else
                                {
                                    return "qrc:/newStyleImg/pc_icon_consultant_off@2x.png"
                                }
                            }
                        }
                    }
                }
            }
            Text {
                text: userName
                elide: Text.ElideRight
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top:statusImg.bottom
                anchors.topMargin: 10 * heightRate
                font.pixelSize: 12 * heightRate
                font.family: Cfg.DEFAULT_FONT
                color: "#111111"
                visible: false
            }
        }
    }

    function initMemberStatus(memberList)
    {
        var teacherId = curriculumData.getTeacherId();
        var currentUserId = curriculumData.getCurrentUserId();
        var joinMicId = curriculumData.getJoinMicId();
        var teacherName = "";
        console.log("initMemberStatus1",teacherId,"q",currentUserId,"w",joinMicId,teacherType)
        for(var j = 0; j < memberList.length ; j++) {
            var dataObject = curriculumData.getUserInfo(memberList[j]);

            var userName = dataObject.userName;//用户名
            if(memberList[j] == 0)
            {
                teacherName = userName;
                continue
            }
            var userOnline = dataObject.userOnline;//用户在线状态
            var isteacher = dataObject.isteacher;//老师状态
            var ccIsOnline = curriculumData.justCCIsOnline();//cc是否在线
            //console.log("initMemberStatus2",j,memberList[j],isteacher,userOnline,joinMicId,"ww",teacherId);
            //            "userType":"student_A",//
            //            "holdMicStatus":"0",//持麦状态 1 持麦 0 非持麦

            //getTeacherId() getJoinMicId()
            //自己
            if(memberList[j] == teacherId)
            {
                showMemberStatusViewModel.append(
                            {
                                "userId":teacherId
                                , "userName": teacherName + "老师"
                                , "onlineStatus":curriculumData.justUserIsOnline(teacherId) ? "1" : "0"
                                , "userType": "teacher"
                                , "holdMicStatus": (teacherId == joinMicId ) ? "1" : "0"
                            }
                            );
                if(currentListenRoleType == 2)
                {
                    showMemberStatusViewModel.insert(0,
                                                     {
                                                         "userId":currentUserId
                                                         , "userName": "课程顾问"
                                                         , "onlineStatus":"1"
                                                         , "userType": "assistent"
                                                         , "holdMicStatus": (teacherType == "T" ) ? "1" : "0"
                                                     }
                                                     );
                }else if(currentListenRoleType == 1)
                {
                    console.log("currentListenRoleType == 1",ccIsOnline)

                    var ccId = curriculumData.getCCId();

                    showMemberStatusViewModel.append(
                                {
                                    "userId":ccId
                                    , "userName": "课程顾问"
                                    , "onlineStatus": ccIsOnline ? "1" : "0"//判断课程顾问在不在线
                                    , "userType": "assistent"
                                    , "holdMicStatus": (ccId == joinMicId ) ? "1" : "0"
                                }
                                );
                }

            }else
            {
                showMemberStatusViewModel.append(
                            {
                                "userId":memberList[j]
                                , "userName": 1 == isteacher ? (userName + "老师") : (userName)
                                , "onlineStatus": curriculumData.justUserIsOnline(memberList[j]) ? "1" : "0"
                                , "userType": 1 == isteacher ? "teacher" : "student_A"
                                , "holdMicStatus": isteacher ? ( "T" == teacherType ? "1" : "0" ) : "1" //学生默认持麦
                            }
                            );
            }

        }
    }

    function updateUserStatus()
    {
        console.log("updateUserStatus()1")
        var joinMicId = curriculumData.getJoinMicId();
        var ccId = curriculumData.getCCId();
        for(var j = 0 ; j < showMemberStatusViewModel.count ; j++){
            var userId = showMemberStatusViewModel.get(j).userId;
            var userType = showMemberStatusViewModel.get(j).userType;
            if("assistent" == userType && userId == "")
            {
                userId = ccId;
                if(userId != "")
                {
                    showMemberStatusViewModel.get(j).userId = userId;
                }else
                {
                    showMemberStatusViewModel.get(j).onlineStatus = curriculumData.justCCIsOnline();
                    showMemberStatusViewModel.get(j).holdMicStatus = (userId == joinMicId ? "1" : "0");
                    console.log("updateUserStatus()2",showMemberStatusViewModel.get(j).onlineStatus,showMemberStatusViewModel.get(j).userType,showMemberStatusViewModel.get(j).userId)
                    continue;
                }
            }
            showMemberStatusViewModel.get(j).onlineStatus = (curriculumData.justUserIsOnline(userId) ? "1" : "0");
            showMemberStatusViewModel.get(j).holdMicStatus = (userId == joinMicId ? "1" : "0");
            console.log("updateUserStatus()3",showMemberStatusViewModel.get(j).onlineStatus,showMemberStatusViewModel.get(j).userType,showMemberStatusViewModel.get(j).userId)

        }
    }
}
