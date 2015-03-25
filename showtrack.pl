#! /usr/bin/perl
#
# Print ardour track info
#
# Usage: showtrack.pl [ardour session file] [track]

use strict;
use warnings;
use XML::LibXML;

my $session_file;
my $session;
my $track;
my $root;
my $value;
my @nodelist;
my $i;

my $numargs = @ARGV;

if ( $numargs > 1 ) {
    $session_file = $ARGV[0];
	$track = $ARGV[1];
}
else {
    die "Usage: showtrack [ardour session file] [track]\n";
}

if ( defined($session_file) ) {
    $session = XML::LibXML->load_xml( location => $session_file );
    $root = $session->documentElement();

    $value = $root->nodeName;
    if ( $value ne "Session" ) { die "This is not an Ardour session"; }
    $value = $root->getAttribute("version");
    if ( $value ne "3001" ) {
        die "This Ardour session version is not supported";
    }

    @nodelist = $root->findnodes("/Session/Routes/Route[\@name='$track']");

    if (@nodelist) {
		print $nodelist[0]->toString() . "\n";
    }
}
else {
    print "Usage: showtracks [ardour session file] [track]\n";
}
