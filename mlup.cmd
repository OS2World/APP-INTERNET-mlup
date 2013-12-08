/* mlup 1.52                                                      */
/*                                                                */
/* Script to upload your dynamic IP to the Monolith server,       */
/* with the new MS3 updating scheme.                              */
/*                                                                */
/* Work by Cristiano Guadagnino                                   */
/* (cristiano.guadagnino@usa.net)                                 */
/*                                                                */
/* (NOTE:                                             )           */
/* (Code for base64 encoding taken from mlddc package,)           */
/* (some other ideas taken from other PD ml scripts.  )           */
/*                                                                */
/* Remember to customize the script with your stuff. See below.   */
/*                                                                */

/* Fill in the following stuff  */

USERNAME='name'         /* Your Monolith Username.                              */
PW='password'           /* Your Monolith Password.                              */
DOMAIN='host_here'      /* Your Host-Name.                                      */
ALIAS='off'             /* Want multiple aliases? (on/off)                      */
MAIL=''                 /* Mail Exchanger (optional)                            */

INJOYPATH=''
                        /* If you have InJoy 1.1+, and you want mlup to signal  */
                        /* injoy on termination, fill in the above line with    */
                        /* the path to the injoy executable.                    */

NETSTR='interface 10'   /* Some national versions of OS/2 translate the message */
                        /* reported by netstat. This makes it impossible for    */
                        /* the program to correctly detect the interface for    */
                        /* PPP/SLIP. If you have such a national version of     */
                        /* OS/2, replace this string with the one reported by   */
                        /* your netstat. EG: italian netstat reports            */
                        /* 'interfaccia 10' instead of 'interface 10'. So the   */
                        /* italian users should replace the above string with:  */
                        /* NETSTR='interfaccia 10'                              */

DEBUGMODE=0             /* This is only useful if you're having problems with   */
                        /* the update process. It will activate various reports */
                        /* and will store the output of the session in the      */
                        /* 'dynreturn' file even on succesfull connections.     */
                        /* Note that reports are NOT auto-explaining. You must  */
                        /* look at this proggie to understand what they mean.   */
                        /* If you're not a rexx programmer, you'll probably do  */
                        /* not need this.                                       */
                        /* 0 = debugging turned off                             */
                        /* 1 = debugging turned on                              */

/* Fill in the above stuff      */

/* -- DO NOT EDIT UNDER THIS LINE!! --------------------------------------- */

/* Constants used by the program */
OKSTRING = ' STATUS:OK '    /* Positive response: database updated  */
ACTIVATE = 'act'            /* Activate your host name in the DNS   */
DEACTIVATE = 'dec'          /* Deactivate your host name in the DNS */
VERSION = '1.52'            /* Program release */

say ''
say '<mlup> script by Cristiano Guadagnino'
say 'Email:  cristiano.guadagnino@usa.net'
say ''
say 'version: 'VERSION
say ''

Parse UPPER ARG ActDec TheRest

if (TheRest \= '' | ActDec = '') then do
    say
    say " Correct syntax is:"
    say "   mlup on|off"
    say
    say " 'mlup on' will refresh your IP and activate your host name in the DNS."
    say " 'mlup off' will deactivate your host name in the DNS."
    say
    say " 'mlup off' is used before dropping connection with your ISP, if"
    say " you don't want your domain name to point anywhere while you're"
    say " not connected to the net."
    say
    exit
end

if ActDec = 'ON' then
    ACTION = ACTIVATE
else
    ACTION = DEACTIVATE

rc = RxFuncAdd("SockLoadFuncs","RxSock","SockLoadFuncs")
if rc=0 then do
    rc = RxFuncAdd("SockLoadFuncs","RxSock","SockLoadFuncs")
    if rc=0 then do
        say 'Error with rxSock.dll'
        say 'check path and make sure file exists'
        call finish2
        exit
    end
end

rc = SockLoadFuncs(bypass_copyright)

/* writes the output of netstat -a  to the file netstat  */
'@netstat.exe -a>netstat'

/* This section sorts through netstat and finds interface 10, which is the    */
/* standard address for SLIP/PPP.  If your software uses a different address, */
/* please modify as needed.  Thanks to NewOrder@flash.net for the idea        */

ok = 0

do until ok = 1
    if LINES(netstat) = 0 then
        call nonetwork
    else
        parse value LINEIN(netstat) with ipaddr
    if subword(ipaddr,3,2) = NETSTR then ok = 1
end

ok = 0

