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

    function addTarget( isSelect,
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
                        app,{ "isSelect":isSelect,
                              "targetPosX":targetPosX,
                              "targetPosY":targetPosY,
                              "targetWidth":targetWidth,
                              "targetHeight":targetHeight,
                              "borderWidth":borderWidth,
                              "borderColor":borderColor,
                              "fillCorlor":fillCorlor,
                              "targetShape":targetShape })
        }
        app.targets[app.targets.length] = curTarget;
    }

    function deleteTarget(pos){
        if(app.targets.length>0){
            var curTarget = app.targets.splice(pos,1);
            curTarget[0].destroy();
        }
    }

    function renderTargets(canvers,scale){
        for(var i = 0; i < targets.length; ++i){
            AddTarget.setProperties(targets[i]);
            AddTarget.drawShape(canvers.context,scale);
        }
        canvers.requestPaint();
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
            Keys.forwardTo: [shortcuts]
            GridLayout{
                columns: 2;
                anchors.fill: parent;
                anchors.margins: 20;

                Rectangle{
                    id: rectPCBViewArea;            // PCBView窗口
                    width: 940;
                    height: 440;

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
                    }

                    Canvas{
                        id:canvasPCBView;
                        x:0;y:0;
                        width: 900;
                        height: 400;
                        anchors.fill: rectBackground;
                        contextType: "2d";
                        clip: true;
                        scale: 1;

                        property real xOffset: 0;
                        property real yOffset: 0;


                        property bool  isSelect: false;
                        property int  targetPosX: 0;
                        property int  targetPosY: 0;
                        property int  targetWidth: 0;
                        property int  targetHeight: 0;
                        property int  borderWidth: 0;
                        property string  borderColor: "transparent";
                        property string  fillColor: "lightgrey";
                        property string targetShape: "rectangle";


                        onPaint: {
                            app.renderTargets( canvasPCBView,
                                               canvasPCBView.scale );
                        }

                        Component.onCompleted: {
                            // 默认target
                            var cnt = 2;
                            for(var i = 0; i < cnt; ++i){
                                canvasPCBView.isSelect = false;
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

                                app.addTarget( isSelect,
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
                            property var startPos: Qt.point(0,0);
                            property var endPos: Qt.point(0,0);
                            property var offSetPos: Qt.point(0,0);

                            onEntered:{
                                // 记录鼠标按压时的坐标
                                curPos.startPos.x = mouseX;
                                curPos.startPos.y = mouseY;
                            }
                            onReleased: {
                                // 记录鼠标松开时的坐标
                                curPos.endPos.x = mouseX;
                                curPos.endPos.y = mouseY;

                                // 计算画布的偏移
                                curPos.offSetPos.x = endPos.x - startPos.x;
                                curPos.offSetPos.y = endPos.y - startPos.y;
                            }
                            onClicked: {

                                canvasPCBView.fillColor = "green";
                                canvasPCBView.targetPosX = mouseX;
                                canvasPCBView.targetPosY = mouseY;

                                app.addTarget( canvasPCBView.isSelect,
                                               canvasPCBView.targetPosX,
                                               canvasPCBView.targetPosY,
                                               canvasPCBView.targetWidth,
                                               canvasPCBView.targetHeight,
                                               canvasPCBView.borderWidth,
                                               canvasPCBView.borderColor,
                                               canvasPCBView.fillColor,
                                               canvasPCBView.targetShape );

                                app.renderTargets( canvasPCBView,
                                                   canvasPCBView.scale);
                                app.renderTargets( canvasPreView,
                                                   canvasPreView.preViewScale);
                                canvasPCBView.x += curPos.offSetPos.x;
                                canvasPCBView.y += curPos.offSetPos.y;
                            }
                        }
                    }

                    Image{
                        id: imgTriangle;            // 提示缩略图显示与关闭的图案
                        source: "qrc:/images/arrow.png";
                        height: 24;
                        width: 24;
                        anchors.bottom: canvasPCBView.top;
                        anchors.right: canvasPCBView.right;

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
                        anchors.top: canvasPCBView.top;
                        anchors.right: canvasPCBView.right;
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
                        }
                        Canvas{
                            id: canvasPreView;
                            anchors.fill:rectPreViewBg;
                            contextType: "2d";

                            property real preViewScale: 0.3;

                            onPaint: {
                                app.renderTargets( canvasPreView,
                                                   canvasPreView.preViewScale)
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

