// ==UserScript==
// @name         Google View Image
// @namespace    http://GoogleViewImage.com/
// @version      0.1
// @description  Bring back Google View Image!
// @author       laidbackTempo
// @match        https://**/*
// @match        http://**/*
// @license MIT
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

function toI18n(str) {
    return str.replace(/__MSG_(\w+)__/g, function (match, v1) {
        return v1 ? chrome.i18n.getMessage(v1) : '';
    });
}

function localiseObject(obj, tag) {
    obj.innerHTML = tag;
    return;
    //var msg = toI18n(tag);
    //if (msg != tag) obj.innerHTML = msg;
}

function addLinks(node) {
    // console.log("Adding link");
    if (node.nodeType === Node.ELEMENT_NODE) {
            // console.log("Adding link in");
        if ((node.classList.contains('irc_ris')) || (node.classList.contains('irc_mi') || (node.classList.contains('irc_tas')))) {
                // console.log("Adding link OK OK ");
            var object = node.closest('.irc_c');
            // Retrive image links, and image url
            var imageLinks = object.querySelector('._FKw.irc_but_r > tbody > tr');
            var imageText = object.querySelector('._cjj > .irc_it > .irc_hd > ._r3');

            // Retrive the image URL
            var imageURL;

            var thumbnail = document.querySelector('img[name="' + object.dataset.itemId + '"]');
            if (thumbnail) {
                var meta = thumbnail.closest('.rg_bx').querySelector('.rg_meta');
                var metadata = JSON.parse(meta.innerHTML);
                imageURL = metadata.ou;
            } else {
                imageURL = document.getElementsByClassName('irc_mi')[0].src;
            }

            // Remove previously generated view image buttons
            var oldViewImage = imageLinks.querySelector('.ext_addon');
            if (oldViewImage) {
                imageLinks.removeChild(oldViewImage);
            }

            // remove previously generated search by image links
            var oldSearchByImage = imageText.querySelector('.ext_addon');
            if (oldSearchByImage) {
                imageText.removeChild(oldSearchByImage);
            }

            // Create Search by image button
            var searchByImage = document.createElement('a');
            searchByImage.setAttribute('href', '/searchbyimage?&image_url=' + imageURL);
            searchByImage.setAttribute('class', 'ext_addon');
            searchByImage.setAttribute('style', 'margin-left:4pt;');

            // Insert text into Search by image button
            var searchByImageText = document.createElement('span');
            localiseObject(searchByImageText, '<span>View Image</span>');
            searchByImage.appendChild(searchByImageText);

            // Append Search by image button
            imageText.appendChild(searchByImage);

            // Create View image button
            var viewImage = document.createElement('td');
            viewImage.setAttribute('class', 'ext_addon');

            // Add globe to View image button
            var viewImageLink = document.createElement('a');
            var globeIcon = document.querySelector('._RKw._wtf._Ptf').cloneNode(true);
            viewImageLink.appendChild(globeIcon);

            // add text to view image button
            var viewImageText = document.querySelector('._WKw').cloneNode(true);
            localiseObject(viewImageText, 'View Image');
            viewImageLink.appendChild(viewImageText);

            // Add View image button URL
            viewImageLink.setAttribute('href', imageURL);
            viewImageLink.setAttribute('target', '_blank');
            viewImage.appendChild(viewImageLink);

            // Add View image button to Image Links
            var save = imageLinks.childNodes[1];
            imageLinks.insertBefore(viewImage, save);
                // console.log("Adding DONE!!!");
        }
    }
}


    var observer = new MutationObserver(function (mutations) {
        mutations.forEach((mutation) => {
            if (mutation.addedNodes && mutation.addedNodes.length > 0) {
                for (var i = 0; i < mutation.addedNodes.length; i++) {
                    var newNode = mutation.addedNodes[i];
                    addLinks(newNode);
                }
            }
        });
    });

    observer.observe(document.body, {
        childList: true,
        subtree: true
    });

    addLinks(document.body);

})();
