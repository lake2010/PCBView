.pragma library

var shape = "";
var xPos = 0;
var yPos = 0;
var width = 0;
var height = 0;
var lineWidth = 0;
var strokeStyle = "";
var fillStyle = "";

function setProperties(target){
    this.shape = target.shape;
    this.xPos = target.xPos;
    this.yPos = target.yPos;
    this.width = target.width;
    this.height = target.height;
    this.lineWidth = target.lineWidth;
    this.strokeStyle = target.strokeStyle;
    this.fillStyle = target.fillStyle;
}

function drawShape(target){
    target.lineWidth = lineWidth;
    target.strokeStyle = strokeStyle;
    target.fillStyle  = fillStyle;
    target.beginPath();
    if( shape === "rectangle" ){
        target.rect(xPos,yPos,width,height);
    }
    else{
        target.ellipse(xPos,yPos,width,height);
    }
    target.fill();
    target.stroke();
    //target.closePath();
}

function randomPosition(){
    xPos = parseInt(Math.random()*890);         // 取整
    yPos = parseInt(Math.random()*390);
}
