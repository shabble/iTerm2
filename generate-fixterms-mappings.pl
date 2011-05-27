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
sub META  () { 2 }
sub CTRL  () { 4 }

# Modifiers:
# 
# Shift  : 0x020000 (Also affects the actual char)
# Ctrl   : 0x040000
# Option : 0x080000
# Cmd    : 0x100000

sub I_SHIFT () { 0x020000 }
sub I_CTRL  () { 0x040000 }
sub I_OPT   () { 0x080000 }
sub I_CMD   () { 0x100000 }


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

sub contains_shift {
    my ($mod) = @_;
    return ($mod & SHIFT) ? 1 : 0;
}

sub contains_meta {
    my ($mod) = @_;
    return ($mod & META) ? 1 : 0;
}

sub contains_ctrl {
    my ($mod) = @_;
    return ($mod & CTRL) ? 1 : 0;
}

sub generate {

    my @modifiers
      = (
         0, # none
         SHIFT,
         META,
         CTRL,

         SHIFT | META,
         SHIFT | CTRL,
         SHIFT | META | CTRL,

         META  | CTRL

        );

    foreach my $modifier (@modifiers) {
        foreach my $char ('a' .. 'z', 'A' .. 'Z') {

            if (contains_shift($modifier)) {
                $char = uc($char);
            }

            my $keycode = ord($char);


            my $iterm_charcode;
            my $iterm_modifier = 0;

            if (contains_shift($modifier)) {
                $iterm_modifier |= I_SHIFT;
            }

            if (contains_meta($modifier)) {
                $iterm_modifier |= I_OPT;
            }

            if (contains_ctrl($modifier)) {
                $iterm_modifier |= I_CTRL;
            }

            $iterm_modifier = sprintf("0x%06x", $iterm_modifier);
            $iterm_charcode = sprintf("0x%02x", $keycode);

            my $iterm_id = "$iterm_charcode-$iterm_modifier";

            my $fixterm_modifier = $modifier + 1;

            # iTerm action 10 provides the \e escape for the CSI.
            my $fixterm_csi = '[' . $keycode;

            if ($fixterm_modifier != 1) {
                $fixterm_csi .= ";$fixterm_modifier";
            }

            $fixterm_csi .= 'u';

            my $output;
            $output .= "<key>$iterm_id</key>\n";
            $output .= "<dict>\n";
            $output .= "    <key>Action</key>\n";
            $output .= "    <integer>10</integer>\n";
            $output .= "    <key>Text</key>\n";
            $output .= "    <string>$fixterm_csi</string>\n";
            $output .= "</dict>\n";

            print $output;
        }
    }
}

generate();

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
