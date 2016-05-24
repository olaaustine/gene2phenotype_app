package Gene2phenotype;
use Mojo::Base 'Mojolicious';
use Bio::EnsEMBL::Registry;
use Mojo::Home;
use Apache::Htpasswd;
use File::Path qw(make_path remove_tree);

# This method will run once at server start
require "/Users/anjathormann/Documents/develop/gene2phenotype_app/cgi-bin/downloads.pl";

sub startup {
  my $self = shift;

# $self->secrets
# $self->app->sessions->cookie_name('moblo');
  $self->app->sessions->default_expiration('36000');


  $self->plugin('CGI');
  $self->plugin('Model');
  $self->plugin('RenderFile');

  my $password_file = '/Users/anjathormann/Sites/gene2phenotype_users';
  my $downloads_dir = '/Users/anjathormann/Documents/develop/gene2phenotype_app/downloads/';

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

# before_dispatch
  $self->hook(after_dispatch => sub {
    my $c = shift;
    $self->defaults(logged_in => $c->session->{logged_in});
  });

  $r->get('/')->to(template => 'home');


  $r->get('/account')->to(template => 'login', account_info => 1);
  $r->get('/login')->to(template => 'login', show_login => 1);
  $r->get('/recover')->to(template => 'login', recover_pwd => 1);
  $r->get('/reset')->to(template => 'login', change_pwd => 1);
  $r->get('/logout')->to('login#on_user_logout');
  
  $r->post('/login')->to('login#on_user_login');
  $r->post('/recover')->to(template => 'login', recover_pwd => 1);
  $r->post('/reset')->to('login#reset_pwd');

  $r->get('/downloads')->to(template => 'downloads');

  $r->get('/gfd')->to('genomic_feature_disease#show');

# :action=add, delete, update, add_comment, delete_comment
  $r->get('/gfd/category/update')->to(controller => 'genomic_feature_disease#update');
  $r->get('/gfd/attributes/:action')->to(controller => 'genomic_feature_disease_attributes');
  $r->get('/gfd/phenotype/:action')->to(controller => 'genomic_feature_disease_phenotype');
  $r->get('/gfd/publication/:action')->to(controller => 'genomic_feature_disease_publication');

  $r->get('/search')->to('search#results');
  $r->get('/cgi-bin/#script_name' => sub {
    my $c = shift;
    my $script_name = $c->stash('script_name');
    my $home =  $c->app->home;
    $c->cgi->run(script => "$home/cgi-bin/$script_name");
  });

  $r->get('/downloads/*' => sub {
    my $c = shift;
    my $panel = 'ALL';
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
    my $stamp = join('_', ($mday, $mon, $hour, $min, $sec));
    my $tmp_dir = "$downloads_dir/$stamp";
    make_path($tmp_dir);
    my $file = download_data($tmp_dir, $panel);
    $c->render_file('filepath' => "$tmp_dir/$file");
    unlink "$tmp_dir/$file";
    remove_tree($tmp_dir);
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
  $self->defaults(show_login => 0);
  $self->defaults(recover_pwd => 0);
  $self->defaults(change_pwd => 0);
  $self->defaults(account_info => 0);
  $self->defaults(logged_in => 0);

}



1;
