package Gene2phenotype::Controller::Login;
use Mojo::Base 'Mojolicious::Controller';

sub on_user_login {
  my $self = shift;
  my $username = $self->param('user');
  if ($self->authenticate($username, $self->param('pw'))) {
    $self->session(logged_in => 1);
    $self->session(username => $username);
#    $self->redirect_to('restricted_area');
    return $self->render(text => 'Logged in!');
  }
  return $self->render(text => 'Wrong username/password', status => 403);
# $self->render(text => 'Wrong username/password', status => 403);
}

sub is_logged_in {
  my $self = shift;

  print STDERR 'Session ', $self->session, "\n";    
  
  return 1 if $self->session('logged_in');

  $self->render(text => 'You are nit logged in', status => 403);

}



1;
