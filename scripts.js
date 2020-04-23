// Make background a random knotris color
let knotrisColors = ["#31EBB6", "#9CBFFB", "#FFAB62", "#EAED82"]; // No light-green cause it's difficult to read
let randomIndex = Math.floor(Math.random() * Math.floor(knotrisColors.length));
document.getElementsByTagName("BODY")[0].style.backgroundColor =
  knotrisColors[randomIndex];

// Attach Listeners for Navigation Menu
document.getElementById("howToPlayButton").addEventListener("click", () => {
  console.log("Click Open");
  document.getElementById("howToPlayPopUp").style.display = "flex";
});
document.getElementById("aboutButton").addEventListener("click", () => {
  document.getElementById("aboutPopUp").style.display = "flex";
});

// Attach listeners for popup exit
Array.from(document.getElementsByClassName("exitPopup")).forEach((element) => {
  element.addEventListener("click", () => {
    console.log("Click close");
    document.getElementById("howToPlayPopUp").style.display = "none";
    document.getElementById("aboutPopUp").style.display = "none";
  });
});
