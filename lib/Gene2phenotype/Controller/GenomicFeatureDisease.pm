package Gene2phenotype::Controller::GenomicFeatureDisease;
use Mojo::Base 'Mojolicious::Controller';

sub show {
  my $self = shift;
  my $model = $self->model('genomic_feature_disease');  

  my $dbID = $self->param('dbID');

  my $gfd = $model->fetch_by_dbID($dbID); 

  my $logged_in = $self->session('logged_in');
  $self->stash(logged_in => $logged_in);
  $self->stash(gfd => $gfd);
  $self->render(template => 'gfd');
}

# show
# update
# add
# delete 
1;
