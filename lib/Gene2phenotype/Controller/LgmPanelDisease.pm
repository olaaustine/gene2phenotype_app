package Gene2phenotype::Controller::LgmPanelDisease;
use base qw(Gene2phenotype::Controller::BaseController);

sub show {
  my $self = shift;
  my $lgm_panel_disease_id = $self->param('id');
  my $model = $self->model('lgm_panel_disease');
  my $lgms = $model->fetch_by_dbID($lgm_panel_disease_id); 
  $self->stash(lgms => $lgms); 
  $self->render(template => 'lgm_panel_disease');
}

1;
