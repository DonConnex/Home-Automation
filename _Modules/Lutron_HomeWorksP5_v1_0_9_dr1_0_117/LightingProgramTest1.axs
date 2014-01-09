PROGRAM_NAME='LightingProgramTest1'
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

dvActualLights1 = 0:5:0
//dvActualLights2 = 0:6:0
//dvActualLights3 = 0:7:0
//dvActualLights4 = 0:8:0
//dvActualLights5 = 0:9:0

(*This is the virtual device... duet modules start at 41000 port 1 system 0*)
vdvLights   = 41001:1:0   //virtual device which to talk to module
//vdvLights2  = 41002:1:0   //virtual device which to talk to module
//vdvLights3  = 41003:1:0   //virtual device which to talk to module
//vdvLights4  = 41004:1:0   //virtual device which to talk to module
//vdvLights5  = 41005:1:0   //virtual device which to talk to module

vdvKeypad1  = 41001:2:0   // keypad 1
vdvKeypad2  = 41001:3:0   // keypad 2
vdvKeypad3  = 41001:4:0   // keypad 3
vdvKeypad4  = 41001:5:0   // keypad 4
vdvKeypad5  = 41001:6:0   // keypad 5
vdvKeypad6  = 41001:7:0   // keypad 6
vdvKeypad7  = 41001:8:0   // keypad 7
vdvKeypad8  = 41001:9:0   // keypad 8
vdvKeypad9  = 41001:10:0   // keypad 9
vdvKeypad10  = 41001:11:0   // keypad 10
vdvKeypad11  = 41001:12:0   // keypad 11
vdvKeypad12  = 41001:13:0   // keypad 12
vdvKeypad13  = 41001:14:0   // keypad 13
vdvKeypad14  = 41001:15:0   // keypad 14
vdvKeypad15  = 41001:16:0   // keypad 15
vdvKeypad16  = 41001:17:0   // keypad 16
vdvKeypad17  = 41001:18:0   // keypad 17

dvTP = 10001:1:0 //modero touchpanel


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLATILE DEV vdvLutron[]={vdvLights, vdvKeypad1, vdvKeypad2,
			vdvKeypad3, vdvKeypad4, vdvKeypad5,
			vdvKeypad6, vdvKeypad7, vdvKeypad8,
			vdvKeypad9, vdvKeypad10, vdvKeypad11,
			vdvKeypad12, vdvKeypad13, vdvKeypad14,
			vdvKeypad15, vdvKeypad16, vdvKeypad17}
			
