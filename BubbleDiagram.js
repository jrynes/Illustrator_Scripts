#target illustrator

//CAD Export from Revit to Bubble Diagrams in Illustrator

//Separate Layers by color
//Apply White Stroke
 
 separateFillsByColor();
 
//packageDesign();
 
 //Function below is not currenty used
//~ function packageDesign() {       // Create new layer based off of file name and move all layers underneath.
//~                 var sourceDoc = app.activeDocument;
//~                 var fileName = sourceDoc.name;
//~                 var newLayer = "";
//~                 var newName = "";
//~                 var dot = fileName.lastIndexOf('.');
//~                 var myLayerCount = sourceDoc.layers.length
//~                 newName = fileName.substring(0, dot);
//~                 mast = sourceDoc.layers.add()
//~                 mast.name = newName
//~  
//~           if ( app.documents.length == 0 ) { return; }

//~             for(var myCounter = 0; myCounter < myLayerCount+1; myCounter++){
//~                var selectLayer = sourceDoc.layers[myCounter]
//~                        
//~                    selectLayer.visible=true
//~                    selectLayer.locked=false
//~             }      
//~  
//~             for ( var  i = sourceDoc.layers.length-1; i >= 1; i-- ) {
//~  
//~                    sourceDoc.layers[i].move( mast, ElementPlacement.PLACEATBEGINNING )
//~           };
//~ };

function onlyUnique(value, index, self) { 
    return self.indexOf(value) === index;
};

//Get Unique Items
function uniques(array) {
    var result = [], val, ridx;
    outer:
    for (var i =0, length = array.length; i < length; i++) {
        val = array[i];
        ridx = result.length;
        while (ridx--) {
          if (val === result[ridx]) continue outer;
        }
        result.push(val);
    }
    return result;
};

//Revised Get Unique Items Method
//~ Array.prototype.unique = function() {
//~   return this.filter(function (value, index, self) { 
//~     return self.indexOf(value) === index;
//~   });
//~ }

//Revised Get Unique Items Method
function uniq(a) {
    var prims = {"boolean":{}, "number":{}, "string":{}}, objs = [];

    return a.filter(function(item) {
        var type = typeof item;
        if(type in prims)
            return prims[type].hasOwnProperty(item) ? false : (prims[type][item] = true);
        else
            return objs.indexOf(item) >= 0 ? false : objs.push(item);
    });
}

//Revised Unique Items Method
Array.prototype.contains = function(v) {
    for(var i = 0; i < this.length; i++) {
        if(this[i] === v) return true;
    }
    return false;
};

Array.prototype.unique = function() {
    var arr = [];
    for(var i = 0; i < this.length; i++) {
        if(!arr.includes(this[i])) {
            arr.push(this[i]);
        }
    }
    return arr; 
}

