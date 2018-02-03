.pragma library

var xPos = 0;
var yPos = 0;

function defaultTarget(target){

    for(var i = 0; i < 20; ++i){
        randomPosition();
        if( 0 == i%2 ){
            drawCircle(target);
        }
        else{
            drawRect(target);
        }
    }
}

function setPosition(x,y){
    xPos = x;
    yPos = y;
}

function randomPosition(){
    xPos = Math.random()*890;
    yPos = Math.random()*390;
}

function drawCircle(circle){

        circle.lineWidth = 1;
        circle.strokeStyle = "grey";
        circle.fillStyle  = "lightgreen";
        circle.beginPath()
        circle.ellipse(xPos,yPos,10,10);
        circle.fill();
        circle.stroke();

}

function drawRect(rect) {

        rect.lineWidth = 1;
        rect.strokeStyle = "grey";
        rect.fillStyle  = "lightgreen";
        rect.beginPath()
        rect.rect(xPos,yPos,10,10);
        rect.fill();
        rect.stroke();
}
