/* 0102: set startup page [SETUP-CHROME]
 * 0=blank, 1=home, 2=last visited page, 3=resume previous session
 * [NOTE] Session Restore is cleared if history is also cleared (2811+), and not used in Private Browsing mode
 * [SETTING] General>Startup>Restore previous session ***/
user_pref("browser.startup.page", 3);

/* 0807: disable urlbar clipboard suggestions [FF118+] ***/
user_pref("browser.urlbar.clipboard.featureGate", false);

/* 0808: disable recent searches [FF120+]
 * [NOTE] Recent searches are cleared if history is cleared (2811+)
 * [1] https://support.mozilla.org/kb/search-suggestions-firefox ***/
user_pref("browser.urlbar.recentsearches.featureGate", false);

/* 0815: disable tab-to-search [FF85+]
 * Alternatively, you can exclude on a per-engine basis by unchecking them in Options>Search
 * [SETTING] Search>Address Bar>When using the address bar, suggest>Search engines ***/
user_pref("browser.urlbar.suggest.engines", false);

/* 2619: use Punycode in Internationalized Domain Names to eliminate possible spoofing
 * [SETUP-WEB] Might be undesirable for non-latin alphabet users since legitimate IDN's are also punycoded
 * [TEST] https://www.xn--80ak6aa92e.com/ (www.apple.com)
 * [1] https://wiki.mozilla.org/IDN_Display_Algorithm
 * [2] https://en.wikipedia.org/wiki/IDN_homograph_attack
 * [3] https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=punycode+firefox
 * [4] https://www.xudongz.com/blog/2017/idn-phishing/ ***/
//user_pref("network.IDN_show_punycode", false); // Uncomment this if legit URLs start showing 'xn--...'

/* 2660: limit allowed extension directories
 * 1=profile, 2=user, 4=application, 8=system, 16=temporary, 31=all
 * The pref value represents the sum: e.g. 5 would be profile and application directories
 * [SETUP-CHROME] Breaks usage of files which are installed outside allowed directories
 * [1] https://archive.is/DYjAM ***/
user_pref("extensions.enabledScopes", 21); // 1 + 4 + 16, for plugin development

/* 2813: set Session Restore to clear on shutdown (if 2810 is true) [FF34+]
 * [NOTE] Not needed if Session Restore is not used (0102) or it is already cleared with history (2811+)
 * [NOTE] If true, this prevents resuming from crashes (also see 5008) ***/
user_pref("privacy.clearOnShutdown.openWindows", false); // Just in case

/** SANITIZE ON SHUTDOWN: RESPECTS "ALLOW" SITE EXCEPTIONS ***/
/* 2815: set "Cookies" and "Site Data" to clear on shutdown (if 2810 is true) [SETUP-CHROME] [FF128+]
 * [NOTE] Exceptions: For cross-domain logins, add exceptions for both sites
 * e.g. https://www.youtube.com (site) + https://accounts.google.com (single sign on)
 * [WARNING] Be selective with what sites you "Allow", as they also disable partitioning (1767271)
 * [SETTING] to add site exceptions: Ctrl+I>Permissions>Cookies>Allow (when on the website in question)
 * [SETTING] to manage site exceptions: Options>Privacy & Security>Permissions>Settings ***/
user_pref("privacy.clearOnShutdown_v2.cookiesAndStorage", false);

/* 4502: set RFP new window size max rounded values [FF55+]
 * [SETUP-CHROME] sizes round down in hundreds: width to 200s and height to 100s, to fit your screen
 * [1] https://bugzilla.mozilla.org/1330882 ***/
user_pref("privacy.window.maxInnerWidth", 1920);
user_pref("privacy.window.maxInnerHeight", 1080);

/* 5014: disable Windows jumplist [WINDOWS] ***/
user_pref("browser.taskbar.lists.enabled", false);
user_pref("browser.taskbar.lists.frequent.enabled", false);
user_pref("browser.taskbar.lists.recent.enabled", false);
user_pref("browser.taskbar.lists.tasks.enabled", false);

/* 5016: discourage downloading to desktop
 * 0=desktop, 1=downloads (default), 2=custom
 * [SETTING] To set your custom default "downloads": General>Downloads>Save files to ***/
user_pref("browser.download.folderList", 1);
// user_pref("browser.download.dir", "/tmp/foobar"); // Custom download directory, if useDownloadDir is true

/* 5017: disable Form Autofill
 * If .supportedCountries includes your region (browser.search.region) and .supported
 * is "detect" (default), then the UI will show. Stored data is not secure, uses JSON
 * [SETTING] Privacy & Security>Forms and Autofill>Autofill addresses
 * [1] https://wiki.mozilla.org/Firefox/Features/Form_Autofill ***/
user_pref("extensions.formautofill.addresses.enabled", false); // [FF55+]
user_pref("extensions.formautofill.creditCards.enabled", false); // [FF56+]

/* 5019: disable page thumbnail collection ***/
user_pref("browser.pagethumbnails.capturing_disabled", true); // [HIDDEN PREF]

/*** === Entirely custom === ****/

/*** Keep closed tab/window undo for 24 hours ***/
user_pref("browser.sessionstore.cleanup.forget_closed_after", 86400000);

/*** Always ask where to save files ***/
user_pref("browser.download.useDownloadDir", false);

/*** Always show downloads button ***/
user_pref("browser.download.autohideButton", false);

/*** "Show an image preview when you hover on a tab" ***/
user_pref("browser.tabs.hoverPreview.showThumbnails", true);

/*** Disable CTRL+Q quitting firefox on linux ***/
user_pref("browser.quitShortcut.disabled", true);

/*** Disable tab grouping ***/
user_pref("browser.tabs.groups.enabled", false);

/*** Disable picture in picture ***/
user_pref("media.videocontrols.picture-in-picture.enabled", false);

/** Always show bookmark toolbar */
user_pref("browser.toolbars.bookmarks.visibility", "always");

/** Disable "XXX is now fullscreen" message */
user_pref("full-screen-api.warning.timeout", 0);
user_pref("full-screen-api.transition-duration.enter", "0 0");
user_pref("full-screen-api.transition-duration.leave", "0 0");
