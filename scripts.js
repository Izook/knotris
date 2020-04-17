// Make background a random knotris color
let knotrisColors = ["#31EBB6", "#CEFFB8", "#9CBFFB", "#FFAB62", "#EAED82"];
let randomIndex = Math.floor(Math.random() * Math.floor(knotrisColors.length));
document.getElementsByTagName("BODY")[0].style.backgroundColor =
  knotrisColors[randomIndex];
