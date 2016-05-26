package Gene2phenotype::Controller::Login;
use Mojo::Base 'Mojolicious::Controller';


sub on_user_login {
  my $self = shift;
  my $email = $self->param('email');
  my $password = $self->param('password');

  if ($self->authenticate($email, $password)) {
    $self->session(logged_in => 1);
    $self->session(email => $email);
    my $last_page = $self->session('last_url') || '/';
    return $self->redirect_to($last_page);
  }

  return $self->render(text => 'Wrong username/password', status => 403);
}

sub on_user_logout {
  my $self = shift;
  $self->session(logged_in => 0);
  $self->session(expires => 1);
  my $last_page = $self->session('last_url') || '/';
  return $self->redirect_to($last_page);
}

sub is_logged_in {
  my $self = shift;
  return 1 if $self->session('logged_in');
}

1;
