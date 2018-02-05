import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1

import "./scripts/AddTarget.js" as AddTarget

ApplicationWindow {
    id:app;
    width: 1280;
    height: 720;
    minimumWidth: 1280;
    minimumHeight: 70;
    maximumWidth: 1280;
    maximumHeight: 720;
    title: qsTr("PCBView");
    visible: true;
    Material.accent: Material.Purple;

    property Component component: null;
    property var targets: [];

    // 创建target
    function addTarget( isSelected,
                       targetPosX,
                       targetPosY,
                       targetWidth,
                       targetHeight,
                       borderWidth,
                       borderColor,
                       fillCorlor,
                       targetShape ){
        if(app.component == null){
            app.component = Qt.createComponent("./Component/Target.qml");
        }
        var curTarget;
        if(app.component.status == Component.Ready){
            curTarget = app.component.createObject(
                        app,{ "isSelect":isSelected,
                            "targetPosX":targetPosX,
                            "targetPosY":targetPosY,
                            "targetWidth":targetWidth,
                            "targetHeight":targetHeight,
                            "borderWidth":borderWidth,
                            "borderColor":borderColor,
                            "fillCorlor":fillCorlor,
                            "targetShape":targetShape })
            canvasPCBView.requestPaint();
        }
        app.targets[app.targets.length] = curTarget;
    }

    // 删除target
    function deleteTarget(pos){
        if(app.targets.length>0){
            var curTarget = app.targets.splice(pos,1);
            curTarget[0].destroy();
        }
    }
    // 重新渲染
    function renderTargets( canvas ){
        canvas.context.clearRect(0,0,900,400);
        for(var i = 0; i < targets.length; ++i){
            AddTarget.setProperties(targets[i]);
            AddTarget.drawShape( canvas.context );
        }
        canvas.requestPaint();
    }

    Item {
        id: shortcuts;                          // alt+G快捷键开关预览图
        focus: true;
        Keys.onPressed: {
            if ((event.modifiers && Qt.AltModifier ) && (event.key === Qt.Key_G)){
                rotationAnimation.start();
            }
        }
    }

    TabBar{
        id: tabBar;                             // TabBar,包含MainWindow和Setting
        width: parent.width;
        Material.foreground: Material.Pink;

        TabButton{
            text: qsTr("MainWindow");           // MainWindow栏
            font.capitalization: Font.MixedCase;// 显示的文本与输入的大小写一致
            Keys.forwardTo: [shortcuts]
        }
        TabButton{
            text: qsTr("Setting");              // Setting栏
            font.capitalization: Font.MixedCase;
        }
    }

    StackLayout {
        width: parent.width;
        height: parent.height;
        anchors.top: tabBar.bottom;
        anchors.bottom: parent.bottom;
        anchors.bottomMargin: 2;

        currentIndex: tabBar.currentIndex;      // 当前窗口索引与tabBar对应

        Page{
            id: mainWinPage;
            Keys.forwardTo: [shortcuts]

            property var floatWinComponent: null;
            property var floatWin;

            GridLayout{
                columns: 2;
                anchors.fill: parent;
                anchors.margins: 20;

                Item{
                    id: pcbViewArea;            // PCBView窗口
                    width: 940;
                    height: 440;

                    Text{
                        text: qsTr("PCBView");
                        color: Material.color(Material.Pink);
                    }

                    Rectangle{
                        id:rectBackground;  // PCBView区域背景色
                        width: 900;
                        height: 400;
                        anchors.centerIn: parent;
                        color: "#fafafa";
                        clip: true;         // 支持裁剪,超过rectBackground不显示

                        Canvas{
                            id:canvasPCBView;
                            x: 0;
                            y: 0;
                            width: 900;
                            height: 400;
                            contextType: "2d";  // 获得画笔
                            scale: 1;

                            property bool isFst: true; //判断是否第一次渲染画布，执行不同操作

                            property bool isSelected: false;  // target是否被选中
                            property int  targetPosX: 0;      // 相对画布x轴位置
                            property int  targetPosY: 0;      // 相对画布y轴位置
                            property int  targetWidth: 900;   // 宽度
                            property int  targetHeight: 400;  // 高度
                            property int  borderWidth: 0;     // 边框宽度
                            property string borderColor: "transparent"; // 边框颜色
                            property string fillColor:   "lightgrey";   // 填充颜色
                            property string targetShape: "rectangle";   // 形状

                            property int selectedObjIdx: -1;

                            // 判断鼠标点击的是空白区域还是在target上,
                            function distinguishTarget(clickX,clickY){
                                // 在target上返回target位置,不在则将selectedObject置为-1并返回;
                                if( canvasPCBView.selectedObjIdx !== -1){
                                    app.targets[canvasPCBView.selectedObjIdx].isSelected = false;
                                    app.targets[canvasPCBView.selectedObjIdx].borderWidth = 0;
                                    app.targets[canvasPCBView.selectedObjIdx].borderColor = "transparent";
                                    canvasPCBView.selectedObjIdx = -1;
                                }

                                for(var i = 0; i < app.targets.length; ++i){
                                    if( app.targets[i].targetShape === "rectangle"){
                                        // 当前鼠标在矩形的target上
                                        if(clickX > app.targets[i].targetPosX &&
                                                clickX < (app.targets[i].targetPosX + app.targets[i].targetWidth) &&
                                                clickY > app.targets[i].targetPosY &&
                                                clickY < (app.targets[i].targetPosY + app.targets[i].targetHeight)){
                                            app.targets[i].isSelected = true;
                                            app.targets[i].borderWidth = 2;
                                            app.targets[i].borderColor = "orange";
                                            canvasPCBView.selectedObjIdx = i;
                                            return;
                                        }
                                    }
                                    else if( app.targets[i].targetShape === "circle"){
                                        // 当前鼠标在圆形的target上
                                        var distance = Math.sqrt(Math.pow(app.targets[i].targetPosX + (app.targets[i].targetWidth / 2) - clickX, 2)
                                                                 + Math.pow(app.targets[i].targetPosY + (app.targets[i].targetHeight / 2)- clickY, 2));
                                        if(distance < app.targets[i].targetWidth/2 ){
                                            app.targets[i].isSelected = true;
                                            app.targets[i].borderWidth = 2;
                                            app.targets[i].borderColor = "orange";
                                            canvasPCBView.selectedObjIdx = i;
                                            return;
                                        }
                                    }
                                }
                            }

                            onPaint: {
                                app.renderTargets( canvasPCBView );
                            }

                            Component.onCompleted: {
                                // 默认添加指定数量的target
                                var cnt = 100;
                                for(var i = 0; i < cnt; ++i){
                                    canvasPCBView.isSelected = false;
                                    // paresInt():取整,Math.random():0-1之间的随机数
                                    canvasPCBView.targetPosX = parseInt(Math.random()*890);
                                    canvasPCBView.targetPosY = parseInt(Math.random()*390);
                                    canvasPCBView.targetWidth = 10;
                                    canvasPCBView.targetHeight = 10;
                                    canvasPCBView.borderWidth = 1;
                                    canvasPCBView.borderColor = "transparent";
                                    if(i%2==0){
                                        canvasPCBView.fillColor = "#ffcc80";
                                        canvasPCBView.targetShape = "circle";
                                    }
                                    else{
                                        canvasPCBView.fillColor = "#81d4fa";
                                        canvasPCBView.targetShape = "rectangle";
                                    }
                                    app.addTarget( isSelected,
                                                  targetPosX,
                                                  targetPosY,
                                                  targetWidth,
                                                  targetHeight,
                                                  borderWidth,
                                                  borderColor,
                                                  fillColor,
                                                  targetShape );
                                }
                            }

                            MouseArea {
                                id: curPos;
                                anchors.fill: parent;
                                acceptedButtons: Qt.RightButton|Qt.LeftButton|Qt.WheelFocus;

                                property point startPoint: Qt.point(0,0);
                                property point endPoint: Qt.point(0,0);
                                property point offSetPoint: Qt.point(0,0);

                                property real scaleFactor: 0.1;     // 鼠标滚轮缩放比例
                                property string buttonType: "null"  // 判断点击的是鼠标左键还是右键

                                // 鼠标滚轮事件,按住Ctrl+滚动滚轮,放大缩小画布
                                onWheel: {
                                    if (wheel.modifiers & Qt.ControlModifier) {
                                        canvasPCBView.scale += scaleFactor * wheel.angleDelta.y / 120.0;
                                        if (canvasPCBView.scale < 0.6) {
                                            // 画布最小缩放比例为0.6
                                            canvasPCBView.scale = 0.6;
                                        }
                                        else if(canvasPCBView.scale > 10) {
                                            // 画布最大缩放比例为10
                                            canvasPCBView.scale = 10;
                                        }

                                        // 重置画布x,y坐标
                                        canvasPCBView.x = rectBackground.width * ( 1 - canvasPCBView.scale ) / 2;
                                        canvasPCBView.y = rectBackground.height * ( 1 - canvasPCBView.scale ) / 2;
                                        // 移动并缩放缩略图中的指示区域框
                                        rectBox.rectBoxView();
                                    }
                                }

                                // 鼠标右键点击事件
                                onClicked: {
                                    if (mouse.button === Qt.RightButton) {
                                        // 打开右键菜单
                                        contentMenu.open();
                                    }
                                }

                                // 鼠标点击事件
                                onPressed: {
                                    if(mouse.button === Qt.LeftButton){
                                        // 右键:记录鼠标开始点击的位置
                                        startPoint = Qt.point(mouseX,mouseY);
                                        // 判断点击是否在target内
                                        canvasPCBView.distinguishTarget(mouseX,mouseY);
                                        // 重新渲染画布
                                        app.renderTargets( canvasPCBView );
                                        buttonType = "left"
                                    }
                                    else{
                                        buttonType = "right"
                                    }

                                    if( null != mainWinPage.floatWinComponent &&
                                            canvasPCBView.selectedObjIdx === -1){
                                        //判断鼠标点击的区域是否存在已有target
                                        if(mainWinPage.floatWinComponent.checkedShape === "rectangle"){
                                            //要添加的target是矩形
                                            app.addTarget(false,
                                                          mouseX,mouseY,
                                                          10,10,
                                                          1,
                                                          "blue","lightblue",
                                                          "rectangle")
                                        }
                                        else if(mainWinPage.floatWinComponent.checkedShape === "circle"){
                                            //要添加的target是圆形
                                            app.addTarget(false,
                                                          mouseX,mouseY,
                                                          10,10,
                                                          1,
                                                          "red","pink",
                                                          "circle")
                                        }
                                    }
                                }

                                // 鼠标点击位置移动
                                onPositionChanged: {
                                    if("left" === buttonType){
                                        // 记录鼠标点击结束时的位置
                                        endPoint = Qt.point(mouseX,mouseY);
                                        if( -1 !== canvasPCBView.selectedObjIdx )
                                        {
                                            // 选中一个target,拖动鼠标,移动target
                                            app.targets[canvasPCBView.selectedObjIdx].targetPosX =
                                                    app.targets[canvasPCBView.selectedObjIdx].targetPosX +
                                                    endPoint.x - startPoint.x;
                                            app.targets[canvasPCBView.selectedObjIdx].targetPosY =
                                                    app.targets[canvasPCBView.selectedObjIdx].targetPosY +
                                                    endPoint.y - startPoint.y;
                                            // 重新渲染PCBView和preView区的画布
                                            app.renderTargets(canvasPCBView);
                                            app.renderTargets(canvasPreView);
                                        }else{
                                            offSetPoint = Qt.point(offSetPoint.x + endPoint.x - startPoint.x,
                                                                   offSetPoint.y + endPoint.y - startPoint.y);
                                            canvasPCBView.x += offSetPoint.x;
                                            canvasPCBView.y += offSetPoint.y;
                                        }
                                        rectBox.rectBoxView();
                                        // 记录鼠标点击结束时的位置为下次开始的位置
                                        startPoint = Qt.point(mouseX,mouseY);
                                    }
                                }

                                // 双击事件
                                onDoubleClicked: {
                                    if(mouse.button === Qt.LeftButton){
                                        if(-1 !== canvasPCBView.selectedObjIdx){
                                            // 左键双击,选中target时删除当前target
                                            app.deleteTarget(canvasPCBView.selectedObjIdx);
                                            canvasPCBView.selectedObjIdx = -1;
                                            // 重新渲染PCBView和preView区的画布
                                            app.renderTargets( canvasPCBView);
                                            app.renderTargets(canvasPreView);
                                        }
                                        else{
                                            // 没有选中target时将画布的缩放比例和偏移恢复默认
                                            curPos.offSetPoint = Qt.point(0,0);
                                            canvasPCBView.x = 0;
                                            canvasPCBView.y = 0;
                                            canvasPCBView.scale = 1;
                                            // 缩略图部分的指示区域框大小和位置恢复默认
                                            rectBox.rectBoxView();
                                        }
                                    }
                                }
                            }

                            Menu { // 右键菜单
                                id: contentMenu;
                                x: curPos.mouseX;
                                y: curPos.mouseY;

                                MenuItem {
                                    id: menuItem;
                                    text: "add";
                                    onTriggered: {
                                        if(null === mainWinPage.floatWinComponent){
                                            mainWinPage.floatWin = Qt.createComponent("qrc:/Component/FloatingWin.qml");
                                            mainWinPage.floatWinComponent = mainWinPage.floatWin.createObject(mainWinPage,{"x":300,"y":150});
                                        }
                                    }
                                }

                                MenuItem {
                                    text: "continue1";
                                    onTriggered: { console.log("continue1 is selected"); }
                                }

                                MenuItem {
                                    text: "continue2";
                                    onTriggered: { console.log("continue2 is selected"); }
                                }
                            }
                        }
                    }

                    Image{
                        id: imgTriangle;            // 提示缩略图显示与关闭的图案
                        source: "qrc:/images/arrow.png";
                        height: 24;
                        width: 24;
                        anchors.bottom: rectBackground.top;
                        anchors.right: rectBackground.right;

                        MouseArea{
                            anchors.fill: parent;
                            hoverEnabled: true;     // 当鼠标徘徊在当前区域变为小手
                            cursorShape: (containsMouse ?
                                              (pressed ? Qt.ClosedHandCursor :
                                                         Qt.PointingHandCursor) :
                                              Qt.ArrowCursor);
                            onClicked:{             // 鼠标点击当前区域,打开缩略图
                                if (rotationAnimation.running === true){
                                    return;         // 判断是否是在运行状态(打开缩略图)
                                }
                                rotationAnimation.start();
                            }
                        }
                        RotationAnimation{
                            id: rotationAnimation;  // 提示缩略图开关的图案的动画
                            target: imgTriangle;
                            from: 0;
                            to: -90;                // 逆时针90度
                            duration: 100;
                            property bool isDown : false;

                            onStopped: {
                                rectPreView.visible = !rectPreView.visible;
                                if (isDown === true){
                                    from = 0;
                                    to = -90;
                                }
                                else{
                                    from = -90;
                                    to = 0;
                                }
                                isDown = !isDown;
                            }
                        }
                    }

                    Rectangle{
                        id:rectPreView;                 // 缩略图视图
                        width: 270;
                        height: 160;
                        visible: false;                 // 默认不显示缩略图
                        anchors.top: rectBackground.top;
                        anchors.right: rectBackground.right;
                        border.width: 3;
                        border.color: "lightgrey";
                        color:"#fafafa";
                        Text{
                            text: qsTr("PreView");
                            color: Material.color(Material.Pink);
                        }

                        Canvas{
                            id: canvasPreView;
                            width:canvasPCBView.width;
                            height:canvasPCBView.height;
                            anchors.centerIn: parent;
                            contextType: "2d";
                            clip: true;
                            scale:0.3;

                            onPaint: {
                                app.renderTargets( canvasPreView )
                            }
                            Rectangle{
                                id: rectBox;
                                width: parent.width;
                                height: parent.height;
                                anchors.left: parent.left;
                                anchors.leftMargin: 1;
                                anchors.top: parent.top;
                                anchors.topMargin: 1;
                                border.width: 3;
                                border.color: Material.color(Material.Purple);
                                color: "transparent";

                                function rectBoxView(){
                                    if(canvasPCBView.scale<=1){
                                        rectBox.width = canvasPCBView.width;
                                        rectBox.height = canvasPCBView.height;
                                        rectBox.anchors.leftMargin = -canvasPCBView.x;
                                        rectBox.anchors.topMargin = -canvasPCBView.y;
                                    }

                                    if(canvasPCBView.scale>1){
                                        // 保持边框宽度高度为偶数,如果产生奇数,矩形框边框可能无法渲染
                                        rectBox.width = ( canvasPCBView.width/canvasPCBView.scale ) % 2
                                                + canvasPCBView.width / canvasPCBView.scale;
                                        rectBox.height = ( canvasPCBView.height / canvasPCBView.scale ) % 2
                                                + canvasPCBView.height / canvasPCBView.scale;
                                        // 指示框相对PCBView上可见部分视图的位置
                                        rectBox.anchors.leftMargin = -canvasPCBView.x*canvasPCBView.scale;
                                        rectBox.anchors.topMargin = -canvasPCBView.y*canvasPCBView.scale;
                                    }
                                }
                            }
                        }
                    }
                }

                Item{
                    id: listArea;                               // List窗口
                    Layout.fillWidth: true;
                    height: pcbViewArea.height;

                    Text{
                        id: idList;
                        text: qsTr("List");
                        color: Material.color(Material.Pink);
                    }
                    GroupBox{
                        width: parent.width * 0.8;
                        anchors.top: idList.bottom;
                        anchors.topMargin: 10;
                        anchors.horizontalCenter: parent.horizontalCenter;
                        Material.foreground: Material.Pink;

                        label: CheckBox{
                            id: ngList;
                            checked: true;
                            text: qsTr("choose");
                        }

                        ColumnLayout{
                            anchors.fill: parent;
                            enabled: ngList.checked;

                            CheckBox { text: qsTr("Icicle"); checked: true; }
                            CheckBox { text: qsTr("Misalign"); }
                            CheckBox { text: qsTr("Bridge"); checked: true; enabled: false;}
                            CheckBox { text: qsTr("Smear"); enabled: false;}
                        }
                    }
                }

                Item{
                    id: equpmentArea;                       // Equipment窗口
                    Layout.fillHeight: true;
                    width: pcbViewArea.width;

                    Text{
                        text: qsTr("Equipment");
                        color: Material.color(Material.Pink);
                    }
                }

                Item{
                    id: lotsArea;                           // Lots窗口
                    Layout.fillHeight: true;
                    Layout.fillWidth: true;

                    Text{
                        text: qsTr("Lots");
                        color: Material.color(Material.Pink);
                    }
                }
            }
        }

        Page{
            Item{
                id: settingWnd;                             // Setting页面
                anchors.fill: parent;
                Text {
                    text: "Setting"
                    color: Material.color(Material.Pink);
                    anchors.centerIn: parent;
                }
            }
        }
    }
}

