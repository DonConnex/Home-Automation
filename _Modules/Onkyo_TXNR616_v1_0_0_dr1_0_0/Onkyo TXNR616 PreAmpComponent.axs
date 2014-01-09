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
MODULE_NAME = 'Onkyo TXNR616 PreAmpComponent' (dev vdvDev[], dev dvTP, INTEGER nDevice, INTEGER nPages[], CHAR sSurroundMode[][])
(***********************************************************)
(* System Type : NetLinx                                   *)
(* Creation Date: 7/29/2008 2:13:21 PM                    *)
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
BTN_GET_SURROUND_MODE           = 1800  // Button: getSurroundMode

#IF_NOT_DEFINED BTN_SURROUND_MODE_LIST
INTEGER BTN_SURROUND_MODE_LIST[]=       // Button: setSurroundMode
{
 1801, 1802, 1803, 1804, 1805,
 1806, 1807, 1808, 1809, 1810,
 1811, 1812, 1813, 1814, 1815,
 1816, 1817, 1818, 1819, 1820,
 1821, 1822, 1823, 1824, 1825,
 1826, 1827, 1828, 1829, 1830,
 1831, 1832, 1833, 1834, 1835,
 1836, 1837, 1838, 1839, 1840,
 1841, 1842, 1843, 1844, 1845,
 1846, 1847, 1848, 1849, 1850,
 1851, 1852, 1853
}
#END_IF // BTN_SURROUND_MODE_LIST

BTN_BALANCE_LVL_RELEASE         = 3800  // Button: setBalance Lvl Release Btn
BTN_BASS_LVL_RELEASE            = 3801  // Button: setBass Lvl Release Btn
BTN_TREBLE_LVL_RELEASE          = 3303  // Button: setTreble Lvl Release Btn

// Levels

// Variable Text Addresses

#IF_NOT_DEFINED TXT_SURROUND_MODE_LIST
INTEGER TXT_SURROUND_MODE_LIST[]=       // Text: Surround Mode Name List
{
 3824, 3825, 3826, 3827, 3828,
 3829, 3830, 3831, 3832, 3833,
 3834, 3835, 3836, 3837, 3838,
 3839, 3840, 3841, 3842, 3843,
 3844, 3845, 3846, 3847, 3848,
 3849, 3850, 3851, 3852, 3853,
 3854, 3855, 3856, 3857, 3858,
 3859, 3860, 3861, 3862, 3863,
 3864, 3865, 3866, 3867, 3868,
 3869, 3870, 3871, 3872, 3873,
 3874, 3875, 3876
}
#END_IF // TXT_SURROUND_MODE_LIST


// G4 CHANNELS
BTN_BALANCE_UP                  = 164   // Button: Balance Up
BTN_BALANCE_DN                  = 165   // Button: Balance Down
BTN_BASS_UP                     = 166   // Button: Bass Up
BTN_BASS_DN                     = 167   // Button: Bass Down
BTN_TREBLE_UP                   = 168   // Button: Treble Up
BTN_TREBLE_DN                   = 169   // Button: Treble Down
BTN_LOUDNESS                    = 206   // Button: Loudness
BTN_SURROUND_NEXT               = 170   // Button: Next Surround Mode
BTN_SURROUND_PREV               = 171   // Button: Previous Surround Mode


// G4 LEVELS
LVL_BALANCE                     = 2     // Level: Balance
LVL_BASS                        = 3     // Level: Bass
LVL_TREBLE                      = 4     // Level: Treble


// SNAPI CHANNELS
SNAPI_BTN_LOUDNESS_ON                     = 207 // Button: setLoudnessOn


// SNAPI LEVELS
SNAPI_LVL_BALANCE_LVL                     = 2 // Level: setBalance
SNAPI_LVL_BASS_LVL                        = 3 // Level: setBass
SNAPI_LVL_TREBLE_LVL                      = 4 // Level: setTreble


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

integer nBALANCE_LVL[MAX_ZONE] // Stores level values for BTN_BALANCE_LVL_RELEASE
integer nBASS_LVL[MAX_ZONE] // Stores level values for BTN_BASS_LVL_RELEASE
integer nTREBLE_LVL[MAX_ZONE] // Stores level values for BTN_TREBLE_LVL_RELEASE