CHAR DimmerAddresses[100][15] = {
    {'2:4:1:1:1'},
    {'2:4:2:1:1'},
    {'2:1:0:1:1'}, //3
    {'2:1:0:1:2'}, //4
    {'2:1:0:1:3'}, //5
    {'2:1:0:1:4'}, //6
    {'2:1:0:2:1'}, //7
    {'2:1:0:2:2'}, //8
    {'2:1:0:2:3'}, //9
    {'2:1:0:2:4'}, //10
    {'2:1:0:3:1'},
    {'2:1:0:3:2'},
    {'2:1:0:3:3'},
    {'2:1:0:3:4'},
    {'2:1:0:4:1'},
    {'2:1:0:4:2'},
    {'2:1:0:4:3'},
    {'2:1:0:4:4'},
    {'2:1:0:5:1'},
    {'2:1:0:5:2'},
    {'2:1:0:5:3'},
    {'2:1:0:5:4'},
    {'2:1:0:6:1'},
    {'2:1:0:6:2'},
    {'2:1:0:6:3'},
    {'2:1:0:6:4'},
    {'2:1:1:1:1'}, //27
    {'2:1:1:1:2'}, //28
    {'2:1:1:1:3'}, //29
    {'2:1:1:1:4'}, //30
    {'2:1:1:2:1'}, //31
    {'2:1:1:2:2'}, //32
    {'2:1:1:2:3'}, //33
    {'2:1:1:2:4'}, //34
    {'2:1:2:1'}, //35
    {'2:1:2:2'}, //36
    {'2:1:2:3'},
    {'3:5:1:1'},
    {'3:5:1:2'},
    {'3:8:1:1'},
    {'3:4:1:1:1'},
    {'3:4:1:1:2'},
    {'3:4:1:1:3'},
    {'3:4:1:1:4'},
    {'3:4:1:1:5'},
    {'3:4:1:1:6'},
    {'3:4:1:2:1'},
    {'3:4:2:2:1'},
    {'3:4:2:4:2'},
    {'3:4:2:6:1'},
    {'3:4:3:2:1'},
    {'3:4:2:4:1'},
    {'3:4:3:6:1'},
    {'3:4:4:2:1'},
    {'3:4:4:4:1'},
    {'3:4:4:6:1'},
    {'3:6:1:1:1'},
    {'3:6:1:1:2'},
    {'3:6:1:1:3'},
    {'3:6:1:1:4'},
    {'3:1:1:1'},
    {'3:1:1:2'},
    {'3:1:1:3'},
    {'3:6:1:2:1'},
    {'3:6:2:1:1'},
    {'3:6:3:1:1'},
    {'3:6:4:1:1'},
    {'4:4:1:1:1'},
    {'4:4:1:1:2'},
    {'4:5:1:1'},
    {'4:5:1:2'},
    {'4:5:1:3'},
    {'4:5:1:4'},
    {'4:5:1:5'},
    {'4:5:1:6'},
    {'4:5:2:1'},
    {'4:5:2:2'},
    {'4:5:2:3'},
    {'4:5:2:4'},
    {'4:5:2:5'},
    {'4:5:2:6'},
    {'4:6:5:1'},
    {'4:6:5:2'},
    {'4:6:5:3'},
    {'4:6:5:4'},
    {'4:6:5:5'},
    {'4:6:5:6'},
    {'4:6:5:7'},
    {'4:6:5:8'},
    {'5:5:1:1'},
    {'5:5:1:2'},
    {'5:8:1:3'},
    {'5:8:1:4'},
    {'5:8:1:5'},
    {'5:8:1:6'},
    {'5:8:1:7'},
    {'5:8:1:8'},
    {'5:8:1:9'},
    {'5:8:1:1'},
    {'5:8:1:2'}
}
CHAR KeypadAddress[17][15] = {
     {'1:8:1:1'},
    {'1:8:2:1'},
    {'2:8:1'},
    {'2:6:1'},
    {'2:6:2'},
    {'2:6:3'},
    {'3:8:2:1'},
    {'3:8:2:2'},
    {'4:6:1'},
    {'4:6:2'},
    {'4:6:3'},
    {'5:6:1'},
    {'5:4:1'},
    {'5:8:2:1'},
    {'5:8:2:2'},
    {'5:8:2:3'},
    {'5:8:2:5'}}
    /*{'4:6:6'},
    {'4:6:7'},
    {'4:6:8'},
    {'4:6:9'},
    {'4:6:10'},
    {'4:6:11'},
    {'4:6:12'},
    {'4:6:13'},
    {'4:6:14'},
    {'4:6:15'},
    {'4:6:16'},
    {'4:6:17'},
    {'4:6:18'},
    {'4:6:19'},
    {'4:6:20'},
    {'4:6:21'},
    {'4:6:22'},
    {'4:6:23'},
    {'4:6:24'},
    {'4:6:25'},
    {'4:6:26'},
    {'4:6:27'},
    {'4:6:28'},
    {'4:6:29'},
    {'4:6:30'},
    {'4:6:31'},
    {'4:6:32'} 
}*/
			    
volatile INTEGER currentLight = 1
volatile INTEGER currentKeypad = 1
volatile integer nOrigPos = 0


char chrText8[25] = '1'
char chrText11[25] = '192.168.1.102'
char chrText12[25] = '23'
char chrText20[25] = '1'
char chrText22[25] = '1'
char chrText25[25] = '1'
char chrtext34[25] = '1'
char chrtext35[25] = '1'
char chrtext43[25] = '1'
char chrtext47[25] = '1'
char chrtext52[25] = '12'
char chrtext53[25] = '31'
char chrtext54[25] = '2006'
char chrtext55[25] = '13'
char chrtext56[25] = '59'
char chrtext57[25] = '00'
char chrtext59[25] = '1'
char chrtext60[25] = '255'
char chrtext62[25] = '1'
char chrtext63[25] = '255'
char chrtext64[25] = '2'
char chrtext67[25] = '1'
char chrtext68[25] = '1'
char chrtext71[25] = '1'
char chrtext74[25] = '1'
char chrtext78[40] = ''


// NOTE:  If not using dynamic device discovery, and want to load module
// uncomment this and comment out the dynamic device below.
//this name is defined in the axs file of the module
DEFINE_MODULE 'LutronHomeWorksP5_dr1_0_117' duet_code(vdvLights, dvActualLights1)


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

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

