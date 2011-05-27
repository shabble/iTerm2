#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use feature qw/say/;

my $presets_plist     = "PresetKeyMappings.plist";
my $presets_plist_tmp = "PresetKeyMappings.plist.tmp";
my $presets_data;
# generate some xml keybindings for iterm2 according to the 'fixterms'
# specification at http://www.leonerd.org.uk/hacks/fixterms/

my @fixterm_entries;

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
sub I_ARROW () { 0x200000 }
sub I_SHIFT () { 0x020000 }
sub I_CTRL  () { 0x040000 }
sub I_OPT   () { 0x080000 }
sub I_CMD   () { 0x100000 }


sub generate_CSI_tilde {
    my ($keycode, $modifiers) = @_;
    return sprintf('%s%d;%s%s', CSI, $keycode, $modifiers, '~');
}

sub generate_specials {

    my $specials_iterm
      = {
         Up    => 0xf700, # arrows need I_ARROW added to their
         Down  => 0xf701, # modifiers in the <key> field.
         Left  => 0xf702, # eg: '0xf702-0x200000'
         Right => 0xf703,
         End   => 0xf72b,
         Home  => 0xf729,
         F1    => 0xf704,
         F2    => 0xf705,
         F3    => 0xf706,
         F4    => 0xf707, # F-keys appear to keep incrementing, F6 = f709...
         PgUp  => 0xf72c,
         PgDn  => 0xf72d,
        };

    my $specials_fixterm
      = {
         Up    => 'A',
         Down  => 'B',
         Right => 'C',
         Left  => 'D',
         End   => 'F',
         Home  => 'H',
         F1    => 'P',
         F2    => 'Q',
         F3    => 'R',
         F4    => 'S',
        };


    # format for these specials is: CSI 1;[modifier] {ABCDFHPQRS}
    # where 1;1 is redundant. All others apply.
}

