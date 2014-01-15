MODULE_NAME='Pioneer_BDP-23FD_Comm'(dev vdvDevice, dev dvDevice, char ipAddress[15], char port[4], integer protocol_type)
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 04/04/2006  AT: 11:33:16        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
*)    
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

vdvBuffer = 36002:1:0

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

CR = 13//$0D

//
TL_TIMELINE = 1

// Send Commands
BR_PWR_ON  	= 'PN'
BR_PWR_OFF  	= 'PF'
BR_TRAY_OPEN	= 'OP'
BR_TRAY_CLOSE	= 'CO'
BR_STOP		= '99RJ'
BR_PLAY		= 'PL'
BR_PAUSE	= 'ST'
BR_NEXT		= 'SF'			// step forward
BR_PREVIOUS	= 'SR'			// step reverse
BR_STOP_SCAN	= 'NS'
BR_KEYLOCK	= 'KL'			// (Parameter)KL
BR_SLOW		= 'SW'			// (Parameter)SW
BR_SCAN_FWD	= 'NF'
BR_SCAN_REV	= 'NR'

// Remote Control Buttons
BR_PWR_TOGGLE		= '/A181AFBC/RU'
BR_TRAY_TOGGLE		= '/A181AFB6/RU'
BR_VIDEO_OUTPUT_RESET	= '/A181AF21/RU'
BR_AUDIO		= '/A181AFBE/RU'
BR_SUBTITLE		= '/A181AF36/RU'
BR_ANGLE		= '/A181AFB5/RU'
BR_FRONT_LIGHT		= '/A181AFF9/RU'
BR_1			= '/A181AFA1/RU'
BR_2			= '/A181AFA2/RU'
BR_3			= '/A181AFA3/RU'
BR_4			= '/A181AFA4/RU'
BR_5			= '/A181AFA5/RU'
BR_6			= '/A181AFA6/RU'
BR_7			= '/A181AFA7/RU'
BR_8			= '/A181AFA8/RU'
BR_9			= '/A181AFA9/RU'
BR_CLEAR		= '/A181AFE5/RU'
BR_0			= '/A181AFA0/RU'
BR_ENTER		= '/A181AFEF/RU'
BR_SECONDARY_VIDEO	= '/A181AFBF/RU'
BR_KEYLOCK2		= '/A181AF22/RU'		// Alternate way to enable keylock
BR_REPEAT		= '/A181AFE8/RU'
BR_REPEAT_OFF		= '/A181AF23/RU'
BR_PAGE_UP		= '/A181AF26/RU'
BR_PAGE_DOWN		= '/A181AF27/RU'
BR_EXIT			= '/A181AF20/RU'
BR_DISPLAY		= '/A181AFE3/RU'
BR_FUNCTION		= '/A181AFB3/RU'
BR_TOP_MENU		= '/A181AFB4/RU'		// Disc Navigator
BR_MENU			= '/A181AFB9/RU'		// Popup Menu/Menu
BR_HOME_MENU		= '/A181AFB0/RU'
BR_RETURN		= '/A181AFF4/RU'
BR_UP			= '/A184FFFF/RU'
BR_RIGHT		= '/A186FFFF/RU'
BR_DOWN			= '/A185FFFF/RU'
BR_LEFT			= '/A187FFFF/RU'
BR_SCAN_REV2		= '/A181AFEA/RU'		// Alternative way to reverse scan
BR_PLAY2		= '/A181AF39/RU'		// Alternative way to play
BR_SCAN_FWD2		= '/A181AFE9/RU'		// Alternative way to forward scan
BR_REV_SKIP		= '/A181AF3E/RU'
BR_PAUSE2		= '/A181AF3A/RU'		// Alternative way to pause
BR_STOP2		= '/A181AF38/RU'		// Alternative way to stop
BR_FWD_SKIP		= '/A181AF3D/RU'
BR_RED			= '/A181AF60/RU'
BR_GREEN		= '/A181AF61/RU'
BR_BLUE			= '/A181AF62/RU'
BR_YELLOW		= '/A181AF63/RU'
BR_REPLAY		= '/A181AF24/RU'
BR_SKIP_SEARCH		= '/A181AF25/RU'
BR_PWR_ON2		= '/A181AFBA/RU'		// Alternative way to power on
BR_PWR_OFF2		= '/A181AFBB/RU'		// Alternative way to power off

