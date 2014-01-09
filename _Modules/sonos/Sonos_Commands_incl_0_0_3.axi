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

PROGRAM_NAME='Sonos_Commands_incl_0_0_2'

/*
	This include is used by the Sonos module directly.
	Do not include this in your project.
	Make sure this file stays with the Sonos module files.

	======

	The valid responses aren't used right now, and probably won't be in the future.
	Plan on having them eliminated.
*/


/* sonos commands and constants */
define_variable
volatile 	char 	ZP_MCAST_SEARCH[130]
volatile 	char 	ZP_STATUS_ZP[50]

volatile 	char 	SOAP_HEADERS[140]

volatile 	char 	SUBSCRIBE_TRANSPORT[200]
volatile 	char 	SUBSCRIBE_RENDERING[200]
volatile 	char 	SUBSCRIBE_DEVICE[180]
volatile 	char 	SUBSCRIBE_AUDIOIN[180]


define_constant
ZP_MCAST_GROUP_IP[] = '239.255.255.250'
long ZP_MCAST_PORT = 1900

SOAP_BODY[] = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body>{body}</s:Body></s:Envelope>'

ENDPOINT_TRANSPORT[] = '/MediaRenderer/AVTransport/Control'
ENDPOINT_RENDERING[] = '/MediaRenderer/RenderingControl/Control'
ENDPOINT_DEVICE[] = '/DeviceProperties/Control'
ENDPOINT_DIRECTORY[] = '/MediaServer/ContentDirectory/Control'

  // transports
PLAY_SOAPACTION[] = 'urn:schemas-upnp-org:service:AVTransport:1#Play'
PLAY_BODY[] = '<u:Play xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"><InstanceID>0</InstanceID><Speed>1</Speed></u:Play>'

PAUSE_SOAPACTION[] = 'urn:schemas-upnp-org:service:AVTransport:1#Pause'
PAUSE_BODY[] = '<u:Pause xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"><InstanceID>0</InstanceID><Speed>1</Speed></u:Pause>'

STOP_SOAPACTION[] = 'urn:schemas-upnp-org:service:AVTransport:1#Stop'
STOP_BODY[] = '<u:Stop xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"><InstanceID>0</InstanceID><Speed>1</Speed></u:Stop>'

NEXT_SOAPACTION[] = 'urn:schemas-upnp-org:service:AVTransport:1#Next'
NEXT_BODY[] = '<u:Next xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"><InstanceID>0</InstanceID><Speed>1</Speed></u:Next>'

PREV_SOAPACTION[] = 'urn:schemas-upnp-org:service:AVTransport:1#Previous'
PREV_BODY[] = '<u:Previous xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"><InstanceID>0</InstanceID><Speed>1</Speed></u:Previous>'

  // rendering
VOLUME_SOAPACTION[] = 'urn:schemas-upnp-org:service:RenderingControl:1#SetVolume'
VOLUME_BODY[] = '<u:SetVolume xmlns:u="urn:schemas-upnp-org:service:RenderingControl:1"><InstanceID>0</InstanceID><Channel>Master</Channel><DesiredVolume>{volume}</DesiredVolume></u:SetVolume>'

VOLUME_REL_SOAPACTION[] = 'urn:schemas-upnp-org:service:RenderingControl:1#SetRelativeVolume'
VOLUME_REL_BODY[] = '<u:SetRelativeVolume xmlns:u="urn:schemas-upnp-org:service:RenderingControl:1"><InstanceID>0</InstanceID><Channel>Master</Channel><Adjustment>{volume}</Adjustment></u:SetRelativeVolume>'

GET_VOLUME_SOAPACTION[] = 'urn:schemas-upnp-org:service:RenderingControl:1#GetVolume'
GET_VOLUME_BODY[] = '<u:GetVolume xmlns:u="urn:schemas-upnp-org:service:RenderingControl:1"><InstanceID>0</InstanceID><Channel>Master</Channel></u:GetVolume>'

MUTE_SOAPACTION[] = 'urn:schemas-upnp-org:service:RenderingControl:1#SetMute'
MUTE_BODY[] = '<u:SetMute xmlns:u="urn:schemas-upnp-org:service:RenderingControl:1"><InstanceID>0</InstanceID><Channel>Master</Channel><DesiredMute>{mute}</DesiredMute></u:SetMute>'

GET_MUTE_SOAPACTION[] = 'urn:schemas-upnp-org:service:RenderingControl:1#GetMute'
GET_MUTE_BODY[] = '<u:GetMute xmlns:u="urn:schemas-upnp-org:service:RenderingControl:1"><InstanceID>0</InstanceID><Channel>Master</Channel></u:GetMute>'