/* Grabs IP address from the line containing "interface 10" */
parse value DELWORD(ipaddr,1,1) with ipaddr
parse value DELWORD(ipaddr,2) with ipaddr
if ipaddr='Not' then call nonetwork
if ipaddr=''  then call nonetwork

iplength = length(ipaddr)
ipaddr = left(ipaddr,(iplength - 1))
rc = stream('netstat','c','close')
'@del netstat >NUL'

/* Gets dotted IP address  of members.ml.org  */
server.!family = 'AF_INET'
server.!port = '80'
server.!addr = 'members.ml.org'
server = 'members.ml.org'
rc=sockgethostbyname(server,serv.!)
dotted = serv.!addr

/* Gets encoded username and password */
ToEncode = USERNAME' 'PW
ToExec = "'"'@base64 'ToEncode' >pwdfile'"'"
interpret ToExec

rc = LINEIN('pwdfile', 1, 0)
if LINES('pwdfile') = 0 then do
    say 'Error trying to encode username and password. Shutting down.'
    call finish
    exit
end /* do */
Encoded = LINEIN('pwdfile')
rc = LINEOUT('pwdfile')
'@del pwdfile >NUL'
if debugmode then do
    say
    say Encoded
    say
    say RIGHT(Encoded, 3)
    say "Lunghezza: "LENGTH(Encoded)
end

sock = SockSocket('AF_INET','SOCK_STREAM','IPPROTO_TCP')

crlf = D2C(13)''D2C(10)
Parse Upper Var ALIAS ALIAS
if ALIAS = 'ON' then
    message = 'GET /mis-bin/ms3/nic/dyndns?command=Update+Host&domain='DOMAIN'&do=mod&act='ACTION'&wildcard=on&ipaddr='ipaddr'&mail='MAIL'&agree=agree HTTP/1.0'
else
    message = 'GET /mis-bin/ms3/nic/dyndns?command=Update+Host&domain='DOMAIN'&do=mod&act='ACTION'&ipaddr='ipaddr'&mail='MAIL'&agree=agree HTTP/1.0'
message = message''crlf
message = message'Pragma: no-cache'crlf
message = message'User-Agent: mlup/'VERSION''crlf
message = message'Authorization: Basic 'Encoded''crlf''crlf
if debugmode then do
    say
    say message
    say
end

addr.!family='AF_INET'
addr.!port = '80'
addr.!addr = dotted

/* Connects to server  */

rc = SockConnect(sock,addr.!)
 if rc = -1 then
    do
       say 'Error connecting!'
       call nonetwork
       exit
  end

/* Sends the IP info to the server, thereby updating the database  */
ret.0 = 15
return = ''
rc = SockSend(sock, message)
/* The following two loops are split to enhance the speed of the first. */
do i=1 to ret.0
    rc = SockRecv(sock, ret.i, 10240)
end
do i=1 to ret.0
    return = return''ret.i
end
rc = SockClose(sock)
rc = SockShutDown(sock, 2)

rc = WORDPOS(OKSTRING, return)
if rc = 0 then do
    say 'Error: ML.ORG did not return the update confirmation.'
    say 'The database was probably NOT updated.'
    say 'See the file <dynreturn> to look at the response given.'
    rc = lineout( 'dynreturn', return )
    rc = lineout( 'dynreturn', '-------End of return from ML.ORG-------' )
    rc = lineout( 'dynreturn', ' ' )
    rc = lineout( 'dynreturn' )
end /* if_do */
else do
    say 'Database correctly updated. Your IP was correctly refreshed.'
    say 'Now you have your hostname configured.'
    if debugmode then do
        rc = lineout( 'dynreturn', return )
        rc = lineout( 'dynreturn', '-------End of (succesfull) return from ML.ORG-------' )
        rc = lineout( 'dynreturn', ' ' )
        rc = lineout( 'dynreturn' )
    end /* if_do */
end /* else_do */

call finish
exit

nonetwork:
say 'No IP address found or problem with server'
call BEEP 392,500
say 'Check your network!'
say 'Make sure you are connected to the internet!'
call finish
exit

finish:
rc = SockDropFuncs()

finish2:
if (INJOYPATH \= '' & ACTION = DEACTIVATE) then do
    curdir = directory()
    injoydir = directory(INJOYPATH)
    PARSE UPPER VAR injoydir injoydir
    PARSE UPPER VAR INJOYPATH INJOYPATH
    if injoydir = INJOYPATH then do
        '@setjoy /C > NUL'
        rc = directory(curdir)
    end
    else do
        say
        say 'Cannot find InJoy directory. Be sure you have typed it correctly.'
        say 'Shutting down without signaling InJoy.'
    end
end
exit

