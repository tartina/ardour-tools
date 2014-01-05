#! /usr/bin/perl
#
# Scale automation of an ardour track
#
# Usage: scaleautomation.pl [ardour session file] [output file] [gain in dB] [track name]...

use strict;
use warnings;
use XML::LibXML;

use constant USAGE => "Usage: scaleautomation.pl [ardour session file] [output file] [gain in dB] [track name]...\n";

sub is_integer { $_[0] =~ /^[+-]?\d+$/ }

my $session_file;
my $outfile;
my $gain;
my $track;
my $session;
my $value;
my $newvalue;
my $root;
my @nodelist;
my $i;
my @event;
my $time;
my @automation;
my $newautomation;
my $scale;

my $numargs = @ARGV;

if ($numargs > 3) {
  $session_file = $ARGV[0];
  $outfile = $ARGV[1];
  $gain = $ARGV[2];
} else {
  die USAGE;
}

if (defined($session_file) && defined($outfile) && defined($gain)) {
	if (is_integer($gain)) {

		if ($gain > 60 || $gain < -60) { die "Gain must be within -60 and 60"; }
		if ($gain == 0) { die "Nothing to do!"; }

		$scale = 10.0 ** ($gain * 0.05);

    $session = XML::LibXML->load_xml(location => $session_file);
    $root = $session->documentElement();

    $value = $root->nodeName;
    if ($value ne "Session") { die "This is not an Ardour session"; }
    $value = $root->getAttribute("version");
    if ($value ne "3001") { die "This Ardour session version is not supported"; }

    for ($i = 3; $i < $numargs; $i++) {
      $track = $ARGV[$i];

      @nodelist =
				$root->findnodes("/Session/Routes/Route[\@name='$track']/Processor[\@type='amp']/Automation/AutomationList[\@automation-id='gain']/events");

      if (@nodelist) {
        $value = $nodelist[0]->firstChild->nodeValue;
				@event = split /^/, $value;
				$newvalue='';
				foreach $value (@event) {
					@automation = split / /, $value;
					$newautomation = $automation[1] * $scale;
					if ($newautomation > 2) { die "Clipping occurred, not saving file"; }
					$newvalue .= sprintf("%u %.16f\n", $automation[0], $newautomation);
				}
				$nodelist[0]->firstChild->replaceNode(XML::LibXML::Text->new( $newvalue ));
      } else {
        print "Track $track or automation not found\n";
      }
		}
    $session->toFile($outfile);
	}
} else {
	print USAGE;
}
