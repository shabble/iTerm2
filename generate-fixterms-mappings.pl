#!/usr/bin/env perl

use strict;
use warnings;

use Data::Plist;
use Data::Plist::XMLReader;
use Data::Dumper;
use feature qw/say/;

my $presets_plist = "PresetKeyMappings.plist";
my $presets_data;
# generate some xml keybindings for iterm2 according to the 'fixterms'
# specification at http://www.leonerd.org.uk/hacks/fixterms/

# some handy constants.

sub CSI () { "\e[" }

sub SHIFT () { 1 }
sub ALT   () { 2 }
sub CTRL  () { 4 }


sub read_plist {
    my $xml_reader = Data::Plist::XMLReader->new;
    my $data_plist = $xml_reader->open_file($presets_plist);
    
    $presets_data = $data_plist->raw_data;
}

sub modifier_value {
    my (@modifiers) = @_;
    my $result = 1;
    $result += $_ for @modifiers;
    return $result == 1 ? '' : $result;
}

sub generate_CSI_u {
    my ($keycode, $modifiers) = @_;
    return sprintf('%s%d;%s%s', CSI, $keycode, $modifiers, 'u');
}

sub generate_CSI_tilde {
    my ($keycode, $modifiers) = @_;
    return sprintf('%s%d;%s%s', CSI, $keycode, $modifiers, '~');
}

sub generate_specials {
}


sub save_to_plist {
}

read_plist();
say Dumper($presets_data);

__END__

# TODO:
# * decode how key is specified in plist
# * write Data::Plist::XMLReader?
# * complete functions above.
# * Make it all work.
#
#
# sample of PresetKeyMappings plist
# <key>xterm Defaults</key> <-- name of preset
# <dict>
#	  <key>0xf700-0x260000</key> <- key, plus modifiers
#	  <dict>
#		  <key>Action</key>
#		  <integer>10</integer>	 <- 10 is 'send escape'
#		  <key>Text</key>
#		  <string>[1;6A</string> <- and the remaining sequence
#	  </dict>
#	  <key>0xf701-0x260000</key>
#	  <dict>
#		  <key>Action</key>
#		  <integer>10</integer>
#		  <key>Text</key>
#		  <string>[1;6B</string>
#	  </dict>
#	  <key>0xf702-0x260000</key>
#	  <dict>
#		  <key>Action</key>
#		  <integer>10</integer>
#		  <key>Text</key>
#		  <string>[1;6D</string>
#	  </dict>
# <dict>
