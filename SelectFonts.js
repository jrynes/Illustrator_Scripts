var inputParams = myInput ();

if(inputParams.length){

  //alert(inputParams)

  var a = inputParams.split(",");

  selectTextWhosePointSizeIs ( a[0], a[1] );

}

 

function myInput () {

  var myWindow = new Window ("dialog", "Form");

  var myInputGroup = myWindow.add ("group");

  myInputGroup.add ("statictext", undefined, "minPointSize:");

  var minText = myInputGroup.add ("edittext", undefined, "12");

  minText.characters = 3;

  minText.active = true;

  

  myInputGroup.add ("statictext", undefined, "maxPointSize:");

  var maxText = myInputGroup.add ("edittext", undefined, "24");

  maxText.characters = 3;

  maxText.active = false;

  

  var myButtonGroup = myWindow.add ("group");

  myButtonGroup.alignment = "right";

  myButtonGroup.add ("button", undefined, "OK");

  myButtonGroup.add ("button", undefined, "Cancel");

  if (myWindow.show () == 1) {

  return minText.text + "," + maxText.text;

  }else{

  return ""; //exit (); // exit function unrecognised in Illustrator CC 2017

  }

}

 

 

function selectTextWhosePointSizeIs ( minPointSize, maxPointSize )

{

    var doc, tfs, i = 0, n = 0, selectionArray = [];

 

 

    if ( !app.documents.length ) { return; }

 

 

    doc = app.activeDocument;

    tfs = doc.textFrames;

    n = tfs.length;

 

 

    if ( !n ){ return; }

 

 

    if ( isNaN ( minPointSize ) )

    {

        alert(minPointSize + " is not a valid number" );

        return;

    }

    else if ( isNaN ( maxPointSize ) )

    {

        alert(maxPointSize + " is not a valid number" );

        return;

    }

    else if ( minPointSize > maxPointSize )

    {

        alert(minPointSize + " can't be greater than "+ maxPointSize);

        return;

    }

 

 

    for ( i = 0 ; i < n ; i++ )

    {

        if ( tfs[i].textRange.size >= minPointSize && tfs[i].textRange.size <= maxPointSize )

        {

            selectionArray [ selectionArray.length ] = tfs[i];

        }

    }

 

 

    if ( selectionArray.length )

    {

        app.selection = selectionArray;

    }

    else

    {

        alert("Nothing found in this range.");

    }

}