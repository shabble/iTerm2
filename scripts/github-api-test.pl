#!/usr/bin/env perl

use 5.012;
use strict;
use warnings;

use Data::Dumper;
use Net::GitHub;

my $github
  = Net::GitHub->new(owner => 'shabble', repo => 'irssi-scripts');

my $issues = $github->issue->list;
