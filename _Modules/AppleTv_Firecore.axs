MODULE_NAME='AppleTv_Firecore' (dev vdvDevice, dev dvDevice, char ipAddress[15], char port[6], integer protocol_type)
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
    http://support.firecore.com/entries/21375902-3rd-Party-Control-API-AirControl-beta-
*)    
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

vdvBuffer = 36001:1:0

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

// channel numbers
INTEGER PLAY = 1
INTEGER STOP = 2
INTEGER PAUSE = 3
INTEGER CHAPTER_SKIP_FORWARD = 4
INTEGER CHAPTER_SKIP_BACKWARDS = 5
INTEGER FAST_FORWARD = 6
INTEGER REWIND = 7
INTEGER MENU = 44
INTEGER ARROW_UP = 45
INTEGER ARROW_DOWN = 46
INTEGER ARROW_LEFT = 47
INTEGER ARROW_RIGHT = 48
INTEGER SELECT_LIST = 49	// SELECT 
INTEGER DEVICE_ONLINE = 251
INTEGER MENU_HOLD = 300
INTEGER SELECT_LIST_HOLD = 301

// physical apple button numbers
INTEGER BTN_MENU = 1
INTEGER BTN_MENU_HOLD = 2
INTEGER BTN_ARROW_UP = 3
INTEGER BTN_ARROW_DOWN = 4
INTEGER BTN_SELECT = 5
INTEGER BTN_ARROW_LEFT = 6
INTEGER BTN_ARROW_RIGHT = 7
INTEGER BTN_PLAY_PAUSE = 10
INTEGER BTN_PAUSE = 15
INTEGER BTN_PLAY = 16
INTEGER BTN_STOP = 17
INTEGER BTN_FAST_FORWARD = 18
INTEGER BTN_REWIND = 19
INTEGER BTN_CHAPTER_SKIP_FORWARD = 20
INTEGER BTN_CHAPTER_SKIP_BACKWARDS = 21
INTEGER BTN_LIST_SELECT_HOLD = 22

INTEGER NOW_PLAYING = 100

// 
TL_TIMELINE = 1

//
PERMENANT_FAILURE = false
    
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

struct _Person {
    CHAR Job[255]
    CHAR Name[255]
}

struct _Cast {
    _Person Person[255]
}

struct _Credits {
    _Cast Cast
}

struct _NowPlaying {
    CHAR Name[255]
    CHAR Album[255]
    CHAR Artist[255]
    CHAR BackDropURL[255]
    CHAR Copyright[255]
    CHAR Type[255]
    CHAR Studio[255]
    CHAR Genre[255]
    CHAR Tagline[255]
    CHAR Released[255]
    CHAR CoverArtURL[255]
    CHAR Certification[5]
    CHAR Overview[255]
    INTEGER Runtime
    _Credits Credits
}

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLATILE INTEGER nDebug = 0   //  DEBUG VARIABLE
VOLATILE CHAR buffer[10000]
VOLATILE SINTEGER connection_status = -2

VOLATILE _IP IP