sub save_to_plist {
    open my $in_fh, '<', $presets_plist
      or die "Couldn't open $presets_plist for reading: $!";
    open my $out_fh, '>', $presets_plist_tmp
      or die "Couldn't open $presets_plist_tmp for writing: $!";

    generate_alpha();

    my $inserted = 0;
    while (my $line = <$in_fh>) {
        print $out_fh $line;
        if (($inserted == 0) and ($line =~ m/<dict>/)) {
            print $out_fh $_ for @fixterm_entries;
            $inserted = 1;
        }
    }
    close $in_fh;
    close $out_fh;

    # move tmp to real?
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

sub mods_to_str {
    my ($mod) = @_;
    my @mods;
    push @mods, 'shift' if (contains_shift($mod));
    push @mods, 'meta'  if (contains_meta($mod));
    push @mods, 'ctrl'  if (contains_ctrl($mod));

    my $str = join(" | ", @mods);
    return $str;
}

sub generate_alpha {

    my @modifiers
      = (
         SHIFT,
         META,
         CTRL,

         SHIFT + META,
         SHIFT + CTRL,
         SHIFT + META + CTRL,

         META  + CTRL

        );
    my $hash = {};

    foreach my $modifier (@modifiers) {
        foreach my $char (('A' .. 'Z'), ('a' .. 'z')) {

            my $fixterm_modifier = $modifier + 1;
            my $uc_char = uc($char);

            my $keycode    = ord($char);
            my $uc_keycode = ord($uc_char);
            # print STDERR sprintf("Processing: %-3s %-3s %03d, %s %d\n",
            #                      $actual_char, $keycode,
            #                      $modifier, mods_to_str($modifier),
            #                      contains_shift($modifier));

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

            # skip ctrl-only for lower-case letters.
            if (($modifier & CTRL) == CTRL) {
                next if ($char ne $uc_char);
                say "ctrl-only for: $char";
            }

            $iterm_modifier = sprintf('0x%x', $iterm_modifier);

            if (contains_shift($modifier)) {
                $iterm_charcode = sprintf('0x%x', $uc_keycode);
            } else {
                $iterm_charcode = sprintf('0x%x', $keycode);
            }

            my $iterm_id = "$iterm_charcode-$iterm_modifier";


            # iTerm action 10 provides the \e escape for the CSI.
            my $fixterm_csi = '[' . $keycode;

            if ($fixterm_modifier != 1) {
                $fixterm_csi .= ";$fixterm_modifier";
            }

            $fixterm_csi .= 'u';

            $hash->{$iterm_id} = $fixterm_csi;
        }
    }

    push @fixterm_entries, "    <key>Fixterm</key>\n";
    push @fixterm_entries, "    <dict>\n";
    foreach my $key (sort keys %$hash) {
        my $val = $hash->{$key};
        my $output;
        $output .= "        <key>$key</key>\n";
        $output .= "        <dict>\n";
		$output .= "			<key>Action</key>\n";
		$output .= "			<integer>10</integer>\n";
		$output .= "			<key>Text</key>\n";
		$output .= "			<string>$val</string>\n";
		$output .= "		</dict>\n";

        push @fixterm_entries, $output;
    }
    push @fixterm_entries, "    </dict>\n";
}

save_to_plist();

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

# Modifiers:
#
# Shift  : 0x020000 (Also affects the actual char)
# Ctrl   : 0x040000
# Option : 0x080000
# Cmd    : 0x100000

# Keys:


#"Keyboard Map" =		                  	  {
#		  "0x41-0x20000" = shift a				   {
#			  Action = 11;
#			  Text = "0x1 0x1";
#		  };
#		  "0x41-0xa0000" = 'shift meta a'		   {
#			  Action = 11;
#			  Text = "0x3 0x1";
#		  };
#		  "0x61-0x0" = 'a'				   {
#			  Action = 11;
#			  Text = 0x01;
#		  };
#		  "0x61-0x100000" = 'cmd a'					{
#			  Action = 11;
#			  Text = "0x8 0x1";
#		  };
#		  "0x61-0x40000" = 'ctrl a'				   {
#			  Action = 11;
#			  Text = "0x04 0x01";
#		  };
#		  "0x61-0x80000" = 'opt a'		   {
#			  Action = 11;
#			  Text = "0x2 0x1";
#		  };
#		  "0x62-0x0" = 'b'			   {
#			  Action = 11;
#			  Text = 0x2;
#		  };
#	  };

      "Keyboard Map" =             {
                "0x1b-0x0" =                 {
                    Action = 12;
                    Text = escape;
                };
                "0x41-0x20000" =                 {
                    Action = 11;
                    Text = "0x1 0x1";
                };
                "0x41-0xa0000" =                 {
                    Action = 11;
                    Text = "0x3 0x1";
                };
                "0x61-0x0" =                 {
                    Action = 11;
                    Text = 0x01;
                };
                "0x61-0x100000" =                 {
                    Action = 11;
                    Text = "0x8 0x1";
                };
                "0x61-0x40000" =                 {
                    Action = 11;
                    Text = "0x04 0x01";
                };
                "0x61-0x80000" =                 {
                    Action = 11;

                    Text = "0x2 0x1";
                };
                "0x62-0x0" =                 {
                    Action = 11;
                    Text = 0x2;
                };
                "0x7f-0x0" =                 {
                    Action = 12;
                    Text = backspace;
                };
                "0x9-0x0" =                 {
                    Action = 12;
                    Text = tab;
                };
                "0xf700-0x200000" =                 {
                    Action = 12;
                    Text = uparrow;
                };
                "0xf701-0x200000" =                 {
                    Action = 12;
                    Text = downarrow;
                };
                "0xf702-0x200000" =                 {
                    Action = 12;
                    Text = leftarrow;
                };
                "0xf703-0x200000" =                 {
                    Action = 12;
                    Text = rightarrow;
                };
                "0xf704-0x0" =                 {
                    Action = 12;
                    Text = f1;
                };
                "0xf705-0x0" =                 {
                    Action = 12;
                    Text = f2;
                };
                "0xf706-0x0" =                 {
                    Action = 12;
                    Text = f3;
                };
                "0xf707-0x0" =                 {
                    Action = 12;
                    Text = f4;
                };
                "0xf708-0x0" =                 {
                    Action = 12;
                    Text = f5;
                };
                "0xf709-0x0" =                 {
                    Action = 12;
                    Text = f6;
                };
                "0xf72c-0x0" =                 {
                    Action = 12;
                    Text = pgup;
                };
                "0xf72d-0x0" =                 {
                    Action = 12;
                    Text = pgdown;
                };
            };





"0x1b-0x0" =                 {
    Action = 12;
    Text = escape;
};
"0x41-0x20000" =                 {
    Action = 12;
    Text = "shift a";
};
"0x41-0x60000" =                 {
    Action = 12;
    Text = "ctrl-shift-a";
};
"0x41-0xa0000" =                 {
    Action = 12;
    Text = "meta-shift-a";
};
"0x41-0xe0000" =                 {
    Action = 12;
    Text = "ctrl-meta-shift-a";
};
"0x61-0x0" =                 {
    Action = 12;
    Text = a;
};
"0x61-0xc0000" =                 {
    Action = 12;
    Text = "ctrl-meta-a";
};
"0x7f-0x0" =                 {
    Action = 12;
    Text = backspace;
};
"0x9-0x0" =                 {
    Action = 12;
    Text = tab;
};
"0xf700-0x200000" =                 {
    Action = 12;
