MODULE_NAME='Weather'(DEV vdvDev, DEV dvDev)
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

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

// Timelines
LONG tlOnline =	1;

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

struct _Day {
    integer nHighTemp;
    integer nLowTemp;
}

struct _Weather {
    integer nCurrentTemp;
    _Day uDay[5];
};

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

// Basic variables
volatile integer i;

// Timeline Arrays
LONG tlOnlineARRAY[1000] = {1000}; // One Second TL

// connection information
non_volatile char cIP[] = 'rss.wunderground.com';
non_volatile integer nPort = 80;
non_volatile integer nProtocol = IP_TCP;

// location information
volatile char cZipcode[] = '';		// unused on this release

// buffer size
volatile char cBuffer[1000];

// weather struct
volatile _Weather uWeather;

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

// Report IP Errors
define_function CHAR[100] SMTPGetIpError (LONG nNUM) {
    switch (nNUM) {
	case 2:
	    return "'IP ERROR (',itoa(nNUM),'): General Failure (IP_CLIENT_OPEN/IP_SERVER_OPEN)'";
	case 4:
	    return "'IP ERROR (',itoa(nNUM),'): Unknown host (IP_CLIENT_OPEN)'";
	case 6:
	    return "'IP ERROR (',itoa(nNUM),'): Connection refused (IP_CLIENT_OPEN)'";
	case 7:
	    return "'IP ERROR (',itoa(nNUM),'): Connection timed out (IP_CLIENT_OPEN)'";
	case 8:
	    return "'IP ERROR (',itoa(nNUM),'): Unknown connection error (IP_CLIENT_OPEN)'";
	case 9:
	    return "'IP ERROR (',itoa(nNUM),'): Already closed (IP_CLIENT_CLOSE/IP_SERVER_CLOSE)'";
	case 14:
	    return "'IP ERROR (',itoa(nNUM),'): Local port already used (IP_CLIENT_OPEN/IP_SERVER_OPEN)'";
	case 16:
	    return "'IP ERROR (',itoa(nNUM),'): Too many open sockets (IP_CLIENT_OPEN/IP_SERVER_OPEN)'";
	case 17:
	    return "'IP ERROR (',itoa(nNUM),'): Local Port Not Open (IP_SERVER_OPEN)'";
	default:
	    return "'IP ERROR (',itoa(nNUM),'): Unknown'";
    }
}

// Process weather buffer
define_function integer fnProcessBufferedData() {
    // temp character variable
    stack_var char cTemp;
    stack_var char cTempTemperture[6];

    // look for information within buffer
    select {
	active (find_string(cBuffer,'Current Conditions : ',1)): {
	    remove_string(cBuffer,'Current Conditions : ',1);
	    
	    i = 1;
	    while(true) {
		cTemp = get_buffer_char(cBuffer);
		
		if(cBuffer == 'F') {
		    // temp in Fahr
		}
		else {
		    // current temp
		    cTempTemperture[i] = cTemp;
		    
		    // increment character location
		    i++;
		}
	    }
	    select {
		active (find_string(cBuffer,'C, ',1)): {
		    //
		}
	    }
	}
    }
    
    // update weather struct
    uWeather.nCurrentTemp = atoi(cTempTemperture);
    
    clear_buffer cBuffer;
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

// Start Timeline event
timeline_create(tlOnline,tlOnlineARRAY,length_array(tlOnlineARRAY),TIMELINE_RELATIVE,TIMELINE_REPEAT); // START TRYING

// create content buffer
create_buffer dvDev, cBuffer;

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

// 
data_event[dvDev] {
    online: {
	// Stop trying
	TIMELINE_KILL(tlOnline);
	
	// debug info
	send_string 0,"'DEVICE ONLINE- PORT ',ITOA(data.device.port)";
	
	// HTTP GET Command
	send_string dvDev, "'GET /auto/rss_full/DC/Washington.xml HTTP/1.1',13,13,'Host: rss.wunderground.com',13,10,13,10";
    }
    offline: {
	// debug info
	send_string 0,"'DEVICE OFFLINE- PORT ',ITOA(data.device.port)";
	
	// Start attempt
	TIMELINE_CREATE(tlOnline,tlOnlineARRAY,LENGTH_ARRAY(tlOnlineARRAY),TIMELINE_RELATIVE,TIMELINE_REPEAT);
    }
    onerror: {
	// Print error/ debug info
	send_string 0,"'REPORT- PORT ',ITOA(data.device.port),'-',SMTPGetIpError(Data.Number)";
	
	// Act Accordingly
	switch(data.number) {
	    case 14: {
		// Stop trying
		TIMELINE_KILL(tlOnline);
	    }
	    case 17: {
		// Start attempt
		TIMELINE_CREATE(tlOnline,tlOnlineARRAY,LENGTH_ARRAY(tlOnlineARRAY),TIMELINE_RELATIVE,TIMELINE_REPEAT);	
	    }
	}
    }
}

//
data_event[vdvDev] {
    online: {
	
    }
    command: {
    
    }
}

// DEVICE ONLINE TIMELINE
TIMELINE_EVENT[tlOnline] {
    // Open IP Connection
    IP_CLIENT_OPEN(dvDev.PORT,cIP,nPort,nProtocol);
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

// wait for content to fill buffer
if(length_string(cBuffer)){
    // handle buffer
    fnProcessBufferedData();
}

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)