//this code is for Dynamic Device Discovery
//DYNAMIC_POLLED_PORT(dvActualLights1)
//DYNAMIC_APPLICATION_DEVICE(vdvLights, DUET_DEV_TYPE_LIGHT, 'My Lighting System1')
/*DYNAMIC_POLLED_PORT(dvActualLights2)
DYNAMIC_APPLICATION_DEVICE(vdvLights2, DUET_DEV_TYPE_LIGHT, 'My Lighting System2')
DYNAMIC_POLLED_PORT(dvActualLights3)
DYNAMIC_APPLICATION_DEVICE(vdvLights3, DUET_DEV_TYPE_LIGHT, 'My Lighting System3')
DYNAMIC_POLLED_PORT(dvActualLights4)
DYNAMIC_APPLICATION_DEVICE(vdvLights4, DUET_DEV_TYPE_LIGHT, 'My Lighting System4')
DYNAMIC_POLLED_PORT(dvActualLights5)
DYNAMIC_APPLICATION_DEVICE(vdvLights5, DUET_DEV_TYPE_LIGHT, 'My Lighting System5')
*/
(* System Information Strings ******************************)
(* Use this section if there is a TP in the System!        *)
(*
    SEND_COMMAND TP,"'!F',250,'1'"
    SEND_COMMAND TP,"'TEXT250-',__NAME__"
    SEND_COMMAND TP,"'!F',251,'1'"
    SEND_COMMAND TP,"'TEXT251-',__FILE__,', ',S_DATE,', ',S_TIME"
    SEND_COMMAND TP,"'!F',252,'1'"
    SEND_COMMAND TP,"'TEXT252-',__VERSION__"
    SEND_COMMAND TP,"'!F',253,'1'"
    (* Must fill this (Master Ver) *)
    SEND_COMMAND TP,'TEXT253-'
    SEND_COMMAND TP,"'!F',254,'1'"
    (* Must fill this (Panel File) *)
    SEND_COMMAND TP,'TEXT254-'
    SEND_COMMAND TP,"'!F',255,'1'"
    (* Must fill this (Dealer Info) *)
    SEND_COMMAND TP,'TEXT255-'
*)

//**********NOTE************
//if NOT using dynamic loading, comment this out!!!
// Have to go to webpage of the master and look for dynamic discovered devices
// to acutally load this module!!!!!!!!!!!!!!
//DYNAMIC_APPLICATION_DEVICE(vdvLights, DUET_DEV_TYPE_LIGHT, 'My Lighting System')



DEFINE_FUNCTION fnAddLights()
{
    stack_var integer nCnt
    for(nCnt=1; nCnt<=100; nCnt++ )
    {
      SEND_COMMAND vdvLights, "'LIGHTADD-', ITOA(nCnt), ',[', DimmerAddresses[nCnt],']'"   
    }
}

DEFINE_FUNCTION fnRemoveLights1()
{
    stack_var integer nCnt
    for(nCnt=1; nCnt<=100; nCnt++ )
    {
      SEND_COMMAND vdvLights, "'LIGHTREMOVEIDX-', ITOA(nCnt)"
    }
}

DEFINE_FUNCTION fnRemoveLights2()
{
    stack_var integer nCnt
    for(nCnt=1; nCnt<=100; nCnt++ )
    {
      SEND_COMMAND vdvLights, "'LIGHTREMOVEADDR-[', DimmerAddresses[nCnt] ,']'"
    }
}

DEFINE_FUNCTION fnAddKeyPads()
{
    stack_var integer nCnt
    for(nCnt=1; nCnt<=(17); nCnt++ )
    {
	SEND_COMMAND vdvLights, "'LUTRONKEYPADADD-', ITOA(nCnt), ',[', KeypadAddress[nCnt],']'"
    }
}

DEFINE_FUNCTION fnRemoveKeyPads1()
{
    stack_var integer nCnt
    for(nCnt=1; nCnt<=(17); nCnt++ )
    {
	SEND_COMMAND vdvLights, " 'LUTRONKEYPADREMOVEADDR-[', KeypadAddress[nCnt],']'"
    }
}

DEFINE_FUNCTION fnRemoveKeyPads2()
{
    stack_var integer nCnt
    for(nCnt=1; nCnt<=(17); nCnt++ )
    {
	SEND_COMMAND vdvLights, " 'LUTRONKEYPADREMOVEIDX-',ITOA(nCnt)"
    }
}


