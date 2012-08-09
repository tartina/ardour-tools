#! /usr/bin/perl
#
# Randomize ardour track
#
# Usage: randtrack [ardour session file] [amount of randomization] [track name]

use strict;
use warnings;
use XML::LibXML;

sub is_integer { $_[0] =~ /^[+-]?\d+$/ }

my $session_file;
my $outfile;
my $randomization;
my $track;
my $session;
my $region;
my $value;
my $temp;
my $rand;
my $root;
my @nodelist;
my $i;

my $numargs = @ARGV;

if ($numargs > 3) {
  $session_file = $ARGV[0];
  $outfile = $ARGV[1];
  $randomization = $ARGV[2];
} else {
  die "Too few parameters\n";
}

if (defined($session_file) && defined($outfile) && defined($randomization)) {
	if (is_integer($randomization)) {

    $session = XML::LibXML->load_xml(location => $session_file);
    $root = $session->documentElement();

    $value = $root->nodeName;
    if ($value ne "Session") { die "This is not an Ardour session"; }
    $value = $root->getAttribute("version");
    if ($value ne "2.0.0") { die "This is not an Ardour session"; }

    for ($i = 3; $i < $numargs; $i++) {
      $track = $ARGV[$i];
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

      } else {
        print "Track $track not found\n";
      }
    }
    $session->toFile($outfile);
	}
} else {
	print "Too few parameters\n";
}
