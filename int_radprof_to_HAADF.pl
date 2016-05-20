#!/usr/bin/perl

$BEAMIN=        "$ARGV[0]";
# Angles in mrad, numerical input
$iang=		int($ARGV[1] + 0.5);
$oang=		int($ARGV[2] + 0.5);
$RADPROFDIR=    "radprofs";
$DATADIR=	"data";
$HAADFDIR=      "HAADF_image";
$RADAVG=        "snap_avg";
$RADAVGEND=     "end_snap_avg_latest.info";
$BEAMDIR=       "beam_pos";
$INTRADOUT=     "int_radprof";
$SLICE=         "slice";
$nradprof=      625;
$everyslice=    4;
$everynrad=     5;
$nsnapstart=    12;
$nsnapend=      162;

@xpos=();
@ypos=();
@OUTFILES=();

open $beamin, '<', $BEAMIN
    or die "Could not open file '$BEAMIN' $!";

# Count loop runs
$counter=0;

while (my $row = <$beamin>) {
    
    local @tmp = ();
    @tmp = split ' ', $row;
    
    if ( $tmp[0] == 0 && $tmp[1] == 0) {
        next;
    } else {
        $xpos[$counter]=$tmp[0];
        $ypos[$counter]=$tmp[1];
	
        print "$tmp[0] $tmp[1]\n";
        $counter++;
    }
}
close ($beamin);

for ($j=0; $j<=$nradprof; $j+=$everynrad) {
    
    $nslice[$j] = $j * $everyslice;
    $TMPFILEOUT = $HAADFDIR . '/' . $DATADIR . '/' . $INTRADOUT . '_' . $iang . '_' . $oang . '_' . $SLICE . '_' . $nslice[$j];
#    print "$j $nslice[$j] $TMPFILEOUT\n";
    
    open local $TMPFILE, '>:encoding(UTF-8)', $TMPFILEOUT;
    push @OUTFILES, $TMPFILE;
}

#print "@OUTFILES";

foreach $index(0 .. $#xpos) {
    
    local @tmp = ();
    
    $TMPIN = $RADPROFDIR . '/' . $BEAMDIR . '_' . $xpos[$index] . '_' . $ypos[$index] . '/' . $RADAVGEND;
    open $endsnapin, '<:encoding(UTF-8)', $TMPIN
	or do{
	    warn "Could not open file '$TMPIN' $!";
	    next;
	};
    $nsnaprealend = <$endsnapin>;
    print "$nsnaprealend\n";
    close ($endsnapin);
    
    $TMPIN = $RADPROFDIR . '/' . $BEAMDIR . '_' . $xpos[$index] . '_' . $ypos[$index] . '/' . $RADAVG . '_' . $nsnapstart . '_' . $nsnaprealend;
    print "$TMPIN\n";
    open $radavginp, '<:encoding(UTF-8)', $TMPIN
        or do{
            warn "Could not open file '$TMPIN' $!";
            next;
        };
    while ( <$radavginp> ) {
	push @tmp, [ split /\s+/ ];
    }
    for $k ( 0 .. $#tmp ) {
	$intrad[$k] = $tmp[$k][($oang + 1)] - $tmp[$k][($iang + 1)];
	print "$intrad[$k]\n";
    }
    
    $TMPOUT = $RADPROFDIR . '/' . $BEAMDIR . '_' . $xpos[$index] . '_' . $ypos[$index] . '/' . $INTRADOUT . '_' . $nsnapstart . '_' . $nsnaprealend;
    open $radout, '>:encoding(UTF-8)', $TMPOUT;
    
    printf $radout "%1.6f\n", $_ for @intrad;
    
    close ($radintout);
    close ($radavginp);
    
    $j = 0;
    foreach $file (@OUTFILES) {
	# Get integrated radial profile at slice $j
#	@tmp = split /\s+/, <$radintinp>;
	
#	print "$xpos[$index] $ypos[$index] $intrad[$j]\n";
	
#	print "$OUTFILES[$j]\n";
#	local $OUT = $OUTFILES[$j];
	printf $file "%2i %2i %1.6f\n", $xpos[$index], $ypos[$index], $intrad[$j];
	
	# Adjust the current line of input file
#	foreach (1 .. ($everynrad - 1)) {
#	    @tmp = split /\s+/, <$radintinp>; 
#	}
#    close ($radintinp);
    $j += $everynrad;
    }
#    die;
}

