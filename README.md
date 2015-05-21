#WHAT IS THIS ?

This is bash script which provides *multiple access point attack* using *reaver* and BSSIDs list from a text file.  
If processed AP reaches rate limit, script goes to another from the list, and so forth.  

#HOW IT WORKS ?
Script takes AP targets list from text file in following format  
`
BSSID CHANNEL ESSID
`
  
For example: 
```
AA:BB:CC:DD:EE:FF 1 MyWlan 
00:BB:CC:DD:EE:FF 13 TpLink 
00:22:33:DD:EE:FF 13 MyHomeSSID
```

And then following steps are being processed:
  * Every line of list file is checked separately in for loop
  * After every AP on the list once, script automatically changes MAC address of your card to random MAC using *macchanger* (you can also setup your own MAC if you need),
  * Whole list is checked again and again, in endless while loop, until there is nothing to check loop is stopped,
  * Found PINS/WPA PASSPHRASES are stored in {CRACKED_LIST_FILE_PATH} file.

#REQUIREMENTS
  * Wireless adapter which supports injection (see [https://code.google.com/p/reaver-wps/wiki/SupportedWirelessDrivers Reaver Wiki])
  * Linux Backtrack 5 
  * Root access on your system (otherwise some things may not work)
  * AND if you use other Linux distribution*
    * Reaver 1.4 (I didn't try it with previous versions)
    * KDE (unless you'll change 'konsole' invocations to 'screen', 'gnome-terminal' or something like that... this is easy)
    * Gawk (Gnu AWK)
    * Macchanger
    * Airmon-ng, Airodump-ng, Aireplay-ng
    * Wash (WPS Service Scanner)
    * Perl
    
#USAGE EXAMPLE
First you have to download lastest version  
` git clone https://code.google.com/p/auto-reaver/ `  

Go to auto-reaver directory  
` cd ./auto-reaver `  

Make sure that scripts have *x permissions* for your user, if not run  
``` chmod 700 ./washAutoReaver
chmod 700 ./autoReaver ```  
Run *wash scanner* to make a formatted list of Access Points with *WPS service enabled*   
` ./washAutoReaverList > myAPTargets `

Wait for 1-2 minutes for *wash* to collect APs, and hit *CTRL+C* to kill the script.
Check if any APs were detected  
` cat ./myAPTargets `  

If there are targets in *myAPTargets* file, you can proceed attack, with following command:  
` ./autoReaver myAPTargets `  


# If using raw Backtrack 5
If you're using Backtrack 5 without any upgrades, with **airodump-ng version 1.0** try to switch to **airodump1.0** branch and **pull request**. <br />
Further updates on **master** will be suited to **Airodump-ng 1.2 rc2**
```
$ git checkout airodump1.0
$ git pull
```

#ADDITIONAL FEATURES
  * Script logs dates of PIN attempts, so you can check *how often AP is locked* and for how long. Default directory for those logs is *ReaverLastPinDates*.
  * Script logs each *AP rate limit* for every AP (default directory is */tmp/APLimitBSSID*), so you can easily check when last *rate limit* occured
  * You can setup your attack using variables from  *configurationSettings* file (sleep/wait times between AP`s and loops, etc.)
  * You can disable checking AP by adding "#" sign in the beginning of line, in *myAPTargets* file (then AP will be ommited in loop)
  * _(added 2014-07-03)_ You can setup specific settings per access point.  
  To do that for AP with MAC *AA:BB:CC:DD:EE:FF*, just create file *./configurationSettingsPerAp/AABBCCDDEEFF*  
  and put there variables from *./configurationSettings* file that you want to change for example:  
` ADDITIONAL_OPTIONS="-g 10 -E -S -N -T 1 -t 15 -d 0 -x 3"; `

so *AA:BB:CC:DD:EE:FF* will have only *ADDITIONAL_OPTIONS* changed (rest of variables from *./configurationSettings* file remains unchanged).

You can define channel as random by setting it's value (in myAPTargets file) to *R*, you can force script to automatically find *AP channel*.  
Example: 
` AA:BB:CC:DD:EE:FF R MyWlan `

But remember that you probably should also increase value of ` BSSID_ONLINE_TIMEOUT ` variable - since hopping between all channels takes much more time than searching on one channel.

#REAVER ACTIVITY CHECKER
This process is responsible for checking whether reaver is active, which means, that is - if it outputs messages similar to:
` [+] Received M1 message `

during *INACTIVITY_TIMEOUT* seconds.
If it's not, then *reaver process* is automatically killed by sending INT signal (which equals hitting CTRL+C), reaver session is saved, and another AP is processed.

#CONFIGURATION SETTINGS DESCRIPTION=
Using file *configurationSettings*, you can adjust *Auto Reaver* to your needs.
  
Setup your additional *reaver* options:
(type ` reaver --help ` for mor information about options)  
` ADDITIONAL_OPTIONS="-E -S -N -T 1 -t 15 -d 0 -x 3"; `

_since (2014-07-12)_  
To set minimum number of *minutes between PIN attempts* per access point, if AP blocks WPS often, consider to use this option to prevent blocking:  
` MINUTES_WAIT_BETWEEN_PIN_ATTEMPTS=15; `

Set this to *0 if you wan't to see what's going on* with AP (signal, beacons...etc),  
1 means that *airodump-ng* window won't appear  
` NO_AIRODUMP=1; `

Set this to 1 means that additional *aireplay-ng (doing fake-auth)* isn't started  
or to 0 if you encountered  *"[!] WARNING: Failed to associate with xx:xx:xx:xx:xx:xx (ESSID: yyyyy)"*  
` NO_AIREPLAY=1; `

Delay in seconds between association requests (aireplay-ng fake auth -l option)  
` FAKE_AUTH_DELAY_SECONDS=60; `

Sleep in seconds between checking different AP's (inner loop iteration)  
Notice: _"Sleeping between AP's for {SLEEP_BETWEEN_APS}"_  
` SLEEP_BETWEEN_APS=5; `

Sleep in seconds before another re-check of whole list (outer loop iteration)  
Notice: _"Sleeping before another list re-check for {SLEEP_BEFORE_LIST_RECHECK} seconds"_  
` SLEEP_BEFORE_LIST_RECHECK=600; `

Time in minutes during which AP is skipped inside loop because of reach *"AP rate limit"*  
Notice: _"...was blocked less than {LIMIT_WAIT_MINUTES} minutes ago, skipping"_  
` LIMIT_WAIT_MINUTES=60; `

Timeout in seconds during script waits for AP to show up in airodump, after that AP is considered offline.  
Notice: _"Wait {BSSID_ONLINE_TIMEOUT} seconds... scanning if XX:XX:XX:XX:XX:XX (XXXX) is online"_   
` BSSID_ONLINE_TIMEOUT=25; `  
SPOOFED MAC (if you want to define your own spoofed mac for wifi card)  
If you leave this empty, MAC will be randomly generated by perl subroutine.  
` SPOOFED_MAC="00:21:6B:B5:E5:22"; `  

Reaver session files directory  
` REAVER_SESSION_DIR="/usr/local/etc/reaver"; `  

Temporary directory for autoReaver script (containing some tmp files which are needed).  
Remember that scripts must have write permissions for this dir.  
` TMP_DIR="/tmp/autoReaver"; `  

Directory with tmp files indicating, that BSSID reached *limit of attempts*, files are named just like reaver session files. 
Simply if MAC=AA:BB:CC:DD:EE:FF file name is AABBCCDDEEFF every file is checking if it was modified over last *LIMIT_WAIT_MINUTES*,  
if it was.. that means AP reached rate limit and will be skipped during the loop:  
` LIMIT_TMP_DIR="$TMP_DIR/APLimitBSSID"; `  

Directory with last dates of pin checks (if pin was checked, date of check was putted into PIN_DATE_TMP_DIR/BSSID file).  
Better don't set this directory in /tmp/ because it's cleared after reboot, and you loose your pin dates which are required to calculate average time between PINs.  
` PIN_DATE_TMP_DIR=$(pwd)"/ReaverLastPinDates"; `

File containing list of cracked access points.  
(If something goes wrong with this file remember you can always *recover PIN* from session file /usr/local/etc/reaver/{MAC}.wpc.  
First 2 lines of session file are first and second part of *PIN*.)  
` CRACKED_LIST_FILE_PATH=$(pwd)"/AUTOREAVER_CRACKED_WPS_LIST"; `

*Activity Checker* script checks, if file *CHECK_ACTIVITY_FILE* was modified before 
` ($NOW - $INACTIVITY_TIMEOUT) `, then reaver process is killed due to inactivity (probably hanged up, can't associate or something like that),  
*CHECK_ACTIVITY_FILE* is touched while AP responds with messsages such like: _"Received M1-M6"_  
` CHECK_ACTIVITY_FILE="$TMP_DIR/autoReaverLastActivity"; `

After *INACTIVITY_TIMEOUT* seconds of inactivity reaver will be killed, and started again with another AP.  
Setting *INACTIVITY_TIMEOUT=0* will prevent "Activity Checker" to run.   
` INACTIVITY_TIMEOUT=300; `  
You should modify this in case you have other interface like ath0 or something else:  
` WIRELESS_INTERFACE="wlan0"; `  

Here you can define your own regexp which if matched - means that Reaver is active  
If you want to be restrictive, you could change this to _"Receive WSC NACK"_, which means that only this message, will be considered as activity.  
Sometimes Reaver outputs only _"Received M1"_ and won't go further, then you should change this to _"Received M3"_.  
This value should depend on specific AP's behavior.  
` REAVER_ACTIVITY_PERL_REGEXP="Received M\d+"; `  

#ADDITIONAL TOOLS
In *auto-reaver* directory you can find *additional tools*:  
###washAutoReaverList
Script that will scan network using *wash*, to search for *Access points* with *WPS service enabled*, and generate *auto-reaver* formatted list like:  
```AA:BB:CC:DD:EE:FF 1 MyWlan
00:BB:CC:DD:EE:FF 13 TpLink
00:22:33:DD:EE:FF 13 MyHomeSSID```

*Important:* You can always block AP checking by simply adding *#* sign before each line, as follows:  
` # 00:22:33:DD:EE:FF 13 MyHomeSSID `

so _MyHomeSSID_ will be skipped during list check.  

###showPinDates
Script shows last *PIN attempt dates* for the certain *BSSID*  
It depends on ` PIN_DATE_TMP_DIR ` variable (see configuration section), from *configurationSettings* file.  
You can use this tool to adjust setting of *LIMIT_WAIT_MINUTES*, it should help you discover, for how long certain AP is blocked during *AP rate limit*.  
Using:  
` ./showPinDates [BSSID] [OPTIONS] `

Example:  
` ./showPinDates AA:BB:CC:DD:EE:FF `

Example output:

` 2014-06-26 06:06:54
2014-06-26 08:06:09
2014-06-26 13:06:08
2014-06-26 14:06:06
2014-06-26 15:06:10 `

You can use additional options for grouping PIN dates:  

Example:

` ./showPinDates AA:BB:CC:DD:EE:FF --group-by-day `

Outputs:

``` Grouping PINs by day
2014-06-23: 24 PINs
2014-06-29: 20 PINs
2014-06-30: 51 PINs ```

Options available:  
*--group-by-day* - Grouping PIN dates, by day and shows PIN count of each day  
*--group-by-hour* - Grouping PIN hours, by day+hour and shows PIN count of each day+hour  

###shuffleReaverSession.pl
PERL script to shuffle PINs in reaver session file.  
This way you can increase probability of finding correct PIN earlier than using regular pin checking. Usage:  
` ./shuffleReaverSession.pl [REAVER_SESSION_FILE_PATH] `  
After execute, script will make a file ` {YOUR_FILE_NAME}_shuffled `.  
Remember to shuffle session *before Access Point attack*, otherwise you'll loose your old session.  

###testShuffledFileAgainstOriginal###
Script purpouse is to test whether shuffled (by *shuffleReaverSession.pl* script) session file was more effective in finding PIN than the original.  
Remember to test 4 digit`s *first part of PIN*, which is crucial to find *whole PIN*  
Usage:  
`  ./testShuffledFileAgainstOriginal [FIRST_PART_OF_PIN (4 digits)] [SESSION_FILE] [SHUFFLED_SESSION_FILE]  `

Example: 

`  ./testShuffledFileAgainstOriginal 7834 ./AABBCCDDEEFF AABBCCDDEEFF_shuffled  `


#Script output distinction
  * Blue color (echoBlue function) displays notice informations from the script
  * Green color (echoGreen function) displays executing commands
  * White color displays output from reaver and other programs which are executed inside the script


#DONATIONS
Like my project ?   
Want to help in future development, and adding new features ?   
If you find AutoReaver useful...  
###Please <a href="https://sites.google.com/site/dominikdonationbutton/">DONATE</a>  
I created PayPal Donation Button as Google Site because here not all HTML tags are allowed and Donation Button HTML can't be put here...  
Every dollar will be appreciated and help me in future development of my projects.  

#Legal Disclaimer
Usage of auto-reaver for attacking targets without prior mutual consent is illegal.  
It is the end user's responsibility to obey all applicable local, state and federal laws.  
Developers assume no liability and are not responsible for any misuse or damage caused by this program.  
