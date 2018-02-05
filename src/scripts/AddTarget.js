.pragma library

var isSelect = false;
var xPos = 0;
var yPos = 0;
var width = 0;
var height = 0;
var lineWidth = 0;
var strokeStyle = "";
var fillStyle = "";
var shape = "";

function setProperties(target){
    this.isSelect = target.isSlelect;
    this.xPos = target.targetPosX;
    this.yPos = target.targetPosY;
    this.width = target.targetWidth;
    this.height = target.targetHeight;
    this.lineWidth = target.borderWidth;
    this.strokeStyle = target.borderColor;
    this.fillStyle = target.fillCorlor;
    this.shape = target.targetShape;
}

function drawShape(target,scale){
    target.lineWidth = lineWidth;
    target.strokeStyle = strokeStyle;
    target.fillStyle  = fillStyle;
    target.beginPath();
    if( shape === "rectangle" ){
        target.rect(xPos*scale,
                    yPos*scale,
                    width*scale,
                    height*scale);
    }
    else{
        target.ellipse(xPos*scale,
                       yPos*scale,
                       width*scale,
                       height*scale);
    }
    target.fill();
    target.stroke();
    target.closePath();
}
