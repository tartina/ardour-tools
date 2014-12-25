#! /usr/bin/perl
#
# Find and print ardour tracks
#
# Usage: findtracks.pl [ardour session file]

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

if ( $numargs > 0 ) {
    $session_file = $ARGV[0];
}
else {
    die "Usage: findtracks [ardour session file]\n";
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

    @nodelist = $root->findnodes("/Session/Routes/Route");

    foreach $track (@nodelist) {
        $value = $track->getAttribute("name");
        print($value);
        print(" ");
    }
}
else {
    print "Usage: findtracks [ardour session file]\n";
}
