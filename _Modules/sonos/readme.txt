Thank you for trying the Sonos AMX module by true.


Startup
=======
The module will wait about 10 seconds after the NI starts to query for Sonos players. Detection is fully automatic.



Command structure
=================
The Sonos module is operated by SEND_COMMANDs to the vdev. The command structure is as follows:

send_command vdev, '<sonos_name> <command> [data1]..[dataN]'

- (required) sonos_name: The name of the Sonos player. If the name contains spaces, enclose it it double quotes (").
- (required) command: The command to use with this player. See the examples and command reference.
- (optional) data: command arguments. See the command reference.

If the Sonos player isn't found by name, a 'not_found' feedback will be sent via SEND_STRING on the vdev.



Some example commands
=====================

- Increase the volume by 1%:
send_command vdev, '"Living Room" vol_rel up'

- Decrease the volume by 3%:
send_command vdev, '"Living Room" vol_rel down 3'

- Set the volume to 60%:
send_command vdev, '"Living Room" vol 60'

- Turn the mute on:
send_command vdev, '"Living Room" mute on'

- Toggle the white LED:
send_command vdev, '"Living Room" light tog'

- Set the source to line-in from the same unit, then start playing
send_command vdev, '"Living Room" line_in_from "Living Room"'
send_command vdev, '"Living Room" play'



Feedback
========

Feedback is sent via SEND_STRINGs on the vdev. Most feedback is unsolicited. Feedback generally looks exactly like
commands with the addition of a <CR> at the end of the feedback string. Not all commands produce feedback (such as
the one-way type commands), and some commands result in feedback that differs from the original command (for example,
using the 'vol_rel' command will result in a 'vol' feedback being received).

Feedback is sent whenever the Sonos receives feedback from a ZP. This happens when event data is received, which can be
a number of times per second. Event data is received when state variables (volume, mute, track playing, etc) change.

Sonos player names are always double quoted in feedback messages. Feedback always ends with <CR>.

All feedback in the feedback reference (except not_found) can be requested; see the command reference. Items with a dash
will be sent unsolicited automatically, while items with an asterisk must be solicited from the module.

To query the module for all feedback of a Sonos device, use the get_all_fb command.



Feedback reference
==================
* not_found =(

* ip_addr <ip address of Sonos device>
* rincon <rincon of Sonos device>
* serial <serial number of Sonos device>
* mac <MAC address of sonos device>
* coordinator <coordinator index of Sonos device>
* icon <icon type of Sonos device>
* index <internal index number of Sonos device>

- volume <level 0..100>
- mute <on/off>
- output_fixed <on/off>

- loudness <level 0..1>
- bass <level -10..10>
- treble <level -10..10>

- play_state (playing/stopped/paused/unknown)
- play_mode (normal/unknown)

- service (radio/pandora/unknown)

- line_in_name <text name of analog audio line-in from device>
- line_in_level <level 0..12>
- line_in_present <yes/no>

- title (title of currently playing track / stream info)
- artist (artist of currently playing track)
- album (artist of currently playing track)
- coverart (url to currently playing cover art)
- time_elapsed (amount of time current track has been playing)
- time_remaining (not_implemented)
- time_total (current track length)



Command reference
=================
- play
Sends the Play command to the ZP.

- stop
Sends the Stop command to the ZP. Some sources want to pause instead; see the 

- pause
Sends the Pause command to the ZP.

- next
Skips to the next item in the queue.

- prev
Skips to the previous item in the queue.

- get_now_playing
Forces the module to send the currently playing track, artist, album, etc. to the vdev.

- get_play_state
Sends the current playback state to the vdev.

- get_play_mode
Sends the current playback mode to the vdev.

- get_service
Sends the currently active service (Radio, Pandora, etc) to the vdev.

- vol <level>
Sets the volume to <level>%. <level> should be 0-100.

- vol_rel <up/down> [amount]
Sets the volume up or down by [amount]%. If [amount] is not specified, it defaults to 1.

- get_vol
Forces the module to send the currently known volume to the vdev.

- mute <on/off/tog>
Sets the mute on or off, or toggles the mute.
'on'/'off' can be replaced with '1'/'0', or 'true'/'false' - feedback will always be 'on'/'off'.

- get_mute
Forces the module to send the currently known mute status to the vdev.

- light <on/off/tog>
Sets the white LED on or off, or toggles the LED.
'on'/'off' can be replaced with '1'/'0', or 'true'/'false' - feedback will always be 'on'/'off'.

- get_light
Forces the module to send the currently known front white LED status to the vdev.

- line_in <sonos_name>
- line_in_from <sonos_name>
Sets the input on the Sonos to the line-in of the source Sonos player.
There are currently no checks to see if the source Sonos player actually supports line-in.
Setting the source stops sound and queues the line in; you will have to send a 'play' command to start audio.

- get_line_in_name
Sends the name of the line-in as configured on the Sonos player.

- get_line_in_lev
Sends the gain level of the line-in as configured on the Sonos player.

- get_line_present
Sends the line-in presence status.
Feedback will always be 'yes'/'no'.

- name_from_index <index>
Returns the name of the Sonos of the specified index.
This command will only return feedback if a valid Sonos player is found.
This function might be used to find the coordinating Sonos using the 'coordinator' feedback.

- get_all_fb [type]
Sends all possible feedback of the Sonos device. [type] is currently ignored.

- forget
- rediscover
Forgets the specified Sonos player. It won't be usable until it is re-found. You probably don't need to do this.
There is currently a bug in that forgotten players will make the index unusable. This will be fixed in a future version.

- event_register
- event_reg
Forces registration of UPnP events for the specified Sonos player. You probably don't need to do this.

- get_ip_addr
Returns the IP address of the ZP.

- get_rincon
Returns the RINCON of the ZP.

- get_serial
Returns the serial number of the ZP.

- get_mac
Returns the MAC address of the ZP.

- get_coordinator
Returns the internal index of the coordinator of the ZP.

- get_player_icon
Returns the raw icon type of the player.