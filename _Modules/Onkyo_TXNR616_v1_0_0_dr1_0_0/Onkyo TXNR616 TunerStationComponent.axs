(*********************************************************************)
(*  AMX Corporation                                                  *)
(*  Copyright (c) 2004-2006 AMX Corporation. All rights reserved.    *)
(*********************************************************************)
(* Copyright Notice :                                                *)
(* Copyright, AMX, Inc., 2004-2007                                   *)
(*    Private, proprietary information, the sole property of AMX.    *)
(*    The contents, ideas, and concepts expressed herein are not to  *)
(*    be disclosed except within the confines of a confidential      *)
(*    relationship and only then on a need to know basis.            *)
(*********************************************************************)
MODULE_NAME = 'Onkyo TXNR616 TunerStationComponent' (dev vdvDev[], dev dvTP, INTEGER nDevice, INTEGER nPages[])
(***********************************************************)
(* System Type : NetLinx                                   *)
(* Creation Date: 12/12/2007 11:14:59 AM                    *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

#include 'ComponentInclude.axi'

#include 'SNAPI.axi'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

// Channels
BTN_GET_BAND                    = 2075  // Button: getBand
BTN_GET_TUNER_STATION           = 2077  // Button: getStation
BTN_GET_TUNER_PRESET            = 2076  // Button: getStationPreset
BTN_FM_BAND                     = 2079  // Button: setBand - FM
BTN_TV_BAND                     = 2086  // Button: setBand - TV
BTN_SHORT_WAVE_BTN              = 2082  // Button: setBand - Short Wave
BTN_SATELLITE_RADIO_BAND        = 2081  // Button: setBand - Satellite Radio
BTN_MEDIUM_WAVE                 = 2083  // Button: setBand - Medium Wave
BTN_FM_MONO_BAND                = 2080  // Button: setBand - FM Mono
BTN_AM_BAND                     = 2078  // Button: setBand - AM
BTN_LONG_WAVE_BTN               = 2084  // Button: setBand - Long Wave


#IF_NOT_DEFINED BTN_TUNER_PRESET_LIST
INTEGER BTN_TUNER_PRESET_LIST[] =       // Button: setStationPreset
{
 2085, 2086, 2087, 2088, 2089, 2090, 2091, 2092, 
 2093, 2094, 2095, 2096, 2097, 2098, 2099, 2100, 
 2101, 2102, 2103, 2104, 2105, 2106, 2107, 2108,
 2109, 2110, 2111, 2112, 2113, 2114, 2115, 2116,
 2117, 2118, 2119, 2120, 2121, 2122, 2123, 2124
}
#END_IF // BTN_TUNER_PRESET_LIST


// Levels

// Variable Text Addresses

// G4 CHANNELS
BTN_TUNER_BAND                  = 40    // Button: Band
BTN_TUNER_PRESET_GROUP          = 224   // Button: Preset Group
BTN_TUNER_STATION_DN            = 226   // Button: Decrement Station
BTN_TUNER_PREV                  = 235   // Button: Goto Previous Station
BTN_TUNER_STATION_UP            = 225   // Button: Increment Station
BTN_CHAN_UP                     = 22    // Button: Next Station Preset
BTN_CHAN_DN                     = 23    // Button: Previous Station Preset
BTN_TUNER_SCAN_FWD              = 227   // Button: Scan Forward
BTN_TUNER_SCAN_REV              = 228   // Button: Scan Backward
BTN_TUNER_SEEK_REV              = 230   // Button: Seek Backward
BTN_TUNER_SEEK_FWD              = 229   // Button: Seek Forward
BTN_DIGIT_3                     = 13    // Button: 3
BTN_DIGIT_0                     = 10    // Button: 0
BTN_DIGIT_1                     = 11    // Button: 1
BTN_DIGIT_7                     = 17    // Button: 7
BTN_MENU_CLEAR                  = 80    // Button: Clear
BTN_MENU_ENTER                  = 21    // Button: Enter
BTN_DIGIT_2                     = 12    // Button: 2
BTN_DIGIT_4                     = 14    // Button: 4
BTN_DIGIT_6                     = 16    // Button: 6
BTN_DIGIT_8                     = 18    // Button: 8
BTN_DIGIT_5                     = 15    // Button: 5
BTN_MENU_DOT                    = 92    // Button: .
BTN_DIGIT_9                     = 19    // Button: 9


// G4 VARIABLE TEXT ADDRESSES
TXT_TUNER_BAND                  = 17    // Text: Band
TXT_TUNER_STATION               = 16    // Text: Channel
TXT_TUNER_STATION1               = 3318    // Text: Channel

// SNAPI CHANNELS
SNAPI_BTN_TUNER_OSD                       = 234 // Button: cycleDisplayInfo


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT


(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile char sTUNERPRESET[MAX_ZONE][40] 
volatile char sBAND[MAX_ZONE][20]
volatile char sStationStore[MAX_ZONE][20]	// Stores the station per output (zone)
volatile char sStationStore1[MAX_ZONE][20]	
//---------------------------------------------------------------------------------
//
// FUNCTION NAME:    OnDeviceChanged
//
// PURPOSE:          This function is used by the device selection BUTTON_EVENT
//                   to notify the module that a device change has occurred
//                   allowing updates to the touch panel user interface.
//
//---------------------------------------------------------------------------------
DEFINE_FUNCTION OnDeviceChanged()
{

    println ("'OnDeviceChanged'")
}

//---------------------------------------------------------------------------------
//
// FUNCTION NAME:    OnPageChanged
//
// PURPOSE:          This function is used by the page selection BUTTON_EVENT
//                   to notify the module that a component change may have occurred
//                   allowing updates to the touch panel user interface.
//
//---------------------------------------------------------------------------------
DEFINE_FUNCTION OnPageChanged()
{

    println ("'OnPageChanged'")
}

//---------------------------------------------------------------------------------
//
// FUNCTION NAME:    OnZoneChange
//
// PURPOSE:          This function is used by the zone selection BUTTON_EVENT
//                   to notify the module that a zone change has occurred
//                   allowing updates to the touch panel user interface.
//
//---------------------------------------------------------------------------------
DEFINE_FUNCTION OnZoneChange()
{
    enableDisableControls()

    SEND_COMMAND dvTP,"'^TXT-',ITOA(TXT_TUNER_BAND),',0,', sBAND[nCurrentZone]"
    SEND_COMMAND dvTP,"'^TXT-',ITOA(TXT_TUNER_STATION),',0,', sStationStore[nCurrentZone]"
    
    println ("'OnZoneChange'")
}

DEFINE_FUNCTION enableDisableControls()
{
  
}

DEFINE_MUTUALLY_EXCLUSIVE
([dvTp,BTN_TUNER_PRESET_LIST[1]]..[dvTp,BTN_TUNER_PRESET_LIST[LENGTH_ARRAY(BTN_TUNER_PRESET_LIST)]])
(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

strCompName = 'TunerStationComponent'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT


(***********************************************************)
(*             TOUCHPANEL EVENTS GO BELOW                  *)
(***********************************************************)
DATA_EVENT [dvTP]
{

    ONLINE:
    {
        bActiveComponent = FALSE
        nActiveDevice = 1
        nActivePage = 0
        nActiveDeviceID = nNavigationBtns[1]
        nActivePageID = 0
        nCurrentZone = 1
        bNoLevelReset = 0
	enableDisableControls()

    }
    OFFLINE:
    {
        bNoLevelReset = 1
    }

}


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       DATA_EVENT for vdvDev
//                   TunerStationComponent: data event 
//
// PURPOSE:          This data event is used to listen for SNAPI component
//                   commands and track feedback for the TunerStationComponent.
//
// LOCAL VARIABLES:  cHeader     :  SNAPI command header
//                   cParameter  :  SNAPI command parameter
//                   nParameter  :  SNAPI command parameter value
//                   cCmd        :  received SNAPI command
//
//---------------------------------------------------------------------------------
DATA_EVENT[vdvDev]
{
    COMMAND :
    {
        // local variables
        STACK_VAR CHAR    cCmd[DUET_MAX_CMD_LEN]
        STACK_VAR CHAR    cHeader[DUET_MAX_HDR_LEN]
        STACK_VAR CHAR    cParameter[DUET_MAX_PARAM_LEN]
        STACK_VAR INTEGER nParameter
        STACK_VAR CHAR    cTrash[20]
        STACK_VAR INTEGER nZone
        
        nZone = getFeedbackZone(data.device)
        
        // get received SNAPI command
        cCmd = DATA.TEXT
        
        // parse command header
        cHeader = DuetParseCmdHeader(cCmd)
        SWITCH (cHeader)
        {
            // SNAPI::TUNERPRESET-<int>
            CASE 'TUNERPRESET' :
            {
                sTUNERPRESET[nZone] = DuetParseCmdParam(cCmd)
                // get parameter value from SNAPI command and set feeback on user interface
                nParameter = ATOI(sTUNERPRESET[nZone])
                off[dvTP,BTN_TUNER_PRESET_LIST]
                if (nParameter)
                    on[dvTP,BTN_TUNER_PRESET_LIST[nParameter]]

            }
            // SNAPI::BAND-<band>
            CASE 'BAND' :
            {
                sBAND[nZone] = DuetParseCmdParam(cCmd)
		if (nZone == nCurrentZone)
		{
		    SEND_COMMAND dvTP,"'^TXT-',ITOA(TXT_TUNER_BAND),',0,', sBAND[nZone]"
		}

            }
            //----------------------------------------------------------
            // CODE-BLOCK For TunerStationComponent
            //
            // The following case statements are used in conjunction
            // with the TunerStationComponent code-block.
            //----------------------------------------------------------
            

            // SNAPI::XCH-<station>
            CASE 'XCH' :
            {
		    sStationStore[nZone] = DuetParseCmdParam(cCmd);
		    if (bActiveComponent)
		    {
			if (nZone == nCurrentZone)
			    SEND_COMMAND dvTP,"'^TXT-',ITOA(TXT_TUNER_STATION),',0,', sStationStore[nZone]"
		    }
		    //sStationStore1[nZone] = ''
            }
            // SNAPI::DEBUG-<state>
            CASE 'DEBUG' :
            {
                // This will toggle debug printing
                nDbg = ATOI(DuetParseCmdParam(cCmd))
            }

        }
    }
}


//----------------------------------------------------------
// CHANNEL_EVENTs For TunerStationComponent
//
// The following channel events are used in conjunction
// with the TunerStationComponent code-block.
//----------------------------------------------------------


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: momentary button - momentary channel
//                   on BTN_CHAN_UP
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_CHAN_UP]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], CHAN_UP]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(CHAN_UP),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: momentary button - momentary channel
//                   on BTN_TUNER_BAND
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_TUNER_BAND]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], TUNER_BAND]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TUNER_BAND),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel button - command
//                   on BTN_SHORT_WAVE_BTN
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_SHORT_WAVE_BTN]
{
    push:
    {
        if (bActiveComponent)
        {
            send_command vdvDev[nCurrentZone], 'BAND-SHORT_WAVE'
            println ("'send_command ',dpstoa(vdvDev[nCurrentZone]),', ',39,'BAND-SHORT_WAVE',39")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel button - command
//                   on BTN_FM_BAND
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_FM_BAND]
{
    push:
    {
        if (bActiveComponent)
        {
            send_command vdvDev[nCurrentZone], 'BAND-FM'
            println ("'send_command ',dpstoa(vdvDev[nCurrentZone]),', ',39,'BAND-FM',39")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel button - command
//                   on BTN_MEDIUM_WAVE
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_MEDIUM_WAVE]
{
    push:
    {
        if (bActiveComponent)
        {
            send_command vdvDev[nCurrentZone], 'BAND-MEDIUM_WAVE'
            println ("'send_command ',dpstoa(vdvDev[nCurrentZone]),', ',39,'BAND-MEDIUM_WAVE',39")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: momentary button - momentary channel
//                   on BTN_CHAN_DN
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_CHAN_DN]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], CHAN_DN]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(CHAN_DN),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel button - command
//                   on BTN_FM_MONO_BAND
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_FM_MONO_BAND]
{
    push:
    {
        if (bActiveComponent)
        {
            send_command vdvDev[nCurrentZone], 'BAND-FM_MONO'
            println ("'send_command ',dpstoa(vdvDev[nCurrentZone]),', ',39,'BAND-FM_MONO',39")
        }
    }
}
//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: momentary button - momentary channel
//                   on BTN_TUNER_STATION_UP
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_TUNER_STATION_UP]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], TUNER_STATION_UP]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TUNER_STATION_UP),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: momentary button - momentary channel
//                   on BTN_TUNER_PREV
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_TUNER_PREV]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], TUNER_PREV]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TUNER_PREV),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel button - command
//                   on BTN_GET_TUNER_PRESET
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_GET_TUNER_PRESET]
{
    push:
    {
        if (bActiveComponent)
        {
            send_command vdvDev[nCurrentZone], '?TUNERPRESET'
            println ("'send_command ',dpstoa(vdvDev[nCurrentZone]),', ',39,'?TUNERPRESET',39")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel button - command
//                   on BTN_GET_TUNER_STATION
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_GET_TUNER_STATION]
{
    push:
    {
        if (bActiveComponent)
        {
            send_command vdvDev[nCurrentZone], '?XCH'
            println ("'send_command ',dpstoa(vdvDev[nCurrentZone]),', ',39,'?XCH',39")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel button - command
//                   on BTN_GET_BAND
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_GET_BAND]
{
    push:
    {
        if (bActiveComponent)
        {
            send_command vdvDev[nCurrentZone], '?BAND'
            println ("'send_command ',dpstoa(vdvDev[nCurrentZone]),', ',39,'?BAND',39")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: momentary button - momentary channel
//                   on BTN_TUNER_STATION_DN
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_TUNER_STATION_DN]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], TUNER_STATION_DN]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TUNER_STATION_DN),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: momentary button - momentary channel
//                   on BTN_TUNER_PRESET_GROUP
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_TUNER_PRESET_GROUP]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], TUNER_PRESET_GROUP]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TUNER_PRESET_GROUP),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: momentary button - momentary channel
//                   on TUNER_OSD
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, TUNER_OSD]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], TUNER_OSD]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TUNER_OSD),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel button - command
//                   on BTN_SATELLITE_RADIO_BAND
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_SATELLITE_RADIO_BAND]
{
    push:
    {
        if (bActiveComponent)
        {
            send_command vdvDev[nCurrentZone], 'BAND-SATELLITE_RADIO'
            println ("'send_command ',dpstoa(vdvDev[nCurrentZone]),', ',39,'BAND-SATELLITE_RADIO',39")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel button - command
//                   on BTN_LONG_WAVE_BTN
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_LONG_WAVE_BTN]
{
    push:
    {
        if (bActiveComponent)
        {
            send_command vdvDev[nCurrentZone], 'BAND-LONG_WAVE'
            println ("'send_command ',dpstoa(vdvDev[nCurrentZone]),', ',39,'BAND-LONG_WAVE',39")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel button - command
//                   on BTN_AM_BAND
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_AM_BAND]
{
    push:
    {
        if (bActiveComponent)
        {
            send_command vdvDev[nCurrentZone], 'BAND-AM'
            println ("'send_command ',dpstoa(vdvDev[nCurrentZone]),', ',39,'BAND-AM',39")
        }
    }
}

//----------------------------------------------------------
// EXTENDED EVENTS For TunerStationComponent
//
// The following events are used in conjunction
// with the TunerStationComponent code-block.
//----------------------------------------------------------



//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel range button - command
//                   on BTN_TUNER_PRESET_LIST
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the .
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
button_event[dvTP, BTN_TUNER_PRESET_LIST]
{
    push:
    {
        if (bActiveComponent)
		{
			stack_var integer btn
			btn = get_last(BTN_TUNER_PRESET_LIST)
			
			send_command vdvDev[nCurrentZone], "'TUNERPRESET-',itoa(btn)"
			println("'send_command ',dpstoa(vdvDev[nCurrentZone]),', ',39,'TUNERPRESET-',itoa(btn),39")
		}
    }
}
//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel button - command
//                   on BTN_DIGIT_0,
//                   BTN_DIGIT_1,
//                   BTN_DIGIT_2,
//                   BTN_DIGIT_3,
//                   BTN_DIGIT_4,
//                   BTN_DIGIT_5,
//                   BTN_DIGIT_6,
//                   BTN_DIGIT_7 ,
//                   BTN_DIGIT_8,
//                   BTN_DIGIT_9
//                                 
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the .
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
button_event[dvTP, BTN_DIGIT_0]
button_event[dvTP, BTN_DIGIT_1]
button_event[dvTP, BTN_DIGIT_2]
button_event[dvTP, BTN_DIGIT_3]
button_event[dvTP, BTN_DIGIT_4]
button_event[dvTP, BTN_DIGIT_5]
button_event[dvTP, BTN_DIGIT_6]
button_event[dvTP, BTN_DIGIT_7]
button_event[dvTP, BTN_DIGIT_8]
button_event[dvTP, BTN_DIGIT_9]
{                                   
    push:
    {
        if (bActiveComponent)
		{
			sStationStore1[nCurrentZone] = "sStationStore1[nCurrentZone],itoa(button.input.channel - BTN_DIGIT_0)"
			SEND_COMMAND dvTP,"'^TXT-',ITOA(TXT_TUNER_STATION1),',0,', sStationStore1[nCurrentZone]"
		}
    }
}
//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel button - command
//                   on BTN_MENU_DOT
//                                 
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the .
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
button_event[dvTP, BTN_MENU_DOT]
{
    push:
    {
        if (bActiveComponent)
		{
			sStationStore1[nCurrentZone] = "sStationStore1[nCurrentZone],'.'"
			SEND_COMMAND dvTP,"'^TXT-',ITOA(TXT_TUNER_STATION1),',0,', sStationStore1[nCurrentZone]"
		}
    }
}
//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel button - command
//                   on BTN_MENU_CLEAR
//                                 
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the .
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
button_event[dvTP, BTN_MENU_CLEAR]
{
    push:
    {
        if (bActiveComponent)
		{
			sStationStore1[nCurrentZone] = ''
			SEND_COMMAND dvTP,"'^TXT-',ITOA(TXT_TUNER_STATION1),',0,', sStationStore1[nCurrentZone]"
		}
    }
}
//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel button - command
//                   on BTN_MENU_ENTER
//                                 
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the .
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
button_event[dvTP, BTN_MENU_ENTER]
{
    push:
    {
        if (bActiveComponent)
		{
			// SNAPI:XCH-<station>
			send_command vdvDev[nCurrentZone], "'XCH-',sStationStore1[nCurrentZone]"
			println("'send_command ',dpstoa(vdvDev[nCurrentZone]),', ',39,'XCH-',sStationStore1[nCurrentZone],39")
			sStationStore1[nCurrentZone] = ''
			SEND_COMMAND dvTP,"'^TXT-',ITOA(TXT_TUNER_STATION1),',0,', sStationStore1[nCurrentZone]"

		}
    }
}
//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel button - ramping channel
//                   on BTN_TUNER_SEEK_FWD
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_TUNER_SEEK_FWD]
{
    push:
    {
        if (bActiveComponent)
        {
            on[vdvDev[nCurrentZone], TUNER_SEEK_FWD]
			on[dvTP, BTN_TUNER_SEEK_FWD]
			println (" 'on[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TUNER_SEEK_FWD),']'")
        }
    }
    release:
    {
        if (bActiveComponent)
        {
            off[vdvDev[nCurrentZone], TUNER_SEEK_FWD]
			off[dvTP, BTN_TUNER_SEEK_FWD]
            println (" 'off[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TUNER_SEEK_FWD),']'")
        }
    }
}
//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel button - ramping channel
//                   on BTN_TUNER_SEEK_REV
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_TUNER_SEEK_REV]
{
    push:
    {
        if (bActiveComponent)
        {
            on[vdvDev[nCurrentZone], TUNER_SEEK_REV]
			on[dvTP, BTN_TUNER_SEEK_REV]
            println (" 'on[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TUNER_SEEK_REV),']'")
        }
    }
    release:
    {
        if (bActiveComponent)
        {
            off[vdvDev[nCurrentZone], TUNER_SEEK_REV]
			off[dvTP, BTN_TUNER_SEEK_REV]
            println (" 'off[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TUNER_SEEK_REV),']'")
        }
    }
}
//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel button - ramping channel
//                   on BTN_TUNER_SCAN_REV
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_TUNER_SCAN_REV]
{
    push:
    {
        if (bActiveComponent)
        {
            on[vdvDev[nCurrentZone], TUNER_SCAN_REV]
			on[dvTP, BTN_TUNER_SCAN_REV]
            println (" 'on[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TUNER_SCAN_REV),']'")
        }
    }
    release:
    {
        if (bActiveComponent)
        {
            off[vdvDev[nCurrentZone], TUNER_SCAN_REV]
			off[dvTP, BTN_TUNER_SCAN_REV]
            println (" 'off[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TUNER_SCAN_REV),']'")
        }
    }
}
//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   TunerStationComponent: channel button - ramping channel
//                   on BTN_TUNER_SCAN_FWD
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the TunerStationComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_TUNER_SCAN_FWD]
{
    push:
    {
        if (bActiveComponent)
        {
            on[vdvDev[nCurrentZone], TUNER_SCAN_FWD]
			on[dvTP, BTN_TUNER_SCAN_FWD]
            println (" 'on[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TUNER_SCAN_FWD),']'")
        }
    }
    release:
    {
        if (bActiveComponent)
        {
            off[vdvDev[nCurrentZone], TUNER_SCAN_FWD]
			off[dvTP, BTN_TUNER_SCAN_FWD]
            println (" 'off[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TUNER_SCAN_FWD),']'")
        }
    }
}


(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