// Response Commands
BR_CURRENT_ADDRESS		= '?A'
BR_TITLE_TRACK_NUMBER		= '?R'
BR_CHAPTER_NUMBER_REQUEST	= '?C'
BR_TIME_CODE_REQUEST		= '?T'
BR_INDEX_NUMBER_REQUEST		= '?I'
BR_DVD_DISC_STATUS		= '?V'
BR_BD_DISC_STATUS		= '?J'
BR_GET_INFORMATION		= '?D'
BR_CD_DISC_STATUS		= '?K'
BR_PLAYER_ACTIVE_MODE		= '?P'
BR_PLAYER_MODEL_NAME		= '?L'
BR_ERROR_CODE_REQUEST		= '?E'
BR_FIRMWARE_VERSION		= '?Z'

// Channels
PLAY		= 1
STOP		= 2
PAUSE		= 3

POWER		= 9
TOP_MENU	= 115
TRAY		= 120


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

struct _IP {
    LONG Flags
    INTEGER LocalPort
    CHAR ServerAddress[16]
    LONG ServerPort
    INTEGER Protocol
}

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLATILE INTEGER nDebug = 0   //  DEBUG VARIABLE
VOLATILE CHAR buffer[10000]
VOLATILE SINTEGER connection_status = -2

VOLATILE _IP IP

// timeline
LONG TimeArray[1] = 10000

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

DEFINE_FUNCTION SINTEGER fnParseCommmand() {
    LOCAL_VAR CHAR temp
    temp = 0
    
    IF (nDebug) 
	send_string 0,"' In fnParseCommmand()'"
    
    // check connection
    if(connection_status < 1){
	SEND_STRING 0, "'exiting -1'"
	return -1
    }
    else{
	send_string 0, "'did not return -1'"
    }
    
    // get command
    temp = GET_BUFFER_CHAR(buffer)
    
    // successfully sent command ?
    CLEAR_BUFFER buffer
    
    IF (nDebug) 
	send_string 0,"' Buffer Cleared'"
    
    // close connection
    //fnCloseConnection()
    
    RETURN 1
}

DEFINE_FUNCTION SINTEGER fnOpenConnection() {
    LOCAL_VAR SINTEGER status
    status = 0
    
    IF (nDebug) 
	send_string 0,"' In fnOpenConnection()'"
    
    IP_CLIENT_OPEN(IP.LocalPort,IP.ServerAddress,IP.ServerPort,IP.Protocol)
    
    // wait and check for flags
    // retry if relevant
    
    return status   
}

DEFINE_FUNCTION INTEGER fnCloseConnection() {
    IF (nDebug) 
	send_string 0,"' In fnCloseConnection()'"
    
    IP_CLIENT_CLOSE(IP.LocalPort)
    
    return 0
}

DEFINE_FUNCTION CHAR[100] GetIpError (LONG nNUM){
    IP.Flags = nNum
    
    IF (nDebug) 
	send_string 0,"' In GetIpError()'"
    
    SWITCH (nNUM){
	// ERROR REPORTING
	CASE 2:
	    RETURN "'IP ERROR (',ITOA(nNUM),'): General Failure (IP_CLIENT_OPEN/IP_SERVER_OPEN)'"
	CASE 4:
	    RETURN "'IP ERROR (',ITOA(nNUM),'): Unknown host (IP_CLIENT_OPEN)'"
	CASE 6:
	    RETURN "'IP ERROR (',ITOA(nNUM),'): Connection refused (IP_CLIENT_OPEN)'"
	CASE 7:
	    RETURN "'IP ERROR (',ITOA(nNUM),'): Connection timed out (IP_CLIENT_OPEN)'"
	CASE 8:
	    RETURN "'IP ERROR (',ITOA(nNUM),'): Unknown connection error (IP_CLIENT_OPEN)'"
	CASE 9:
	    RETURN "'IP ERROR (',ITOA(nNUM),'): Already closed (IP_CLIENT_CLOSE/IP_SERVER_CLOSE)'"
	CASE 14:
	    RETURN "'IP ERROR (',ITOA(nNUM),'): Local port already used (IP_CLIENT_OPEN/IP_SERVER_OPEN)'"
	CASE 16:
	    RETURN "'IP ERROR (',ITOA(nNUM),'): Too many open sockets (IP_CLIENT_OPEN/IP_SERVER_OPEN)'"
	CASE 17:
	    RETURN "'IP ERROR (',ITOA(nNUM),'): Local Port Not Open (IP_SERVER_OPEN)'"
	DEFAULT:
	    RETURN "'IP ERROR (',ITOA(nNUM),'): Unknown'"
    }
}