(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT
/*
DATA_EVENT [vdvLights]
{
    ONLINE: 
    {
	// string representing a login name. 
	SEND_COMMAND vdvLights,'PROPERTY-Login,Admin'
	SEND_COMMAND vdvLights,'reinit'
    }
}
*/

BUTTON_EVENT[dvTP,1]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights,"'?FWVERSION'"
    }
}
BUTTON_EVENT[dvTP,2]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights,"'?DEBUG'"
    }
}
BUTTON_EVENT[dvTP,3]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights,"'?SECURITYMODESTATE'"
    }
}
BUTTON_EVENT[dvTP,4]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights,"'?VACATIONMODESTATE'"
    }
}
BUTTON_EVENT[dvTP,5]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights,"'?PROPERTY-IP-Address'"
    }
}
BUTTON_EVENT[dvTP,6]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights,"'?PROPERTY-port'"
    }
}
BUTTON_EVENT[dvTP,7]
{
    RELEASE:
    {
			send_command dvTP,"'@TXT',2,''"
    }
}
BUTTON_EVENT[dvTP,8]
{
    RELEASE:
    {
	nOrigPos = 8
    }
}
BUTTON_EVENT[dvTP,9]
{
    RELEASE:
    {
    send_command dvTP,"'@TXT',4,''"
    }
}
BUTTON_EVENT[dvTP,10]
{
    RELEASE:
    {
    send_command dvTP,"'@TXT',5,''"
    }
}
BUTTON_EVENT[dvTP,11]
{
    RELEASE:
    {
	nOrigPos = 11
    }
}
BUTTON_EVENT[dvTP,12]
{
    RELEASE:
    {
	nOrigPos = 12
    }
}
BUTTON_EVENT[dvTP,13]
{
    RELEASE:
    {
    SEND_COMMAND vdvLights,"'?VERSION'"
    }
}
BUTTON_EVENT[dvTP,14]
{
    RELEASE:
    {
    send_command dvTP,"'@TXT',8,''"
    }
}
BUTTON_EVENT[dvTP,15]
{
    RELEASE:
    {
			//SEND_STRING 0,"'Button15'"
    }
}
BUTTON_EVENT[dvTP,16]
{
    RELEASE:
    {
			fnAddLights()
    }
}
BUTTON_EVENT[dvTP,18]
{
    RELEASE:
    {
    SEND_COMMAND vdvLights, "'?LIGHTADDR-',chrText20"
    }
}
BUTTON_EVENT[dvTP,19]
{
    RELEASE:
    {
	SEND_COMMAND vdvLights, "'?LIGHTIDX-[',chrText20,']'"
    }
}
BUTTON_EVENT[dvTP,20]
{
    RELEASE:
    {
	nOrigPos = 20
    }
}

BUTTON_EVENT[dvTP,22]
{
    RELEASE:
    {
	nOrigPos = 22
    }
}

BUTTON_EVENT[dvTP,23]
{
    RELEASE:
    {
	SEND_COMMAND vdvLights, "'?LIGHTLEVEL-',chrtext22"
    }

}

BUTTON_EVENT[dvTP,24]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'?LUTRONKEYPADENABLED-',chrtext25"
    }
}

BUTTON_EVENT[dvTP,25]
{
    RELEASE:
    {
	nOrigPos = 25
    }
}

BUTTON_EVENT[dvTP,26]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'LUTRONKEYPADENABLE-',chrtext25"
    }
}
BUTTON_EVENT[dvTP,27]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'LUTRONKEYPADDISABLE-',chrtext25"
    }
}

BUTTON_EVENT[dvTP,28]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'SECURITYMODESTATE-ON'"
    }
}

BUTTON_EVENT[dvTP,29]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'SECURITYMODESTATE-OFF'"
    }
}

BUTTON_EVENT[dvTP,30]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'VACATIONMODESTATE-STOPPED'"
    }
}

BUTTON_EVENT[dvTP,31]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'VACATIONMODESTATE-RECORD'"
    }
}
BUTTON_EVENT[dvTP,32]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'VACATIONMODESTATE-PLAY'"
    }
}

BUTTON_EVENT[dvTP,33]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'?LUTRONKEYPADLEDUPDATE-',chrtext34,',',chrtext35"
    }
}

BUTTON_EVENT[dvTP,34]
{
    RELEASE:
    {
	nOrigPos = 34
    }
}

BUTTON_EVENT[dvTP,35]
{
    RELEASE:
    {
	nOrigPos = 35
    }
}

BUTTON_EVENT[dvTP,37]
{
    RELEASE:
    {
	fnAddKeyPads()
    }
}

BUTTON_EVENT[dvTP,38]
{
    RELEASE:
    {
	fnRemoveKeyPads1()
    }
}

BUTTON_EVENT[dvTP,39]
{
    RELEASE:
    {
	fnRemoveKeyPads2()
    }
}

BUTTON_EVENT[dvTP,17]
{
    RELEASE:
    {
		fnRemoveLights1()
    }
}

BUTTON_EVENT[dvTP,40]
{
    RELEASE:
    {
		fnRemoveLights2()
    }
}

BUTTON_EVENT[dvTP,41]
{
    RELEASE:
    {
		SEND_COMMAND vdvLights, "'?LUTRONKEYPADADDR-', chrtext43"
    }
}

