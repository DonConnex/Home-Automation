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
PROGRAM_NAME = 'Onkyo TXNR616 Main' 
(***********************************************************)
(* System Type : NetLinx                                   *)
(* Creation Date: 7/29/2008 3:24:43 PM                    *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
#WARN 'Verify that the PROPERTY-IP_Address has been set to the desired setting.'
#WARN 'Verify that the PROPERTY-Port has been set to the desired setting - Default 60128.'

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

vdvOnkyoTXNR616 = 41001:1:0  // The COMM module should use this as its duet device
vdvOnkyoTXNR6162 = 41001:2:0  // ZONE 2
vdvOnkyoTXNR6163 = 41001:3:0  // ZONE 3
//dvOnkyoTXNR616 = 0:3:0 //Ethernet control. 
dvOnkyoTXNR616 = 5001:1:0 // This device should be used as the physical device by the COMM module
dvOnkyoTXNR616Tp = 10001:1:0 // This port should match the assigned touch panel device port

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT


// ----------------------------------------------------------
// User must fill in these values
VOLATILE CHAR sSurroundMode[50][50] = 
{
    'STEREO',
    'DIRECT',
    'SURROUND',
    'FILM',
    'THX',
    'ACTION',
    'MUSICAL',
    'ORCHESTRA',
    'UNPLUGGED',
    'STUDIO_MIX',	
    'TV_LOGIC',
    'ALL_CH_STEREO',
    'THEATER_DIMENSIONAL',
    'ENHANCED_7',
    'MONO',
    'PURE_AUDIO',
    'FULL_MONO',
    'AUDYSSEY_DSX',
    'WHOLE_HOUSE_MODE',
    'GENRE_STAGE',
    'GENRE_ACTION',
    'GENRE_MUSIC',
    'GENRE_SPORTS',
    'STRAIGHT',
    'DOLBY_EX',
    'THX_CINEMA',
    'THX_SURROUND_EX',
    'THX_MUSIC',
    'THX_GAMES',
    'U2_S2_CINEMA',
    'U2_S2_MUSIC',
    'U2_S2_GAMES',
    'PLII_MOVIE',
    'PLII_MUSIC',
    'NEO6_CINEMA',
    'NEO6_MUSIC',
    'PLII_THX_CINEMA',
    'NEO6_THX_CINEMA',
    'PLII_GAME',
    'PLII_THX_GAMES',
    'NEO6_THX_GAMES',
    'PLII_THX_MUSIC',
    'NEO6_THX_MUSIC',
    'PLIIz_HEIGHT',
    'PLIIz_HEIGHT_THX_CINEMA',
    'PLIIz_HEIGHT_THX_MUSIC',
    'PLIIz_HEIGHT_THX_GAMES',
    'PLII_MOVIE_AUDYSSEY_DSX',
    'PLII_MUSIC_AUDYSSEY_DSX',
    'PLII_GAME_AUDYSSEY_DSX'
}


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

DEV vdvDev2[] = {vdvOnkyoTXNR616,vdvOnkyoTXNR6162,vdvOnkyoTXNR6163}
DEV vdvDev[] = {vdvOnkyoTXNR616}
// ----------------------------------------------------------
// CURRENT DEVICE NUMBER ON TP NAVIGATION BAR
INTEGER nOnkyoTXNR616 = 1

// ----------------------------------------------------------
// DEFINE THE PAGES THAT YOUR COMPONENTS ARE USING IN THE 
// SUB NAVIGATION BAR HERE
INTEGER nSourceSelectPages[] = { 1 }
INTEGER nTunerStationPages[] = { 2,3 }
INTEGER nVolumePages[] = { 4 }
INTEGER nPowerPages[] = { 5 }
INTEGER nPreAmpPages[] = { 6,7 }
INTEGER nMenuPages[] = { 8,9,10 }
INTEGER nModulePages[] = { 11 }


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START


// ----------------------------------------------------------
// DEVICE MODULE GROUPS SHOULD ALL HAVE THE SAME DEVICE NUMBER
DEFINE_MODULE 'Onkyo TXNR616 MenuComponent' menu(vdvDev, dvOnkyoTXNR616Tp, nOnkyoTXNR616, nMenuPages)
DEFINE_MODULE 'Onkyo TXNR616 ModuleComponent' module(vdvDev, dvOnkyoTXNR616Tp, nOnkyoTXNR616, nModulePages)
DEFINE_MODULE 'Onkyo TXNR616 PowerComponent' power(vdvDev2, dvOnkyoTXNR616Tp, nOnkyoTXNR616, nPowerPages)
DEFINE_MODULE 'Onkyo TXNR616 PreAmpComponent' preamp(vdvDev, dvOnkyoTXNR616Tp, nOnkyoTXNR616, nPreAmpPages,  sSurroundMode)
DEFINE_MODULE 'Onkyo TXNR616 SourceSelectComponent' sourceselect(vdvDev2, dvOnkyoTXNR616Tp, nOnkyoTXNR616, nSourceSelectPages)
DEFINE_MODULE 'Onkyo TXNR616 TunerStationComponent' tunerstation(vdvDev, dvOnkyoTXNR616Tp, nOnkyoTXNR616, nTunerStationPages)
DEFINE_MODULE 'Onkyo TXNR616 VolumeComponent' volume(vdvDev2, dvOnkyoTXNR616Tp, nOnkyoTXNR616, nVolumePages)


// Define your communications module here like so:
DEFINE_MODULE 'Onkyo_TXNR616_Comm_dr1_0_0' comm(vdvOnkyoTXNR616, dvOnkyoTXNR616)

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

//Ethernet Control
/*
DATA_EVENT  [vdvOnkyoTXNR616]
{
    ONLINE:
    {
	SEND_COMMAND vdvOnkyoTXNR616,'PROPERTY-IP_Address,192.168.100.106'
	SEND_COMMAND vdvOnkyoTXNR616,'PROPERTY-Port,60128'
	SEND_COMMAND vdvOnkyoTXNR616,'reinit'
    }
}
*/
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