LIGHT_SOAPACTION[] = 'urn:schemas-upnp-org:service:DeviceProperties:1#SetLEDState'
LIGHT_BODY[] = '<u:SetLEDState xmlns:u="urn:schemas-upnp-org:service:DeviceProperties:1"><DesiredLEDState>{light}</DesiredLEDState></u:SetLEDState>'

GET_LIGHT_SOAPACTION[] = 'urn:schemas-upnp-org:service:DeviceProperties:1#GetLEDState'
GET_LIGHT_BODY[] = '<u:GetLEDState xmlns:u="urn:schemas-upnp-org:service:DeviceProperties:1" />'

TRANSPORTURI_SOAPACTION[] = 'urn:schemas-upnp-org:service:AVTransport:1#SetAVTransportURI'

LINE_IN_BODY[] = '<u:SetAVTransportURI xmlns:u="urn:schemas-upnp-org:service:AVTransport:1"><InstanceID>0</InstanceID><CurrentURI>x-rincon-stream:{rincon}</CurrentURI><CurrentURIMetaData></CurrentURIMetaData></u:SetAVTransportURI>'

GET_OUT_FIXED_SOAPACTION[] = 'urn:schemas-upnp-org:service:RenderingControl:1#GetOutputFixed'
GET_OUT_FIXED_BODY[] = '<u:GetOutputFixed xmlns:u="urn:schemas-upnp-org:service:RenderingControl:1"><InstanceID>0</InstanceID></u:GetOutputFixed>'



/* startup */
define_start
ZP_MCAST_SEARCH = "'M-SEARCH * HTTP/1.1', $0d, $0a,
		'HOST: 239.255.255.250:1900', $0d, $0a,
		'MAN: "ssdp:discover"', $0d, $0a,
		'MX: 1', $0d, $0a,
		'ST: urn:schemas-upnp-org:device:ZonePlayer:1', $0d, $0a, $0d, $0a"

ZP_STATUS_ZP = "'GET /status/zp HTTP/1.1', $0d, $0a,
		'HOST: {ip}:1400', $0d, $0a, $0d, $0a"

SOAP_HEADERS = "'POST {endpoint} HTTP/1.1', $0d, $0a,
			'Host: {ip}:1400', $0d, $0a,
			'SOAPACTION: {soapaction}', $0d, $0a,
			'Content-Type: text/xml; charset="utf-8"', $0d, $0a,
			'Content-Length: {len}', $0d, $0a,
			$0d, $0a"


/* functions */
define_function event_regenerate()
{
	SUBSCRIBE_TRANSPORT = "
		'SUBSCRIBE /MediaRenderer/AVTransport/Event HTTP/1.1', $0d, $0a,
		'NT: upnp:event', $0d, $0a,
		'HOST: {ip}:1400', $0d, $0a,
		'CALLBACK: <http://', amx_ip.ipaddress, ':', itoa(event_port), '/{zpidx}/Transport>', $0d, $0a,
		'TIMEOUT: Second-180', $0d, $0a,
		'Content-Length: 0', $0d, $0a,
		$0d, $0a"

	SUBSCRIBE_RENDERING = "
		'SUBSCRIBE /MediaRenderer/RenderingControl/Event HTTP/1.1', $0d, $0a,
		'NT: upnp:event', $0d, $0a,
		'HOST: {ip}:1400', $0d, $0a,
		'CALLBACK: <http://', amx_ip.ipaddress, ':', itoa(event_port), '/{zpidx}/Rendering>', $0d, $0a,
		'TIMEOUT: Second-180', $0d, $0a,
		'Content-Length: 0', $0d, $0a,
		$0d, $0a"

	SUBSCRIBE_DEVICE = "
		'SUBSCRIBE /DeviceProperties/Event HTTP/1.1', $0d, $0a,
		'NT: upnp:event', $0d, $0a,
		'HOST: {ip}:1400', $0d, $0a,
		'CALLBACK: <http://', amx_ip.ipaddress, ':', itoa(event_port), '/{zpidx}/Device>', $0d, $0a,
		'TIMEOUT: Second-180', $0d, $0a,
		'Content-Length: 0', $0d, $0a,
		$0d, $0a"

	SUBSCRIBE_AUDIOIN = "
		'SUBSCRIBE /AudioIn/Event HTTP/1.1', $0d, $0a,
		'NT: upnp:event', $0d, $0a,
		'HOST: {ip}:1400', $0d, $0a,
		'CALLBACK: <http://', amx_ip.ipaddress, ':', itoa(event_port), '/{zpidx}/AudioIn>', $0d, $0a,
		'TIMEOUT: Second-180', $0d, $0a,
		'Content-Length: 0', $0d, $0a,
		$0d, $0a"
}