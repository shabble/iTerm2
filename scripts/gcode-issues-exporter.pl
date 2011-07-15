#!/usr/bin/env perl

use 5.012;
use strict;
use warnings;

use Data::Dumper;
use Net::Google::Code;

{
    no warnings 'once';
    $Net::Google::Code::Issue::USE_HYBRID = 1;
    use warnings 'once';
}
my $project = Net::Google::Code->new(project => 'iterm2' );
$project->load; # load its metadata, e.g. summary, owners, members, etc.

say "Project: $project->{project}";

my $issue_obj = $project->issue;
my @issues = $issue_obj->list(max_results => $ARGV[0] || 10);
my @names = map { defined && "$_->{id} = \"$_->{summary}\"" } @issues;
say Dumper(\@names);
__END__

my $issue = $project->issue(id => 1051);
$issue->load;
$issue->load_comments;
#$issue->parse_hybrid;
my $comments = $issue->{comments};

say "Issue: $issue: " . Dumper($issue);
say "Comments: " . Dumper($comments);
#say join(', ', @{ $project->owners } );
