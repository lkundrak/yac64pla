use strict;
use warnings;

use lib qw/./;
use genpin;

# Pin descriptions

# This visually matches the board,
# hopefully making sensible routing easier

                                        my @LP = qw{
(FE)                                                                                        (VCC)
                11|9|FE 10|8|A15 9|7|A14 8|X 7|6|~AEC 6|5|BA 5|4|A12
(*A13)                                                                                      (*A12)
           12|10|A13                                                            4|3|R/~W
(*A14)     13|11|~CHAREN                                                       3|2|~CAS    (*BA)
           14|12|GND                                                           2|1|~EXROM
(*A15)     15|X                         (plcc24)                               1|X          (*~AEC)
           16|13|~OE                                                          28|24|VCC
(~VA14)    17|14|~IRAM                                                        27|23|~GAME    (R/~W)
           18|15<GR/~W                                                        26|22<TCR
(*~CHAREN)                                                                                  (~EXROM)
               19|16|~LORAM 20|17<~ROML 21|18<~I/O 22|X 23|19<~BASIC 24|20<TIO1 25|21<TIO2
(~IRAM)                                                                                     (~GAME)
                                       }; my @RP = qw{
(*~LORAM)                                                                                    (VA13)
                  11|9|~LORAM 10|8|FE 9|7|~IRAM 8|X 7|6|~CHAREN 6|5|TCR 5|4|~AEC
(~CAS)                                                                                      (VA12)
           12|10|~VA14                                                          4|3|VA13
(<~ROMH)   13|11|A13                                                          3|2|R/~W      (~OE)
           14|12|GND                                                          2|1|A12
(<~ROML)   15|X                         (plcc24)                              1|X           (<~CASRAM)
           16|13|~OE                                                         28|24|VCC
(<~I/O)    17|14|A15                                                       27|23|VA12    (<~BASIC)
           18|15|uTIO2                                                       26|22<~CASRAM
(<GR/~W)                                                                                    (<~KERNAL)
            19|16<~ROMH 20|17|A14 21|18|~EXROM 22|X 23|19|~GAME 24|20<~CHAROM 25|21<~KERNAL
(GND)                                                                                       (<~CHAROM)
};

sub doone
{
	my $fn = shift;
	my $dev = shift;
	my $cmt = shift;

	genpin::dogen ("$fn.pld", $dev, $cmt, @_);
	system ("galette $fn.pld") and exit $?;
}

my $dev = 'GAL20V8';

# Template the KiCAD schematic
genpin::dosch ('yac64pla-tmpl.kicad_sch', 'yac64pla.kicad_sch', \@LP, \@RP);

# Compile the GAL fuse map
doone ('yac64pla-top', $dev, 'C64 PLA replacement top chip', @LP);
doone ('yac64pla-bot', $dev, 'C64 PLA replacement bottom chip', @RP);