BUTTON_EVENT[dvTP,42]
{
    RELEASE:
    {
		SEND_COMMAND vdvLights, "'?LUTRONKEYPADIDX-[', chrtext43, ']'"
    }
}

BUTTON_EVENT[dvTP,43]
{
    RELEASE:
    {
	nOrigPos = 43
    }
}

BUTTON_EVENT[dvTP,45]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'REINIT'"
    }
}


BUTTON_EVENT[dvTP,47]
{
    RELEASE:
    {
	nOrigPos = 47
    }
}

BUTTON_EVENT[dvTP,46]
{
    RELEASE:
    {
		SEND_COMMAND vdvLights, "'LIGHTRAMP-', chrText47 , ',UP'"
    }
}

BUTTON_EVENT[dvTP,51]
{
    RELEASE:
    {
		SEND_COMMAND vdvLights, "'LIGHTRAMP-', chrText47 , ',STOP'"
    }
}
BUTTON_EVENT[dvTP,50]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'LIGHTRAMP-', chrText47 , ',DOWN'"
    }
}

BUTTON_EVENT[dvTP,48]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'CLOCK-', chrtext52 , '/',chrtext53, '/', chrtext54 , ' ', chrtext55,':',chrtext56,':', chrtext57"
    }
}


BUTTON_EVENT[dvTP,52]
{
    RELEASE:
    {
	nOrigPos = 52
    }
}

BUTTON_EVENT[dvTP,53]
{
    RELEASE:
    {
	nOrigPos = 53
    }
}
BUTTON_EVENT[dvTP,54]
{
    RELEASE:
    {
	nOrigPos = 54
    }
}
BUTTON_EVENT[dvTP,55]
{
    RELEASE:
    {
	nOrigPos = 55
    }
}
BUTTON_EVENT[dvTP,56]
{
    RELEASE:
    {
	nOrigPos = 56
    }
}
BUTTON_EVENT[dvTP,57]
{
    RELEASE:
    {
	nOrigPos = 57
    }
}
BUTTON_EVENT[dvTP,58]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'LIGHTLEVEL-', chrtext59,',',chrtext60"
    }
}

BUTTON_EVENT[dvTP,59]
{
    RELEASE:
    {
	nOrigPos = 59
    }
}
BUTTON_EVENT[dvTP,60]
{
    RELEASE:
    {
	nOrigPos = 60
    }
}
BUTTON_EVENT[dvTP,61]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'LIGHTLEVEL-', chrtext62,',',chrtext63,',',chrtext64"
    }
}

BUTTON_EVENT[dvTP,62]
{
    RELEASE:
    {
	nOrigPos = 62
    }
}
BUTTON_EVENT[dvTP,63]
{
    RELEASE:
    {
	nOrigPos = 63
    }
}
BUTTON_EVENT[dvTP,64]
{
    RELEASE:
    {
	nOrigPos = 64
    }
}
BUTTON_EVENT[dvTP,67]
{
    RELEASE:
    {
	nOrigPos = 67
    }
}
BUTTON_EVENT[dvTP,68]
{
    RELEASE:
    {
	nOrigPos = 68
    }
}
BUTTON_EVENT[dvTP,69]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'LUTRONKEYPADDOUBLETAP-',chrtext67,',',chrtext68"
    }
}
BUTTON_EVENT[dvTP,65]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'LUTRONKEYPADHOLD-',chrtext67,',',chrtext68"
    }
}
BUTTON_EVENT[dvTP,66]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'LUTRONKEYPADRELEASE-',chrtext67,',',chrtext68"
    }
}
BUTTON_EVENT[dvTP,81]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'LUTRONKEYPADPRESS-',chrtext67,',',chrtext68"
    }
}

BUTTON_EVENT[dvTP,71]
{
    RELEASE:
    {
	nOrigPos = 71
    }
}
BUTTON_EVENT[dvTP,73]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'LIGHTSTATE-',chrtext74,',OFF'"
    }
}
BUTTON_EVENT[dvTP,74]
{RELEASE:{nOrigPos = 74}}

BUTTON_EVENT[dvTP,70]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'?LIGHTSTATE-',chrtext71"
    }
}


BUTTON_EVENT[dvTP,72]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'LIGHTSTATE-',chrtext74,',ON'"
    }
}

BUTTON_EVENT[dvTP,76]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'LIGHTSTATE-',chrtext74,',TOGGLE'"
    }
}

BUTTON_EVENT[dvTP,77]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'PASSTHRU-', chrtext78"
    }
}


BUTTON_EVENT[dvTP,78]
{RELEASE:{nOrigPos=78}}

BUTTON_EVENT[dvTP,79]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'PASSBACK-0'"
    }
}

