import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
//新版 评价 不满意不扣课时
Rectangle {
    id:tipEvaluateWidgetItem

    property double widthRates: tipEvaluateWidgetItem.width /  300.0
    property double heightRates: tipEvaluateWidgetItem.width /  300.0 * 1.46
    property double ratesRates: widthRates > heightRates? heightRates : widthRates
    radius: 10 * ratesRates

    color: "#f6f6f6"//#f6f6f6

    property int currentSelectStatus: 1; //1 满意界面 2 不满意届满
    property bool hasSelectReason: false;

    //学生姓名
    property string  studentName: "郭靖"

    //评价 optionId 评价配置ID、用英文逗号隔开 stuSatisfiedFlag 学生是否满意:0不满意、1满意  otherReason 其他原因
    signal sigSaveStuEvaluation(int stuSatisfiedFlag , string optionId , string otherReason);

    //关闭界面
    signal closeTheWidget();
    Rectangle
    {
        radius: 10 * ratesRates
        width: parent.width
        height: 40 * widthRates
        color: "white"
        anchors.top:parent.top
        visible: !sureQuitButton.visible
        Rectangle
        {
            width: parent.width
            height: 20 * widthRates
            color: "white"
            anchors.bottom: parent.bottom
        }
    }


    //提示信息
    Rectangle{
        id: tagNameBackGround
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: 12 * tipEvaluateWidgetItem.heightRates
        anchors.leftMargin: 0 * tipEvaluateWidgetItem.widthRates
        anchors.topMargin: 8 * tipEvaluateWidgetItem.heightRates
        color: "#00000000"
        z:2
        visible: !sureQuitButton.visible
        Text {
            id: tagName
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height:parent.height
            font.pixelSize: 10 * tipEvaluateWidgetItem.heightRates
            color: "#111111"
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            z:2
            text: qsTr("课堂评价")
        }
    }

    //127 标题栏
    Row
    {
        id:titleButton
        spacing: 10 * widthRates
        height: 45 * widthRates
        width: parent.width - 40 * widthRates
        anchors.top: parent.top
        anchors.topMargin: 40 * heightRates
        anchors.horizontalCenter: parent.horizontalCenter
        visible: !sureQuitButton.visible
        Rectangle
        {
            width: ( parent.width - 10 * widthRates ) / 2
            height: width / 3.8
            color: "transparent"
            Image {
                width: parent.width
                height: width / 2.7
                anchors.centerIn: parent
                source: currentSelectStatus == 1 ? "qrc:/images/crfeedback_good_sed@2x.png" : "qrc:/images/crfeedback_good@2x.png"
            }
            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked:
                {
                    currentSelectStatus = 1;
                }

            }
        }

        Rectangle
        {
            width: ( parent.width - 10 * widthRates ) / 2
            height: width / 3.8
            color: "transparent"
            Image {
                width: parent.width
                height: width / 2.7
                anchors.centerIn: parent
                source: currentSelectStatus == 2 ? "qrc:/images/crfeedback_bad_sed@2x.png" : "qrc:/images/crfeedback_bad@2x.png"
            }
            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked:
                {
                    currentSelectStatus = 2;
                }

            }
        }
    }

    //中间的选项框
    Rectangle
    {
        anchors.top: titleButton.bottom
        //anchors.topMargin: 10 * heightRates
        width:titleButton.width + 10 * heightRates
        height: parent.height / 1.5
        color: "transparent"
        anchors.horizontalCenter: parent.horizontalCenter
        visible: !sureQuitButton.visible

        Image {
            anchors.fill: parent

            source: currentSelectStatus == 2 ?　"qrc:/images/bumanyi.png"　: "qrc:/images/manyi.png"
        }
        //不满意处理框
        Column
        {
            id: col_unsatisfy
            width: parent.width - 15 * heightRates
            height: parent.height - 25 * heightRates
            spacing: 5 * heightRates
            anchors.centerIn: parent
            visible: currentSelectStatus == 2
            Text {
                text: qsTr("老师原因")
                font.pixelSize: 8 * tipEvaluateWidgetItem.heightRates
                color: "#111111"
                wrapMode:Text.WordWrap
                font.family: "Microsoft YaHei"
                visible: teacherReasonModel.count > 0
            }

            GridView
            {
                id:grideView
                width: parent.width //+ 5 * heightRates
                height: parent.height / 4.1
                model: teacherReasonModel
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                cellWidth: grideView.width / 3;
                cellHeight: 20 * heightRates
                visible: teacherReasonModel.count > 0
                delegate: Rectangle
                {
                    color: !isSelect ? "#eeeeee" : "#ff5000";
                    width:grideView.width / 3.2
                    height: 15 * heightRates
                    radius: 1 * heightRates
                    border.color: "#dddddd"
                    border.width: 1

                    Text
                    {
                        id:texts
                        text: teacherReasonText
                        width: grideView.width / 3.5
                        font.pixelSize:texts.text.toString().length  > 6 ?  6 * tipEvaluateWidgetItem.heightRates : 6 * tipEvaluateWidgetItem.heightRates
                        color: !isSelect ? "#666666" : "#ffffff"
                        wrapMode:Text.WordWrap
                        font.family: "Microsoft YaHei"
                        anchors.centerIn: parent
                        //anchors.verticalCenter: parent.verticalCenter
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            isSelect = !isSelect;
                            chargeHasSelectReason();//判断是否有选中项

                            //console.log("current index :",index,teacherReasonText)
                        }
                    }
                }

            }


            Text {
                text: qsTr("教室原因")
                font.pixelSize: 8 * tipEvaluateWidgetItem.heightRates
                color: "#111111"
                wrapMode:Text.WordWrap
                font.family: "Microsoft YaHei"
                visible: roomReasonModel.count > 0
            }

            GridView
            {
                id:grideViewt
                width: parent.width
                height: parent.height / 4.1
                model: roomReasonModel
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                cellWidth: grideView.width / 3;
                cellHeight: 20 * heightRates
                visible: roomReasonModel.count > 0
                delegate: Rectangle
                {
                    color: !isSelect ? "#eeeeee" : "#ff5000";
                    width:grideView.width / 3.2
                    height: 15 * heightRates
                    radius: 1 * heightRates
                    border.color: "#dddddd"
                    border.width: 1

                    Text
                    {
                        id:textst
                        text: roomReasonText
                        width: grideView.width / 3.5
                        font.pixelSize:textst.text.toString().length  > 6 ?  6 * tipEvaluateWidgetItem.heightRates : 6 * tipEvaluateWidgetItem.heightRates
                        color: !isSelect ? "#666666" : "#ffffff"
                        wrapMode:Text.WordWrap
                        font.family: "Microsoft YaHei"
                        anchors.centerIn: parent
                        //anchors.verticalCenter: parent.verticalCenter
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            isSelect = !isSelect;
                            chargeHasSelectReason();
                        }
                    }
                }

            }

            Text {
                text: qsTr("其他原因")
                font.pixelSize: 8 * tipEvaluateWidgetItem.heightRates
                color: "#111111"
                wrapMode:Text.WordWrap
                font.family: "Microsoft YaHei"
            }
            //评价内容
            Rectangle{

                //                anchors.left: parent.left
                //                anchors.top: parent.top
                id:tempRectang
                color: "#ffffff"
                border.color: "#E3E6E9"
                border.width: 1
                //radius: 5 *  tipEvaluateWidgetItem.ratesRates
                //                anchors.leftMargin:15 * tipEvaluateWidgetItem.widthRates
                //                anchors.topMargin:  244 * tipEvaluateWidgetItem.heightRates
                width:  parent.width
                height: 50 * tipEvaluateWidgetItem.heightRates - 10 * heightRates//col_unsatisfy.spacing
                z:3
                clip: true

                //                Flickable{
                //                    id: imgScroll
                //                    width: parent.width
                //                    height: parent.height
                //                    contentHeight: tcontentEditText.height + 10 * heightRates
                //                    contentWidth: width
                //                    clip: true

                //                    TextEdit{
                //                        id:tcontentEditText
                //                        //anchors.centerIn: parent
                //                        width: parent.width - 8 * heightRates
                //                        height: 80 * heightRates
                //                        anchors.top:parent.top
                //                        anchors.topMargin: 2 * heightRates
                //                        anchors.left: parent.left
                //                        anchors.leftMargin:  6 * heightRates
                //                        color: "#222222"
                //                        font.family: "Microsoft YaHei"
                //                        selectByMouse:true

                //                        font.pixelSize: 10 *  tipEvaluateWidgetItem.ratesRates
                //                        wrapMode: TextEdit.Wrap
                //                        onLengthChanged:
                //                        {

                //                            if(tcontentEditText.length > 0)
                //                            {
                //                                hasSelectReason = true;
                //                            }else
                //                            {
                //                                chargeHasSelectReason();
                //                            }

                //                            tempRectang.border.color = "#c3c6c9";
                //                            if(tcontentEditText.length >= 200)
                //                            {
                //                                tempRectang.border.color = "#ec3c3c";
                //                                var prePosition = cursorPosition;
                //                                tcontentEditText.text = tcontentEditText.text.substring(0, 200);
                //                                cursorPosition = Math.min(prePosition, 200);
                //                            }
                //                        }
                //                    }
                //            //    }

                TextInput{
                    id:tcontentEditText
                    //anchors.centerIn: parent
                    width: parent.width - 8 * heightRates
                    height: parent.height//80 * heightRates
                    anchors.top:parent.top
                    anchors.topMargin: 2 * heightRates
                    anchors.left: parent.left
                    anchors.leftMargin:  6 * heightRates
                    color: "#222222"
                    font.family: "Microsoft YaHei"
                    selectByMouse: true
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 2 * heightRates
                    font.pixelSize: 10 *  tipEvaluateWidgetItem.ratesRates
                    wrapMode: TextEdit.Wrap
                    onLengthChanged:
                    {

                        if(tcontentEditText.length > 0)
                        {
                            hasSelectReason = true;
                        }else
                        {
                            chargeHasSelectReason();
                        }

                        tempRectang.border.color = "#c3c6c9";
                        if(tcontentEditText.length >= 200)
                        {
                            tempRectang.border.color = "#ec3c3c";
                            var prePosition = cursorPosition;
                            tcontentEditText.text = tcontentEditText.text.substring(0, 200);
                            cursorPosition = Math.min(prePosition, 200);
                        }
                    }
                }



                Text {
                    id: contentEditTip
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 4 * heightRates
                    //anchors.topMargin: 2 * heightRates
                    width: parent.width - 4 *  heightRates
                    height: parent.height - 4 * heightRates
                    color: "#c3c6c9"
                    wrapMode:Text.WordWrap
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 10 *  tipEvaluateWidgetItem.ratesRates
                    text: qsTr("其他原因，最多二百个中文字符超过不予填写。")
                    //opacity:tcontentEditText.length > 0? 0 :1
                    visible: !tcontentEditText.focus
                }
            }

        }

        //满意处理框
        Column
        {
            width: parent.width - 15 * heightRates
            height: parent.height - 25 * heightRates
            spacing: 5 * heightRates
            anchors.centerIn: parent
            visible: currentSelectStatus == 1
            GridView
            {
                id:sGrideView
                width: parent.width
                height: parent.height
                model: satisfactionModel
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                cellWidth: sGrideView.width / 3;
                cellHeight: 20 * heightRates
                delegate: Rectangle
                {
                    color: !isSelect ? "#eeeeee" : "#ff5000";
                    width:sGrideView.width / 3.2
                    height: 15 * heightRates
                    radius: 1 * heightRates
                    border.color: "#dddddd"
                    border.width: 1

                    Text
                    {
                        id:stexts
                        text: satisfiedText
                        width: sGrideView.width / 3.5
                        font.pixelSize:stexts.text.toString().length  > 6 ?  6 * tipEvaluateWidgetItem.heightRates : 6 * tipEvaluateWidgetItem.heightRates
                        color: !isSelect ? "#666666" : "#ffffff"
                        wrapMode:Text.WordWrap
                        font.family: "Microsoft YaHei"
                        anchors.centerIn: parent
                        //anchors.verticalCenter: parent.verticalCenter
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            isSelect = !isSelect;
                        }
                    }
                }

            }


        }
    }
    ListModel
    {
        id:teacherReasonModel
    }

    ListModel
    {
        id:roomReasonModel
    }
    ListModel
    {
        id:satisfactionModel
    }


    //确定按钮
    Rectangle{
        id:okBtn
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 15 *  tipEvaluateWidgetItem.widthRates
        anchors.bottomMargin:  8 * tipEvaluateWidgetItem.heightRates
        width:  270  *  tipEvaluateWidgetItem.widthRates
        height:  22 * tipEvaluateWidgetItem.heightRates
        enabled: currentSelectStatus == 2 ?  hasSelectReason  : true
        color: "#ff5000"
        radius: 2 * tipEvaluateWidgetItem.heightRates
        z:3
        visible: !sureQuitButton.visible
        Text {
            id: okBtnName
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14  * tipEvaluateWidgetItem.ratesRates
            wrapMode:Text.WordWrap
            font.family: "Microsoft YaHei"
            color: "#ffffff"
            text: qsTr("提交评价")
        }
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            enabled: okBtn.enabled
            onEnabledChanged: {
                if(enabled) {
                    okBtn.color = "#ff5000";

                }else {
                    okBtn.color = "#c3c6c9";

                }

            }

            onPressed: {
                okBtn.color = "#c3c6c9";

            }
            onReleased: {
                okBtn.color = "#ff5000";

                // sigEvaluateContents(teachingContentType,teachingAttitudeType ,homeworkType ,tcontentEditText.text );
                saveStuEvaluation();
                tcontentEditText.text = "";

            }
        }
    }

    //关闭按钮
    Rectangle{
        id:closeBtn
        width: 22  * tipEvaluateWidgetItem.ratesRates
        height: 22 * tipEvaluateWidgetItem.ratesRates
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 10 * tipEvaluateWidgetItem.ratesRates
        anchors.rightMargin:  8 * tipEvaluateWidgetItem.ratesRates
        color: "#00000000"
        z:3
        visible: !sureQuitButton.visible
        Image {
            width: parent.width
            height: parent.height
            source: "qrc:/images/cr_btn_quittwo.png"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                sureQuitButton.visible = true;
                tcontentEditText.text = "";
            }
        }
    }

    Rectangle
    {
        id:sureQuitButton
        anchors.fill: parent
        color: "transparent"
        z:100
        visible: false

        Rectangle{
            id: backView
            width: 240 * widthRates;
            height: 60 * heightRates;
            radius:  6
            anchors.centerIn: parent
            color: "#ffffff"

            Text {
                text: qsTr("还没评价呢，确定离开吗")
                //color:  "#cccccc"
                font.pixelSize: 12  * tipEvaluateWidgetItem.ratesRates
                font.family: "Microsoft YaHei"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 35 * heightRates
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row{
                width: parent.width * 0.8
                height: 35 * heightRate
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5 * heightRates
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10 * heightRates

                MouseArea{
                    width: parent.width  * 0.5
                    height: parent.height
                    cursorShape: Qt.PointingHandCursor

                    Rectangle{
                        anchors.fill: parent
                        radius: 6 * heightRates
                        color: "#ffffff"
                        border.color: "#cccccc"
                        border.width: 1
                    }

                    Text {
                        text: qsTr("取消")
                        color:  "#cccccc"
                        font.pixelSize: 14  * tipEvaluateWidgetItem.ratesRates
                        font.family: "Microsoft YaHei"
                        anchors.centerIn: parent
                    }
                    onClicked: {
                        sureQuitButton.visible = false;
                    }
                }

                MouseArea{
                    width: parent.width  * 0.5
                    height: parent.height
                    cursorShape: Qt.PointingHandCursor

                    Rectangle{
                        anchors.fill: parent
                        radius: 6 * heightRates
                        color: "#ff5000"
                        border.color: "#cccccc"
                        border.width: 1
                    }

                    Text {
                        text: qsTr("确定")
                        color:  "#ffffff"
                        font.pixelSize: 14  * tipEvaluateWidgetItem.ratesRates
                        font.family: "Microsoft YaHei"
                        anchors.centerIn: parent
                    }
                    onClicked: {
                        closeTheWidget();
                    }
                }
            }
        }

        onVisibleChanged:
        {
            if(visible)
            {
                parent.color = "transparent";
            }else
            {
                parent.color = "#f6f6f6";
            }
        }
    }


    function chargeHasSelectReason()
    {
        hasSelectReason = false;
        for(var i = 0; i<roomReasonModel.count; i ++)
        {
            var isselects = roomReasonModel.get(i).isSelect

            if(isselects == true)
            {
                hasSelectReason = true;
                break;
            }
        }

        if(!hasSelectReason)
        {
            for(var ii = 0; ii<teacherReasonModel.count; ii ++)
            {
                var isselectss = teacherReasonModel.get(ii).isSelect
                if(isselectss)
                {
                    hasSelectReason = true;
                    break;
                }
            }
        }
    }
    function resetAllReasonModel(modelData)
    {
        var data = modelData.data;
        //console.log("updateAllReasonModel(modelData)",JSON.stringify(data[0]),data.length);
        for(var i = 0; i< data.length; i++)
        {
            var detailData = data[i];
            console.log("updateAllReasonModel(modelData)w",JSON.stringify(detailData),data.length);
            //不满意的
            if(detailData.satisfactoryType == 0)
            {
                if(detailData.type == 1)//老师原因
                {
                    teacherReasonModel.append(
                                {
                                    "teacherReasonText":detailData.optionName,
                                    "isSelect":false,
                                    "id":detailData.id,
                                    "optionName":detailData.optionName,
                                    "satisfactoryType":detailData.satisfactoryType,
                                })
                }else if(detailData.type == 2)//技术原因
                {
                    roomReasonModel.append(
                                {
                                    "roomReasonText":detailData.optionName,
                                    "isSelect":false,
                                    "id":detailData.id,
                                    "optionName":detailData.optionName,
                                    "satisfactoryType":detailData.satisfactoryType,
                                })
                }
            }else
            {
                satisfactionModel.append(
                            {
                                "satisfiedText":detailData.optionName,
                                "isSelect":false,
                                "id":detailData.id,
                                "optionName":detailData.optionName,
                                "satisfactoryType":detailData.satisfactoryType,
                            })
            }
        }

    }

    function saveStuEvaluation()
    {
        var optionId = "";
        //满意界面
        if(currentSelectStatus == 1)
        {
            //获取 拼接满意的optionId

            for(var i = 0; i < satisfactionModel.count; i++)
            {
                if(satisfactionModel.get(i).isSelect)
                {

                    if(optionId == "")
                    {
                        optionId = satisfactionModel.get(i).id;
                    }else
                    {
                        optionId = optionId + "," + satisfactionModel.get(i).id;
                    }

                }
            }
            console.log("function saveStuEvaluation() optiont Id",optionId);
            sigSaveStuEvaluation(1 , optionId , "");


        }else if(currentSelectStatus == 2)//不满意界面
        {


            for(var a = 0; a < teacherReasonModel.count; a++)
            {
                if(teacherReasonModel.get(a).isSelect)
                {

                    if(optionId == "")
                    {
                        optionId = teacherReasonModel.get(a).id;
                    }else
                    {
                        optionId = optionId + "," + teacherReasonModel.get(a).id;
                    }

                }
            }

            for(var b = 0; b < roomReasonModel.count; b++)
            {
                if(roomReasonModel.get(b).isSelect)
                {
                    if(optionId == "")
                    {
                        optionId = roomReasonModel.get(b).id;
                    }else
                    {
                        optionId = optionId + "," + roomReasonModel.get(b).id;
                    }
                }
            }

            sigSaveStuEvaluation( 0 , optionId , tcontentEditText.text);
        }
    }

}