VOLATILE _NowPlaying nowPlaying

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
    
    // send command
    // if remote action
    IF(temp == NOW_PLAYING) {
	SEND_STRING dvDevice, "'GET /npx HTTP/1.1',13,10,'Host: ',IP.ServerAddress,13,10,13,10"
	
	IF (nDebug) 
	    SEND_STRING dvDevice, "'GET /npx HTTP/1.1',13,10,'Host: ',IP.ServerAddress,13,10,13,10"
    }
    ELSE {
	SEND_STRING dvDevice, "'GET /remoteAction=',itoa(temp),' HTTP/1.1',13,10,'Host: ',IP.ServerAddress,13,10,13,10"
	    
	IF (nDebug) 
	    send_string 0,"'--> GET /remoteAction=1 HTTP/1.1',$0D,$0A,'Host: 192.168.166.68',$0D,$0A,$0D,$0A"
    }
    
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
	case BTN_PLAY: send_string vdvBuffer, "BTN_PLAY"
	case BTN_PAUSE: send_string vdvBuffer, "BTN_PAUSE"
	case BTN_STOP: send_string vdvBuffer, "BTN_STOP"
	case BTN_FAST_FORWARD: send_string vdvBuffer, "BTN_FAST_FORWARD"
	case BTN_REWIND: send_string vdvBuffer, "BTN_REWIND"
	case BTN_CHAPTER_SKIP_FORWARD: send_string vdvBuffer, "BTN_CHAPTER_SKIP_FORWARD"
	case BTN_CHAPTER_SKIP_BACKWARDS: send_string vdvBuffer, "BTN_CHAPTER_SKIP_BACKWARDS"
	case BTN_ARROW_UP: send_string vdvBuffer, "BTN_ARROW_UP"
	case BTN_ARROW_DOWN: send_string vdvBuffer, "BTN_ARROW_DOWN"
	case BTN_ARROW_LEFT: send_string vdvBuffer, "BTN_ARROW_LEFT"
	case BTN_ARROW_RIGHT: send_string vdvBuffer, "BTN_ARROW_RIGHT"
	case BTN_MENU: send_string vdvBuffer, "BTN_MENU"
	case BTN_MENU_HOLD: send_string vdvBuffer, "BTN_MENU_HOLD"
	case BTN_LIST_SELECT_HOLD: send_string vdvBuffer, "BTN_LIST_SELECT_HOLD"
	case BTN_SELECT: send_string vdvBuffer, "BTN_SELECT"
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
	    SEND_STRING 0,"'online: client'"
	
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
	    SEND_STRING 0,"'offline: client'"
	
	connection_status = 0
	
	// pause timeline
	TIMELINE_PAUSE(TL_TIMELINE)
	
	// retry connection
	wait 5
	    fnOpenConnection()
    }
    STRING: {
	STACK_VAR INTEGER pos
	STACK_VAR INTEGER i
	
	IF (nDebug) 
	    SEND_STRING 0,"'string: client=',Data.Text"
	
	SELECT {
	    ACTIVE (FIND_STRING(DATA.TEXT,"'There is currently no media playing'",1)): {
		REMOVE_STRING(DATA.TEXT,"'There is currently no media playing'",1)
		
		// clear all properties
		nowPlaying.Name = ''
		nowPlaying.Album = ''
		nowPlaying.Artist = ''
	
		nowPlaying.BackDropURL = ''
		nowPlaying.Copyright = ''
		nowPlaying.Type = ''
	
		nowPlaying.Studio = ''
		nowPlaying.Genre = ''
		nowPlaying.Tagline = ''
	
		nowPlaying.Released = ''
		nowPlaying.CoverArtURL = ''
		nowPlaying.Certification = ''
	
		nowPlaying.Overview = ''
		nowPlaying.Runtime = 0
		//nowPlaying.Credits.Cast.Person = 0
	    }
	    ACTIVE (FIND_STRING(DATA.TEXT,"'HTTP/1.1 '",1)): {
		REMOVE_STRING(DATA.TEXT,"'HTTP/1.1 '",1)
		
		GetHTTPStatus(atoi(LEFT_STRING(DATA.TEXT,3)))
	    }
	    ACTIVE (FIND_STRING(DATA.TEXT,"'<nowplaying>'",1)): {
		REMOVE_STRING(DATA.TEXT,"'<nowplaying>'",1)
		
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'<name>'",1)): {
			REMOVE_STRING(DATA.TEXT,"'<name>'",1)
			
			pos = FIND_STRING(DATA.TEXT,"'</name>'",1)
			
			if(pos) {
			    nowPlaying.Name = LEFT_STRING(DATA.TEXT, pos-1)
			}
		    }
		}
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'<backDropURL>'",1)): {
			REMOVE_STRING(DATA.TEXT,"'<backDropURL>'",1)
			
			pos = FIND_STRING(DATA.TEXT,"'</backDropURL>'",1)
			
			if(pos) {
			    nowPlaying.BackDropURL = LEFT_STRING(DATA.TEXT, pos-1)
			}
		    }
		}
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'<album>'",1)): {
			REMOVE_STRING(DATA.TEXT,"'<album>'",1)
			
			pos = FIND_STRING(DATA.TEXT,"'</album>'",1)
			
			if(pos) {
			    nowPlaying.Album = LEFT_STRING(DATA.TEXT, pos-1)
			}
		    }
		}
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'<artist>'",1)): {
			REMOVE_STRING(DATA.TEXT,"'<artist>'",1)
			
			pos = FIND_STRING(DATA.TEXT,"'</artist>'",1)
			
			if(pos) {
			    nowPlaying.Artist = LEFT_STRING(DATA.TEXT, pos-1)
			}
		    }
		}
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'<copyright>'",1)): {
			REMOVE_STRING(DATA.TEXT,"'<copyright>'",1)
			
			pos = FIND_STRING(DATA.TEXT,"'</copyright>'",1)
			
			if(pos) {
			    nowPlaying.Copyright = LEFT_STRING(DATA.TEXT, pos-1)
			}
		    }
		}
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'<type>'",1)): {
			REMOVE_STRING(DATA.TEXT,"'<type>'",1)
			
			pos = FIND_STRING(DATA.TEXT,"'</type>'",1)
			
			if(pos) {
			    nowPlaying.Type = LEFT_STRING(DATA.TEXT, pos-1)
			}
		    }
		}
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'<studio>'",1)): {
			REMOVE_STRING(DATA.TEXT,"'<studio>'",1)
			
			pos = FIND_STRING(DATA.TEXT,"'</studio>'",1)
			
			if(pos) {
			    nowPlaying.Studio = LEFT_STRING(DATA.TEXT, pos-1)
			}
		    }
		}
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'<genre>'",1)): {
			REMOVE_STRING(DATA.TEXT,"'<genre>'",1)
			
			pos = FIND_STRING(DATA.TEXT,"'</genre>'",1)
			
			if(pos) {
			    nowPlaying.Genre = LEFT_STRING(DATA.TEXT, pos-1)
			}
		    }
		}
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'<tagline>'",1)): {
			REMOVE_STRING(DATA.TEXT,"'<tagline>'",1)
			
			pos = FIND_STRING(DATA.TEXT,"'</tagline>'",1)
			
			if(pos) {
			    nowPlaying.Tagline = LEFT_STRING(DATA.TEXT, pos-1)
			}
		    }
		}
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'<released>'",1)): {
			REMOVE_STRING(DATA.TEXT,"'<released>'",1)
			
			pos = FIND_STRING(DATA.TEXT,"'</released>'",1)
			
			if(pos) {
			    nowPlaying.Released = LEFT_STRING(DATA.TEXT, pos-1)
			}
		    }
		}
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'<credits>'",1)): {
			REMOVE_STRING(DATA.TEXT,"'<credits>'",1)
			
			SELECT {
			    ACTIVE (FIND_STRING(DATA.TEXT,"'<cast>'",1)): {
				REMOVE_STRING(DATA.TEXT,"'<cast>'",1)
				
				i = 1
				
				while(!FIND_STRING(DATA.TEXT,"'</cast>'",1)) {
				    SELECT {
					ACTIVE (FIND_STRING(DATA.TEXT,"'<person'",1)): {
					    REMOVE_STRING(DATA.TEXT,"'<person'",1)
					    
					    SELECT {
						ACTIVE (FIND_STRING(DATA.TEXT,"'job="'",1)): {
						    REMOVE_STRING(DATA.TEXT,"'job="'",1)
						    
						    pos = FIND_STRING(DATA.TEXT,"'"'",1)
						    
						    if(pos) {
							nowPlaying.Credits.Cast.Person[i].Job = LEFT_STRING(DATA.TEXT, pos-1)
						    }
						}
						ACTIVE (FIND_STRING(DATA.TEXT,"'name="'",1)): {
						    REMOVE_STRING(DATA.TEXT,"'name="'",1)
						    
						    pos = FIND_STRING(DATA.TEXT,"'" />'",1)
						    
						    if(pos) {
							nowPlaying.Credits.Cast.Person[i].Name = LEFT_STRING(DATA.TEXT, pos-1)
						    }
						}
					    }
					    
					    // increment person
					    i++
					}
				    }
				}
			    }
			}
		    }
		}
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'<coverArtURL>'",1)): {
			REMOVE_STRING(DATA.TEXT,"'<coverArtURL>'",1)
			
			pos = FIND_STRING(DATA.TEXT,"'</coverArtURL>'",1)
			
			if(pos) {
			    nowPlaying.CoverArtURL = LEFT_STRING(DATA.TEXT, pos-1)
			}
		    }
		}
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'<certification>'",1)): {
			REMOVE_STRING(DATA.TEXT,"'<certification>'",1)
			
			pos = FIND_STRING(DATA.TEXT,"'</certification>'",1)
			
			if(pos) {
			    nowPlaying.Certification = LEFT_STRING(DATA.TEXT, pos-1)
			}
		    }
		}
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'<overview>'",1)): {
			REMOVE_STRING(DATA.TEXT,"'<overview>'",1)
			
			pos = FIND_STRING(DATA.TEXT,"'</overview>'",1)
			
			if(pos) {
			    nowPlaying.Overview = LEFT_STRING(DATA.TEXT, pos-1)
			}
		    }
		}
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'<runtime>'",1)): {
			REMOVE_STRING(DATA.TEXT,"'<runtime>'",1)
			
			pos = FIND_STRING(DATA.TEXT,"'</runtime>'",1)
			
			if(pos) {
			    nowPlaying.Runtime = ATOI(LEFT_STRING(DATA.TEXT, pos-1))
			}
		    }
		}
	    }
	}
	
	// TEMP
	send_command vdvDevice, "'NAME-', nowPlaying.Name"
	send_command vdvDevice, "'ARTIST-', nowPlaying.Artist"
	send_command vdvDevice, "'COVERARTURL-', nowPlaying.CoverArtURL"
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
			
			fnSendCommand(BTN_PLAY)
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'STOP'",1)): {
			REMOVE_STRING(DATA.TEXT,"'STOP'",1)
			
			fnSendCommand(BTN_STOP)
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'PAUSE'",1)): {
			REMOVE_STRING(DATA.TEXT,"'PAUSE'",1)
			
			fnSendCommand(BTN_PAUSE)
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'PREVIOUS'",1)): {
			REMOVE_STRING(DATA.TEXT,"'PREVIOUS'",1)
			
			fnSendCommand(BTN_CHAPTER_SKIP_BACKWARDS)
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'NEXT'",1)): {
			REMOVE_STRING(DATA.TEXT,"'NEXT'",1)
			
			fnSendCommand(BTN_CHAPTER_SKIP_FORWARD)
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'REWIND'",1)): {
			REMOVE_STRING(DATA.TEXT,"'REWIND'",1)
			
			fnSendCommand(BTN_REWIND)
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'FAST_FORWARD'",1)): {
			REMOVE_STRING(DATA.TEXT,"'FAST_FORWARD'",1)
			
			fnSendCommand(BTN_FAST_FORWARD)
		    }
		}
	    }
	    ACTIVE (FIND_STRING(DATA.TEXT,"'REMOTE-'",1)): {
		REMOVE_STRING(DATA.TEXT,"'REMOTE-'",1)
		
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'MENU'",1)): {
			REMOVE_STRING(DATA.TEXT,"'MENU'",1)
			
			fnSendCommand(BTN_MENU)
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'MENU_HOLD'",1)): {
			REMOVE_STRING(DATA.TEXT,"'MENU_HOLD'",1)
			
			fnSendCommand(BTN_MENU_HOLD)
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'UP'",1)): {
			REMOVE_STRING(DATA.TEXT,"'UP'",1)
			
			fnSendCommand(BTN_ARROW_UP)
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'DOWN'",1)): {
			REMOVE_STRING(DATA.TEXT,"'DOWN'",1)
			
			fnSendCommand(BTN_ARROW_DOWN)
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'LEFT'",1)): {
			REMOVE_STRING(DATA.TEXT,"'LEFT'",1)
			
			fnSendCommand(BTN_ARROW_LEFT)
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'RIGHT'",1)): {
			REMOVE_STRING(DATA.TEXT,"'RIGHT'",1)
			
			fnSendCommand(BTN_ARROW_RIGHT)
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'SELECT'",1)): {
			REMOVE_STRING(DATA.TEXT,"'SELECT'",1)
			
			fnSendCommand(BTN_SELECT)
		    }
		}
	    }
	    ACTIVE (FIND_STRING(DATA.TEXT,"'INFO-'",1)): {
		REMOVE_STRING(DATA.TEXT,"'INFO-'",1)
		
		SELECT {
		    ACTIVE (FIND_STRING(DATA.TEXT,"'NAME'",1)): {
			REMOVE_STRING(DATA.TEXT,"'NAME'",1)
			
			SEND_COMMAND vdvDevice, "'NAME-',nowPlaying.Name"
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'ALBUM'",1)): {
			REMOVE_STRING(DATA.TEXT,"'ALBUM'",1)
			
			SEND_COMMAND vdvDevice, "'ALBUM-',nowPlaying.Album"
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'ARTIST'",1)): {
			REMOVE_STRING(DATA.TEXT,"'ARTIST'",1)
			
			SEND_COMMAND vdvDevice, "'ARTIST-',nowPlaying.Artist"
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'BACKDROPURL'",1)): {
			REMOVE_STRING(DATA.TEXT,"'BACKDROPURL'",1)
			
			SEND_COMMAND vdvDevice, "'BACKDROPURL-',nowPlaying.BackDropURL"
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'COPYRIGHT'",1)): {
			REMOVE_STRING(DATA.TEXT,"'COPYRIGHT'",1)
			
			SEND_COMMAND vdvDevice, "'COPYRIGHT-',nowPlaying.Copyright"
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'TYPE'",1)): {
			REMOVE_STRING(DATA.TEXT,"'TYPE'",1)
			
			SEND_COMMAND vdvDevice, "'TYPE-',nowPlaying.Type"
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'STUDIO'",1)): {
			REMOVE_STRING(DATA.TEXT,"'STUDIO'",1)
			
			SEND_COMMAND vdvDevice, "'STUDIO-',nowPlaying.Studio"
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'GENRE'",1)): {
			REMOVE_STRING(DATA.TEXT,"'GENRE'",1)
			
			SEND_COMMAND vdvDevice, "'GENRE-',nowPlaying.Genre"
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'TAGLINE'",1)): {
			REMOVE_STRING(DATA.TEXT,"'TAGLINE'",1)
			
			SEND_COMMAND vdvDevice, "'TAGLINE-',nowPlaying.Tagline"
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'RELEASED'",1)): {
			REMOVE_STRING(DATA.TEXT,"'RELEASED'",1)
			
			SEND_COMMAND vdvDevice, "'RELEASED-',nowPlaying.Released"
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'COVERARTURL'",1)): {
			REMOVE_STRING(DATA.TEXT,"'COVERARTURL'",1)
			
			SEND_COMMAND vdvDevice, "'COVERARTURL-',nowPlaying.CoverArtURL"
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'CERTIFICATION'",1)): {
			REMOVE_STRING(DATA.TEXT,"'CERTIFICATION'",1)
			
			SEND_COMMAND vdvDevice, "'CERTIFICATION-',nowPlaying.Certification"
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'OVERVIEW'",1)): {
			REMOVE_STRING(DATA.TEXT,"'OVERVIEW'",1)
			
			SEND_COMMAND vdvDevice, "'OVERVIEW-',nowPlaying.Overview"
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'RUNTIME'",1)): {
			REMOVE_STRING(DATA.TEXT,"'RUNTIME'",1)
			
			SEND_COMMAND vdvDevice, "'RUNTIME-',ITOA(nowPlaying.Runtime)"
		    }
		    ACTIVE (FIND_STRING(DATA.TEXT,"'CREDITS'",1)): {
			REMOVE_STRING(DATA.TEXT,"'CREDITS'",1)
			
			// todo: print credits
			//SEND_COMMAND vdvDevice, "'CREDITS-',nowPlaying.Overview"
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

    send_string vdvBuffer, "NOW_PLAYING"
}

CHANNEL_EVENT[vdvDevice, PLAY] {
    ON: {   
	fnSendCommand(BTN_PLAY)
    }
}

CHANNEL_EVENT[vdvDevice, PAUSE] {
    ON: {  
	fnSendCommand(BTN_PAUSE)
    }
}

CHANNEL_EVENT[vdvDevice, STOP] {
    ON: {  
	fnSendCommand(BTN_STOP)
    }
}

CHANNEL_EVENT[vdvDevice, CHAPTER_SKIP_BACKWARDS] {
    ON: {  
	fnSendCommand(BTN_CHAPTER_SKIP_BACKWARDS)
    }
}

CHANNEL_EVENT[vdvDevice, CHAPTER_SKIP_FORWARD] {
    ON: {  
	fnSendCommand(BTN_CHAPTER_SKIP_FORWARD)
    }
}

CHANNEL_EVENT[vdvDevice, REWIND] {
    ON: {  
	fnSendCommand(BTN_REWIND)
    }
}

CHANNEL_EVENT[vdvDevice, FAST_FORWARD] {
    ON: {  
	fnSendCommand(BTN_FAST_FORWARD)
    }
}

CHANNEL_EVENT[vdvDevice, ARROW_UP] {
    ON: {
	fnSendCommand(BTN_ARROW_UP)
    }
}

CHANNEL_EVENT[vdvDevice, ARROW_DOWN] {
    ON: {
	fnSendCommand(BTN_ARROW_DOWN)
    }
}

CHANNEL_EVENT[vdvDevice, ARROW_LEFT] {
    ON: {
	fnSendCommand(BTN_ARROW_LEFT)
    }
}

CHANNEL_EVENT[vdvDevice, ARROW_RIGHT] {
    ON: {
	fnSendCommand(BTN_ARROW_RIGHT)
    }
}

CHANNEL_EVENT[vdvDevice, MENU] {
    ON: {
	fnSendCommand(BTN_MENU)
    }
}

CHANNEL_EVENT[vdvDevice, MENU_HOLD] {
    ON: {
	fnSendCommand(BTN_MENU_HOLD)
    }
}

CHANNEL_EVENT[vdvDevice, SELECT_LIST] {
    ON: {
	fnSendCommand(BTN_SELECT)
    }
}

CHANNEL_EVENT[vdvDevice, SELECT_LIST_HOLD] {
    ON: {
	fnSendCommand(BTN_LIST_SELECT_HOLD)
    }
}


CHANNEL_EVENT[vdvDevice, DEVICE_ONLINE] {
    ON: {
	
    }
    OFF: {
	
    }
}


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