volatile integer nSurroundCount = 0		// How many surround modes are on this device, to be calculated when the modes are read in
volatile char    sSurrModes[100][50]	// Stores all surround mode values when read in from the file


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


	displaySurroundModes();
	send_command vdvDev, '?SURROUNDMODES';
	send_command vdvDev, '?SURROUND';

    send_level dvTP, LVL_TREBLE, nTREBLE_LVL[nCurrentZone]
    send_level dvTP, LVL_BALANCE, nBALANCE_LVL[nCurrentZone]
    send_level dvTP, LVL_BASS, nBASS_LVL[nCurrentZone]

    println ("'OnZoneChange'")
}



define_function clearSurroundButtons( INTEGER startFrom )
{
	stack_var integer nLoop
    OFF [dvTP,BTN_SURROUND_MODE_LIST];
	for (nLoop = startFrom; nLoop <= LENGTH_ARRAY(TXT_SURROUND_MODE_LIST); nLoop++)
		setSurroundMode( nLoop, '' );
}
//*********************************************************************
// Function : displaySurroundMode
// Purpose  : display a specific surround modes
// Params   : none
// Return   : none
//*********************************************************************
define_function displaySurroundMode( INTEGER index)
{	
	send_command dvTP, "'^TXT-',itoa(TXT_SURROUND_MODE_LIST[index]),',0,',sSurrModes[index]";
	if ( LENGTH_STRING(sSurrModes[index]) > 0 ) 
	{
		send_command dvTP, "'^SHO-',itoa(TXT_SURROUND_MODE_LIST[index]),',1'";
	} 
	else 
	{
		send_command dvTP, "'^SHO-',itoa(TXT_SURROUND_MODE_LIST[index]),',0'";
	}
}
//*********************************************************************
// Function : displaySurroundModes
// Purpose  : display all available surround modes
// Params   : none
// Return   : none
//*********************************************************************
define_function displaySurroundModes()
{	
	stack_var integer nLoop;
	for (nLoop = 1; nLoop <= LENGTH_ARRAY(BTN_SURROUND_MODE_LIST); nLoop++)
	{
		displaySurroundMode( nLoop );
	}
}
//*********************************************************************
// Function : querySurroundModes
// Purpose  : query device for surround modes and store it for use
// Params   : none
// Return   : none
//*********************************************************************
define_function querySurroundModes()
{	
	SEND_COMMAND vdvDev[nCurrentZone], '?SURROUNDMODES';
}
//*********************************************************************
// Function : setSurroundMode
// Purpose  : query device for surround modes and store it for use
// Params   : none
// Return   : none
//*********************************************************************
define_function setSurroundMode( INTEGER index, CHAR text[] )
{	
	sSurrModes[index] = text;
	send_command dvTP, "'^TXT-',itoa(TXT_SURROUND_MODE_LIST[index]),',0,',sSurrModes[index]";
	displaySurroundMode( index );
}
//*********************************************************************
// Function : loadSurroundModes
// Purpose  : read in a file with surround modes and store it for use
// Params   : none
// Return   : none
//*********************************************************************
define_function loadSurroundModes()
{
    stack_var slong lSurrModeFile
    stack_var integer bEOF
    stack_var sinteger nBytes
    stack_var char sLine[256]
    stack_var integer nModes
    stack_var char sTempModes[100][50]
    
    nModes = 0
    
    // attempt to open the file
    lSurrModeFile = file_open("itoa(vdvDev[1].number),'_SURROUND_MODES.TXT'", 1)
    
    // validate and proceed if successful
    if (lSurrModeFile > 0)
    {
		// loop through all entries
		while(!bEOF)
		{
			// read a line from the file
			nBytes = file_read_line(lSurrModeFile, sLine, 256)
			
			// we've reached the end of the file
			if (nBytes <= 0)
			{
				bEOF = 1
			}
			else
			{
				nModes++
				
				sTempModes[nModes] = sLine
				sSurrModes[nModes] = sTempModes[nModes]
				if (nModes <= LENGTH_ARRAY(TXT_SURROUND_MODE_LIST))
					send_command dvTP, "'^TXT-',itoa(TXT_SURROUND_MODE_LIST[nModes]),',0,',sSurrModes[nModes]"
			}
		}
		
		file_close(lSurrModeFile)
		nSurroundCount = nModes
		
		// make sure we stay within the smallest bounds
		if (nSurroundCount > LENGTH_ARRAY(TXT_SURROUND_MODE_LIST))
			nSurroundCount = LENGTH_ARRAY(TXT_SURROUND_MODE_LIST)
	}
	else
	{
		stack_var integer nLoop
		
		for (nLoop = 1; nLoop <= nSurroundCount; nLoop++)
		{
			// make sure we stay within the smallest bounds
			if (nLoop <= LENGTH_ARRAY(sSurroundMode))
				sSurrModes[nLoop] = sSurroundMode[nLoop]
			else
				set_length_string(sSurrModes[nLoop], 0)
			
			send_command dvTP, "'^TXT-',itoa(TXT_SURROUND_MODE_LIST[nLoop]),',0,',sSurrModes[nLoop]"
		}
    }
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

strCompName = 'PreAmpComponent'

nSurroundCount = LENGTH_ARRAY(TXT_SURROUND_MODE_LIST)


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

		loadSurroundModes()

    }
    OFFLINE:
    {
        bNoLevelReset = 1
    }

}


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       DATA_EVENT for vdvDev
//                   PreAmpComponent: data event 
//
// PURPOSE:          This data event is used to listen for SNAPI component
//                   commands and track feedback for the PreAmpComponent.
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
            
            //----------------------------------------------------------
            // CODE-BLOCK For PreAmpComponent
            //
            // The following case statements are used in conjunction
            // with the PreAmpComponent code-block.
            //----------------------------------------------------------
            

            // SNAPI::SURROUND-<mode>
            CASE 'SURROUND' :
            {
                // get parameter value from SNAPI command and set feeback on user interface
                OFF [dvTP,BTN_SURROUND_MODE_LIST]
                cParameter = DuetParseCmdParam(cCmd)
				if (nZone == nCurrentZone)
				{
					stack_var integer nLoop
					for (nLoop = 1; nLoop <= nSurroundCount; nLoop++)
					[dvTP, BTN_SURROUND_MODE_LIST[nLoop]] = (sSurrModes[nLoop] = cParameter)
				}
            }
			// SNAPI::SURROUNDMODE-<index>,<mode>
            CASE 'SURROUNDMODE' :
            {
				if (nZone == nCurrentZone)
				{
					// get parameter value from SNAPI command and set feeback on user interface
					stack_var integer nSurroundIndex;
					nSurroundIndex = ATOI(DuetParseCmdParam(cCmd))
					cParameter = DuetParseCmdParam(cCmd)
					if( nSurroundIndex > 0 ) 
					{
						setSurroundMode( nSurroundIndex, cParameter );
					}
				}
            }
			// SNAPI::SURROUNDMODECOUNT-<number>
            CASE 'SURROUNDMODECOUNT' :
            {
				if (nZone == nCurrentZone)
				{
					nSurroundCount = ATOI(DuetParseCmdParam(cCmd));
					clearSurroundButtons( nSurroundCount );
				}
            }
			// SNAPI::SURROUNDMODECOUNT-<number>
            CASE 'SURROUNDMODESELECT' :
            {
				if (nZone == nCurrentZone)
				{
	                OFF [dvTP,BTN_SURROUND_MODE_LIST]
					nSurroundCount = ATOI(DuetParseCmdParam(cCmd));
					ON [dvTP, BTN_SURROUND_MODE_LIST[nSurroundCount]];
				}
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
// CHANNEL_EVENTs For PreAmpComponent
//
// The following channel events are used in conjunction
// with the PreAmpComponent code-block.
//----------------------------------------------------------


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PreAmpComponent: momentary button - momentary channel
//                   on BTN_SURROUND_NEXT
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the PreAmpComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_SURROUND_NEXT]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], SURROUND_NEXT]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(SURROUND_NEXT),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PreAmpComponent: channel button - level
//                   on BTN_BALANCE_LVL_RELEASE
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the PreAmpComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_BALANCE_LVL_RELEASE]
{
    release:
    {
        if (bActiveComponent)
        {
            if (!bNoLevelReset)
            {
                send_level vdvDev[nCurrentZone], BALANCE_LVL, nBALANCE_LVL[nCurrentZone]
                println (" 'send_level ',dpstoa(vdvDev[nCurrentZone]),', ',itoa(BALANCE_LVL),', ',itoa(nBALANCE_LVL[nCurrentZone])")
            }
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PreAmpComponent: channel button - level
//                   on BTN_BASS_LVL_RELEASE
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the PreAmpComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_BASS_LVL_RELEASE]
{
    release:
    {
        if (bActiveComponent)
        {
            if (!bNoLevelReset)
            {
                send_level vdvDev[nCurrentZone], BASS_LVL, nBASS_LVL[nCurrentZone]
                println (" 'send_level ',dpstoa(vdvDev[nCurrentZone]),', ',itoa(BASS_LVL),', ',itoa(nBASS_LVL[nCurrentZone])")
            }
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PreAmpComponent: channel button - level
//                   on BTN_TREBLE_LVL_RELEASE
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the PreAmpComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_TREBLE_LVL_RELEASE]
{
    release:
    {
        if (bActiveComponent)
        {
            if (!bNoLevelReset)
            {
                send_level vdvDev[nCurrentZone], TREBLE_LVL, nTREBLE_LVL[nCurrentZone]
                println (" 'send_level ',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TREBLE_LVL),', ',itoa(nTREBLE_LVL[nCurrentZone])")
            }
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PreAmpComponent: momentary button - ramping channel
//                   on BTN_BALANCE_UP
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the PreAmpComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_BALANCE_UP]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], BALANCE_UP]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(BALANCE_UP),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PreAmpComponent: momentary button - ramping channel
//                   on BTN_BALANCE_DN
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the PreAmpComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_BALANCE_DN]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], BALANCE_DN]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(BALANCE_DN),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PreAmpComponent: momentary button - ramping channel
//                   on BTN_BASS_UP
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the PreAmpComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_BASS_UP]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], BASS_UP]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(BASS_UP),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PreAmpComponent: momentary button - ramping channel
//                   on BTN_BASS_DN
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the PreAmpComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_BASS_DN]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], BASS_DN]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(BASS_DN),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PreAmpComponent: momentary button - ramping channel
//                   on BTN_TREBLE_UP
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the PreAmpComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_TREBLE_UP]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], TREBLE_UP]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TREBLE_UP),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PreAmpComponent: momentary button - ramping channel
//                   on BTN_TREBLE_DN
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the PreAmpComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_TREBLE_DN]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], TREBLE_DN]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TREBLE_DN),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PreAmpComponent: channel button - command
//                   on BTN_GET_SURROUND_MODE
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the PreAmpComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_GET_SURROUND_MODE]
{
    push:
    {
        if (bActiveComponent)
        {
            send_command vdvDev[nCurrentZone], '?SURROUND'
            println ("'send_command ',dpstoa(vdvDev[nCurrentZone]),', ',39,'?SURROUND',39")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PreAmpComponent: momentary button - momentary channel
//                   on BTN_SURROUND_PREV
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the PreAmpComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_SURROUND_PREV]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], SURROUND_PREV]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(SURROUND_PREV),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PreAmpComponent: channel button - discrete channel
//                   on LOUDNESS_ON
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the PreAmpComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, LOUDNESS_ON]
{
    push:
    {
        if (bActiveComponent)
        {
            [vdvDev[nCurrentZone],LOUDNESS_ON] = ![vdvDev[nCurrentZone],LOUDNESS_ON]
            println (" '[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(LOUDNESS_ON),'] = ![',dpstoa(vdvDev[nCurrentZone]),', ',itoa(LOUDNESS_ON),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PreAmpComponent: momentary button - momentary channel
//                   on BTN_LOUDNESS
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the PreAmpComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_LOUDNESS]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], LOUDNESS]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(LOUDNESS),']'")
        }
    }
}