//Separate Filled Area Colors to separate layers
function separateFillsByColor() {
    var sourceDoc = app.activeDocument;
    var targetLayerName = "A-AREA-PATT"
    var targetLayer = sourceDoc.layers[targetLayerName];
    var items = targetLayer.pageItems;
    var box = new Window('dialog', "Some title"); 
    var myLayer = targetLayer;
    var group = targetLayer.groupItems;
    var colorList = []
    var strokeColor = new RGBColor();
    strokeColor.red = 0
    strokeColor.blue = 0
    strokeColor.green = 0
    
    $.writeln("Test colour ",targetLayer.groupItems.length)

 //Ungroup each area color fill
    for (d=0;d<targetLayer.groupItems.length;d++){
    var mygroups = group[d];
          for (i=mygroups.pageItems.length-1; i>=0; i--)
               mygroups.pageItems[i].move(myLayer, ElementPlacement.PLACEATBEGINNING);
     }
 
    //Hide other layers than the target layer
    for(var i = 0; i < sourceDoc.layers.length; i++) {
            var layer = sourceDoc.layers[i];
            
            if (layer.name != targetLayerName)
            {
                layer.visible = false;
            }
    }

//Get all fill colors
   $.writeln("Test colour ",targetLayer.pathItems.length)
   
   for(var i = 0; i < targetLayer.pathItems.length; i++) {
            var item = targetLayer.pathItems[i];
            colorList.push(item.fillColor.spot.name)
            $.writeln("Test colour ",item.fillColor.spot.colorType)
            //sourceDoc.selection.add(item)
            //app.executeMenuCommand('Effect:Stylize:Round Corners')
    }

//Get unique fill colors
var uniqueColors = uniques(colorList)
$.writeln("Unique Color List: ",uniqueColors)
//var uniqueColors = uniq(colorList(str.split('')));
//var uniqueColors = colorList.unique();

$.writeln("Number of Unique Colors",uniqueColors.length)

//Create new layers for each unique color
   for(var i = 0; i < uniqueColors.length; i++) {
        
        var myLayer = sourceDoc.layers.add();
        
        myLayer.name = uniqueColors[i]
        
        //Create Object Style for each layer

        //SCRIPTS CANNOT CREATE OBJECT STYLES

//~         var myPlainTextObjectStyle = sourceDoc.graphicStyles.add();  
//~             myPlainTextObjectStyle.properties = {  
//~                  name : uniqueColors[i],  
//~                  enableFill : true,  
//~                  enableStroke : true,  
//~                  //enableStrokeAndCornerOptions : false,  
//~                  //enableTextFrameBaselineOptions : true,  
//~                  //enableTextFrameGeneralOptions : true,  
//~                  fillColor : myDocument.swatches.item(i),  
//~                  strokeColor : strokeColor,  
//~                  textFramePreferences : {   
//~                       firstBaselineOffset : FirstBaseline.FIXED_HEIGHT,  
//~                       minimumFirstBaselineOffset : myLeading,  
//~                       textColumnCount : 1,  
//~                       verticalJustification : VerticalJustification.TOP_ALIGN   
//~                  }  
//~             //} 
            
            //Add items with matching colors to the newly created layer
           for(var x = 0; x < targetLayer.pathItems.length; x++) {
                var item = targetLayer.pathItems[x];
                
                if (item.fillColor.spot.name === myLayer.name)
                {
                        item.move(myLayer, ElementPlacement.PLACEATEND);
                        item.stroked = true;  
                        item.strokeColor = strokeColor;  
                        item.strokeWidth = 2;
                        $.writeln("Target layer path item match: ", item.fillColor.spot.name + " - " + myLayer.name)
                        //Stylize > Round Corners:
                        //app.executeMenuCommand('Live Adobe Round Corners');
                        //myPlainTextObjectStyle.applyTo(item);
                }
            else {
                $.writeln("Layer colors do not match:   " + item.fillColor.spot.name , "-" + myLayer.name)
                }
            }
   }

//While statement to ensure that items are placed on the matching layer - loose repeat of the method above

//Loop over remaining path items on the target layer
while (targetLayer.pathItems.length != 0) {
    for(var x = 0; x < targetLayer.pathItems.length; x++) {
                    var item = targetLayer.pathItems[x];
                    
                    //Match the remaining items against all existing layer names
                    for (var y = 0; y < sourceDoc.layers.length; y++){
                            if (item.fillColor.spot.name === sourceDoc.layers[y].name)
                            {
                                    $.writeln("Target layer path item second round match: ", item.fillColor.spot.name + " - " + sourceDoc.layers[y].name)
                                    item.move(sourceDoc.layers[y], ElementPlacement.PLACEATEND);
                                    item.stroked = true;  
                                    item.strokeColor = strokeColor;  
                                    item.strokeWidth = 2;
                                    //var itemCopy = item.duplicate(item)
                            }
                        }
                }
        }

//Get compound path items on the target layer
while (targetLayer.compoundPathItems.length != 0) {
    for(var x = 0; x < targetLayer.compoundPathItems.length ; x++) {
                    var itemIndex = targetLayer.compoundPathItems[x];
                    var item = itemIndex.pathItems[0]
                    //var item = itemIndex.index
                    
                    //Match the remaining items against all existing layer names
                    for (var y = 0; y < sourceDoc.layers.length; y++){
                            if (item.fillColor.spot.name === sourceDoc.layers[y].name)
                            {
                                    $.writeln("Target layer path item second round match: ", item.fillColor.spot.name + " - " + sourceDoc.layers[y].name)
                                    targetLayer.compoundPathItems[x].move(sourceDoc.layers[y], ElementPlacement.PLACEATEND);
                                    //item.stroked = true;  
                                   // item.strokeColor = strokeColor;  
                                    //item.strokeWidth = 2;
                                    //var itemCopy = item.duplicate(item)
                            }
                        }
                }
        }
    
//Print out item attributes on remaining layer
for(var x = 0; x < targetLayer.pathItems.length; x++){
    $.writeln("Remaining Items: ", targetLayer.pathItems[x].fillColor.spot.name)
    }


//Create Key Layer with text boxes
var keyLayer = sourceDoc.layers.add();
        keyLayer.name = "Key"

}

