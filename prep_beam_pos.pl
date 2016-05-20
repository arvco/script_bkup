#!/usr/bin/perl

open inp, "<$ARGV[0]";
$NSNAPS=	"$ARGV[1]";
$NLINES=	"$ARGV[2]";
$FILTPL=	"$ARGV[3]";
@ATOMICNUM=	(38, 22, 8);

$TYPNUM= @ATOMICNUM;

for($i=0;$i<=$NSNAPS;$i++) {
    
#    $tmp = $FILTPL . '_' . $i . '/' . 'fort.20';
#    print "$tmp \n";
    
#    open out, ">$tmp";
    
    @lbound = ();
    @ubound = ();
    @box = ();
    
    
    for($j=1;$j<=$NLINES;$j++) {
	
	$l = <inp>;
	@tar = split /\s+/, $l;
	
#	print "$tar[1] "; print "$tar[2] "; print "$tar[3] "; print "$tar[4]\n";
	
	if( $j == 1 || $j == 3 || $j == 5) {
#	    print "$j";
	    next;
	}
        if( $j == 2 ) {
	    $tar[0] /= 1000;
	    $tmp = $FILTPL . '_' . $tar[0] . '/' . 'fort.20';
	    print "$tmp \n";
	    open out, ">$tmp";
            next;
        }
	if( $j == 4 ) {
	    $NATOMS = $tar[0];
#	    print "$NATOMS $j \n";
	    next;
	}
	if( $j == 6 || $j == 7 || $j == 8) {
#	    print "$j";
	    $now = $j - 5;
#	    print "$now \n";
	    $lbound[$now] = $tar[0];
	    $ubound[$now] = $tar[1];
	    $box[$now]	  = $ubound[$now] - $lbound[$now];
	    printf out "%3.10f ", $box[$now];
	    if($j==8) {printf out "\n";}
	}
	if( $j == 9 ) {
	    printf out "%i L\n",$NATOMS;
	}

	if( $j >= 10 ) {
	    
	    $tar[3] -= $lbound[1];
	    $tar[4] -= $lbound[2];
	    $tar[5] -= $lbound[3];
	    
	    if($tar[3] < 0) {$tar[3] += $box[1];}
	    if($tar[4] < 0) {$tar[4] += $box[2];}
	    if($tar[5] < 0) {$tar[5] += $box[3];}
	    
	    if($tar[3] > $box[1]) {$tar[3] -= $box[1];}
	    if($tar[4] > $box[2]) {$tar[4] -= $box[2];}
	    if($tar[5] > $box[3]) {$tar[5] -= $box[3];}
	    
	    for( $k=0; $k<$TYPNUM; $k++ ) {
		if($tar[2] == ($k + 1)) {printf out "%2i %2.10f %2.10f %3.10f\n", $ATOMICNUM[$k], $tar[3], $tar[4], $tar[5];}
	    }
	}
    }

    close out

}
