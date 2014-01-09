/**
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is used to interoperate Sonos audio equipment with AMX.
 *
 * The Initial Developer of the Original Code is true <trueamx at gmail dot com>.
 *
 * Portions created by the Initial Developer are Copyright (C) 2010 the
 * Initial Developer. All Rights Reserved.
 *
 *
 * $Id$
 * tab-width: 4 columns: 120
 */

MODULE_NAME='Sonos_0_0_3' (
	dev vdev,
	integer start_port
)

/*
	Sonos
	copyright 2013 true & truecontrol

	begin date: 	20130417
	0.0.1 release:	20130421
	0.0.2 release: 	20130428
	0.0.3 release:

	====

	Supports up to 64 players (tested up to XX, results in XX% cpu load)
	Uses 20 IP ports - 1 for UDP search, 10 for Sonos UPnP/HTTP comms, 9 for Sonos eventing

	====

	TODO:
	- fully test (of course), find out what our NI processor limits are
	- find out what subscribe port requirements are in large (30+) systems
	- optimize queueing for large systems, make sure it works
	- get eventing done
	- implement queueing for event registration, so that mass online events
	    don't cause a shitstorm and lack of feedback received
	- implement groups
	- implement browsing
	- add command to get list of all valid players
	- add timers for zoneplayers; if not found after a while, forget them
	- make forgetting work (add variable? reprocessing?
	- make count actually count working players
	- figure out largest return sizes, largest needed buffer sizes
	- create a function for handling feedback - the current way is shit and prone to duplication / mistakes
	- check for duplicated information before sending feedback (reduce chatter / processing time of the UI modules)
	- general optimizations
	- close the comms TCP connections if they don't close quickly (currently
		the	Sonos seems to close the connection after ~5 seconds if, say, an
		invalid command is sent, but we want this to be more like 250ms
		so we don't hold up the queue.)
	- also close the event TCP connections instead of having the Sonos do it
	- make the todo list smaller in the next release =)
	- finish the jorb


	====

	Dedications

	- kasper: build something new

	- a_riot42: to prove you wrong (one of my great motivations)

*/

/* system constants */
define_constant
STRING_RETURN_SIZE_LIMIT 	= 24576


/* system incl */
include 'string'
include 'array'
include 'math'



/* constants */
define_constant
integer 	ZP_MAX	 			= 64

  // debug
integer 	ERR 				= 1
integer 	WARN				= 2
integer 	ALERT 				= 3
integer 	INFO 				= 4

  // communications
integer 	COMMS_COUNT			= 10
integer 	EVENT_COUNT			= 9

integer 	QUEUE_COUNT			= 96

integer 	QUEUE_NONE 			= 0
integer 	QUEUE_READY			= 1
integer 	QUEUE_PENDING		= 2
integer 	QUEUE_SENT 			= 3
integer 	QUEUE_EXPIRED 		= 4

integer 	EVENT_OFFLINE		= 0
integer 	EVENT_ONLINE 		= 1
integer 	EVENT_LISTENING		= 2

  // general flags
integer 	UNKNOWN 		 	= 255

integer 	PLAYING 			= 1
integer 	STOPPED				= 2
integer 	PAUSED 				= 3

integer 	PLAY_MODE_NORMAL 	= 1

integer 	SVC_RADIO			= 1
integer 	SVC_MEDIA_LIBRARY 	= 2
integer 	SVC_LINE_IN 		= 3
integer 	SVC_PANDORA 		= 11
integer 	SVC_RHAPSODY		= 12

  // feedback types (used by zp_fb function)
integer 	FB_NOT_FOUND 		= $00

integer 	FB_IP_ADDR 			= $01
integer 	FB_RINCON 			= $02
integer 	FB_SERIAL 			= $03
integer 	FB_MAC 				= $04
integer 	FB_COORDINATOR 		= $05
integer 	FB_PLAYER_ICON		= $06
integer 	FB_LIGHT 			= $0e
integer 	FB_NAME_FROM_INDEX 	= $0f

integer 	FB_VOLUME 			= $11
integer 	FB_MUTE 			= $12
integer 	FB_OUTPUT_FIXED 	= $13

integer 	FB_LOUDNESS 		= $19
integer 	FB_BASS 			= $1a
integer 	FB_TREBLE 			= $1b

integer 	FB_PLAY_STATE 		= $21
integer 	FB_PLAY_MODE 		= $22
integer 	FB_SERVICE 			= $23
integer 	FB_LINE_IN_NAME 	= $2d
integer 	FB_LINE_IN_LEVEL 	= $2e
integer 	FB_LINE_IN_PRESENT 	= $2f

integer 	FB_TITLE 			= $31
integer 	FB_ARTIST 			= $32
integer 	FB_ALBUM 			= $33
integer 	FB_COVERART			= $34
integer 	FB_TIME_ELAPSED		= $39
integer 	FB_TIME_REMAINING 	= $3a
integer 	FB_TIME_TOTAL 		= $3b



/* structures */
define_type
struct SonosZP {
	  // standard info
	char 		name[20] 			// sonos max settable seems to be 16
	integer 	valid
	char 		ip[16]
	char 		rincon[24] 			// typical 24
	char 		serial[20] 			// typical 19
	char 		mac[17]
	integer 	coordinator 		// index of SonosZP of the group coordinator
	char 		icon[48] 			// max is...?
	  // extended info
	integer 	is_bridge
	  // rendering feedback
	integer 	volume
	integer 	mute
	sinteger 	bass
	sinteger 	treble
	sinteger 	loudness
	  // rendering extended
	integer 	volume_is_fixed
	  // audio in
	integer 	line_in_present
	integer 	line_in_level
	char 		line_in_name[28] 	// max 25
	  // device feedback
	integer 	light
	  // alarms
	integer 	alarm
	integer 	snooze
	  // transport feedback
	integer 	play_state
	integer 	play_mode
	integer 	service
	  // now playing
	char 		np_service_data[96]
	char 		np_uri[512]
	char 		np_title[80]
	char 		np_artist[80]
	char 		np_album[80]
	char 		np_duration_elapsed[12]
	char 		np_duration_total[12]
	char 		np_img_url[256]

}

struct SonosQueue {
	integer 	zpidx
	integer 	status
	char 		cmd[16]
	char 		data1[56]
	char 		data2[56]
}

/* variables */
define_variable
volatile 	integer 	i

  // zp info
volatile 	SonosZP 	sonos[ZP_MAX]
volatile 	integer 	sonos_count

  // ip-related stuff
IP_ADDRESS_STRUCT 		amx_ip

  // discovery
volatile 	dev 		disc_dev

  // outgoing comms
volatile 	dev 		comms_dev[COMMS_COUNT]
volatile 	integer 	comms_queue[COMMS_COUNT]

volatile 	char 		data_buf[COMMS_COUNT][16384] //1536
volatile 	char 		data_header[512]

  // incoming events
