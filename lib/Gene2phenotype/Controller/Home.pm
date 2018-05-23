package Gene2phenotype::Controller::Home;
use base qw(Gene2phenotype::Controller::BaseController);

sub show {
  my $self = shift;
  my $model = $self->model('home'); 
  my $logged_in = $self->stash('logged_in');
  my $authorised_panels = $self->stash('authorised_panels');
  my $updates = $model->fetch_updates($logged_in, $authorised_panels);
  $self->stash(updates => $updates);  
  $self->render(template => 'home');
}

1;