DEFINE_FUNCTION CHAR[100] GetHTTPStatus (LONG nNUM){
    IF (nDebug) 
	send_string 0,"' In GetHTTPStatus()'"
    
    SWITCH (nNUM){
	CASE 100: {
	    RETURN "'HTTP/1.1 100 Continue'"
	}
	CASE 101: {
	    RETURN "'HTTP/1.1 101 Switching Protocols'"
	}
	CASE 200: {
	    // Received command correctly
	    
	    RETURN "'HTTP/1.1 200 OK'"
	}
	CASE 201: {
	    RETURN "'HTTP/1.1 201 Created'"
	}
	CASE 202: {
	    RETURN "'HTTP/1.1 202 Accepted'"
	}
	CASE 203: {
	    RETURN "'HTTP/1.1 203 Non-Authoritative Information'"
	}
	CASE 204: {
	    RETURN "'HTTP/1.1 204 No Content'"
	}
	CASE 205: {
	    RETURN "'HTTP/1.1 205 Reset Content'"
	}
	CASE 206: {
	    RETURN "'HTTP/1.1 206 Partial Content'"
	}
	CASE 300: {
	    RETURN "'HTTP/1.1 300 Multiple Choices'"
	}
	CASE 301: {
	    RETURN "'HTTP/1.1 301 Moved Permanently'"
	}
	CASE 302: {
	    RETURN "'HTTP/1.1 302 Moved Temporarily'"
	}
	CASE 303: {
	    RETURN "'HTTP/1.1 303 See Other'"
	}
	CASE 304: {
	    RETURN "'HTTP/1.1 304 Not Modified'"
	}
	CASE 305: {
	    RETURN "'HTTP/1.1 305 Use Proxy'"
	}
	CASE 306: {
	    RETURN "'HTTP/1.1 306 (Unused)'"
	}
	CASE 307: {
	    RETURN "'HTTP/1.1 307 Temporary Redirect'"
	}
	CASE 400: {
	    RETURN "'HTTP/1.1 400 Bad Request'"
	}
	CASE 401: {
	    RETURN "'HTTP/1.1 401 Unauthorized'"
	}
	CASE 402: {
	    RETURN "'HTTP/1.1 402 Payment Required'"
	}
	CASE 403: {
	    RETURN "'HTTP/1.1 403 Forbidden'"
	}
	CASE 404: {
	    RETURN "'HTTP/1.1 404 Not Found'"
	}
	CASE 405: {
	    RETURN "'HTTP/1.1 405 Method Not Allowed'"
	}
	CASE 406: {
	    RETURN "'HTTP/1.1 406 Not Acceptable'"
	}
	CASE 407: {
	    RETURN "'HTTP/1.1 407 Proxy Authentication Required'"
	}
	CASE 408: {
	    RETURN "'HTTP/1.1 408 Request Timeout'"
	}
	CASE 409: {
	    RETURN "'HTTP/1.1 409 Conflict'"
	}
	CASE 410: {
	    RETURN "'HTTP/1.1 410 Gone'"
	}
	CASE 411: {
	    RETURN "'HTTP/1.1 411 Length Required'"
	}
	CASE 412: {
	    RETURN "'HTTP/1.1 412 Precondition Failed'"
	}
	CASE 413: {
	    RETURN "'HTTP/1.1 413 Request Entity Too Large'"
	}
	CASE 414: {
	    RETURN "'HTTP/1.1 414 Request-URI Too Long'"
	}
	CASE 415: {
	    RETURN "'HTTP/1.1 415 Unsupported Media Type'"
	}
	CASE 416: {
	    RETURN "'HTTP/1.1 416 Requested Range Not Satisfiable'"
	}
	CASE 417: {
	    RETURN "'HTTP/1.1 417 Expectation Failed'"
	}
	CASE 500: {
	    RETURN "'HTTP/1.1 500 Server Error'"
	}
	CASE 501: {
	    RETURN "'HTTP/1.1 501 Not Implemented'"
	}
	CASE 502: {
	    RETURN "'HTTP/1.1 502 Bad Gateway'"
	}
	CASE 503: {
	    RETURN "'HTTP/1.1 503 Service Unavailable'"
	}
	CASE 504: {
	    RETURN "'HTTP/1.1 504 Gateway Timeout'"
	}
	CASE 505: {
	    RETURN "'HTTP/1.1 505 HTTP Version Not Supported'"
	}
	DEFAULT: {
	    SEND_STRING 0, "'Unknown result'"
	    RETURN "'Unknown result'"
	}
    }
}

