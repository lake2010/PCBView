import QtQuick 2.9

QtObject{
    id: target;

    property string targetShape: "rectangle";
    property int targetPosX: 0;
    property int targetPosY: 0;
    property int targetWidth: 900;
    property int targetHeight: 400;
    property int  borderWidth: 0;
    property string borderColor: "transparent";
    property string fillCorlor: "lightgray";
    property bool isSelect: false;
}
