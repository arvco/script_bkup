#!/usr/bin/perl

use Cwd;

$BEAMIN=	"<$ARGV[0]";
$RADPROFDIR=	"radprofs";
$SNAPDIR=	"snapshots";
$SNAPSHOT=	"snapshot";
$BEAMDIR=	"beam_pos";
$RADAVG=	"snap_avg";
$RADAVGEND=	"end_snap_avg_latest.info";
$MULTRADOUT=	"fort.36";
$SLICE=		"slice";
$nradprof=	626;
$everyslice=	4;
$everynrad=	5;
$nsnapstart=	12;
$nsnapend=	162;
$everysnap=	3;

@xpos=();
@ypos=();

open (beamin, $BEAMIN)
    or die "Could not open file '$BEAMIN' $!";

# Count loop runs
$counter=0;

while (my $row = <beamin>) {
    local @tmp = split ' ', $row;

    if ( $tmp[0] == 0 && $tmp[1] == 0) {
	next;
    } else {
	$xpos[$counter]=$tmp[0];
	$ypos[$counter]=$tmp[1];
	
#	print "$tmp[0] $tmp[1]\n";
	$counter++;
    }
}

foreach $index(0 .. $#xpos) {
    
#    for ($j=$everynrad; $j<=$nradprof; $j += $everynrad) {
	
	# +1 here to get the average right
	$radcount = $nsnapend - $nsnapstart + 1;
#	print "$radcount $xpos[$index] $ypos[$index] $nradprof $everynrad\n";

#	die;

	for ($i=$nsnapstart; $i<=$nsnapend; $i++) {
	    
	    local @tmp = ();
	    $TMPIN = $SNAPDIR . '/' . $SNAPSHOT . '_' . $i . '/' . $BEAMDIR . '_' . $xpos[$index] . '_' . $ypos[$index] . '/' . $MULTRADOUT;
#	    print "$i $nsnapstart $nsnapend $radcount $TMPIN \n";
	    open local $radinp, '<', $TMPIN 
		or do{
		    warn "Could not open file '$TMPIN' $!";
		    $radcount -= 1;
#		    print "$i $radcount\n";
		    next;
		};
	    while ( <$radinp> ) {
		push @tmp, [ split /\s+/ ];
	    }
	    
#	    for $k ( 0 .. $#tmp ) {
#		print "[ @{$tmp[$k]} ],\n";
#	    }
	    
#	    die;
	    
	    if ($i==$nsnapstart) {
		for $k ( 0 .. $#tmp ) {
		    $radprof[$k]= [ (0) x @{$tmp[$k]} ];
#		    print "[ @{$radprof[$k]} ],\n";
		}
	    }
	    
	    for $k( 0 .. $#tmp ) {
		for $l( 0 .. $#{$tmp[$k]} ) {
		    $radprof[$k][$l] += $tmp[$k][$l];
		}
	    }
#	    for $k ( 0 .. $#tmp ) {
#		print "[ @{$radprof[$k]} ],\n";
#	    }
	    
	    close ($radinp);
	    
#	    die;
	}
	
	
	
#	$nslice = $j * $everyslice;
#	print "$nslice\n";

	$nsnaprealend = $nsnapstart + ($radcount - 1) * $everysnap;
	
#	for $k ( ($#radprof - 10) .. $#radprof ) {
#	    print "[ @{$radprof[$k]} ],\n";
#	}

	$TMPOUT = $RADPROFDIR . '/' . $BEAMDIR . '_' . $xpos[$index] . '_' . $ypos[$index] . '/' . $RADAVG . '_' . $nsnapstart . '_' . $nsnaprealend;
#	print "$TMPOUT\n";
	open $radout, '>:encoding(UTF-8)', $TMPOUT;
	
#	print "@{$#radprof}\n";
	
	for $k ( 0 .. $#radprof ) {
	    printf $radout "%1.6f ", ($_ /= $radcount) for @{$radprof[$k]};
	    printf $radout "\n";
	}
	close ($radout);

	$TMPOUT = $RADPROFDIR . '/' . $BEAMDIR . '_' . $xpos[$index] . '_' . $ypos[$index] . '/' . $RADAVGEND;
	open $endsnapout, '>:encoding(UTF-8)', $TMPOUT;
	printf $endsnapout "%i", $nsnaprealend;
	close ($endsnapout);

#	die;
#    }
}

