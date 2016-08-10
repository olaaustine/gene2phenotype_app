package Gene2phenotype::Controller::Login;
use Digest::MD5 qw/md5_hex/;
use base qw(Gene2phenotype::Controller::BaseController);

sub on_user_login {
  my $self = shift;
  my $email = $self->param('email');
  my $password = $self->param('password');

  if ($self->authenticate($email, $password)) {
    $self->session(logged_in => 1);
    $self->session(expiration => 3600);
    $self->session(email => $email);
    my $model = $self->model('user');
    my $user = $model->fetch_by_email($email);
    my @panels = split(',', $user->panel);
    $self->session(panels => \@panels);
    my $last_page = $self->session('last_url') || '/gene2phenotype';
    return $self->redirect_to($last_page);
  }

  return $self->render(text => 'Wrong username/password', status => 403);
}

sub on_user_logout {
  my $self = shift;
  $self->session(logged_in => 0);
  $self->session(panels => []);
  $self->session(expires => 1);
  my $last_page = $self->session('last_url') || '/gene2phenotype';
  return $self->redirect_to($last_page);
}

sub is_logged_in {
  my $self = shift;
  return 1 if $self->session('logged_in');
}

sub send_recover_pwd_mail {
  my $self = shift;
  my $email = $self->param('email');

  my $autologin_code = md5_hex( time + rand(time) );

  my $url = $self->url_for('/gene2phenotype/login/recovery/reset')->query(code => $autologin_code)->to_abs;

  $self->session(email => $email);
  $self->session(code => $autologin_code);
  $self->session(send_recover_email_mail => 1);

  $self->mail(
    to      => $email,
    subject => 'Reset your password for gene2phenotype website',
    data    => $url,
  );
  $self->flash(message => "An email with instructions for how to reset your email has been sent to $email", alert_class => 'alert-info');
  return $self->redirect_to('/gene2phenotype');

}

sub validate_pwd_recovery {
  my $self = shift;
  my $code = $self->param('code');
  my $email = $self->session('email');
  $self->render(template => 'login/reset_password', email => $email, authcode => "$code");
}


sub account_info {
  my $self = shift;
  if ($self->session('logged_in')) {
    my $email = $self->session('email');
    my $registry = $self->app->defaults('registry');
    my $user_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'user');
    my $user = $user_adaptor->fetch_by_email($email);

    my $username = $user->username; 
    my $panel = $user->panel;

    $self->stash(email => $email, username => $username, panel => $panel);
    $self->render(template => 'login/account_info');
  } else {
    $self->feedback_message('LOGIN_FOR_ACCOUNT_INFO');
    return $self->redirect_to('/gene2phenotype');
  }
}

1;