//----------------------------------------------------------
// LEVEL_EVENTs For PreAmpComponent
//
// The following level events are used in conjunction
// with the PreAmpComponent code-block.
//----------------------------------------------------------


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for dvTP
//                   PreAmpComponent: level event for dvTP
//
// PURPOSE:          This level event is used to listen for touch panel changes 
//                   and update the PreAmpComponent
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[dvTP, BALANCE_LVL]
{
    if (bActiveComponent)
    {
        if (!bNoLevelReset)
        {
            nBALANCE_LVL[nCurrentZone] = Level.value
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for dvTP
//                   PreAmpComponent: level event for dvTP
//
// PURPOSE:          This level event is used to listen for touch panel changes 
//                   and update the PreAmpComponent
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[dvTP, BASS_LVL]
{
    if (bActiveComponent)
    {
        if (!bNoLevelReset)
        {
            nBASS_LVL[nCurrentZone] = Level.value
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for dvTP
//                   PreAmpComponent: level event for dvTP
//
// PURPOSE:          This level event is used to listen for touch panel changes 
//                   and update the PreAmpComponent
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[dvTP, TREBLE_LVL]
{
    if (bActiveComponent)
    {
        if (!bNoLevelReset)
        {
            nTREBLE_LVL[nCurrentZone] = Level.value
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for vdvDev
//                   PreAmpComponent: level event for PreAmpComponent
//
// PURPOSE:          This level event is used to listen for SNAPI PreAmpComponent changes
//                   on the PreAmpComponent and update the touch panel user
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[vdvDev, TREBLE_LVL]
{
    if (!bNoLevelReset)
    {
        stack_var integer zone
        zone = getFeedbackZone(Level.input.device)
        
        nTREBLE_LVL[zone] = level.value
        if (zone == nCurrentZone)
        {
            send_level dvTP, LVL_TREBLE, nTREBLE_LVL[nCurrentZone]
            println (" 'send_level ',dpstoa(dvTP),', ',itoa(LVL_TREBLE),', ',itoa(nTREBLE_LVL[nCurrentZone])")
        }
    }
}


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for vdvDev
//                   PreAmpComponent: level event for PreAmpComponent
//
// PURPOSE:          This level event is used to listen for SNAPI PreAmpComponent changes
//                   on the PreAmpComponent and update the touch panel user
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[vdvDev, BALANCE_LVL]
{
    if (!bNoLevelReset)
    {
        stack_var integer zone
        zone = getFeedbackZone(Level.input.device)
        
        nBALANCE_LVL[zone] = level.value
        if (zone == nCurrentZone)
        {
            send_level dvTP, LVL_BALANCE, nBALANCE_LVL[nCurrentZone]
            println (" 'send_level ',dpstoa(dvTP),', ',itoa(LVL_BALANCE),', ',itoa(nBALANCE_LVL[nCurrentZone])")
        }
    }
}


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for vdvDev
//                   PreAmpComponent: level event for PreAmpComponent
//
// PURPOSE:          This level event is used to listen for SNAPI PreAmpComponent changes
//                   on the PreAmpComponent and update the touch panel user
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[vdvDev, BASS_LVL]
{
    if (!bNoLevelReset)
    {
        stack_var integer zone
        zone = getFeedbackZone(Level.input.device)
        
        nBASS_LVL[zone] = level.value
        if (zone == nCurrentZone)
        {
            send_level dvTP, LVL_BASS, nBASS_LVL[nCurrentZone]
            println (" 'send_level ',dpstoa(dvTP),', ',itoa(LVL_BASS),', ',itoa(nBASS_LVL[nCurrentZone])")
        }
    }
}



//----------------------------------------------------------
// EXTENDED EVENTS For PreAmpComponent
//
// The following events are used in conjunction
// with the PreAmpComponent code-block.
//----------------------------------------------------------



//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PreAmpComponent: channel range button - command
//                   on BTN_SURROUND_MODE_LIST
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the .
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
button_event[dvTP, BTN_SURROUND_MODE_LIST]
{
    push:
    {
        if (bActiveComponent)
		{
			stack_var integer nCurrentMode
			
			nCurrentMode = get_last(BTN_SURROUND_MODE_LIST)
			send_command vdvDev[nCurrentZone], "'SURROUND-',sSurrModes[nCurrentMode]"
			println("'send_command ',dpstoa(vdvDev[nCurrentZone]),', ',39,'SURROUND-',sSurrModes[nCurrentMode],39")
		}
    }
}
//---------------------------------------------------------------------------------
//
// EVENT TYPE:       CHANNEL_EVENT for dvTP
//                   SourceSelectComponent: on DATA_INITIALIZED
//
// PURPOSE:          This channel event is used to listen for the comm module's 
//                   data initialized event.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
channel_event[vdvDev[1], DATA_INITIALIZED]
{
    ON:
    {
		stack_var integer nLoop
		// query for new properties
		for (nLoop = 1; nLoop <= length_array(vdvDev); nLoop++)
		{
			SEND_COMMAND vdvDev[nLoop], '?SURROUNDMODECOUNT'
			SEND_COMMAND vdvDev[nLoop], '?SURROUNDMODES'
			SEND_COMMAND vdvDev[nLoop], '?SURROUND'
		}
    }
}


(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

[dvTP,LOUDNESS_ON] = [vdvDev[nCurrentZone],LOUDNESS_FB]

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

