// ==UserScript==
// @name                Return YouTube Dislike Info
// @homepage            https://chrome.google.com/webstore/detail/return-youttube-dislike-c/dhmlhfeidohokcpddoamenbkecjlmkjd
// @version             2021.11.24
// @description         shows dislike info for youtube videos
// @author              NiceL, ported by a redditor
// @match               https://*.youtube.com/watch*
// @grant               none
 
// ==/UserScript==

var JsCode = `
//-----------------------------------------------------------------------------
// Tools
//-----------------------------------------------------------------------------

async function waitForElm(s) {
    while (!document.querySelector(s)) {
        await new Promise(r => requestAnimationFrame(r))
    }
    return;
}

function FormatNumber(num) {
	if (num >= 1000000000) {
		 return (num / 1000000000).toFixed(1).replace(/\.0$/, '') + 'B';
	}
	if (num >= 1000000) {
		 return (num / 1000000).toFixed(1).replace(/\.0$/, '') + 'M';
	}
	if (num >= 1000) {
		 return (num / 1000).toFixed(1).replace(/\.0$/, '') + 'K';
	}
	return num;
}


//-----------------------------------------------------------------------------
// Return system
//-----------------------------------------------------------------------------

function SetStatisticInfo()
{
    var data = document.querySelector("ytd-app").data;
    var vidroot = null;
    for (var i = 0; i < data.response.contents.twoColumnWatchNextResults.results.results.contents.length; i++)
        if (typeof data.response.contents.twoColumnWatchNextResults.results.results.contents[i].videoPrimaryInfoRenderer != 'undefined')
            vidroot = data.response.contents.twoColumnWatchNextResults.results.results.contents[i];

    var ratio = data.playerResponse.videoDetails.averageRating;
    if (!ratio)
        return false;

    // Calculate
    var likes = Number(vidroot.videoPrimaryInfoRenderer.videoActions.menuRenderer.topLevelButtons[0].toggleButtonRenderer.toggledText.accessibility.accessibilityData.label.replace(/[^0-9]/g,'')) - 1;
    //if (document.querySelectorAll("yt-formatted-string#text.ytd-toggle-button-renderer")[0].parentNode.parentNode.children[0].children[0].children[0].getAttribute("aria-pressed") == "true")
    //    likes++; // Is we putted like?
    var dislikes = Math.round(likes * ((5 - ratio) / (ratio - 1)));
    //if (document.querySelectorAll("yt-formatted-string#text.ytd-toggle-button-renderer")[1].parentNode.parentNode.children[0].children[0].children[0].getAttribute("aria-pressed") == "true")
    //    dislikes++; // Is we putted dislike?
	
    // Modify score
    //document.querySelectorAll("yt-formatted-string#text.ytd-toggle-button-renderer")[0].innerHTML = FormatNumber(likes.toString());
    document.querySelectorAll("yt-formatted-string#text.ytd-toggle-button-renderer")[1].innerHTML = FormatNumber(dislikes.toString());

    // Modify ratio
    var sentimentPercent = parseInt((((likes / (likes + dislikes)) * 100 * 100) / 100)).toString();
    document.querySelector("ytd-sentiment-bar-renderer").removeAttribute("hidden");
    document.getElementById("like-bar").setAttribute("style", "width: " + sentimentPercent + "%;");
    document.getElementById("sentiment").setAttribute("style", "width: " + 
        String(document.querySelectorAll("yt-formatted-string#text.ytd-toggle-button-renderer")[0].parentElement.getBoundingClientRect().width + 
        document.querySelectorAll("yt-formatted-string#text.ytd-toggle-button-renderer")[1].parentElement.getBoundingClientRect().width + 12) +
        "px;");
        
	return true;
}

function Init()
{
    if (!SetStatisticInfo())
		return false;
	
    // To fix value on "like" press
    document.querySelectorAll("ytd-toggle-button-renderer")[0].parentNode.addEventListener('click', SetStatisticInfo);
	
	return true;
}


//-----------------------------------------------------------------------------
// Init
//-----------------------------------------------------------------------------

waitForElm("yt-formatted-string#text.ytd-toggle-button-renderer").then(() => Init());
window.addEventListener('yt-page-data-updated', Init, false);
//window.addEventListener('yt-navigate-finish', Init, false);
`;

var script = document.createElement('script');
script.textContent = JsCode;
(document.head||document.documentElement).appendChild(script);
script.remove();
