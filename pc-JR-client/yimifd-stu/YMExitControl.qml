﻿import QtQuick 2.0
import QtQuick.Controls 2.0

//点击右上角"设置"按钮以后, 弹出来的菜单
Popup{
    id: exitMouseArea
    width: 90 * widthRate
    height:  3 * 46 * heightRate

    signal updatePwd();//修改密码信号
    signal exitConfirm();
    signal changeRole();
    signal deviceDisplayer()//显示测试设备信号
    signal showInformation();//显示个人信息信号

    background: Image{
        anchors.fill: parent
        source: "qrc:/images/edit_xiala@2x.png"
        fillMode: Image.Stretch
    }

    Column{
        z: 2
        width: parent.width - 40 * widthRate
        height: parent.height - 40 * heightRate
        anchors.horizontalCenter: parent.horizontalCenter
       // anchors.centerIn: parent
        spacing: 5 * widthRate
//        YMMenuButton{
//            width: parent.width
//            height: 35*heightRate
//            displayerText: "个人中心"
//        }

        YMMenuButton{
            width: parent.width
            height: 35 * heightRate
            displayerText: "修改密码"
            onClicked: {
                updatePwd();
                exitMouseArea.close();
            }
        }
        YMMenuButton{
            width: parent.width
            height: 35*heightRate
            displayerText: "联系客服"
            onClicked: {
                showInformation();
                exitMouseArea.close();
            }
        }

        YMMenuButton{
            width: parent.width
            height: 35*heightRate
            displayerText: "退出登录"
            onClicked: {
                exitConfirm();
                exitMouseArea.close();
            }
        }

    }
}