//
//Illustrator Script to connect two shape center points as selected by the user
//
//Created by Jeffrey Rynes
//

var myDoc Document = app.activeDocument;
var myLine PathItem = myDoc.pathItems.add();
//set stroked to true so we can see the path
myLine.stroked = true;
var newPoint:PathPoint = myLine.pathPoints.add();
newPoint.anchor = [220, 475];
//giving the direction points the same value as the 
//anchor point creates a straight line segment
newPoint.leftDirection = newPoint.anchor;
newPoint.rightDirection = newPoint.anchor;
newPoint.pointType = PointType.CORNER;
var newPoint1:PathPoint = myLine.pathPoints.add();
newPoint1.anchor = [375, 300];
newPoint1.leftDirection = newPoint1.anchor;
newPoint1.rightDirection = newPoint1.anchor;
newPoint1.pointType = PointType.CORNER;
var newPoint2:PathPoint = myLine.pathPoints.add();
newPoint2.anchor = [220, 300];
//giving the direction points different values
//than the anchor point creates a curve 
newPoint2.leftDirection =[180, 260];
newPoint2.rightDirection = [240, 320];
newPoint2.pointType = PointType.CORNER;
app.redraw();