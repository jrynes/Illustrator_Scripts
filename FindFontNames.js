#target illustrator

var count, i, find, log="Fonts found:\n";
find = prompt ("Find font name:","targetString");
count = textFonts.length;
for (i=0; i<count; i++)
{ if (textFonts[i].name.match (find) == find)
  { log = log + textFonts[i].name + "\n";
  }
}
alert (log);