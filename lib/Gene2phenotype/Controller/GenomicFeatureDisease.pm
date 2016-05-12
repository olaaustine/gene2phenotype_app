package Gene2phenotype::Controller::GenomicFeatureDisease;
use Mojo::Base 'Mojolicious::Controller';

sub show {
  my $self = shift;
  $self->render(template => 'g2p');
}


# show
# update
# add
# delete 
1;
