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
    minimumHeight: 720;
    maximumWidth: 1280;
    maximumHeight: 720;
    title: qsTr("PCBView");
    visible: true;
    Material.accent: Material.Purple;
    property var targets: [];

    QtObject{
        id: target;

        property string shape: "rectangle";
        property int xPos: 0;
        property int yPos: 0;
        property int width: 900;
        property int height: 400;
        property int  lineWidth: 0;
        property string strokeStyle: "transparent";
        property string fillStyle: "lightgray";
    }

    function renderTarget(canvers){
        for(var i = 0; i < targets.length; i += 8){
            target.shape = app.targets[i];
            target.xPos = app.targets[i+1];
            target.yPos = app.targets[i+2];
            target.width = app.targets[i+3];
            target.height = app.targets[i+4];
            target.lineWidth = app.targets[i+5];
            target.strokeStyle = app.targets[i+6];
            target.fillStyle = app.targets[i+7];
            AddTarget.setProperties(target);
            AddTarget.drawShape(canvers.context);
            canvers.requestPaint();
        }
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

    header: TabBar{
        id: tabBar;                             // TabBar,包含MainWindow和Setting
        width: parent.width;
        currentIndex: swipeView.currentIndex;   // 当前tab的索引与窗口对应
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

    SwipeView {
        id: swipeView;
        anchors.fill: parent;
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
                    clip: true;

                    Text{
                        text: qsTr("PCBView");
                        color: Material.color(Material.Pink);
                    }

                    Canvas{
                        id:canvasPCBView;
                        width: parent.width - 40;
                        height: parent.height - 40;
                        anchors.centerIn: parent;
                        contextType: "2d";
                        visible: true;
                        scale: 1;

                        onPaint: {
                            app.renderTarget(canvasPCBView);
                        }

                        Component.onCompleted: {
                            // 灰色画布
                            targets[0] = "rectangle";
                            targets[1] = 0;
                            targets[2] = 0;
                            targets[3] = width;
                            targets[4] = height;
                            targets[5] = 1;
                            targets[6] = "transparent";
                            targets[7] = "#fafafa";
                            // 默认target
                            for(var i = 8; i < 160; i+=8){
                                if(i<80){
                                    targets[i] = "circle";
                                    targets[i+7] = "red";
                                }
                                else{
                                    targets[i] = "rectangle";
                                    targets[i+7] = "blue";
                                }
                                targets[i+1] = parseInt(Math.random()*890);
                                targets[i+2] = parseInt(Math.random()*390);
                                targets[i+3] = 10;
                                targets[i+4] = 10;
                                targets[i+5] = 1;
                                targets[i+6] = "transparent";
                            }
                        }

                        MouseArea {
                            id: curPos;
                            anchors.fill: parent;
                            onClicked: {
                                app.renderTarget(canvasPCBView);
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
                                if (isDown === true){
                                    rotationAnimation.from = 0;
                                    rotationAnimation.to = -90;
                                    rectPreView.visible = false;
                                }
                                else{
                                    rotationAnimation.from = -90;
                                    rotationAnimation.to = 0;
                                    rectPreView.visible = true;
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
                        Canvas{
                            id: canvasPreView;
                            width: 270;
                            height: 120;
                            anchors.left: parent.left;
                            anchors.leftMargin: 2;
                            anchors.bottom: parent.bottom;
                            anchors.bottomMargin: 2;
                            contextType: "2d";
                            scale: 0.3;

                            onPaint: {
                                app.renderTarget(canvasPreView);
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

