package Gene2phenotype;
use Mojo::Base 'Mojolicious';
use Bio::EnsEMBL::Registry;
use Mojo::Home;
use Apache::Htpasswd;

# This method will run once at server start
sub startup {
  my $self = shift;

# $self->secrets
# $self->app->sessions->cookie_name('moblo');
# $self->app->sessions->default_expiration('600');


  $self->plugin('CGI');
  $self->plugin('Model');

  my $password_file = '/Users/anjathormann/Sites/gene2phenotype_users';

  $self->plugin('authentication' => {
    'load_user' => sub {
      my ($self, $uid) = @_;
      return $uid;
    },
    'validate_user' => sub {
      my ($self, $user, $pw) = @_;
      my $auth = new Apache::Htpasswd({ passwdFile => $password_file, ReadOnly => 1, UseMD5 => 1,});
      return $auth->htCheckPassword($user, $pw);
    },
  });

  $self->defaults(layout => 'base');
  $self->g2p_defaults;

  # Router
  my $r = $self->routes;

  my $authorized = $r->under('/admin')->to('Login#is_logged_in');
  $authorized->get('/')->name('restricted_area')->to(text => 'Session');


  $r->get('/logout')->name('do_logout')->to(cb => sub {
    my $self = shift;
    $self->session(expires => 1);
    $self->redirect_to('/search');
 });

  $r->get('/' => sub {
    my $c = shift;
    $c->render(template => 'home');
  });

  $r->get('/login')->to('login#on_user_login');

  $r->get('/gfd')->to('genomic_feature_disease#show');

  $r->get('/search')->to('search#results');

  $r->get('/cgi-bin/#script_name' => sub {
    my $c = shift;
    my $script_name = $c->stash('script_name');
    my $home =  $c->app->home;
    $c->cgi->run(script => "$home/cgi-bin/$script_name");
  });
  
}


sub g2p_defaults {
  my $self = shift;
  my $registry = 'Bio::EnsEMBL::Registry';

  $registry->load_all('/Users/anjathormann/Documents/G2P/scripts/ensembl.registry');
  my @panel_imgs = ();
  my $attribute_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'attribute');
  my $attribs = $attribute_adaptor->get_attribs_by_type_value('g2p_panel');
  foreach my $value (sort keys %$attribs) {
    push @panel_imgs,[
      $value => $value,
    ];
  }
  $self->defaults(panel_imgs => \@panel_imgs);
  $self->defaults(registry => $registry);
  $self->defaults(panel => 'ALL');

  my $logged_in = $self->session('logged_in');
  $logged_in = 1;
  $self->defaults(logged_in => $logged_in);

}



1;
