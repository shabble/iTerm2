#!/usr/bin/env perl

=head1 NAME generate_fixterms-mappings - create an xml output file suitable for
loading into iTerm as a preset list conforming to the fixterms specification.

=cut


use strict;
use warnings;

use Data::Dumper;
use feature qw/say/;


my $presets_plist     = "PresetKeyMappings.plist";
my $presets_plist_tmp = "PresetKeyMappings.plist.tmp";


# some handy constants.

sub CSI () { "\e[" }


sub SHIFT () { 1 }
sub META  () { 2 }
sub CTRL  () { 4 }

# all combinations of modifiers.
# not all should be used for all characters.

sub MODIFIERS () {
    return (

            SHIFT,
            META,
            CTRL,

            SHIFT + META,
            SHIFT + CTRL,
            SHIFT + META + CTRL,

            META  + CTRL

           );
}

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


sub main {
    my @entries;
    push @entries, @{ generate_lower_case_entries() };
    push @entries, @{ generate_upper_case_entries() };
    push @entries, @{ generate_specials() };
    push @entries, @{ generate_very_specials() };

    save_to_plist(\@entries);
}



sub generate_lower_case_entries {
    my @output;

    my @mods = (
                META,
                META + CTRL,
               );

    for my $modifiers (@mods) {
        for my $char ('a'..'z') {
            my $keycode = ord($char);

            my $i_key = construct_iterm_key($keycode, $modifiers);
            my $csi_u = construct_fixterm_csi_u($keycode, $modifiers);
            push @output, [$i_key, $csi_u];

            say 'LC: creating: ' . to_string($keycode, $modifiers, $i_key, $csi_u);
        }
    }

    return \@output;
}


sub generate_upper_case_entries {

    my @output;

    my @mods = (
                SHIFT + CTRL,
                SHIFT + META,
                SHIFT + META + CTRL,
               );

    for my $modifiers (@mods) {

        for my $char ('A'..'Z') {
            my $keycode = ord($char);

            my $i_key = construct_iterm_key($keycode, $modifiers);

            my $remove_shift = $modifiers & ~SHIFT;
            my $csi_u = construct_fixterm_csi_u($keycode, $remove_shift);

            push @output, [$i_key, $csi_u];

            say 'UC: creating: ' . to_string($keycode, $modifiers, $i_key, $csi_u);

        }
    }
    return \@output;
}

sub generate_specials {
    #Ctrl-H = CSI 104;5 u	Ctrl-Shift-H = CSI  72;5 u	Backspace = 0x08
    #Ctrl-I = CSI 105;5 u	Ctrl-Shift-I = CSI  73;5 u	Tab       = 0x09
    #Ctrl-M = CSI 109;5 u	Ctrl-Shift-M = CSI  77;5 u	Enter     = 0x0d
    #Ctrl-[ = CSI  91;5 u	Ctrl-{       = CSI 123;5 u	Escape    = 0x1b
    my @output;

    my @chars = ( '{', '}', '[', ']', "\\", '/', (0 .. 9) );

    my @mods = (
                META,
                CTRL,
                META + CTRL,
               );

    for my $modifiers (@mods) {
        for my $char (@chars) {
            my $keycode = ord($char);

            my $i_key = construct_iterm_key($keycode, $modifiers);
            my $csi_u = construct_fixterm_csi_u($keycode, $modifiers);
            push @output, [$i_key, $csi_u];

            say 'GS: creating: ' . to_string($keycode, $modifiers, $i_key, $csi_u);
        }
    }

    return \@output;
}

