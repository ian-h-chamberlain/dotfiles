// ==UserScript==
// @name         GitHub Notification Repo Icons
// @namespace    https://ian-h-chamberlain.com
// @version      2024-08-26
// @description  Restore the old repository icons they used to have in GH notifications dashboard.
// @author       Ian Chamberlain
// @match        https://github.com/*
// @icon         https://icons.duckduckgo.com/ip2/github.com.ico
// @grant        window.onurlchange
// @run-at       document-start
// ==/UserScript==

(function() {
    'use strict';

    function addIcons() {
        const nav = document.querySelector('.js-notification-sidebar-repositories nav');
        if (!nav) {
            // inbox zero
            return;
        }

        const repoLinks = document.querySelectorAll('.js-notification-sidebar-repositories li .ActionListContent');
        if (repoLinks.length == 0) {
            // maybe not done loading, try again soon
            setTimeout(100, addIcons);
            return;
        }

        for (const link of repoLinks) {
            if (link.querySelector('img')) {
                // don't add another if we've already done it for this repo.
                continue;
            }

            const repoLabel = link.querySelector('.ActionListItem-label');
            const user = repoLabel.innerText.split('/')[0];
            const imgElem = document.createElement('img');
            const width = 20;

            imgElem.src = `https://avatars.githubusercontent.com/${user}?size=${width}`;
            imgElem.width = width;
            imgElem.className = 'avatar';
            link.insertBefore(imgElem, repoLabel);
        }
    }

    if (window.onurlchange === null) {
        // When the notifications page is loaded (even from e.g. a new tab)
        // it seems to trigger its own urlchange which allows the handler to fire.
        // Somehow this seems more reliable than a plain onload
        window.addEventListener('urlchange', (info) => {
            if (Object.values(info)[0].includes("/notifications")) {
                addIcons();
            }
        });
    }
})();
