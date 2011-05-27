#!/usr/bin/env perl

use strict;
use warnings;

use Data::Plist;

my $presets_plist = "PresetKeyMappings.plist";

# generate some xml keybindings for iterm2 according to the 'fixterms'
# specification at http://www.leonerd.org.uk/hacks/fixterms/

sub generate_CSI_u {
}

sub generate_CSI_tilde {
}

sub generate_specials {
}


sub save_to_plist {
}

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
