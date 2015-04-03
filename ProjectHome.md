# WHAT IS THIS ? #

This is bash script which provides **multiple access point attack** using **reaver** and BSSIDs list from a text file.<br>
If processed AP reaches rate limit, script goes to another from the list, and so forth.<br>

<h1>HOW IT WORKS ?</h1>
Script takes AP targets list from text file in following format <br>
<pre><code>BSSID CHANNEL ESSID<br>
</code></pre>
<br>
For example:<br>
<br>
<pre><code>AA:BB:CC:DD:EE:FF 1 MyWlan<br>
00:BB:CC:DD:EE:FF 13 TpLink<br>
00:22:33:DD:EE:FF 13 MyHomeSSID<br>
</code></pre>
And then following steps are being processed:<br>
<ul><li>Every line of list file is checked separately in for loop<br>
</li><li>After every AP on the list once, script automatically changes MAC address of your card to random MAC using <b>macchanger</b> (you can also setup your own MAC if you need),<br>
</li><li>Whole list is checked again and again, in endless while loop, until there is nothing to check loop is stopped,<br>
</li><li>Found PINS/WPA PASSPHRASES are stored in {CRACKED_LIST_FILE_PATH} file.</li></ul>

<h1>REQUIREMENTS</h1>
<ul><li>Wireless adapter which supports injection (see <a href='https://code.google.com/p/reaver-wps/wiki/SupportedWirelessDrivers'>Reaver Wiki</a>)<br>
</li><li>Linux Backtrack 5<br>
<b>AND (if you use other Linux distribution)</b>
</li><li>Reaver 1.4 (I didn't try it with previous versions)<br>
</li><li>KDE (unless you'll change 'konsole' invocations to 'screen', 'gnome-terminal' or something like that... this is easy)<br>
</li><li>Gawk (Gnu AWK)<br>
</li><li>Macchanger<br>
</li><li>Airmon-ng, Airodump-ng, Aireplay-ng<br>
</li><li>Wash (WPS Service Scanner)<br>
</li><li>Perl<br>
</li><li>Root access on your system (otherwise some things may not work)</li></ul>

<h1>USAGE EXAMPLE</h1>
First you have to download lastest version<br>
<pre><code>git clone https://code.google.com/p/auto-reaver/<br>
</code></pre>
Go to auto-reaver directory<br>
<pre><code>cd ./auto-reaver<br>
</code></pre>
Make sure that scripts have <b>x permissions</b> for your user, if not run<br>
<pre><code>chmod 700 ./washAutoReaver<br>
chmod 700 ./autoReaver<br>
</code></pre>
Run <b>wash scanner</b> to make a formatted list of Access Points with <b>WPS service enabled</b> <br>
<pre><code>./washAutoReaverList &gt; myAPTargets<br>
</code></pre>
Wait for 1-2 minutes for <b>wash</b> to collect APs, and hit <b>CTRL+C</b> to kill the script.<br>
Check if any APs were detected<br>
<pre><code>cat ./myAPTargets<br>
</code></pre>
If there are targets in <b>myAPTargets</b> file, you can proceed attack, with following command: <br>
<pre><code>./autoReaver myAPTargets<br>
</code></pre>

<h1>ADDITIONAL FEATURES</h1>
<ul><li>Script logs dates of PIN attempts, so you can check <b>how often AP is locked</b> and for how long. Default directory for those logs is <b>ReaverLastPinDates</b>.<br>
</li><li>Script logs each <b>AP rate limit</b> for every AP (default directory is <b>/tmp/APLimitBSSID</b>), so you can easily check when last <b>rate limit</b> occured<br>
</li><li>You can setup your attack using variables from  <b>configurationSettings</b> file (sleep/wait times between AP`s and loops, etc.)<br>
</li><li>You can disable checking AP by adding "#" sign in the beginning of line, in <b>myAPTargets</b> file (then AP will be ommited in loop)<br>
</li><li><i>(added 2014-07-03)</i> You can setup specific settings per access point. To do that for AP with MAC <b>AA:BB:CC:DD:EE:FF</b>, just create file <b>./configurationSettingsPerAp/AABBCCDDEEFF</b> and put there variables from <b>./configurationSettings</b> file that you want to change for example:<br>
<pre><code>#!/bin/bash<br>
ADDITIONAL_OPTIONS="-g 10 -E -S -N -T 1 -t 15 -d 0 -x 3";<br>
</code></pre>
so <b>AA:BB:CC:DD:EE:FF</b> will have only <b>ADDITIONAL_OPTIONS</b> changed (rest of variables from <b>./configurationSettings</b> file remains unchanged).<br>
</li><li><i>(added 2014-07-06)</i> Fixed <b>random channel</b> issue. From now you can define channel as random by setting it's value (in myAPTargets file) to <b>R</b>, you can force script to automatically find <b>AP channel</b>. Example:<br>
<pre><code>AA:BB:CC:DD:EE:FF R MyWlan<br>
</code></pre>
But remember that you probably should also increase value of <code> BSSID_ONLINE_TIMEOUT </code> variable - since hopping between all channels takes much more time than searching on one channel.</li></ul>

<h1>REAVER ACTIVITY CHECKER</h1>
This process is responsible for checking whether reaver is active, which means, that is - if it outputs messages similar to:<br>
<pre><code>[+] Received M1 message<br>
</code></pre>
during <b>INACTIVITY_TIMEOUT</b> seconds.<br>
If it's not, then <b>reaver process</b> is automatically killed by sending INT signal (which equals hitting CTRL+C), reaver session is saved, and another AP is processed.<br>
<br>
<h1>CONFIGURATION SETTINGS DESCRIPTION</h1>
Using file <b>configurationSettings</b>, you can adjust <b>Auto Reaver</b> to your needs.<br>
<br>
Setup your additional <b>reaver</b> options:<br>
(type <code> reaver --help </code> for mor information about options)<br>
<pre><code>ADDITIONAL_OPTIONS="-E -S -N -T 1 -t 15 -d 0 -x 3";<br>
</code></pre>


<i>since (2014-07-12)</i>
To set minimum number of <b>minutes between PIN attempts</b> per access point, if AP blocks WPS often, consider to use this option to prevent blocking:<br>
<pre><code>MINUTES_WAIT_BETWEEN_PIN_ATTEMPTS=15;<br>
</code></pre>
Set this to <b>0 if you wan't to see what's going on</b> with AP (signal, beacons...etc),<br>
1 means that <b>airodump-ng</b> window won't appear;<br>
<pre><code>NO_AIRODUMP=1;<br>
</code></pre>
Set this to 1 means that additional <b>aireplay-ng (doing fake-auth)</b> isn't started<br>
or to 0 if you encountered  <b>"[!] WARNING: Failed to associate with xx:xx:xx:xx:xx:xx (ESSID: yyyyy)"</b>
<pre><code>NO_AIREPLAY=1;<br>
</code></pre>
Delay in seconds between association requests (aireplay-ng fake auth -l option)<br>
<pre><code>FAKE_AUTH_DELAY_SECONDS=60;<br>
</code></pre>
Sleep in seconds between checking different AP's (inner loop iteration)<br>
Notice: <i>"Sleeping between AP's for {SLEEP_BETWEEN_APS}"</i>
<pre><code>SLEEP_BETWEEN_APS=5;<br>
</code></pre>
Sleep in seconds before another re-check of whole list (outer loop iteration)<br>
Notice: <i>"Sleeping before another list re-check for {SLEEP_BEFORE_LIST_RECHECK} seconds"</i>
<pre><code>SLEEP_BEFORE_LIST_RECHECK=600;<br>
</code></pre>
Time in minutes during which AP is skipped inside loop because of reach <b>"AP rate limit"</b>
Notice: <i>"...was blocked less than {LIMIT_WAIT_MINUTES} minutes ago, skipping"</i>
<pre><code>LIMIT_WAIT_MINUTES=60;<br>
</code></pre>
Timeout in seconds during script waits for AP to show up in airodump, after that AP is considered offline.<br>
Notice: <i>"Wait {BSSID_ONLINE_TIMEOUT} seconds... scanning if XX:XX:XX:XX:XX:XX (XXXX) is online"</i>
<pre><code>BSSID_ONLINE_TIMEOUT=25;<br>
</code></pre>
SPOOFED MAC (if you want to define your own spoofed mac for wifi card)<br>
If you leave this empty, MAC will be randomly generated by perl subroutine.<br>
<pre><code>SPOOFED_MAC="00:21:6B:B5:E5:22";<br>
</code></pre>
Reaver session files directory<br>
<pre><code>REAVER_SESSION_DIR="/usr/local/etc/reaver";<br>
</code></pre>
Temporary directory for autoReaver script (containing some tmp files which are needed).<br>
Remember that scripts must have write permissions for this dir.<br>
<pre><code>TMP_DIR="/tmp/autoReaver";<br>
</code></pre>
Directory with tmp files indicating, that BSSID reached <b>limit of attempts</b>, files are named just like reaver session files. Simply if MAC=AA:BB:CC:DD:EE:FF file name is AABBCCDDEEFF<br>
every file is checking if it was modified over last <b>LIMIT_WAIT_MINUTES</b>,<br>
if it was.. that means AP reached rate limit and will be skipped during the loop:<br>
<pre><code>LIMIT_TMP_DIR="$TMP_DIR/APLimitBSSID";<br>
</code></pre>
Directory with last dates of pin checks (if pin was checked, date of check was putted into PIN_DATE_TMP_DIR/BSSID file). Better don't set this directory in /tmp/ because it's cleared after reboot, and you loose your pin dates which are required to calculate average time between PINs.<br>
<pre><code>PIN_DATE_TMP_DIR=$(pwd)"/ReaverLastPinDates";<br>
</code></pre>

File containing list of cracked access points.<br>
(If something goes wrong with this file remember you can always <b>recover PIN</b> from session file /usr/local/etc/reaver/{MAC}.wpc. First 2 lines of session file are first and second part of <b>PIN</b>.)<br>
<pre><code>CRACKED_LIST_FILE_PATH=$(pwd)"/AUTOREAVER_CRACKED_WPS_LIST";<br>
</code></pre>

<b>Activity Checker</b> script checks, if file <b>CHECK_ACTIVITY_FILE</b> was modified before<br>
<code> ($NOW - $INACTIVITY_TIMEOUT) </code>, then reaver process is killed due to inactivity (probably hanged up, can't associate or something like that), <b>CHECK_ACTIVITY_FILE</b> is touched while AP responds with messsages such like: <i>"Received M1-M6"</i>
<pre><code>CHECK_ACTIVITY_FILE="$TMP_DIR/autoReaverLastActivity";<br>
</code></pre>

After <b>INACTIVITY_TIMEOUT</b> seconds of inactivity reaver will be killed, and started again with another AP. Setting <b>INACTIVITY_TIMEOUT=0</b> will prevent "Activity Checker" to run.<br>
<pre><code>INACTIVITY_TIMEOUT=300;<br>
</code></pre>
You should modify this in case you have other interface like ath0 or something else:<br>
<pre><code>WIRELESS_INTERFACE="wlan0";<br>
</code></pre>

Here you can define your own regexp which if matched - means that Reaver is active<br>
If you want to be restrictive, you could change this to <i>"Receive WSC NACK"</i>, which means that only this message, will be considered as activity. Sometimes Reaver outputs only <i>"Received M1"</i> and won't go further, then you should change this to <i>"Received M3"</i>.<br>
This value should depend on specific AP's behavior.<br>
<pre><code>REAVER_ACTIVITY_PERL_REGEXP="Received M\d+";<br>
</code></pre>

<h1>ADDITIONAL TOOLS</h1>
In <b>auto-reaver</b> directory you can find <b>additional tools</b>:<br>
<h3>washAutoReaverList</h3>
Script that will scan network using <b>wash</b>, to search for <b>Access points</b> with <b>WPS service enabled</b>, and generate <b>auto-reaver</b> formatted list like:<br>
<pre><code>AA:BB:CC:DD:EE:FF 1 MyWlan<br>
00:BB:CC:DD:EE:FF 13 TpLink<br>
00:22:33:DD:EE:FF 13 MyHomeSSID<br>
</code></pre>
<b>Important:</b> You can always block AP checking by simply adding <b>#</b> sign before each line,<br>
as follows:<br>
<pre><code># 00:22:33:DD:EE:FF 13 MyHomeSSID<br>
</code></pre>
so <i>MyHomeSSID</i> will be skipped during list check.<br>
<br>
<h3>showPinDates</h3>
Script shows last <b>PIN attempt dates</b> for the certain <b>BSSID</b>
It depends on <code> PIN_DATE_TMP_DIR </code> variable (see configuration section), from <b>configurationSettings</b> file.<br>
You can use this tool to adjust setting of <b>LIMIT_WAIT_MINUTES</b>, it should help you discover, for how long certain AP is blocked during <b>AP rate limit</b>.<br>
Using:<br>
<pre><code>./showPinDates [BSSID] [OPTIONS]<br>
</code></pre>
Example:<br>
<pre><code>./showPinDates AA:BB:CC:DD:EE:FF<br>
</code></pre>
Example output:<br>
<pre><code>2014-06-26 06:06:54<br>
2014-06-26 08:06:09<br>
2014-06-26 13:06:08<br>
2014-06-26 14:06:06<br>
2014-06-26 15:06:10<br>
</code></pre>
You can use additional options for grouping PIN dates:<br>
Example:<br>
<pre><code>./showPinDates AA:BB:CC:DD:EE:FF --group-by-day<br>
</code></pre>
Outputs:<br>
<pre><code>Grouping PINs by day<br>
2014-06-23: 24 PINs<br>
2014-06-29: 20 PINs<br>
2014-06-30: 51 PINs<br>
</code></pre>
Options available:<br>
<b>--group-by-day</b> - Grouping PIN dates, by day and shows PIN count of each day<br>
<b>--group-by-hour</b> - Grouping PIN hours, by day+hour and shows PIN count of each day+hour<br>


<h3>shuffleReaverSession.pl</h3>
PERL script to shuffle PINs in reaver session file.<br>
This way you can increase probability of finding correct PIN earlier than using regular pin checking. Usage:<br>
<code> ./shuffleReaverSession.pl [REAVER_SESSION_FILE_PATH] </code>
After execute, script will make a file <code> {YOUR_FILE_NAME}_shuffled </code>.<br>
Remember to shuffle session <b>before Access Point attack</b>, otherwise you'll loose your old session.<br>
<h3>testShuffledFileAgainstOriginal</h3>
Script purpouse is to test whether shuffled (by <b>shuffleReaverSession.pl</b> script) session file was more effective in finding PIN than the original. Remember to test 4 digit`s <b>first part of PIN</b>, which is crucial to find <b>whole PIN</b>
Usage:<br>
<pre><code>./testShuffledFileAgainstOriginal [FIRST_PART_OF_PIN (4 digits)] [SESSION_FILE] [SHUFFLED_SESSION_FILE] <br>
</code></pre>
Example:<br>
<pre><code>./testShuffledFileAgainstOriginal 7834 ./AABBCCDDEEFF AABBCCDDEEFF_shuffled <br>
</code></pre>


<h1>Script output distinction</h1>
<ul><li>Blue color (echoBlue function) displays notice informations from the script<br>
</li><li>Green color (echoGreen function) displays executing commands<br>
</li><li>White color displays output from reaver and other programs which are executed inside the script</li></ul>


<h1>DONATIONS</h1>
Like my project ? <br>
Want to help in future development, and adding new features ? <br>
If you find AutoReaver useful...<br>
<h3>Please <a href='https://sites.google.com/site/dominikdonationbutton/'>DONATE</a></h3>
I created PayPal Donation Button as Google Site because here not all HTML tags are allowed and Donation Button HTML can't be put here...<br>
Every dollar will be appreciated and help me in future development of my projects.<br>
<br>
<h1>Legal Disclaimer</h1>
Usage of auto-reaver for attacking targets without prior mutual consent is illegal. It is the end user's responsibility to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage caused by this program.<br>