BUTTON_EVENT[dvTP,80]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'PASSBACK-1'"
    }
}
BUTTON_EVENT[dvTP,82]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'DEBUG-',chrText8"
    }
}
BUTTON_EVENT[dvTP,83]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'PROPERTY-IP_Address,',chrText11"
    }
}
BUTTON_EVENT[dvTP,84]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'PROPERTY-port,',chrText12"
    }
}

BUTTON_EVENT[dvTP,105]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'LUTRONKEYPADPRESS-13,24'"
    }
}
BUTTON_EVENT[dvTP,106]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'LUTRONKEYPADPRESS-13,23'"
    }
}
BUTTON_EVENT[dvTP,107]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'LUTRONKEYPADPRESS-13,1'"
    }
}
BUTTON_EVENT[dvTP,108]
{
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'LUTRONKEYPADPRESS-13,2'"
    }
}

BUTTON_EVENT[dvTP,109]
{
    PUSH:
    {
			SEND_COMMAND vdvLights, "'LUTRONKEYPADPRESS-7,1'"
    }
    RELEASE:
    {
		SEND_COMMAND vdvLights, "'LUTRONKEYPADRELEASE-7,1'"
    }
}

BUTTON_EVENT[dvTP,110]
{
    PUSH:
    {
		SEND_COMMAND vdvLights, "'LUTRONKEYPADPRESS-7,2'"
    }
    RELEASE:
    {
		SEND_COMMAND vdvLights, "'LUTRONKEYPADRELEASE-7,2'"
    }
}

BUTTON_EVENT[dvTP,111]
{
    PUSH:
    {
    	//SEND_STRING 0, "'LUTRONKEYPADPRESS-7,3'"
	SEND_COMMAND vdvLights, "'LUTRONKEYPADPRESS-7,3'"
	wait 3
	{
	    SEND_COMMAND vdvLights, "'LUTRONKEYPADHOLD-7,3'"
	}
	
    }
    RELEASE:
    {
    	//SEND_STRING 0, "'LUTRONKEYPADRELEASE-7,3'"
	SEND_COMMAND vdvLights, "'LUTRONKEYPADRELEASE-7,3'"
    }
}

BUTTON_EVENT[dvTP,112]
{
    PUSH:
    {
			SEND_COMMAND vdvLights, "'LUTRONKEYPADPRESS-7,4'"
    }
    RELEASE:
    {
			SEND_COMMAND vdvLights, "'LUTRONKEYPADRELEASE-7,4'"
    }
    HOLD [3,REPEAT]:
    {
    SEND_COMMAND vdvLights, "'LUTRONKEYPADHOLD-7,4'"
    }
}


