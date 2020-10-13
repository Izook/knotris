function setUpGoogleAnalytics() {
  window.dataLayer = window.dataLayer || [];
  function gtag() {
    dataLayer.push(arguments);
  }
  gtag("js", new Date());
  gtag("config", "UA-162642839-1", {});
}

function getCookie(name) {
  const value = `; ${document.cookie}`;
  const parts = value.split(`; ${name}=`);
  if (parts.length === 2) return parts.pop().split(";").shift();
}

// Opt out of google analytics on all my pages
function optOut() {
  window["ga-disable-UA-162642839-1"] = true;
  document.getElementsByClassName("cookieBanner")[0].style.transform =
    "translateY(0%)";
  document.cookie = "IZOOK_OPT_OUT=true";
  setTimeout(function hideBanner() {
    document.getElementsByClassName("cookieBanner")[0].style.transform =
      "translateY(100%)";
  }, 8000);
}

// Check if user isn't opted out
const optOutCookie = getCookie("IZOOK_OPT_OUT");
if (optOutCookie != "true") {
  setUpGoogleAnalytics();
}

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