volatile 	dev 		event_dev[EVENT_COUNT]
volatile 	integer 	event_status[EVENT_COUNT]
volatile 	integer 	event_zpidx[EVENT_COUNT]
volatile 	char 		event_type[EVENT_COUNT][32]

volatile 	integer 	event_port = 1400

volatile 	char 		event_buf[EVENT_COUNT][21845]
volatile 	integer		event_len[EVENT_COUNT]
volatile 	char 		event_work[21845]
volatile 	char 		event_metadata[16384]

  // sonos queue
volatile 	SonosQueue	queue_data[QUEUE_COUNT]
// volatile char 		queue_response[8][1024]


/* commands incl */
include 'Sonos_Commands_incl_0_0_3'


/* startup */
define_start
{
	// get our IP info (used for eventing)
	get_ip_address(0:0:0, amx_ip)

	// set up IP devices
	disc_dev = 0:start_port:0

	comms_dev[1] = 0:start_port + 1:0
	comms_dev[2] = 0:start_port + 2:0
	comms_dev[3] = 0:start_port + 3:0
	comms_dev[4] = 0:start_port + 4:0
	comms_dev[5] = 0:start_port + 5:0
	comms_dev[6] = 0:start_port + 6:0
	comms_dev[7] = 0:start_port + 7:0
	comms_dev[8] = 0:start_port + 8:0
	comms_dev[9] = 0:start_port + 9:0
	comms_dev[10] = 0:start_port + 10:0

	event_dev[1] = 0:start_port + 11:0
	event_dev[2] = 0:start_port + 12:0
	event_dev[3] = 0:start_port + 13:0
	event_dev[4] = 0:start_port + 14:0
	event_dev[5] = 0:start_port + 15:0
	event_dev[6] = 0:start_port + 16:0
	event_dev[7] = 0:start_port + 17:0
	event_dev[8] = 0:start_port + 18:0
	event_dev[9] = 0:start_port + 19:0
	
	// fixes rebuild_event bug - thanks tomk
	comms_dev = comms_dev
	event_dev = event_dev
	rebuild_event()

	// start up the discovery agent
	ip_client_open(disc_dev.port, ZP_MCAST_GROUP_IP, ZP_MCAST_PORT, IP_UDP_2WAY)
	ip_set_option(disc_dev.port, IP_MULTICAST_TTL_OPTION, 2)

	// create our event listeners
	for (i = 1; i <= EVENT_COUNT; i++) {
		event_status[i] = EVENT_OFFLINE
	}

	event_regenerate()
	event_start(0)
}


/* events */
define_event
data_event[vdev] {
	string: {
		// we send feedback via strings and never need to parse them.
		// please use string events for UI modules.
	}

	command: {
		local_var char 		cmd[6][512]
		local_var integer 	zpidx

		stack_var integer 	w
		stack_var char 		work[16]

		explode_quoted(' ', data.text, cmd, 6, '"')

		zpidx = 0

		// first item should always be the name, ip, or rincon of the target.
		zpidx = zp_idx_get(cmd[1])

		if (zpidx) {
			switch (cmd[2]) {
				// transport
				case 'play':
				case 'pause':
				case 'stop':
				case 'next':
				case 'prev': {
					zp_queue(zpidx, cmd[2], '', '')
				}

				case 'get_now_playing': {
					zp_fb(zpidx, FB_TITLE, '')
					zp_fb(zpidx, FB_ARTIST, '')
					zp_fb(zpidx, FB_ALBUM, '')
					zp_fb(zpidx, FB_COVERART, '')
					zp_fb(zpidx, FB_TIME_ELAPSED, '')
					zp_fb(zpidx, FB_TIME_REMAINING, '')
					zp_fb(zpidx, FB_TIME_TOTAL, '')
				}

				case 'get_play_state': {
					zp_fb(zpidx, FB_PLAY_STATE, '')
				}

				case 'get_play_mode': {
					zp_fb(zpidx, FB_PLAY_MODE, '')
				}

				case 'get_service': {
					zp_fb(zpidx, FB_SERVICE, '')
				}

				// rendering
				case 'vol': {
					if (is_numeric(cmd[3])) {
						if (atoi(cmd[3]) <= 100) {
							zp_queue(zpidx, cmd[2], cmd[3], '')
						}
					}
				}
				case 'vol_rel': {
					// cmd[4] should contain a step amount, even though it is optional
					if (!length_string(cmd[4])) {
						cmd[4] = '1'
					}

					if (is_numeric(cmd[4])) {
						cmd[6] = lower_string(cmd[3])
						if (cmd[6] == 'up' || cmd[6] == '1') {
							zp_queue(zpidx, cmd[2], cmd[4], '')
						} else if (cmd[6] == 'dn' || cmd[6] == 'down' || cmd[6] == '0') {
							zp_queue(zpidx, cmd[2], "'-', cmd[4]", '')
						} else if (is_numeric_signed(cmd[3])) {
							// direct relative offset mode
							zp_queue(zpidx, cmd[2], cmd[3], '')
						}
					}
				}
				case 'get_vol': {
					zp_fb(zpidx, FB_VOLUME, '')
				}

				case 'mute': {
					cmd[6] = left_string(lower_string(cmd[3]), 3)
					if (cmd[6] == 'tog') {
						if (sonos[zpidx].mute) {
							zp_queue(zpidx, cmd[2], 'False', '')
						} else {
							zp_queue(zpidx, cmd[2], 'True', '')
						}
					} else if (cmd[6] == 'on' || cmd[6] == "'1'" || cmd[6] == 'tru') {
						zp_queue(zpidx, cmd[2], 'True', '')
					} else if (cmd[6] == 'off' || cmd[6] == "'0'" || cmd[6] == 'fal') {
						zp_queue(zpidx, cmd[2], 'False', '')
					}
				}
				case 'get_mute': {
					zp_fb(zpidx, FB_MUTE, '')
				}

				case 'get_output_fixed': {
					zp_queue(zpidx, cmd[2], '', '')
				}

				// device
				case 'light': {
					cmd[6] = left_string(lower_string(cmd[3]), 3)
					if (cmd[6] == 'tog') {
						if (sonos[zpidx].light) {
							zp_queue(zpidx, cmd[2], 'Off', '')
						} else {
							zp_queue(zpidx, cmd[2], 'On', '')
						}
					} else if (cmd[6] == 'on' || cmd[6] == "'1'" || cmd[6] == 'tru') {
						zp_queue(zpidx, cmd[2], 'On', '')
					} else if (cmd[6] == 'off' || cmd[6] == "'0'" || cmd[6] == 'fal') {
						zp_queue(zpidx, cmd[2], 'Off', '')
					}
				}
				case 'get_light': {
					zp_fb(zpidx, FB_LIGHT, '')
				}

				// audio in
				case 'line_in':
				case 'line_in_from': {
					w = zp_idx_get(cmd[3])
					if (w) {
						zp_queue(zpidx, 'line_in', itoa(w), '')
					}
				}

				case 'get_line_in_name': {
					zp_fb(zpidx, FB_LINE_IN_NAME, '')
				}
				case 'get_line_in_lev': {
					zp_fb(zpidx, FB_LINE_IN_LEVEL, '')
				}
				case 'get_line_present': {
					zp_fb(zpidx, FB_LINE_IN_PRESENT, '')
				}

				// special
				case 'name_from_index': {
					zp_fb(0, FB_NAME_FROM_INDEX, cmd[3])
				}

				case 'forget':
				case 'rediscover': {
					sonos[zpidx].valid = 0
					sonos[zpidx].name = ''
					sonos[zpidx].ip = ''
				}

				case 'get_all_fb': {
					zp_fb_all(zpidx)
				}

				case 'event_register':
				case 'event_reg': {
					zp_queue(zpidx, 'ereg_transport', '', '')
					zp_queue(zpidx, 'ereg_rendering', '', '')
					zp_queue(zpidx, 'ereg_device', '', '')
					zp_queue(zpidx, 'ereg_audioin', '', '')
				}

				case 'get_ip_addr': {
					zp_fb(zpidx, FB_IP_ADDR, '')
				}
				case 'get_rincon': {
					zp_fb(zpidx, FB_RINCON, '')
				}
				case 'get_serial': {
					zp_fb(zpidx, FB_SERIAL, '')
				}
				case 'get_mac': {
					zp_fb(zpidx, FB_MAC, '')
				}
				case 'get_coordinator': {
					zp_fb(zpidx, FB_COORDINATOR, '')
				}
				case 'get_player_icon': {
					zp_fb(zpidx, FB_PLAYER_ICON, '')
				}
			}
		} else {
			if (cmd[1] == 'moduleconfig') {
				switch (cmd[2]) {
					case 'event_port': {
						if (is_numeric(cmd[3])) {
							event_port = atoi(cmd[3])
							event_regenerate()
						}
					}
				}
			} else {
				zp_fb(0, FB_NOT_FOUND, cmd[1])
			}
		}
	}
}