DEFINE_EVENT
DATA_EVENT [dvTP]
{
 STRING:
 {
   switch(remove_string(DATA.TEXT,'-',1))
    {
	case 'KEYP-':
	{
	    if (DATA.TEXT != 'ABORT')
	    {
		switch (nOrigPos)
		{
		    case 0: //error
		    {
					send_string 0, "'There was an error'"
		    }
		    break
		    case 20:
		    {
					chrText20 = DATA.TEXT
					send_command dvTP, "'@TXT',12,DATA.TEXT"
					nOrigPos = 0
		    }
		    break
		    case 22:
		    {
					chrText22 = DATA.TEXT
					send_command dvTP, "'@TXT',17,DATA.TEXT"
					nOrigPos = 0
		    }
		    break
		    case 25:
		    {
			chrText25 = DATA.TEXT
			send_command dvTP, "'@TXT',19,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 34:
		    {
			chrText34 = DATA.TEXT
			send_command dvTP, "'@TXT',29,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 35:
		    {
			chrText35 = DATA.TEXT
			send_command dvTP, "'@TXT',30,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 43:
		    {
			chrText43 = DATA.TEXT
			send_command dvTP, "'@TXT',38,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 47:
		    {
			chrText47 = DATA.TEXT
			send_command dvTP, "'@TXT',44,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 52:
		    {
			chrText52 = DATA.TEXT
			send_command dvTP, "'@TXT',47,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 53:
		    {
			chrText53 = DATA.TEXT
			send_command dvTP, "'@TXT',48,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 54:
		    {
			chrText54 = DATA.TEXT
			send_command dvTP, "'@TXT',49,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 55:
		    {
			chrText55 = DATA.TEXT
			send_command dvTP, "'@TXT',50,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 56:
		    {
			chrText56 = DATA.TEXT
			send_command dvTP, "'@TXT',51,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 57:
		    {
			chrText57 = DATA.TEXT
			send_command dvTP, "'@TXT',52,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 59:
		    {
			chrText59 = DATA.TEXT
			send_command dvTP, "'@TXT',54,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 60:
		    {
			send_command dvTP, "'@TXT',55, DATA.TEXT"
			chrText60 = DATA.TEXT
			nOrigPos = 0
		    }
		    break
		    case 62:
		    {
			chrText62 = DATA.TEXT
			send_command dvTP, "'@TXT',57,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 63:
		    {
			chrText63 = DATA.TEXT
			send_command dvTP, "'@TXT',58,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 64:
		    {
			chrText64 = DATA.TEXT
			send_command dvTP, "'@TXT',59,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 67:
		    {
			chrText67 = DATA.TEXT
			send_command dvTP, "'@TXT',63,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 68:
		    {
			chrText68 = DATA.TEXT
			send_command dvTP, "'@TXT',64,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 71:
		    {
			chrText71 = DATA.TEXT
			send_command dvTP, "'@TXT',66,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 74:
		    {
			chrText74 = DATA.TEXT
			send_command dvTP, "'@TXT',69,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 8:
		    {
			chrText8 = DATA.TEXT
			send_command dvTP, "'@TXT',3,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 11:
		    {
			chrText11 = DATA.TEXT
			send_command dvTP, "'@TXT',6,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    case 12:
		    {
			chrText12 = DATA.TEXT
			send_command dvTP, "'@TXT',7,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		    
		}
	    }
	}
	break
	case 'KEYB-':
	{
	     if (DATA.TEXT != 'ABORT')
	    {
		switch (nOrigPos)
		{
		    case 78:
		    {
			chrText78 = DATA.TEXT
			send_command dvTP, "'@TXT',72,DATA.TEXT"
			nOrigPos = 0
		    }
		    break
		}
	    }
	}
	break
    }
 }
}


DATA_EVENT[vdvLights]
{

    
    OFFLINE:
    {
			send_string 0, 'Netlinx Virtual Device OFFLINE, please try to REINIT to reconnect'
    }
    
    ONLINE:
    {
			send_string 0, 'Netlinx Virtual Device ONLINE.'
    }
    
    COMMAND:
    {
	switch(remove_string(DATA.TEXT,'-',1))
	{
	case 'LIGHTLEVEL-':
	{
	    stack_var integer nTmpLightIndex, nTmpLightLevel
	    //send_string 0, "'LIGHTLEVEL-', DATA.TEXT"
	    nTmpLightIndex = ATOI(remove_string(DATA.TEXT,',',1))
	    nTmpLightLevel = ATOI(DATA.TEXT)
	    if (nTmpLightLevel = -2147483648)
	    {
		send_command dvTP,"'@TXT',16,'Light Not In System'"
	    }
	    else
	    {
		//send_string 0,"'Light Level - ', nTmpLightIndex, '-', nTmpLightLevel"
		switch(nTmpLightIndex)
		{
		    case 35:
		    {send_command dvTP,"'@TXT',78,itoa(nTmpLightLevel)"} break
		    case 36:
		    {send_command dvTP,"'@TXT',83,itoa(nTmpLightLevel)"} break
		    case 37:
		    {send_command dvTP,"'@TXT',88,itoa(nTmpLightLevel)"} break
		    case 27:
		    {send_command dvTP,"'@TXT',79,itoa(nTmpLightLevel)"} break
		    case 28:
		    {send_command dvTP,"'@TXT',84,itoa(nTmpLightLevel)"} break
		    case 29:
		    {send_command dvTP,"'@TXT',89,itoa(nTmpLightLevel)"} break
		    case 30:
		    {send_command dvTP,"'@TXT',94,itoa(nTmpLightLevel)"} break
		    case 31:
		    {send_command dvTP,"'@TXT',80,itoa(nTmpLightLevel)"} break
		    case 32:
		    {send_command dvTP,"'@TXT',85,itoa(nTmpLightLevel)"} break
		    case 33:
		    {send_command dvTP,"'@TXT',90,itoa(nTmpLightLevel)"} break
		    case 34:
		    {send_command dvTP,"'@TXT',95,itoa(nTmpLightLevel)"} break
		    case 3:
		    {send_command dvTP,"'@TXT',81,itoa(nTmpLightLevel)"} break
		    case 4:
		    {send_command dvTP,"'@TXT',86,itoa(nTmpLightLevel)"} break
		    case 5:
		    {send_command dvTP,"'@TXT',91,itoa(nTmpLightLevel)"} break
		    case 6:
		    {send_command dvTP,"'@TXT',96,itoa(nTmpLightLevel)"} break
		    case 7:
		    {send_command dvTP,"'@TXT',82,itoa(nTmpLightLevel)"} break
		    case 8:
		    {send_command dvTP,"'@TXT',87,itoa(nTmpLightLevel)"} break
		    case 9:
		    {send_command dvTP,"'@TXT',92,itoa(nTmpLightLevel)"} break
		    case 10:
		    {send_command dvTP,"'@TXT',97,itoa(nTmpLightLevel)"} break
		}
		send_command dvTP,"'@TXT',16,'Light Level: Index=', ITOA(nTmpLightIndex),  ' Level=', ITOA(nTmpLightLevel*100/255)"
	    }
	}
	break
	
	//todo
	case 'LUTRONKEYPADBUTTONSTATE-':
	{
	    //SEND_STRING 0,"'Netlinx Got This from module: ',DATA.TEXT"
	    send_command dvTP, "'@TXT',1001, DATA.TEXT"
	}
	break
	
	case 'LUTRONKEYPADLEDUPDATE-':
	{
	    stack_var char sOutput[100]
	    sOutput = "'Light: ', REMOVE_STRING(DATA.TEXT,',',1), ' LED: ', REMOVE_STRING(DATA.TEXT,',',1), ' Level: ', DATA.TEXT"
	    //SEND_STRING 0, sOutput
	    SEND_COMMAND dvTP, "'@TXT', 31, sOutput"
	}
	break
	case 'FWVERSION-':
	{
	    send_command dvTP,"'@TXT',2,data.text"
	}
	break
	case 'DEBUG-': //this might have to come from TP
	{
	    send_string 0, data.text
	    send_command dvTP,"'@TXT',3,data.text"
	    chrtext8 = data.text
	}
	break
	case 'SECURITYMODESTATE-':
	{
	    send_command dvTP,"'@TXT',4,data.text"
	}
	break
	case 'VACATIONMODESTATE-':
	{
	    send_command dvTP,"'@TXT',5,data.text"
	}
	break
	case 'PROPERTY-':
	{
	    switch(remove_string(DATA.TEXT,',',1))
	    {
		case 'IP-Address,':
		{
		    send_command dvTP,"'@TXT',6,data.text"
		    chrText11 = data.text
		}
		break
		case 'port,':
		{
		    send_command dvTP,"'@TXT',7,data.text"
		    chrText12 = data.text
		}
		break
	    }
	}
	break
	case 'VERSION-':
	{
	    send_command dvTP,"'@TXT',8,data.text"
	}
	break
	case 'CONNECTION-':
	{
	    if (Data.Text = 'Successful')
	    {
		send_command dvTP,"'@TXT',9,'Connected To Processor'"
	    }
	}
	break
	case 'LIGHTADDR-':
	{
	    stack_var char sAMXAddress[10]
	    stack_var char sLutAddress[25]
	    sAMXAddress = remove_string(DATA.TEXT,',',1)
	    //send_string 0, "sAMXAddress"
	    sLutAddress = DATA.TEXT
	    send_command dvTP,"'@TXT',14,'Lut: ', sLutAddress, ' AMX: ', sAMXAddress"
	}
	break
	case 'LUTRONKEYPADADDR-':
	{
	    stack_var char sOutput[100]
	    //send_string 0, 'LUTRONKEYPADADDR'
	    sOutput = "'Keypad: ', REMOVE_STRING(DATA.TEXT, ',', 1), ' Address: ', DATA.TEXT"
	    //SEND_STRING 0, sOutput
	    SEND_COMMAND dvTP,"'@TXT',39,sOutput"
	}
	break
	
	case 'LUTRONKEYPADENABLEDSTATE-':
	{
	    stack_var char sOutput[100]
	    //send_string 0, 'LUTRONKEYPADENABLEDSTATE'
	    sOutput = "'Keypad: ', REMOVE_STRING(DATA.TEXT, ',', 1), ' State: ', DATA.TEXT"
	    //SEND_STRING 0, sOutput
	    SEND_COMMAND dvTP,"'@TXT',20,sOutput"
	}
	break
	case 'LIGHTRAMP-':
	{
	    stack_var char sOutput[100]
	    //send_string 0, 'LIGHTRAMP'
	    sOutput = "'Light: ', REMOVE_STRING(DATA.TEXT, ',', 1), ' Ramping: ', DATA.TEXT"
	    //SEND_STRING 0, sOutput
	    SEND_COMMAND dvTP,"'@TXT',43,sOutput"
	}
	break
	case 'LIGHTSTATE-':
	{
	    stack_var char sOutput[100]
	    //send_string 0, 'LIGHTSTATE'
	    sOutput = "'Light: ', REMOVE_STRING(DATA.TEXT, ',', 1), ' State: ', DATA.TEXT"
	    //SEND_STRING 0, sOutput
	    SEND_COMMAND dvTP,"'@TXT',70,sOutput"
	}
	break
	}
    }
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BEsLOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)