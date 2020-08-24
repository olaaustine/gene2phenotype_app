package Gene2phenotype::Controller::LocusGenotypeMechanism;
use base qw(Gene2phenotype::Controller::BaseController);

sub show {
  my $self = shift;
  my $lgm_id = $self->param('lgm_id');
  my $model = $self->model('locus_genotype_mechanism');
  my $lgm = $model->fetch_by_dbID($lgm_id); 
  $self->stash(lgm => $lgm); 
  $self->render(template => 'lgm');
}

1;
