#! /usr/bin/perl
#
# Randomize ardour track
#
# Usage: randtrack.pl [ardour session file] [amount of randomization] [track name]

use strict;
use warnings;
use XML::Simple;

sub is_integer { $_[0] =~ /^[+-]?\d+$/ }

my $session_file = $ARGV[0];
my $randomization = $ARGV[1];
my $track = $ARGV[2];
my $session;
my $playlist;
my $region;
my $outfile;
my $regions;
my $key;
my $value;
my $temp;
my $rand;

if (defined($session_file) && defined($randomization) && defined($track)) {
	$outfile = $session_file . ".new";
	if (is_integer($randomization)) {
		$session = XMLin($session_file, KeepRoot => 1, KeyAttr => { Region => 'id', AudioDiskstream => 'name', Playlist => 'name' });

		$playlist = $session->{Session}->{DiskStreams}->{AudioDiskstream}->{$track}->{playlist};
		$regions = $session->{Session}->{Playlists}->{Playlist}->{$playlist}->{Region};

		while ( ($key, $value) = each %$regions ) {
			$rand = int(rand($randomization)) - ($randomization / 2);
			$temp = $value->{position} + $rand;
			if ($temp < 0) {$temp = 0};
			$value->{position} = $temp;
	}
	XMLout($session, KeepRoot => 1, KeyAttr => { Region => 'id', AudioDiskstream => 'name', Playlist => 'name'}, OutputFile => $outfile, XMLDecl => '<?xml version="1.0" encoding="UTF-8"?>');
	}
} else {
	print "Too few parameters\n";
}