sub generate_very_specials {

    my @output;

    my $specials_iterm
      = {
         Up    => 0xf700,       # arrows need I_ARROW added to their
         Down  => 0xf701,       # modifiers in the <key> field.
         Left  => 0xf702,       # eg: '0xf702-0x200000'
         Right => 0xf703,
         End   => 0xf72b,
         Home  => 0xf729,
         F1    => 0xf704,
         F2    => 0xf705,
         F3    => 0xf706,
         F4    => 0xf707,     # F-keys appear to keep incrementing, F6 = f709...
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

    my @mods = (
                SHIFT,
                META,
                CTRL,
                SHIFT + META,
                SHIFT + CTRL,
                SHIFT + CTRL + META,
                CTRL  + META
               );
    # format for these specials is: CSI 1;[modifier] {ABCDFHPQRS}
    # where 1;1 is redundant. All others apply.

    foreach my $modifiers (@mods) {
        foreach my $key (sort keys %$specials_fixterm) {
            my $fix_val = $specials_fixterm->{$key};
            my $i_val   = $specials_iterm->{$key};

            my $i_key = construct_iterm_key($i_val, $modifiers);

            #my $remove_shift = $modifiers & ~SHIFT;
            my $fix_seq  = construct_csi_very_special($fix_val, $modifiers);

            push @output, [$i_key, $fix_seq];

            say 'VS: creating: ' . to_string(ord($fix_val),
                                             $modifiers, $i_key, $fix_seq);
        }
    }

    return \@output;
}

sub save_to_plist {
    my ($entries) = @_;

    #say Dumper($entries);
    #return;

    open my $in_fh, '<', $presets_plist
      or die "Couldn't open $presets_plist for reading: $!";
    open my $out_fh, '>', $presets_plist_tmp
      or die "Couldn't open $presets_plist_tmp for writing: $!";

    my $inserted = 0;
    while (my $line = <$in_fh>) {
        print $out_fh $line;
        if (($inserted == 0) and ($line =~ m/<dict>/)) {
            print $out_fh header();
            print $out_fh entry( @{ $_ } ) for @$entries;
            print $out_fh footer();

            $inserted = 1;
        }
    }

    close $in_fh  or die "Couldn't close input filehandle: $!";
    close $out_fh or die "Couldn't close output filehandle: $!";
}

sub is_arrow {
    my ($key) = @_;
    if (($key >= 0xf700) and ($key <= 0xf703)) {
        return 1;
    } else {
        return 0;
    }
}

sub contains_shift {
    my ($mod) = @_;
    return ($mod & SHIFT)
      ? 1
      : 0;
}

sub contains_meta {
    my ($mod) = @_;
    return ($mod & META)
      ? 1
      : 0;
}

sub contains_ctrl {
    my ($mod) = @_;
    return ($mod & CTRL)
      ? 1
      : 0;
}

sub modifiers_to_string {
    my ($mod) = @_;
    my @mods;
    push @mods, 'SHIFT' if (contains_shift($mod));
    push @mods, 'META'  if (contains_meta($mod));
    push @mods, 'CTRL'  if (contains_ctrl($mod));

    my $str = join(" | ", @mods);
    return $str;
}


sub construct_iterm_key {
    my ($keycode, $modifiers) = @_;

    my $mod_num = 0;

    $mod_num += I_SHIFT  if contains_shift($modifiers);
    $mod_num += I_OPT    if contains_meta ($modifiers);
    $mod_num += I_CTRL   if contains_ctrl ($modifiers);

    $mod_num += I_ARROW  if is_arrow($keycode);

    return sprintf('0x%x-0x%x', $keycode, $mod_num);
}

sub construct_fixterm_csi_u {
    my ($keycode, $modifiers) = @_;
    return construct_fixterm_csi($keycode, $modifiers, 'u');
}

sub construct_csi_very_special {
    my ($keystr, $modifiers) = @_;
    my $mod_value = fixterm_modvalue($modifiers);
    $mod_value = '1' . $mod_value if $mod_value;

    return '[' . $mod_value . $keystr;
}

sub fixterm_modvalue {
    my ($modifiers) = @_;

    my $mod_value = 1;

    if ($modifiers) {

        $mod_value += SHIFT  if contains_shift($modifiers);
        $mod_value += META   if contains_meta ($modifiers);
        $mod_value += CTRL   if contains_ctrl ($modifiers);

        $mod_value = ';' . $mod_value;
    } else {
        $mod_value = '';
    }

    return $mod_value;
}

sub construct_fixterm_csi {
    my ($keycode, $modifiers, $term_char) = @_;

    $term_char //= '';
    my $mod_value = fixterm_modvalue($modifiers);

    return '[' . $keycode . $mod_value . $term_char;
}

sub to_string {
    my ($keycode, $modifiers, $i_key, $csi_u) = @_;
    return sprintf('key: %s keycode: %-3d %-25s %-16s %-10s',
                   chr($keycode), $keycode,
                   modifiers_to_string($modifiers),
                   $i_key, $csi_u);
}

################################################################################


sub header {
    return
      "    <key>Fixterm</key>\n".
      "    <dict>\n";
}

sub entry {
    my ($iterm_key, $fixterm_val) = @_;

    my @output
      = (
         "        <key>$iterm_key</key>\n",
         "        <dict>\n",
         "            <key>Action</key>\n",
         "            <integer>10</integer>\n",
         "            <key>Text</key>\n",
		 "            <string>$fixterm_val</string>\n",
         "        </dict>\n",
        );

    return join '', @output;
}

sub footer {
    return "    </dict>\n";
}

################################################################################

say 'Running fixterm generator script...';
main();
say 'Done';

################################################################################




# sub generate_alpha {
#     my @output;

#     my $hash = {};

#     foreach my $modifier (@modifiers) {
#         foreach my $char (('A'..'Z'),('a' .. 'z'),(0..9)) {

#             my $fixterm_modifier = $modifier + 1;

#             my $uc_char = uc($char);

#             my $keycode    = ord($char);
#             my $uc_keycode = ord($uc_char);


#             my $iterm_charcode;
#             my $iterm_modifier = 0;

#             if (contains_shift($modifier)) {
#                 $iterm_modifier |= I_SHIFT;
#             }

#             if (contains_meta($modifier)) {
#                 $iterm_modifier |= I_OPT;
#             }

#             if (contains_ctrl($modifier)) {
#                 $iterm_modifier |= I_CTRL;
#             }

#             # skip ctrl-only for lower-case letters.
#             if ($modifier == CTRL) {
#                 next if ($char ne $uc_char);
#                 say "ctrl-only ok for: $char";
#             }

#             $iterm_modifier = sprintf('0x%x', $iterm_modifier);

#             if (contains_shift($modifier)) {
#                 $iterm_charcode = sprintf('0x%x', $uc_keycode);
#             } else {
#                 $iterm_charcode = sprintf('0x%x', $keycode);
#             }

#             my $iterm_id = "$iterm_charcode-$iterm_modifier";


#             # iTerm action 10 provides the \e escape for the CSI.
#             my $fixterm_csi = '[' . $keycode;

#             if ($fixterm_modifier != 1) {
#                 $fixterm_csi .= ";$fixterm_modifier";
#             }

#             $fixterm_csi .= 'u';

#             print STDERR sprintf("Processing: %-3s %-3s %s, %s %d\n",
#                                  $char, $keycode,
#                                  $fixterm_csi, mods_to_str($modifier),
#                                  contains_shift($modifier));

#             $hash->{$iterm_id} = $fixterm_csi;
#         }
#     }
#     foreach my $key (sort keys %$hash) {
#         my $val = $hash->{$key};
#         push @output, [$key, $val];


#         push @fixterm_entries, $output;
#     }
# }



__END__

# TODO:

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
