package DDG::Goodie::Tips;
# ABSTRACT: calculate a tip/tax on a bill or a general percentage

use strict;
use DDG::Goodie;
with 'DDG::GoodieRole::NumberStyler';

# Yes, 'of' is very generic, the guard should kick back false positives very quickly.
triggers any => 'tip', 'tips', 'of', 'tax';

zci answer_type => 'tip';
zci is_cached   => 1;

my $number_re = number_style_regex();

handle query_lc => sub {
    return unless (/^(?<p>$number_re)(?: ?%| percent) (?<tax_or_tip>tip|tax) (?:on|for|of)|of(?: an?)? (?<sign>[\$\-]?)(?<num>$number_re)(?: bill)?$/);
    
    my ($p, $num, $sign) = ($+{'p'}, $+{'num'}, $+{'sign'});
    my $style = number_style_for($p, $num);
    $p   = $style->for_computation($p) / 100;
    $num = $style->for_computation($num);
    my $t = $p * $num;
    
    my $subtotal = $style->for_display(sprintf "%.2f", $num);
    my $tax_or_tip = ucfirst($+{'tax_or_tip'});
    my $tax_or_tip_value = $style->for_display(sprintf "%.2f", $t);
    my $total = $style->for_display(sprintf "%.2f", $num + $t);
        
    my $tax_or_tip_answer = "Subtotal: \$$subtotal; $tax_or_tip: \$$tax_or_tip_value; Total: \$$total";
    return $tax_or_tip_answer,
        structured_answer => {
            data => {
                title => "$tax_or_tip_answer",
            },
            templates => {
                group => 'text'
            }
         };
};

1;
