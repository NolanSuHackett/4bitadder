 #!/usr/bin/env perl
use strict;
use warnings;

my $log = @ARGV ? $ARGV[0] : 'sim.log';

open my $FH, '<', $log or die "Cannot open $log: $!";
my @lines = <$FH>;
close $FH;

# Normalize CRLF just in case
s/\r\n/\n/g for @lines;

my @rows;
my ($tests, $passes, $fails) = (0, 0, 0);

for my $ln (@lines) {
    chomp $ln;
    if ($ln =~ /^RESULT,(PASS|FAIL),(\d+),(\d+),(\d+),(\d+)$/) {
        my ($status,$a,$b,$sum,$exp) = ($1,$2,$3,$4,$5);
        push @rows, { status=>$status, a=>$a, b=>$b, sum=>$sum, exp=>$exp };
    }
    if ($ln =~ /^SUMMARY,TESTS,(\d+),PASS,(\d+),FAIL,(\d+)$/) {
        ($tests,$passes,$fails) = ($1,$2,$3);
    }
}

# If SUMMARY wasn't printed (older TBs), infer from rows
$tests  ||= scalar @rows;
$passes ||= scalar grep { $_->{status} eq 'PASS' } @rows;
$fails  ||= $tests - $passes;

# CSV
open my $CSV, '>', 'results.csv' or die $!;
print $CSV "status,a,b,sum,expected,overflow\n";
for my $i (0..$#rows) {
    my $r = $rows[$i];
    my $ovf = ($r->{sum} >= 16) ? 1 : 0;  # 4-bit a/b → 5-bit sum overflow flag
    print $CSV "$r->{status},$r->{a},$r->{b},$r->{sum},$r->{exp},$ovf\n";
}
close $CSV;

# JUnit (one testcase per vector)
open my $J, '>', 'junit.xml' or die $!;
print $J qq{<?xml version="1.0" encoding="UTF-8"?>\n};
print $J qq{<testsuite name="tb_adder4" tests="$tests" failures="$fails">\n};
for my $i (0..$#rows) {
    my $r = $rows[$i];
    my $name = "a=$r->{a},b=$r->{b}";
    if ($r->{status} eq 'FAIL') {
        print $J qq{  <testcase name="$name"><failure message="sum=$r->{sum} expected=$r->{exp}"/></testcase>\n};
    } else {
        print $J qq{  <testcase name="$name"/>\n};
    }
}
print $J qq{</testsuite>\n};
close $J;

# Simple HTML report
open my $H, '>', 'report.html' or die $!;
print $H <<"HTML";
<!doctype html><meta charset="utf-8">
<title>tb_adder4 Report</title>
<h1>tb_adder4 Regression</h1>
<p>Tests: <b>$tests</b> | Pass: <b>$passes</b> | Fail: <b>$fails</b></p>
<table border="1" cellpadding="4" cellspacing="0">
<tr><th>#</th><th>Status</th><th>a</th><th>b</th><th>sum</th><th>expected</th><th>overflow</th></tr>
HTML
for my $i (0..$#rows) {
    my $r = $rows[$i];
    my $ovf = ($r->{sum} >= 16) ? 1 : 0;
    print $H "<tr><td>", $i+1, "</td><td>$r->{status}</td><td>$r->{a}</td><td>$r->{b}</td><td>$r->{sum}</td><td>$r->{exp}</td><td>$ovf</td></tr>\n";
}
print $H "</table>\n";
close $H;

print "Parsed: tests=$tests pass=$passes fail=$fails\n";
exit($fails ? 1 : 0);  # nonzero exit makes Jenkins mark build red on failures
