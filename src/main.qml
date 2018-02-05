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

    //g
    function check(posX,posY){
        return true;
    }

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
            canvasPCBView.requestPaint();　//重新渲染
            app.targets[app.targets.length] = curTarget;
        }
    }

    function deleteTarget(pos){
        if(app.targets.length>0){
            var curTarget = app.targets.splice(pos,1);
            curTarget[0].destroy();
        }
    }

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

        currentIndex: tabBar.currentIndex;      // 当前窗口索引与tab对应

        Page{
            id: mainWinPage;
            Keys.forwardTo: [shortcuts];

            property var floatWinComponent: null;
            property var floatWin;

            GridLayout{
                columns: 2;
                anchors.fill: parent;
                anchors.margins: 20;

                Rectangle{
                    id: rectPCBViewArea;            // PCBView窗口
                    width: 940;
                    height: 440;

                    state: "null";

                    Text{
                        text: qsTr("PCBView");
                        color: Material.color(Material.Pink);
                    }

                    Rectangle{
                        id:rectBackground;
                        width: 900;
                        height: 400;
                        anchors.centerIn: parent;
                        color: "#fafafa";
                        clip: true;

                        Canvas{
                            id:canvasPCBView;
                            x: 0;
                            y: 0;
                            width: 900;
                            height: 400;
                            contextType: "2d";
                            clip: true;
                            scale: 1;

                            property bool isFst: true; //判断是否第一次渲染画布，执行不同操作
                            property real xOffset: 0; //画图的起始x坐标
                            property real yOffset: 0; //画图的起始y坐标

                            property bool  isSelected: false;
                            property int  targetPosX: 0;
                            property int  targetPosY: 0;
                            property int  targetWidth: 900;
                            property int  targetHeight: 400;
                            property int  borderWidth: 0;
                            property string  borderColor: "transparent";
                            property string  fillColor: "lightgrey";
                            property string targetShape: "rectangle";

                            onPaint: {
                                app.renderTargets( canvasPCBView );
                            }

                            Component.onCompleted: {
                                app.addTarget( isSelected,
                                              targetPosX,
                                              targetPosY,
                                              targetWidth,
                                              targetHeight,
                                              borderWidth,
                                              borderColor,
                                              fillColor,
                                              targetShape );
                                // 默认target
                                var cnt = 200;
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
                                        canvasPCBView.fillColor = "red";
                                        canvasPCBView.targetShape = "circle";
                                    }
                                    else{
                                        canvasPCBView.fillColor = "blue";
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
                                id: zoomArea;
                                anchors.fill: parent;
                                property real scaleFactor: 0.1;
                                onWheel: {
                                    if (wheel.modifiers & Qt.ControlModifier) {
                                        canvasPCBView.scale += scaleFactor * wheel.angleDelta.y / 120;
                                        if (canvasPCBView.scale < 0.6) {
                                            canvasPCBView.scale = 0.6;
                                        }
                                        else if(canvasPCBView.scale > 10) {
                                            canvasPCBView.scale = 10;
                                        }
                                        app.renderTargets( canvasPCBView );
                                    }
                                }
                            }
                            MouseArea {
                                id: curPos;
                                anchors.fill: parent;
                                property point startPoint: Qt.point(0,0);
                                property point endPoint: Qt.point(0,0);
                                property point offSetPoint: Qt.point(0,0);

                                onPressed: {
                                    curPos.startPoint = Qt.point(mouseX,mouseY);
                                }

                                onPositionChanged: {
                                    endPoint = Qt.point(mouseX,mouseY);
                                    offSetPoint = Qt.point(offSetPoint.x + endPoint.x - startPoint.x,
                                                           offSetPoint.y + endPoint.y - startPoint.y);

                                    canvasPCBView.context.clearRect(0,0,900,400);
                                    canvasPCBView.x += offSetPoint.x;
                                    canvasPCBView.y += offSetPoint.y;
                                    app.renderTargets( canvasPCBView );
                                    startPoint = Qt.point(mouseX,mouseY);


                                }

                                onDoubleClicked: {
                                    canvasPCBView.context.clearRect(0,0,900,400);
                                    curPos.offSetPoint = Qt.point(0,0);
                                    canvasPCBView.x = offSetPoint.x;
                                    canvasPCBView.y = offSetPoint.y;
                                    canvasPCBView.scale = 1;
                                    app.renderTargets( canvasPCBView);
                                }
                            }

                            Menu { // 右键菜单
                                id: contentMenu;
                                x: mouseRegion.mouseX;
                                y: mouseRegion.mouseY;

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

                            MouseArea {
                                id: mouseRegion;
                                anchors.fill: parent;
                                acceptedButtons: Qt.RightButton; // 激活右键

                                onClicked: {
                                    if (mouse.button === Qt.RightButton) { // 右键菜单
                                        contentMenu.open();
                                    }
                                }
                            }

                            MouseArea{ //鼠标点击canvasPCBView区域添加一个target
                                anchors.fill: parent;
                                onClicked:  {
                                    if(check(mouseX,mouseY) && null != mainWinPage.floatWinComponent ){ //判断鼠标点击的区域是否存在已有target
                                        if(mainWinPage.floatWinComponent.checkedShape === "rectangle"){ //要添加的target是矩形
                                            app.addTarget(false,
                                                          mouseX,mouseY,
                                                          10,10,
                                                          1,
                                                          "blue","lightblue",
                                                          "rectangle")
                                        }
                                        else if(mainWinPage.floatWinComponent.checkedShape === "circle"){　//要添加的target是圆形
                                            app.addTarget(false,
                                                          mouseX,mouseY,
                                                          10,10,
                                                          1,
                                                          "red","pink",
                                                          "circle")
                                        }
                                    }
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
                        width: 274;
                        height: 142;
                        visible: false;                 // 默认不显示缩略图
                        anchors.top: rectBackground.top;
                        anchors.right: rectBackground.right;
                        Text{
                            text: qsTr("PreView");
                            color: Material.color(Material.Pink);
                        }
                        Rectangle{
                            id: rectPreViewBg;
                            width: 270;
                            height: 120;
                            anchors.left: parent.left;
                            anchors.leftMargin: 2;
                            anchors.bottom: parent.bottom;
                            anchors.bottomMargin: 2;
                            color: "#fafafa";

                            Canvas{
                                id: canvasPreView;
                                width:canvasPCBView.width;
                                height:canvasPCBView.height;
                                anchors.centerIn: parent;
                                contextType: "2d";
                                scale:0.3;

                                onPaint: {
                                    app.renderTargets( canvasPreView )
                                }
                            }
                        }
                    }
                }

                Rectangle{
                    id: rectListArea;                               // List窗口
                    Layout.fillWidth: true;
                    height: rectPCBViewArea.height;

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

                Rectangle{
                    id: rectEqupmentArea;                       // Equipment窗口
                    Layout.fillHeight: true;
                    width: rectPCBViewArea.width;

                    Text{
                        text: qsTr("Equipment");
                        color: Material.color(Material.Pink);
                    }
                }

                Rectangle{
                    id: rectLotsArea;                           // Lots窗口
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
            Rectangle{
                id: rectSettingWnd;                             // Setting页面
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