DEFINE_FUNCTION INTEGER fnSendCommand(INTEGER function) {
    IF (nDebug) 
	send_string 0,"' UI: Command received from SNAPI ', itoa(function)"
	
    switch(function){
	//case BTN_PLAY: send_string vdvBuffer, "BTN_PLAY"
	default: send_string 0, "'bad command'"
    }
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

CREATE_BUFFER vdvBuffer, buffer

IP.Flags = 0
IP.LocalPort = dvDevice.Port
IP.ServerAddress = ipAddress
IP.ServerPort = atoi(port)
IP.Protocol = protocol_type

// open connection upon startup of module
fnOpenConnection()

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvDevice] {
    ONERROR: {
	IF (nDebug) 
	    SEND_STRING 0,"'onerror: ', GetIpError(Data.Number)"
	
	connection_status = -1
	
	// if timeout 3 times
	// PERMENANT_FAILURE = true
	
	// pause timeline
	TIMELINE_PAUSE(TL_TIMELINE)
    }
    ONLINE: {
	STACK_VAR INTEGER created
	created = 0
	
	IF (nDebug) 
	    SEND_STRING 0,"'online: bluray'"
	
	connection_status = 1
	IP.Flags = 0
	
	// check to see if timeline is running already
	IF(TIMELINE_ACTIVE(TL_TIMELINE)) {
	    TIMELINE_RESTART(TL_TIMELINE)
	}
	else {
	    TIMELINE_CREATE(TL_TIMELINE, TimeArray, 1, TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
	}
    }
    OFFLINE: {
	IF (nDebug) 
	    SEND_STRING 0,"'offline: bluray'"
	
	connection_status = 0
	
	// pause timeline
	TIMELINE_PAUSE(TL_TIMELINE)
	
	// retry connection
	//wait 5
	    //fnOpenConnection()
    }
    STRING: {
	STACK_VAR INTEGER pos
	STACK_VAR INTEGER i
	
	IF (nDebug) 
	    SEND_STRING 0,"'string: bluray=',Data.Text"
	
	SELECT {
	    ACTIVE (FIND_STRING(DATA.TEXT,"'There is currently no media playing'",1)): {
		REMOVE_STRING(DATA.TEXT,"'There is currently no media playing'",1)
		
		// clear all properties
		
	    }
	}
    }
}

DATA_EVENT[vdvDevice] {
    STRING: {
	send_string 0,"'Adding to string buffer ',DATA.TEXT"
    }
    COMMAND: {
        IF (nDebug) 
            send_string 0,"' UI: Command received from SNAPI ',DATA.TEXT"
	
	SELECT {
	    ACTIVE (FIND_STRING(DATA.TEXT,"'TRANSPORT-'",1)): {
		REMOVE_STRING(DATA.TEXT,"'TRANSPORT-'",1)
		
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'PLAY'",1)): {
			REMOVE_STRING(DATA.TEXT,"'PLAY'",1)
			
			//fnSendCommand(BTN_PLAY)
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'STOP'",1)): {
			REMOVE_STRING(DATA.TEXT,"'STOP'",1)
			
			//fnSendCommand(BTN_STOP)
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'PAUSE'",1)): {
			REMOVE_STRING(DATA.TEXT,"'PAUSE'",1)
			
			//fnSendCommand(BTN_PAUSE)
		    }
		}
	    }
	    ACTIVE (FIND_STRING(DATA.TEXT,"'REMOTE-'",1)): {
		REMOVE_STRING(DATA.TEXT,"'REMOTE-'",1)
		
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'MENU'",1)): {
			REMOVE_STRING(DATA.TEXT,"'MENU'",1)
			
			//fnSendCommand(BTN_MENU)
		    }
		}
	    }
	    ACTIVE (FIND_STRING(DATA.TEXT,"'INFO-'",1)): {
		REMOVE_STRING(DATA.TEXT,"'INFO-'",1)
		
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'NAME'",1)): {
			REMOVE_STRING(DATA.TEXT,"'NAME'",1)
			
			//SEND_COMMAND vdvDevice, "'NAME-',nowPlaying.Name"
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'ALBUM'",1)): {
			REMOVE_STRING(DATA.TEXT,"'ALBUM'",1)
			
			//SEND_COMMAND vdvDevice, "'ALBUM-',nowPlaying.Album"
		    }
		}
	    }
	    ACTIVE (FIND_STRING(DATA.TEXT,"'DEBUG-'",1)): {
		REMOVE_STRING(DATA.TEXT,"'DEBUG-'",1)
		
		nDebug = ATOI(DATA.TEXT)
		
		send_string 0,"'Debug level -> ',itoa(nDebug)"
	    }
	    ACTIVE (FIND_STRING(DATA.TEXT,"'VERSION?'",1)): {
		send_string 0,"' Current version is: '"
	    }
	}
    }    
}

TIMELINE_EVENT[TL_TIMELINE] {
    IF (nDebug) 
	send_string 0,"' Inside Timeline, '"

    // Send Current status item requests
    //send_string vdvBuffer, "BR_GET_INFORMATION,CR"
}

