use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }


#my $t = Test::Mojo->new(Mojo::File->new('../script/gene2phenotype'));

my $t = Test::Mojo->new('Gene2phenotype');
$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);

done_testing();
