package Gene2phenotype::Controller::GenomicFeatureDisease;
use Mojo::Base 'Mojolicious::Controller';

sub show {
  my $self = shift;


  my $model = $self->model('genomicfeaturedisease');  

  my $dbID = $self->param('dbID');

  my $gfd = $model->fetch_by_dbID($dbID); 

  $self->stash(gfd => $gfd);

  $self->render(template => 'g2p');
}


# show
# update
# add
# delete 
1;
