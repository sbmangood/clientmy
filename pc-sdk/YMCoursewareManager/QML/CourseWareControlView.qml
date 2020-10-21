import QtQuick 2.7
import QtQuick.Controls 2.0
//import CourseWareViewManager 1.0
//课件显示层控制中心  图片课件 结构化课件 h5课件

Item {
    anchors.fill: parent
    property int currentBeshowViewType: 0;// 当前被显示的课件界面类型 0空白界面 1图片课件界面 2结构化课件 3 h5课件
    signal sigImageLoadReadys();// 图像加载状态未ready
    signal sigChangeScoreBarVisibles(var visibles);// 设置滚动条的显示状态
    signal sigUploadLoadingImgFailLogs();// 图片加载失败信号
    signal sigAnimationNotifications(var animationStepIndex);// 动画同步通知信号,用于通知对方目前动画播放到第几步，animationStepIndex为动画步骤索引
    signal sigLoadCoursewareSuccess();// 加载课件成功信号

    /*
    CourseWareViewManager {
        // 获取课件视图
        onSigGetCourseWareView: {

        }
        // 展示课件
        onSigShowCourseWareView: {
            setCoursewareVisible(currentBeshowViewType, true);
        }
        // 隐藏课件
        onSigHideCourseWareView: {
            setCoursewareVisible(0, false);
            setCoursewareVisible(1, false);
            setCoursewareVisible(2, false);
            setCoursewareVisible(3, false);
        }
    }
*/
    //图片课件界面
    ImageView {
        id: imageView
        anchors.fill: parent
        visible: currentBeshowViewType == 1
        enabled: currentBeshowViewType == 1
        onSigImageLoadReady:
        {
            sigImageLoadReadys();
        }
        onSigChangeScoreBarVisible:
        {
            sigChangeScoreBarVisibles(visibles);
        }
        onSigUploadLoadingImgFailLog: {
            sigUploadLoadingImgFailLogs();
        }
    }

    // H5课件界面
    H5EngineView {
        id: h5EngineView
        anchors.fill: parent
        visible: currentBeshowViewType == 3
        enabled: currentBeshowViewType == 3
        onSigAnimationNotification: {
            sigAnimationNotifications(animationIndex);
        }
        onSigLoadH5Success: {
            sigLoadCoursewareSuccess();
        }
    }

    // 设置课件类型和课件url, role:教师“teacher”、学生“student”
    function setCoursewareSource(role, coursewareType, url, width, height, token)
    {
        currentBeshowViewType = coursewareType;
        if(coursewareType == 1){// 图片课件
            imageView.setBeShowImgUrl(url, width, height);
        }
        else if(coursewareType == 2){// 结构化课件需要区分角色

        }
        else if(coursewareType == 3){// H5课件
            if(url == ""){
                return;
            }
            h5EngineView.setBeShowedH5CourseWareUrl(url, token);
        }
    }

    // 设置课件的可见性
    function setCoursewareVisible(coursewareType, isVisible)
    {
        if(coursewareType == 1){// 图片课件
            imageView.setImgViewVisible(isVisible);
        }
        else if(coursewareType == 2){// 结构化课件
        }
        else if(coursewareType == 3){// H5课件
            h5EngineView.setWebEngineViewVisible(isVisible);
        }
    }

    // 清除课件源
    function clearCoursewareSource(coursewareType)
    {
        if(coursewareType == 1){// 图片课件
            imageView.removeImgViewUrl();
        }
        else if(coursewareType == 2){// 结构化课件

        }
        else if(coursewareType == 3){// H5课件
            h5EngineView.removeWebEngineViewUrl();
        }
    }

    /*******************************************************************************
     * 课件操作接口
     * 参数：coursewareType 课件类型 0空白界面 1图片课件界面 2h5课件 3结构化课件
     *      operationType  操作类型 0上一页 1下一页 2增一页 3减一页 4跳转到指定页 5点击事件
     *      operationIndex 操作索引 要操作到的索引，比如跳转的索引
     *      step           动画播放步骤
     *******************************************************************************/
    function coursewareOperation(coursewareType, operationType, operationIndex, step){
        // 目前只有H5课件需要此接口
        if(coursewareType == 3){
            if(operationType == 0){// 上一页
                h5EngineView.goBackPage();
            }
            else if(operationType == 1){// 下一页
                h5EngineView.goNextPage();
            }
            else if(operationType == 2){// 增一页
                h5EngineView.addPage();
            }
            else if(operationType == 3){// 减一页
                h5EngineView.deletePage();
            }
            else if(operationType == 4){// 跳转到指定页
                h5EngineView.goNewPage(operationIndex);
            }
            else if(operationType == 5){// 鼠标点击事件通知web端播放动画
                h5EngineView.stepClick(step);
            }
        }
    }

    /***************************
     * H5课件加载同步信息设置
     ***************************/
    function h5CoursewareSetPlanInfo(json){
        h5EngineView.setPlanInfo(json);
    }

    /***************************
     * H5课件同步函数
     **************************/
    function coursewareSyn(jsonObj){
        h5EngineView.setPlanInfodata(jsonObj);
    }
}
