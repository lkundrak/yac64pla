package genpin;

use strict;
use warnings;

my %S;

############## ############## ############## ############## ##############


$S{GRW} = <<'SNIP';
/GRW.T = A15 & A14 & /A13 & A12 & /AEC & /CAS & /RW
GRW.E = /OE
SNIP

$S{ROML} = <<'SNIP';
/ROML.T = A15 & /A14 & /A13 & /AEC & /EXROM & IRAM & LORAM & RW +
          A15 & /A14 & /A13 & /AEC & EXROM & /GAME
ROML.E = /OE
SNIP

$S{IO} = <<'SNIP';
/IO.T = /TIO2 +
        /TIO1
IO.E = /OE
SNIP

$S{BASIC} = <<'SNIP';
/BASIC.T = A15 & /A14 & A13 & /AEC & GAME & IRAM & LORAM & RW
BASIC.E = /OE
SNIP

$S{TIO1} = <<'SNIP';
/TIO1.T = A15 & A14 & /A13 & A12 & /AEC &      CHAREN & GAME & LORAM & /RW +
          A15 & A14 & /A13 & A12 & /AEC &      CHAREN & GAME & IRAM  & /RW +
          A15 & A14 & /A13 & A12 & /AEC & BA & CHAREN & GAME & LORAM       +
          A15 & A14 & /A13 & A12 & /AEC & BA & CHAREN & GAME & IRAM
TIO1.E = VCC
SNIP

$S{TIO2} = <<'SNIP';
/TIO2.T = A15 & A14 & /A13 & A12 & /AEC &      CHAREN & /GAME & LORAM & /RW +
          A15 & A14 & /A13 & A12 & /AEC &      CHAREN & /GAME & IRAM  & /RW +
          A15 & A14 & /A13 & A12 & /AEC & BA & CHAREN & /GAME & LORAM       +
          A15 & A14 & /A13 & A12 & /AEC & BA & CHAREN & /GAME & IRAM        +
          A15 & A14 & /A13 & A12 & /AEC &      EXROM  & /GAME         & /RW +
          A15 & A14 & /A13 & A12 & /AEC & BA & EXROM  & /GAME
TIO2.E = /OE
SNIP

$S{TCR} = <<'SNIP';
/TCR.T = A15 & A14 & /A13 & /A12 & EXROM & /GAME +
         /TIO2 +
         /TIO1 +
         /ROML +
         /BASIC +
         CAS
TCR.E = /OE
SNIP

############## ############## ############## ############## ##############

$S{CASRAM} = <<'SNIP';
/CASRAM.T =       /A14 & /A13 & /A12 & CHAROM & KERNAL & ROMH & TCR +
            A15 &  A14 &               CHAROM & KERNAL & ROMH & TCR +
            A15 &        /A13 &        CHAROM & KERNAL & ROMH & TCR +
                                GAME & CHAROM & KERNAL & ROMH & TCR +
                              /EXROM & CHAROM & KERNAL & ROMH & TCR
CASRAM.E = /OE
SNIP

$S{ROMH} = <<'SNIP';
/ROMH.T = A15 & /A14 & A13 &               /AEC & /EXROM & /GAME & IRAM & RW +
                             VA13 & VA12 &  AEC &  EXROM & /GAME             +
          A15 &  A14 & A13 &               /AEC &  EXROM & /GAME
ROMH.E = /OE
SNIP

$S{CHAROM} = <<'SNIP';
/CHAROM.T = A15 & A14 & /A13 & A12 & /AEC & /CHAREN & /EXROM & /GAME & IRAM  & RW  +
            A15 & A14 & /A13 & A12 & /AEC & /CHAREN &           GAME & LORAM & RW  +
            A15 & A14 & /A13 & A12 & /AEC & /CHAREN &           GAME & IRAM  & RW  +
            VA14 & /VA13 & VA12 &     AEC &           /EXROM                       +
            VA14 & /VA13 & VA12 &     AEC &                     GAME
CHAROM.E = /OE
SNIP

$S{KERNAL} = <<'SNIP';
/KERNAL.T = A15 & A14 & A13 & /AEC & /EXROM & /GAME & IRAM & RW +
            A15 & A14 & A13 & /AEC &           GAME & IRAM & RW
KERNAL.E = /OE
SNIP

############## ############## ############## ############## ##############

sub gen
{
	my $out = shift;
	my $pins = shift;

	my @p = sort { $a->{dip_pin} <=> $b->{dip_pin} }
		grep { $_->{dip_pin} ne '' }
		values %$pins;
	my ($max) = sort { $b <=> $a } map { length $_->{pld_name} } @p;
	for (0..$#p) {
		printf $out "%-$max"."s", $p[$_]->{pld_name};
		print $out (($_+1) % (($#p+1)/2) ? ' ' : "\n");
	}
	print $out "\n\n";

	for my $p (@p) {
		next unless $p->{output};
		print $out $S{$p->{pld_name}};
		print $out "\n";
	}
}

sub kicad_name
{
	my $n = shift;
	$n =~ s/\//{slash}/g;
	$n =~ s/~([^~\/]+)/~{$1}/g;
	return $n;
}

sub pld_name
{
	my $n = shift;
	$n =~ s/[\/~]//g;
	return $n;
}

sub pp
{
        my %p;
        foreach (@_) {
		/^\(.*\)$/ and next;
                /^(\d+)\|?(\d*)([\|<])(.*)$/ or die;
                $p{$4 eq 'X' ? "$4$1" : pld_name($4)} = {
                        kicad_name => kicad_name($4),
                        pld_name => pld_name($4),
                        output => $3 eq '<',
                        plcc_pin => $1,
                        dip_pin => $2,
                };
        }
        return %p;
}

sub dogen
{
	my $fn = shift;
	my $dev = shift;
	my $cmt = shift;
	my %pins = pp @_;

	open my $out, '>', $fn or die "$fn: $!";
	print $out "$dev\n$cmt\n\n\n";
	gen $out, \%pins;
	print $out "\nDESCRIPTION\n";
	print $out "Replacement for 906114-01\n";
	print $out "Generated with $0\n";
}

sub dosubst
{
	my $t = shift;
	my $pfx = shift;
	my %pins = pp @{(shift)};
	my %subst;

	$$t =~ s/"\$$pfx$_->{plcc_pin}"/"$_->{kicad_name}"/g
		foreach (values %pins);
}

sub dosch
{
	my $tmpl = shift;
	my $out = shift;
	my $top = shift;
	my $bot = shift;

	open my $tf, '<', $tmpl or die "$tmpl: $!";
	my $t = join '', <$tf>;

	dosubst (\$t, 'T', $top);
	dosubst (\$t, 'B', $bot);
	$t =~ s/"\$TEMPLATE"/"Generated from $0"/;
	die if $t =~ /\$[TB]/;

	open my $of, '>', $out or die "$out: $!";
	print $of $t;
}

1;
