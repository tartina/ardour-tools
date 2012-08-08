#! /usr/bin/perl
#
# Randomize ardour track
#
# Usage: randtrack.pl [ardour session file] [output file] [amount of randomization] [track name]

use strict;
use warnings;
use XML::LibXML;

sub is_integer { $_[0] =~ /^[+-]?\d+$/ }

my $session_file = $ARGV[0];
my $outfile = $ARGV[1];
my $randomization = $ARGV[2];
my $track = $ARGV[3];
my $session;
my $region;
my $value;
my $temp;
my $rand;
my $root;
my @nodelist;

if (defined($session_file) && defined($outfile) && defined($randomization) && defined($track)) {
	if (is_integer($randomization)) {

    $session = XML::LibXML->load_xml(location => $session_file);
    $root = $session->documentElement();

    $value = $root->nodeName;
    if ($value ne "Session") { die "This is not an Ardour session"; }
    $value = $root->getAttribute("version");
    if ($value ne "2.0.0") { die "This is not an Ardour session"; }

    @nodelist = $root->findnodes("/Session/DiskStreams/AudioDiskstream[\@name='$track']");

    if (@nodelist) {
      $value = $nodelist[0]->getAttribute("playlist");
      @nodelist = $root->findnodes("/Session/Playlists/Playlist[\@name='$value']/Region");

      foreach $region (@nodelist) {
	      $rand = int(rand($randomization) - ($randomization / 2));
        $value = $region->getAttribute("position");
	      $temp = $value + $rand;
	      if ($temp < 0) {$temp = 0};
	      $region->setAttribute("position", $temp);
      }

      $session->toFile($outfile);
    } else {
      print "Track not found\n";
    }
	}
} else {
	print "Too few parameters\n";
}