data_event[disc_dev] {
	offline: {
		wait (50) 'discovery_connect_wait' {
			ip_client_open(disc_dev.port, ZP_MCAST_GROUP_IP, ZP_MCAST_PORT, IP_UDP_2WAY)
			ip_set_option(disc_dev.port, IP_MULTICAST_TTL_OPTION, 2)
		}
	}

	onerror: {
		// not sure why we're here. let's start over.
		wait (50) 'discovery_connect_wait' {
			ip_client_open(disc_dev.port, ZP_MCAST_GROUP_IP, ZP_MCAST_PORT, IP_UDP_2WAY)
			ip_set_option(disc_dev.port, IP_MULTICAST_TTL_OPTION, 2)
		}
	}

	string: {
		// all we care about is the responding device IP address.
		// we'll grab all the other shit from the device later.

		if (!zp_idx_ip(data.sourceip)) {
			sonos_count++
			sonos[sonos_count].ip = data.sourceip

			dbg(INFO, "'disc_dev_str: possible Sonos at ', data.sourceip")

			// we need to get more metadata from this zoneplayer now...
			zp_queue(sonos_count, 'statuszp', '', '')
		}
	}
}

data_event[comms_dev] {
	online: {
		stack_var integer 	cidx
		stack_var integer 	zpidx
		stack_var char 		work[16]

		cidx = array_index(data.device, comms_dev)

		data_buf[cidx] = ''

		if (comms_queue[cidx]) {
			if (queue_data[comms_queue[cidx]].status == QUEUE_PENDING) {
				zpidx = queue_data[comms_queue[cidx]].zpidx

				// we send our commands from here - they were queued by zp_queue()
				switch (queue_data[comms_queue[cidx]].cmd) {
					case 'ereg_transport': {
						data_buf[cidx] = string_replace_first(SUBSCRIBE_TRANSPORT, '{ip}',
								sonos[zpidx].ip)
						data_buf[cidx] = string_replace_first(data_buf[cidx], '{zpidx}',
								itoa(zpidx))

						send_string data.device, data_buf[cidx]
					}
					case 'ereg_rendering': {
						data_buf[cidx] = string_replace_first(SUBSCRIBE_RENDERING, '{ip}',
								sonos[zpidx].ip)
						data_buf[cidx] = string_replace_first(data_buf[cidx], '{zpidx}',
								itoa(zpidx))

						send_string data.device, data_buf[cidx]
					}
					case 'ereg_device': {
						data_buf[cidx] = string_replace_first(SUBSCRIBE_DEVICE, '{ip}',
								sonos[zpidx].ip)
						data_buf[cidx] = string_replace_first(data_buf[cidx], '{zpidx}',
								itoa(zpidx))

						send_string data.device, data_buf[cidx]
					}
					case 'ereg_audioin': {
						data_buf[cidx] = string_replace_first(SUBSCRIBE_AUDIOIN, '{ip}',
								sonos[zpidx].ip)
						data_buf[cidx] = string_replace_first(data_buf[cidx], '{zpidx}',
								itoa(zpidx))

						send_string data.device, data_buf[cidx]
					}

					case 'statuszp': {
						send_string data.device,
							string_replace_first(ZP_STATUS_ZP, '{ip}', sonos[zpidx].ip)
					}

					case 'play': {
						comm_send_basic(cidx, zpidx, ENDPOINT_TRANSPORT, PLAY_BODY, PLAY_SOAPACTION, '', '', '', '')
					}
					case 'pause': {
						comm_send_basic(cidx, zpidx, ENDPOINT_TRANSPORT, PAUSE_BODY, PAUSE_SOAPACTION, '', '', '', '')
					}
					case 'stop': {
						comm_send_basic(cidx, zpidx, ENDPOINT_TRANSPORT, STOP_BODY, STOP_SOAPACTION, '', '', '', '')
					}
					case 'next': {
						comm_send_basic(cidx, zpidx, ENDPOINT_TRANSPORT, NEXT_BODY, NEXT_SOAPACTION, '', '', '', '')
					}
					case 'prev': {
						comm_send_basic(cidx, zpidx, ENDPOINT_TRANSPORT, PREV_BODY, PREV_SOAPACTION, '', '', '', '')
					}

					case 'vol': {
						comm_send_basic(cidx, zpidx, ENDPOINT_RENDERING, VOLUME_BODY, VOLUME_SOAPACTION,
							'{volume}', queue_data[comms_queue[cidx]].data1, '', '')
					}
					case 'vol_rel': {
						comm_send_basic(cidx, zpidx, ENDPOINT_RENDERING, VOLUME_REL_BODY, VOLUME_REL_SOAPACTION,
							'{volume}', queue_data[comms_queue[cidx]].data1, '', '')
					}
					case 'get_vol': {
						comm_send_basic(cidx, zpidx, ENDPOINT_RENDERING, GET_VOLUME_BODY, GET_VOLUME_SOAPACTION, '', '', '', '')
					}

					case 'mute': {
						comm_send_basic(cidx, zpidx, ENDPOINT_RENDERING, MUTE_BODY, MUTE_SOAPACTION,
							'{mute}', queue_data[comms_queue[cidx]].data1, '', '')
					}
					case 'get_mute': {
						comm_send_basic(cidx, zpidx, ENDPOINT_RENDERING,
								GET_MUTE_BODY, GET_MUTE_SOAPACTION, '', '', '', '')
					}

					case 'light': {
						comm_send_basic(cidx, zpidx, ENDPOINT_DEVICE, LIGHT_BODY, LIGHT_SOAPACTION,
							'{light}', queue_data[comms_queue[cidx]].data1, '', '')
					}
					case 'get_light': {
						comm_send_basic(cidx, zpidx, ENDPOINT_DEVICE,
								GET_LIGHT_BODY, GET_LIGHT_SOAPACTION, '', '', '', '')
					}

					case 'line_in': {
						comm_send_basic(cidx, zpidx, ENDPOINT_TRANSPORT, LINE_IN_BODY, TRANSPORTURI_SOAPACTION,
							'{rincon}', sonos[atoi(queue_data[comms_queue[cidx]].data1)].rincon, '', '')
					}

					case 'get_output_fixed': {
						comm_send_basic(cidx, zpidx, ENDPOINT_RENDERING,
							GET_OUT_FIXED_BODY, GET_OUT_FIXED_SOAPACTION, '', '', '', '')
					}
				}

				queue_data[comms_queue[cidx]].status = QUEUE_SENT
			} else {
				// how did we get an invalid queue attached? whatever, we can wipe it out, right? :/
				queue_data[comms_queue[cidx]].status = QUEUE_NONE
				ip_client_close(data.device.port)

			}
		} else {
			// there's no queue index attached to this connection...why is it online?
			ip_client_close(data.device.port)
		}
	}

	offline: {
		stack_var integer 	cidx
		stack_var integer 	zpidx
		stack_var char 		work[16]

		cidx = array_index(data.device, comms_dev)

		if (comms_queue[cidx]) {
			if (queue_data[comms_queue[cidx]].status == QUEUE_SENT) {
				queue_data[comms_queue[cidx]].status = QUEUE_EXPIRED
				zpidx = queue_data[comms_queue[cidx]].zpidx

				// we process our command feedback here
				switch (queue_data[comms_queue[cidx]].cmd) {
					case 'statuszp': {
						sonos[zpidx].name = tag_get_contents(data_buf[cidx], 'ZoneName', 1)
						sonos[zpidx].icon = tag_get_contents(data_buf[cidx], 'ZoneIcon', 1)
						sonos[zpidx].rincon = tag_get_contents(data_buf[cidx], 'LocalUID', 1)
						sonos[zpidx].serial = tag_get_contents(data_buf[cidx], 'SerialNumber', 1)
						sonos[zpidx].mac = tag_get_contents(data_buf[cidx], 'MACAddress', 1)

						sonos[zpidx].valid = 1

						dbg(INFO, "'comms_dev_', itoa(cidx), '_done: statuszp: Got ZP: "',
								sonos[zpidx].name, '" - ', sonos[zpidx].rincon")

						/*
						// now we need to get the basics from this guy.
						zp_queue(zpidx, 'get_vol', '', '')
						zp_queue(zpidx, 'get_mute', '', '')
						zp_queue(zpidx, 'get_light', '', '')
						zp_queue(zpidx, 'get_output_fixed', '', '')
						*/

						// now let's register for events and get some feedback...
						zp_queue(zpidx, 'ereg_transport', '', '')
						zp_queue(zpidx, 'ereg_rendering', '', '')
						zp_queue(zpidx, 'ereg_device', '', '')
						zp_queue(zpidx, 'ereg_audioin', '', '')
					}
				}
			} else {
				queue_data[comms_queue[cidx]].status = QUEUE_NONE
			}
		}

		comms_queue[cidx] = 0
		zp_send()
	}

	onerror: {

	}

	string: {
		stack_var integer cidx

		cidx = array_index(data.device, comms_dev)

		data_buf[cidx] = "data_buf, data.text"
	}
}

data_event[event_dev] {
	online: {
		stack_var integer 	eidx

		eidx = array_index(data.device, event_dev)

		event_status[eidx] = EVENT_ONLINE
		event_buf[eidx] = ''
		event_len[eidx] = 0
		event_zpidx[eidx] = 0
	}

	offline: {
		stack_var integer 	eidx

		eidx = array_index(data.device, event_dev)

		event_status[eidx] = EVENT_OFFLINE
		event_start(0)
	}

	onerror: {
		// what happen? somebody set up us the bomb?
		stack_var integer 	eidx

		eidx = array_index(data.device, event_dev)

		event_status[eidx] = EVENT_OFFLINE

		if (data.number == 14) { 	// already in use error
			ip_server_close(data.device.port)
		}

		wait (10) {
			// we'll just try to restart all events after a delay...
			event_start(0)
		}
	}

	string: {
		stack_var integer 	eidx
		stack_var integer 	zpidx
		stack_var char 		type[16]

		stack_var char 		tag[32]
		local_var char 		work[512]

		stack_var integer 	w
		stack_var integer 	x

		eidx = array_index(data.device, event_dev)

		// pull out header, parse, and fill out info as necessary
		if (left_string(data.text, 6) == 'NOTIFY') {
			event_parse_header(remove_string(data.text, "$0d, $0a", 1), event_zpidx[eidx], event_type[eidx])
		}

		// try to find content-length and parse
		w = find_string(data.text, 'CONTENT-LENGTH:', 1)
		if (w) {
			// remove everything up to and including CONTENT-LENGTH:
			remove_string_by_length(data.text, w + 15)

			// get the length value
			event_len[eidx] = atoi(remove_string(data.text, "$0d, $0a", 1))

			/*
			 * we could get the zpidx here, but instead we parse it straight from the feedback. this will
			 * probably be removed later.
			 *

			// prep for rincon/zpidx
			remove_string(data.text, 'SID: uuid:', 1)

			// and grab that beeotch.
			event_work = remove_string(data.text, '_sub', 1)
			event_zpidx[eidx] = zp_idx_rincon(mid_string(event_work, 1, length_string(event_work) - 4))

			 *
			**/

			// remove the rest of the header, my body is ready
			remove_string(data.text, "$0d, $0a, $0d, $0a", 1)
		}

		event_buf[eidx] = "event_buf[eidx], data.text"

		if (length_string(event_buf[eidx]) >= event_len[eidx]) {
			if (event_zpidx[eidx]) {
				zpidx = event_zpidx[eidx]
				type = event_type[eidx]

				w = 1
				x = 0

				switch (type) {
					case 'Transport':
					case 'Rendering': {
						// <Event xmlns="urn:schemas-upnp-org:metadata-1-0/RCS/"></Event>
						// these have feedback in self-closing tags with the property 'val' containing the value
						event_buf[eidx] = tag_get_contents(event_buf[eidx], 'LastChange', 1)

						// LastChange is encoded xml inside of xml tag. let's decode what we know.
						// TODO: replace this function in the future with a proper decode function
						// TODO: add a string_replace_all function so we don't have to do this nonsense
						while (event_buf[eidx] != event_work) {
							event_work = event_buf[eidx]
							event_buf[eidx] = string_replace_first(event_buf[eidx], '&quot;', '"')
							event_buf[eidx] = string_replace_first(event_buf[eidx], '&lt;', '<')
							event_buf[eidx] = string_replace_first(event_buf[eidx], '&gt;', '>')
						}

						// now let's grab the tasty bits,
						while (true) {
							event_work = tag_get_idx(event_buf[eidx], w)
							if (!length_string(event_work)) {
								break
							}

							tag = tag_get_name(event_work)

							if (left_string(tag, 3) == 'err' || tag == 'Event' || tag == 'InstanceID') {
								w++
								continue
							}

							switch (type) {
								case 'Transport': {
									switch (lower_string(tag)) {
										case 'transportstate': {
											switch (lower_string(tag_get_attribute(event_work, 'val'))) {
												case 'playing': 		sonos[zpidx].play_state = PLAYING
												case 'stopped': 		sonos[zpidx].play_state = STOPPED
												case 'paused_playback': sonos[zpidx].play_state = PAUSED
												default: 				sonos[zpidx].play_state = UNKNOWN
											}

											zp_fb(zpidx, FB_PLAY_STATE, '')
										}

										case 'currentplaymode': {
											switch (lower_string(tag_get_attribute(event_work, 'val'))) {
												case 'normal': 			sonos[zpidx].play_mode = PLAY_MODE_NORMAL
												default: 				sonos[zpidx].play_mode = UNKNOWN
											}

											zp_fb(zpidx, FB_PLAY_MODE, '')
										}

										case 'currenttrackmetadata': {
											event_metadata = tag_get_attribute(event_work, 'val')

											// this data is &amp;d, fix
											while (event_metadata != event_work) {
												event_work = event_metadata
												event_metadata = string_replace_first(event_metadata, '&amp;', '&')
											}

											// then process
											event_work = ''
											while (event_metadata != event_work) {
												event_work = event_metadata
												event_metadata = string_replace_first(event_metadata, '&quot;', '"')
												event_metadata = string_replace_first(event_metadata, '&lt;', '<')
												event_metadata = string_replace_first(event_metadata, '&gt;', '>')
											}

											// tag layout: <DIDL-Lite><item><res></res>--others--</item></DIDL-Lite>
											// until a proper XML parser is written for NetLinx, I will assume this.

											// we need to know what type this is to know how to parse it. this can be
											// found in the <res> tag.
											event_work = tag_get_idx(event_metadata, 3)
											work = tag_get_attribute(event_work, 'protocolInfo')

											// all types seem to be like sonos.com-(data) or pandora.com-(data)
											work = remove_string(work, '-', 1)

											switch (mid_string(work, 1, length_string(work) - 1)) {
												case 'sonos.com': {
													sonos[zpidx].service = SVC_RADIO

													// internet radio is STREAMS man
													// TODO: implement, on service change, zeroing and counting
													// of the elapsed time
													sonos[zpidx].np_duration_elapsed = ''
													sonos[zpidx].np_duration_total = ''

													sonos[zpidx].np_img_url = tag_get_contents(event_metadata, 'upnp:albumArtURI', 1)
													switch (lower_string(tag_get_contents(event_metadata, 'r:streamContent', 1))) {
														case 'zpstr_connecting': {
															sonos[zpidx].np_title = 'Connecting...'
														}
														case 'zpstr_buffering': {
															sonos[zpidx].np_title = 'Buffering...'
														}
														default: {
															// DEBUG
															send_string 0, "$0d, $0a, $0d, $0a, 'ctmd: val: ', tag_get_contents(event_metadata, 'r:streamContent', 1), $0d, $0a"
															// END DEBUG
															sonos[zpidx].np_title = tag_get_contents(event_metadata, 'r:streamContent', 1)
														}
													}

													sonos[zpidx].np_artist = ''
													sonos[zpidx].np_album = ''
												}
												case 'pandora.com': {
													sonos[zpidx].service = SVC_PANDORA

													sonos[zpidx].np_duration_elapsed = '0:00:00'
													// current track length is in the <res> tag
													sonos[zpidx].np_duration_total = tag_get_attribute(event_work, 'duration')

													sonos[zpidx].np_img_url = tag_get_contents(event_metadata, 'upnp:albumArtURI', 1)
													sonos[zpidx].np_title = tag_get_contents(event_metadata, 'dc:title', 1)
													sonos[zpidx].np_artist = tag_get_contents(event_metadata, 'dc:creator', 1)
													sonos[zpidx].np_album = tag_get_contents(event_metadata, 'dc:album', 1)
												}
												default: {
													sonos[zpidx].service = UNKNOWN

													sonos[zpidx].np_duration_elapsed = '0:00:00'
													sonos[zpidx].np_duration_total = '0:00:00'

													sonos[zpidx].np_img_url = ''
													sonos[zpidx].np_title = ''
													sonos[zpidx].np_artist = ''
													sonos[zpidx].np_album = ''

													dbg(ALERT, "'event_string: Transport: Service Not Implemented: ', work")
												}
											}

											zp_fb(zpidx, FB_TITLE, '')
											zp_fb(zpidx, FB_ARTIST, '')
											zp_fb(zpidx, FB_ALBUM, '')
											zp_fb(zpidx, FB_COVERART, '')

											zp_fb(zpidx, FB_TIME_ELAPSED, '')
											zp_fb(zpidx, FB_TIME_REMAINING, '')
											zp_fb(zpidx, FB_TIME_TOTAL, '')
										}

										default: {
											dbg(INFO, "'event_string: Transport: UNHANDLED: ', tag")
										}
									}
								}

								case 'Rendering': {
									switch (lower_string(tag)) {
										case 'volume': {
											if (tag_get_attribute(event_work, 'channel') == 'Master') {
												sonos[zpidx].volume = atoi(tag_get_attribute(event_work, 'val'))
												zp_fb(zpidx, FB_VOLUME, '')
											}
										}
										case 'mute': {
											if (tag_get_attribute(event_work, 'channel') == 'Master') {
												sonos[zpidx].mute = atoi(tag_get_attribute(event_work, 'val'))
												zp_fb(zpidx, FB_MUTE, '')
											}
										}
										case 'loudness': {
											if (tag_get_attribute(event_work, 'channel') == 'Master') {
												sonos[zpidx].loudness = atoi(tag_get_attribute(event_work, 'val'))
												zp_fb(zpidx, FB_LOUDNESS, '')
											}
										}
										case 'bass': {
											sonos[zpidx].bass = atoi(tag_get_attribute(event_work, 'val'))
											zp_fb(zpidx, FB_BASS, '')
										}
										case 'treble': {
											sonos[zpidx].treble = atoi(tag_get_attribute(event_work, 'val'))
											zp_fb(zpidx, FB_TREBLE, '')
										}
										case 'outputfixed': {
											sonos[zpidx].volume_is_fixed = atoi(tag_get_attribute(event_work, 'val'))
											zp_fb(zpidx, FB_OUTPUT_FIXED, '')
										}

										default: {
											dbg(INFO, "'event_string: Rendering: UNHANDLED: ', tag_get_name(event_work)")
										}
									}
								}
							}

							w++
							x++
						}
					}
					case 'Device': {

					}
					case 'AudioIn': {
						// hopefully <e:propertyset xmlns:e="urn:schemas-upnp-org:event-1-0"></e:propertyset>
						// these have feedback as <e:property><FeedbackItem>value</FeedbackItem></e:property>

						while (true) {
							event_work = tag_get_contents(event_buf[eidx], 'e:property', 1)
							if (!length_string(event_work)) {
								break
							}

							remove_string(event_buf[eidx], event_work, 1)

							tag = tag_get_idx(event_work, 1)
							tag = mid_string(tag, 2, length_string(tag) - 2)

							switch (lower_string(tag)) {
								case 'audioinputname': {
									sonos[zpidx].line_in_name = tag_get_contents(event_work, tag, 1)
									zp_fb(zpidx, FB_LINE_IN_NAME, '')
								}
								case 'rightlineinlevel': 		// sonos app only allows setting stereo compensation
								case 'leftlineinlevel': {
									sonos[zpidx].line_in_level = atoi(tag_get_contents(event_work, tag, 1))
									zp_fb(zpidx, FB_LINE_IN_LEVEL, '')
								}
								case 'lineinconnected': {
									sonos[zpidx].line_in_present = atoi(tag_get_contents(event_work, tag, 1))
									zp_fb(zpidx, FB_LINE_IN_PRESENT, '')
								}
								case 'icon': {
									// we don't care about the line-in icon...
								}

								default: {
									dbg(INFO, "'event_string: AudioIn: UNHANDLED: ', tag_get_name(event_work)")
								}
							}

							x++
						}
					}
				}

				dbg(INFO, "'event_string: "', sonos[event_zpidx[eidx]].name, '" got ', itoa(x), ' feedback items'")
			} else {
				// wtf? why are we getting feedback from a device from which we don't know about?
			}

			// send the oll korrect,
			send_string data.device, "
				'HTTP/1.1 200 OK', $0d, $0a,
				'Content-Length: 0', $0d, $0a,
				$0d, $0a"

			// then close this bitch. close handler handles recreating the server socket.
			ip_server_close(event_dev[eidx].port)
		}
	}
}


/* mainline */
define_program
wait (10) {
	// we just need to keep the data moving.
	// when a command completes and the ip connection closes this should happen automatically,
	// but just in case we'll lazily force sending commands about every 200ms.

	zp_send()
}

wait (100) {
	// unless the NI broke, the UDP connection should be open, so let's send discover packets.
	send_string disc_dev, ZP_MCAST_SEARCH
}

wait (1200) {
	// it's reregister time
	for (i = 1; i <= sonos_count; i++) {
		zp_queue(i, 'ereg_transport', '', '')
	}

	wait (10) {
		for (i = 1; i <= sonos_count; i++) {
			zp_queue(i, 'ereg_rendering', '', '')
		}
	}

	wait (20) {
		for (i = 1; i <= sonos_count; i++) {
			zp_queue(i, 'ereg_device', '', '')
		}
	}

	wait (30) {
		for (i = 1; i <= sonos_count; i++) {
			zp_queue(i, 'ereg_audioin', '', '')
		}
	}
}


/* functions */
/*
 * Queues data to send to a Sonos ZP, then attempts to unload the queue.
 *
 * @param 	zpidx 		Index of zoneplayer
 * @param	cmd 		Command type
 * @param	data1 		First argument
 * @param 	data2		Second argument
 */
define_function zp_queue(integer zpidx, char cmd[], char data1[], char data2[])
{
	stack_var integer i

	for (i = 1; i <= QUEUE_COUNT; i++) {
		if (queue_data[i].status == QUEUE_NONE || queue_data[i].status == QUEUE_EXPIRED) {
			queue_data[i].zpidx = zpidx
			queue_data[i].status = QUEUE_READY
			queue_data[i].cmd = cmd
			queue_data[i].data1 = data1
			queue_data[i].data2 = data2

			break
		}
	}

	zp_send()
}

/*
 * Attempts to send data using a free IP port.
 * Does nothing if there is no unused port available.
 */
define_function zp_send()
{
	stack_var integer c
	stack_var integer q
	stack_var integer s

	// find a free comms port
	for (c = 1; c <= COMMS_COUNT; c++) {
		if (!comms_queue[c]) {
			// ok, now find a queued command
			for (q = 1; q <= QUEUE_COUNT; q++) {
				if (queue_data[q].status == QUEUE_READY) {
					// planets align, fire it up
					queue_data[q].status = QUEUE_PENDING
					comms_queue[c] = q
					ip_client_open(
						comms_dev[c].port,
						sonos[queue_data[q].zpidx].ip,
						1400,
						IP_TCP
					)

					break
				}
			}
		}
	}
}

/*
 * Sends all feedback of a specific ZP via the vdev.
 *
 * @param 	zpidx 	Sonos ZP index
 */
define_function zp_fb_all(integer zpidx)
{
	stack_var integer 	i

	for (i = 1; i <= $3f; i++) {
		zp_fb(zpidx, i, '')
	}
}

/*
 * Sends feedback of a specific ZP via the vdev.
 *
 * @param 	zpidx	Sonos ZP index
 * @param	type 	Type of feedback to send
 * @param 	data 	Additional data
 */
define_function zp_fb(integer zpidx, integer type, char data[])
{
	switch (type) {
		case FB_VOLUME: {
			send_string vdev, "'"', sonos[zpidx].name, '" volume ', itoa(sonos[zpidx].volume), $0d"
		}
		case FB_MUTE: {
			if (sonos[zpidx].mute) {
				send_string vdev, "'"', sonos[zpidx].name, '" mute on', $0d"
			} else {
				send_string vdev, "'"', sonos[zpidx].name, '" mute off', $0d"
			}
		}
		case FB_OUTPUT_FIXED: {
			if (sonos[zpidx].volume_is_fixed) {
				send_string vdev, "'"', sonos[zpidx].name, '" output_fixed on', $0d"
			} else {
				send_string vdev, "'"', sonos[zpidx].name, '" output_fixed off', $0d"
			}
		}

		case FB_LOUDNESS: {
			send_string vdev, "'"', sonos[zpidx].name, '" loudness ', itoa(sonos[zpidx].loudness), $0d"
		}
		case FB_BASS: {
			send_string vdev, "'"', sonos[zpidx].name, '" bass ', itoa(sonos[zpidx].bass), $0d"
		}
		case FB_TREBLE: {
			send_string vdev, "'"', sonos[zpidx].name, '" treble ', itoa(sonos[zpidx].treble), $0d"
		}

		case FB_LINE_IN_NAME: {
			send_string vdev, "'"', sonos[zpidx].name, '" line_in_name "', sonos[zpidx].line_in_name, '"', $0d"
		}
		case FB_LINE_IN_LEVEL: {
			send_string vdev, "'"', sonos[zpidx].name, '" line_in_level ', itoa(sonos[zpidx].line_in_level), $0d"
		}
		case FB_LINE_IN_PRESENT: {
			if (sonos[zpidx].line_in_present) {
				send_string vdev, "'"', sonos[zpidx].name, '" line_in_present yes', $0d"
			} else {
				send_string vdev, "'"', sonos[zpidx].name, '" line_in_present no', $0d"
			}
		}

		case FB_PLAY_STATE: {
			switch (sonos[zpidx].play_state) {
				case PLAYING: 	send_string vdev, "'"', sonos[zpidx].name, '" play_state playing', $0d"
				case STOPPED:	send_string vdev, "'"', sonos[zpidx].name, '" play_state stopped', $0d"
				case PAUSED:	send_string vdev, "'"', sonos[zpidx].name, '" play_state paused', $0d"
				default:	 	send_string vdev, "'"', sonos[zpidx].name, '" play_state unknown', $0d"
			}
		}
		case FB_PLAY_MODE: {
			switch (sonos[zpidx].play_mode) {
				case PLAY_MODE_NORMAL: 	send_string vdev, "'"', sonos[zpidx].name, '" play_mode normal', $0d"
				default: 				send_string vdev, "'"', sonos[zpidx].name, '" play_mode unknown', $0d"
			}
		}
		case FB_SERVICE: {
			switch (sonos[zpidx].service) {
				case SVC_RADIO: 	send_string vdev, "'"', sonos[zpidx].name, '" service radio', $0d"
				case SVC_PANDORA: 	send_string vdev, "'"', sonos[zpidx].name, '" service pandora', $0d"
				default: 			send_string vdev, "'"', sonos[zpidx].name, '" service unknown', $0d"
			}
		}

		case FB_TITLE: {
			send_string vdev, "'"', sonos[zpidx].name, '" title "', sonos[zpidx].np_title, '"', $0d"
		}
		case FB_ARTIST: {
			send_string vdev, "'"', sonos[zpidx].name, '" artist "', sonos[zpidx].np_artist, '"', $0d"
		}
		case FB_ALBUM: {
			send_string vdev, "'"', sonos[zpidx].name, '" album "', sonos[zpidx].np_album, '"', $0d"
		}
		case FB_COVERART: {
			if (length_string(sonos[zpidx].np_img_url)) {
				if (sonos[zpidx].np_img_url[1] == '/') {
					// cover art is on the ZP
					send_string vdev, "'"', sonos[zpidx].name, '" coverart http://',
						sonos[zpidx].ip, ':1400', sonos[zpidx].np_img_url, $0d"
				} else {
					send_string vdev, "'"', sonos[zpidx].name, '" coverart ', sonos[zpidx].np_img_url, $0d"
				}
			} else {
				send_string vdev, "'"', sonos[zpidx].name, '" coverart none', $0d"
			}
		}
		case FB_TIME_ELAPSED: {
			send_string vdev, "'"', sonos[zpidx].name, '" time_elapsed ', sonos[zpidx].np_duration_elapsed, $0d"
		}
		case FB_TIME_REMAINING: {
			send_string vdev, "'"', sonos[zpidx].name, '" time_remaining not_implemented', $0d"
		}
		case FB_TIME_TOTAL: {
			send_string vdev, "'"', sonos[zpidx].name, '" time_total ', sonos[zpidx].np_duration_total, $0d"
		}

		case FB_NOT_FOUND: {
			send_string vdev, "'"', data, '" not_found =(', $0d"
		}

		case FB_IP_ADDR: {
			send_string vdev, "'"', sonos[zpidx].name, '" ip_addr ', sonos[zpidx].ip, $0d"
		}
		case FB_RINCON: {
			send_string vdev, "'"', sonos[zpidx].name, '" rincon ', sonos[zpidx].rincon, $0d"
		}
		case FB_SERIAL: {
			send_string vdev, "'"', sonos[zpidx].name, '" serial ', sonos[zpidx].serial, $0d"
		}
		case FB_MAC: {
			send_string vdev, "'"', sonos[zpidx].name, '" mac ', sonos[zpidx].mac, $0d"
		}
		case FB_COORDINATOR: {
			send_string vdev, "'"', sonos[zpidx].name, '" coordinator ', itoa(sonos[zpidx].coordinator), $0d"
		}
		case FB_PLAYER_ICON: {
			send_string vdev, "'"', sonos[zpidx].name, '" player_icon ', sonos[zpidx].icon, $0d"
		}
		case FB_LIGHT: {
			if (sonos[zpidx].light) {
				send_string vdev, "'"', sonos[zpidx].name, '" light on', $0d"
			} else {
				send_string vdev, "'"', sonos[zpidx].name, '" light off', $0d"
			}
		}
		case FB_NAME_FROM_INDEX: {
			if (is_numeric(data)) {
				if (atoi(data) >= 1 && atoi(data) <= ZP_MAX) {
					if (sonos[atoi(data)].valid == 1) {
						send_string vdev, "'"', sonos[atoi(data)].name, '" index ', data, $0d"
					}
				}
			}
		}
	}
}

/*
 * Returns the index of the entry in the Sonos info array that
 * matches the supplied data by name, IP address, or RINCON.
 *
 * @param 	search 		Data to search for
 * @return 				Index of matching player, or 0 if none match
 */
define_function integer zp_idx_get(char search[48])
{
	stack_var integer i

	i = zp_idx_name(search)
	if (!i) {
		i = zp_idx_ip(search)
		if (!i) {
			i = zp_idx_rincon(search)
		}
	}

	return i
}
/*
 * Returns the index of the entry in the Sonos info array that
 * matches the supplied name.
 *
 * @param	zp_name 	Text name of the zoneplayer
 * @return 				Index of matching player, or 0 if none match
 */
define_function integer zp_idx_name(char zp_name[48])
{
	stack_var integer i

	for (i = 1; i <= 64; i++) {
		if (sonos[i].name == zp_name) {
			return i
		}
	}

	return 0
}

/*
 * Returns the index of the entry in the Sonos info array that
 * matches the supplied IP address.
 *
 * @param	zp_ip	 	IP address of the zoneplayer
 * @return 				Index of matching player, or 0 if none match
 */
define_function integer zp_idx_ip(char zp_ip[16])
{
	stack_var integer i

	for (i = 1; i <= 64; i++) {
		if (sonos[i].ip == zp_ip) {
			return i
		}
	}

	return 0
}

/*
 * Returns the index of the entry in the Sonos info array that
 * matches the supplied RINCON.
 *
 * @param	zp_rincon 	RINCON / LocalUID of the zoneplayer
 * @return 				Index of matching player, or 0 if none match
 */
define_function integer zp_idx_rincon(char zp_rincon[48])
{
	stack_var integer i

	for (i = 1; i <= 64; i++) {
		if (sonos[i].rincon == zp_rincon) {
			return i
		}
	}

	return 0
}

/*
 * Prepares and sends a Sonos UPnP command through a comm_dev.
 *
 * @param 	cidx 		comm_dev index
 * @param 	zpidx 		sonos zoneplayer index
 * @param	endpoint	UPnP endpoint
 * @param	body 		body to use with template
 * @param 	soapaction	soapaction to use with template
 * @param	find1 		optional first field to find
 * @param	data1 		data to replace find1 with
 * @param	find2 		optional second field to find
 * @param	data2 		data to replace find2 with
 */
define_function char[1024] comm_send_basic(integer cidx, integer zpidx, char endpoint[],
	char body[], char soapaction[], char find1[], char data1[],	char find2[], char data2[])
{
	data_buf[cidx] = string_replace_first(SOAP_BODY, '{body}', body)
	if (length_string(find1)) {
		data_buf[cidx] = string_replace_first(data_buf[cidx], find1, data1)
	}
	if (length_string(find2)) {
		data_buf[cidx] = string_replace_first(data_buf[cidx], find1, data1)
	}

	data_header = string_replace_first(SOAP_HEADERS, '{endpoint}', endpoint)
	data_header = string_replace_first(data_header, '{ip}', sonos[zpidx].ip)
	data_header = string_replace_first(data_header, '{soapaction}', soapaction)
	data_header = string_replace_first(data_header, '{len}', itoa(length_string(data_buf[cidx])))

	send_string data.device, "data_header, data_buf[cidx]"
	data_buf[cidx] = ''
}

/*
 * Starts the event listeners if they have not been started.
 *
 * @param 	idx 	Index of event connection to start, or 0 to start all listeners
 */
define_function event_start(integer idx)
{
	stack_var integer i

	if (!idx) {
		for (i = 1; i <= EVENT_COUNT; i++) {
			if (event_status[i] == EVENT_OFFLINE) {
				ip_server_open(event_dev[i].port, event_port, IP_TCP)
				event_status[i] = EVENT_LISTENING
			}
		}
	} else {
		if (event_status[idx] == EVENT_OFFLINE) {
			ip_server_open(event_dev[idx].port, event_port, IP_TCP)
			event_status[i] = EVENT_LISTENING
		}
	}
}

/*
 * Parses the notify line, and sets the passed variables to the values they should be at.
 *
 * @param 	notify_str 	The 'NOTIFY xxx HTTP/1.1' line
 * @param 	zpidx 		The zpidx specified
 * @param 	type 		The event type specified
 */
define_function event_parse_header(char notify_str[], integer zpidx, char type[])
{
	stack_var integer start
	stack_var integer start2

	start = find_string(notify_str, '/', 1)
	start2 = find_string(notify_str, '/', start + 1)

	zpidx = atoi(mid_string(notify_str, start + 1, start2 - start - 1))
	type = mid_string(notify_str, start2 + 1, find_string(notify_str, 'HTTP/1.1', 1) - start2 - 2)
}

/*
 * Prints debug information to the console if the debug level is the same as or is more severe than the
 * currently selected debug level.
 *
 * @param	lev 	Debug level (constants like ERR, WARN, INFO)
 * @param	msg 	Debug message to show
 * @todo 			THIS FUNCTION IS INCOMPLETE. IT DOES NOT HONOR ANY DEBUG LEVEL.
 */
define_function dbg(integer lev, char msg[])
{
	stack_var char type[8]

	switch (lev) {
		case ERR: 	type = '[err!]'
		case WARN: 	type = '[warn]'
		case ALERT: type = '[alrt]'
		case INFO: 	type = '[info]'
	}

	send_string 0, "'==Sonos== ', type, ' ', msg"
}

/*
 * Returns the contents of an XML / HTML standard tag. Does NOT yet support
 * self-closing tags.
 *
 * @param	html 	the html to grep
 * @param	tag 	the tag which contents we will return
 * @param	count 	unimplemented; get the N'th tag
 */
define_function char[STRING_RETURN_SIZE_LIMIT] tag_get_contents(char html[], char tag[], integer count)
{
	stack_var slong start
	stack_var slong length

	start = find_string(html, "'<', tag, '>'", 1) + length_string(tag) + 2
	length = find_string(html, "'</', tag, '>'", type_cast(start)) - start

	if (start && length > 0) {
		return mid_string(html, type_cast(start), type_cast(length))
	} else {
		return ''
	}
}

/*
 * Returns the XML / HTML tag via index. Opening, closing, self-closing, doesn't matter.
 *  This function SUCKS. Do NOT rely on it; this function WILL be replaced.
 *
 * @param	html 	the html to grep
 * @param	idx 	get the N'th tag
 */
define_function char[STRING_RETURN_SIZE_LIMIT] tag_get_idx(char html[], integer idx)
{
	stack_var integer	start
	stack_var integer	length

	stack_var integer 	c

	start = 1
	length = 0

	while (true) {
		if (start + length >= length_string(html)) {
			start = 0
			break
		}

		start = find_string(html, "'<'", start + length)
		length = find_string(html, "'>'", start) - start + 1
		c++

		if (c >= idx) {
			break;
		}
	}

	if (start && length > 0) {
		return mid_string(html, start, length)
	} else {
		return ''
	}
}

/*
 * Returns the name of the tag.
 * @param	tag 		the tag to grep
 */
define_function char[STRING_RETURN_SIZE_LIMIT] tag_get_name(char tag[])
{
	stack_var integer i

	i = 2

	if (tag[1] == '<') {
		if (tag[2] == '/') {
			return 'error: is a closing tag'
		}

		while (!(tag[i] == ' ' || tag[i] == '>')) {
			i++
			if (i >= length_string(tag)) {
				return 'err: broken tag'
			}
		}
	} else {
		return 'error: not a tag'
	}

	return mid_string(tag, 2, i - 2)
}

/*
 * Returns the contents of the specified attribute.
 * @param	tag 		the tag to grep
 * @param	attribute	the attribute to find
 */
define_function char[STRING_RETURN_SIZE_LIMIT] tag_get_attribute(char tag[], char attribute[])
{
	stack_var integer 	start
	stack_var integer 	end

	start = 0

	while (true) {
		if (start < length_string(tag)) {
			start = find_string(tag, "' '", start + 1)
		} else {
			break
		}

		if (start) {
			if (mid_string(tag, start + 1, length_string(attribute)) == attribute) {
				start = find_string(tag, "'"'", start + length_string(attribute))
				end = find_string(tag, "'"'", start + 2)

				return mid_string(tag, start + 1, end - start - 1)
			}
		} else {
			break
		}
	}

	return ''
}