CHANNEL_EVENT[vdvDevice, 3000] {
    ON: {	send_string vdvBuffer, "BR_GET_INFORMATION,CR"
	    send_string 0, "'sending get info command to bluray'"
    }
}

CHANNEL_EVENT[vdvDevice, POWER] {
    ON: {	send_string vdvBuffer, "BR_PWR_ON,CR"	
	send_string 0,"'inside power on command bdp'"
    }
    OFF: {	send_string vdvBuffer, "BR_PWR_OFF,CR"	}
}

CHANNEL_EVENT[vdvDevice, TRAY] {
    ON: {	send_string vdvBuffer, "BR_TRAY_OPEN,CR"	}
    OFF: {	send_string vdvBuffer, "BR_TRAY_CLOSE,CR"	}
}
/*
CHANNEL_EVENT[vdvDevice, ENTER] {
    ON: {	send_string vdvBuffer, "BR_ENTER,CR"	}
}

CHANNEL_EVENT[vdvDevice, DISPLAY] {
    ON: {	send_string vdvBuffer, "BR_DISPLAY,CR"	}
}

CHANNEL_EVENT[vdvDevice, FUNCTION] {
    ON: {	send_string vdvBuffer, "BR_FUNCTION,CR"	}
}

CHANNEL_EVENT[vdvDevice, GO_BACK] {	// RETURN
    ON: {	send_string vdvBuffer, "BR_RETURN,CR"	}
}

CHANNEL_EVENT[vdvDevice, EXIT] {
    ON: {	send_string vdvBuffer, "BR_EXIT,CR"	}
}

CHANNEL_EVENT[vdvDevice, CLEAR] {
    ON: {	send_string vdvBuffer, "BR_CLEAR,CR"	}
}
*/
CHANNEL_EVENT[vdvDevice, PLAY] {
    ON: {	send_string vdvBuffer, "BR_PLAY,CR"	}
}

CHANNEL_EVENT[vdvDevice, STOP] {
    ON: {	send_string vdvBuffer, "BR_STOP,CR"	}
}

CHANNEL_EVENT[vdvDevice, PAUSE] {
    ON: {	send_string vdvBuffer, "BR_PAUSE,CR"	}
}
/*
CHANNEL_EVENT[vdvDevice, STEP_FORWARD] {
    ON: {	send_string vdvBuffer, "BR_FWD_SKIP,CR"	}
}

CHANNEL_EVENT[vdvDevice, STEP_REVERSE] {
    ON: {	send_string vdvBuffer, "BR_REV_SKIP,CR"	}
}

CHANNEL_EVENT[vdvDevice, SCAN_FORWARD] {
    ON: {	send_string vdvBuffer, "BR_SCAN_FWD,CR"	}
    OFF: {	send_string vdvBuffer, "BR_STOP_SCAN,CR"	}
}

CHANNEL_EVENT[vdvDevice, SCAN_REVERSE] {
    ON: {	send_string vdvBuffer, "BR_SCAN_REV,CR"	}
    OFF: {	send_string vdvBuffer, "BR_STOP_SCAN,CR"	}
}
*/
CHANNEL_EVENT[vdvDevice, TOP_MENU] {
    ON: {	send_string vdvBuffer, "BR_TOP_MENU,CR"	}
}
/*
CHANNEL_EVENT[vdvDevice, MENU] {
    ON: {	send_string vdvBuffer, "BR_MENU,CR"	}
}

CHANNEL_EVENT[vdvDevice, HOME_MENU] {
    ON: {	send_string vdvBuffer, "BR_HOME_MENU,CR"	}
}

CHANNEL_EVENT[vdvDevice, LEFT] {
    ON: {	send_string vdvBuffer, "BR_LEFT,CR"	}
}

CHANNEL_EVENT[vdvDevice, RIGHT] {
    ON: {	send_string vdvBuffer, "BR_RIGHT,CR"	}
}

CHANNEL_EVENT[vdvDevice, UP] {
    ON: {	send_string vdvBuffer, "BR_UP,CR"	}
}

CHANNEL_EVENT[vdvDevice, DOWN] {
    ON: {	send_string vdvBuffer, "BR_DOWN,CR"	}
}

CHANNEL_EVENT[vdvDevice, NUM_1] {
    ON: {	send_string vdvBuffer, "BR_1,CR"	}
}
*/
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

IF (LENGTH_STRING(buffer)) {
    IF (nDebug) 
	send_string 0,"' Buffer has content'"
	    
    IF(fnParseCommmand() < 1)
	fnOpenConnection()
}

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
