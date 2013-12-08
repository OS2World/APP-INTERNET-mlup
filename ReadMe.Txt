mlup 1.52 ReadMe file

I will be VERY short :-)

mlup is a script to update your configuration at ml.org.

If you don't know what ml.org is, go to www.ml.org. BTW, it is a *FREE* system
that enables those having dynamic IPs to have a *static* domain name.


Installation:
^^^^^^^^^^^^^
All you have to do is put the files in a directory (you can delete base64.c,
it is there just for programmers who want to dig in) and edit the file
mlup.cmd with your personal data.

(You need the RexxSockets library. If you're running Warp4, you already have
it. If you're running Warp 3, download it from the same site where you have
downloaded this: http://members.tripod.com/~Guadagnino/index.html)


Usage:
^^^^^^
It is self explaining: launch it without parameters and it will show some
help.


New Features:
^^^^^^^^^^^^^
This release includes integration with InJoy 1.1+. If you're using InJoy 1.1+,
you can tell it to start automatically mlup on connect, and to launch it again
before hanging up, waiting for it to finish before actually hanging the phone.
I leave it up to you to look at the InJoy docs and find out how to do it.
Only a couple of suggestions:
-you should set InJoy to start mlup at 'host connect', with the command line
 'mlup on'.
-then you should set InJoy to start mlup again at 'discon.(before)', with the
 command line 'mlup off'. AND you should set the 'SetJoy wait (caution)'
 checkbox.


Future plans:
^^^^^^^^^^^^^
-PM version (low priority)
-Your ideas


History:
^^^^^^^^
(13/08/1998)
v1.52 : +Made corrections to adapt to a change in the response page by
	 Monolith members site

	+Other minor corrections

(19/08/1997)
v1.51 : +Fixed a bug that prevents mlup to find the correct tcp/ip interface
         when run on a nationalized version of OS/2

        +Added integration with InJoy 1.1+

        +Made some minor corrections

(28/07/1997)
v1.50 : First public release


Why:
^^^^
I needed more flexibility than offered from the other scripts I've tested.
EG: I wanted to be able to deactivate my domain name when disconnecting from
my ISP.


Thanks:
^^^^^^^
Thanks go to all writers of scripts for ml, and in particular to:
    Arthur Skawina (skawina@usa.net) for his mlddc proggie
    Rocko (rocko@orlinter.com) for his previous OS/2 rexx script

Thanks also to Stefano Zamprogno (never@tvol.it) for his suggestions and bug
reports.


Mail:
^^^^^
You can contact me at the following addresses:

    cristiano.guadagnino@usa.net
    herbie@elettrodata.it

End of ReadMe file.

