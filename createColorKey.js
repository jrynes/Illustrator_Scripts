
createColorKey();

function createColorKey()
{
   //var docRef = app.ActiveDocument.add();
    //var myRectangle = docRef.pathItems.rectangle(-100,100,150,150);
    rectangleWidth = 500
    rectangleHeight = rectangleWidth
    rectangleTop = 0
    rectangleLeft = 0
    
    numberOfBoxes = 23
    
    //Get all colors from the AutoCAD Colors used
    
    //var docRef = documents.add();
    
    var myRectangle = new Array();
 
    for (i=0;i<numberOfBoxes;i++){
    myRectangle[i] = app.activeDocument.pathItems.rectangle(i*15+30,100,10,10);
    //Add Text Frame next to Rectangles
    //frame = app.activeDocument.textFrames.add ({geometricBounds:[100,100,0,0]});  
    //frame.contents = "Key";  
    
    }

}