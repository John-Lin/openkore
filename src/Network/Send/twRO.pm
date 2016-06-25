#########################################################################
#  OpenKore - Network subsystem
#  This module contains functions for sending messages to the server.
#
#  This software is open source, licensed under the GNU General Public
#  License, version 2.
#  Basically, this means that you're allowed to modify and distribute
#  this software. However, if you distribute modified versions, you MUST
#  also distribute the source code.
#  See http://www.gnu.org/licenses/gpl.html for the full license.
#########################################################################
# tRO (Thai) for 2008-09-16Ragexe12_Th
# Servertype overview: http://wiki.openkore.com/index.php/ServerType
package Network::Send::twRO;

use strict;
use Globals;
use Network::Send::ServerType0;
use base qw(Network::Send::ServerType0);
use Log qw(error debug);
use I18N qw(stringToBytes);
use Utils qw(getTickCount getHex getCoordString);
use Math::BigInt;

sub new {
	my ($class) = @_;
	my $self = $class->SUPER::new(@_);
	$self->{char_create_version} = 1;

	my %packets = (
		'0933' => ['friend_request', 'a*', [qw(username)]],
		'0885' => ['party_join_request_by_name', 'Z24', [qw(partyName)]],
		'0A5A' => ['actor_look_at', 'v C', [qw(head body)]],
		'0863' => ['item_drop', 'v2', [qw(index amount)]],
		'089D' => ['storage_item_add', 'v V', [qw(index amount)]],
		'094B' => ['storage_item_remove', 'v V', [qw(index amount)]],
		'0281' => ['storage_password'],
		'087E' => ['homunculus_command', 'v C', [qw(commandType, commandID)]],
		'0884' => ['sync', 'V', [qw(time)]],
		'088F' => ['item_take', 'a4', [qw(ID)]],
		'0A68' => ['skill_use', 'v2 a4', [qw(lv skillID targetID)]],
		'0438' => ['skill_use_location', 'v4', [qw(lv skillID x y)]],
		'0369' => ['actor_action', 'a4 C', [qw(targetID type)]],
		'096A' => ['actor_info_request', 'a4', [qw(ID)]],
		'0368' => ['actor_name_request', 'a4', [qw(ID)]],
		'0437' => ['character_move','a3', [qw(coords)]],
		'088E' => ['map_login', 'a4 a4 a4 V C', [qw(accountID charID sessionID tick sex)]],
		'0970' => ['char_create', 'a24 C v2', [qw(name, slot, hair_style, hair_color)]],
		'0064' => ['master_login', 'V Z24 a24 C', [qw(version username password_rijndael master_version)]],
		);
	$self->{packet_list}{$_} = $packets{$_} for keys %packets;

	
	my %handlers = qw(
		friend_request 0933
		party_join_request_by_name 0885
		actor_look_at 0A5A
		item_drop 0863
		storage_item_add 089D
		storage_item_remove 094B
		storage_password 0281
		homunculus_command 087E
		sync 0884
		item_take 088F
		skill_use 0A68
		skill_use_location 0438
		actor_action 0369
		actor_info_request 096A
		actor_name_request 0368
		character_move 0437
		map_login 088E
		char_create 0970
		party_setting 07D7
		buy_bulk_vender 0801
		send_equip 0998
	);

	$self->{packet_lut}{$_} = $handlers{$_} for keys %handlers;
	$self->cryptKeys(0x6DF05E78, 0x7799393A, 0x48376267);

	return $self;
}
sub sendCharCreate {
	my ($self, $slot, $name, $hair_style, $hair_color) = @_;

	my $msg = pack('C2 a24 C v2', 0x70, 0x09, stringToBytes($name), $slot, $hair_color, $hair_style);
	$self->sendToServer($msg);
	debug "Sent sendCharCreate\n", "sendPacket", 2;
}

1;