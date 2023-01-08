use strict;
use warnings;

use lib qw/./;
use genpin;

my @LP = qw(

       11|9|~CAS 10|8|~LORAM 9|7|~IRAM 8|X 7|6|~CHAREN 6|5|~AEC 5|4|A15
  
  12|10|FE                                                            4|3|BA
  13|11|R/~W                                                          3|2|A13
  14|12|GND                                                           2|1|A12
  15|X                                                                1|X
  16|13|~OE                                                           28|24|VCC
  17|14|~EXROM                                                        27|23|~GAME
  18|15<GR/~W                                                         26|22<TCR
  
      19|16<~ROML 20|17<~I/O 21|18|A14 22|X 23|19<~BASIC 24|20<TIO1 25|21<TIO2

);

my @RP = qw(

         11|9|FE 10|8|~LORAM 9|7|~IRAM 8|X 7|6|~CHAREN 6|5|~AEC 5|4|A15
  
  12|10|VA13                                                          4|3|TCR
  13|11|R/~W                                                          3|2|A13
  14|12|GND                                                           2|1|A12
  15|X                                                                1|X
  16|13|~OE                                                           28|24|VCC
  17|14|~EXROM                                                        27|23|~GAME
  18|15<~CASRAM                                                       26|22|TIO2
  
   19|16<~ROMH 20|17<~CHAROM 21|18|A14 22|X 23|19<~KERNAL 24|20|~VA14 25|21|VA12

);

sub doone
{
	my $fn = shift;
	my $dev = shift;
	my $cmt = shift;

	genpin::dogen ("$fn.pld", $dev, $cmt, @_);
	system ("galette $fn.pld") and exit $?;
	system ("diff <(jedutil -view ../yac64pla/$cmt.jed $dev) <(jedutil -view $fn.jed $dev)") and exit $?;
}

my $dev = 'GAL20V8';
doone ('old-l', $dev, '906114-01_20V8_L', @LP);
doone ('old-r', $dev, '906114-01_20V8_R', @RP);
genpin::dosch ('yac64pla-tmpl.kicad_sch', 'old.kicad_sch', \@LP, \@RP);
