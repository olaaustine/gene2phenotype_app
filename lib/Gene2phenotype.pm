package Gene2phenotype;
use Mojo::Base 'Mojolicious';
use Mojo::Home;
use Mojo::Log;
use HTTP::Tiny;
use Apache::Htpasswd;
use File::Path;
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::G2P::Utils::Downloads qw(download_data);

use JSON;
use Data::Dumper;

# This method will run once at server start
sub startup {
  my $self = shift;

# $self->secrets
# $self->app->sessions->cookie_name('moblo');
  $self->sessions->default_expiration(3600);

  my $config = $self->plugin('Config' => {file => $self->app->home .'/etc/gene2phenotype.conf'});
  my $password_file = $config->{password_file};
  my $downloads_dir = $config->{downloads_dir};
  my $registry_file = $config->{registry};
  my $public_folder = $config->{public_folder};
  my $passphrase = $config->{passphrase};
  my $log_dir = $config->{log_dir};
  my $log = Mojo::Log->new(path => "$log_dir/log_file"); 

  $self->app->secrets([$passphrase]);

#  my $static = $self->app->static();
#  push @{$static->paths}, $public_folder;

  $self->plugin('CGI' => {
    before => sub {
      my $c = shift;
      $c->req->url->query->param(registry_file => $registry_file);
    },
  });
  $self->plugin('Model');
  $self->plugin('RenderFile');
  $self->plugin(mail => {
    from => 'anja@ebi.ac.uk',
    type => 'text/html',
  });

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
  $self->g2p_defaults($registry_file);

  my $r = $self->routes;

  $self->hook(before_dispatch => sub {
    my $c = shift;
    $c->stash(logged_in => $c->session('logged_in'));
    $c->stash(panels => $c->session('panels'));
    my $registry = $c->app->defaults('registry');
    my $user_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'user');
    my $panel_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'panel');
    my $attribute_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'attribute');

    my @panels = map { $_->name } @{$panel_adaptor->fetch_all_visible_Panels};
    my @authorised_panels = (); # all visible and only visible by curator
    my $logged_in = $c->session('logged_in');
    if ($logged_in) {
      my $email = $c->session('email');
      my $user = $user_adaptor->fetch_by_email($email);
      @authorised_panels = split(',', $user->panel);
      foreach my $panel (@authorised_panels) {
        if (!grep{$_ eq $panel} @panels) {
          push @panels, $panel;
        }
      }
    }
    if (scalar @panels > 1) {
      push @panels, 'ALL';
    }

    my @panel_imgs = ();
    my $attribs = $attribute_adaptor->get_attribs_by_type_value('g2p_panel');
    foreach my $value (sort keys %$attribs) {
      if (grep {$value eq $_} @panels) {
        push @panel_imgs, [$value => $value,];
      }
    }
    $c->stash(panel_imgs => \@panel_imgs);
    $c->stash(authorised_panels => \@panels);
  });


# redirect from old page:
  $r->get('/gene2phenotype/redirect')->to(template => 'redirect');

  $r->get('/gene2phenotype/gene2phenotype-webcode/*' => sub {
    my $c = shift;
    return $c->redirect_to('/gene2phenotype/redirect');
  });

  $r->get('/gene2phenotype')->to('home#show');
  $r->get('/gene2phenotype/disclaimer')->to(template => 'disclaimer');
  $r->get('/gene2phenotype/documentation')->to(template => 'documentation');
  $r->get('/gene2phenotype/help')->to(template => 'help');
  $r->get('/gene2phenotype/documentation/enter_new_gene_disease_pair' => sub {
    my $c = shift;
    if ($c->session('logged_in')) {
      $c->render(template => 'enter_new_gene_disease_pair');
    } else {
      $c->redirect_to('/gene2phenotype');
    }
  });

  $r->get('/gene2phenotype/account')->to('login#account_info');
  $r->post('/gene2phenotype/account/update' => sub {
    my $c = shift;
    my $auth = new Apache::Htpasswd({ passwdFile => $password_file, ReadOnly => 0, UseMD5 => 1,});

    my $email = $c->param('email');
    my $current_pwd = $c->param('current_password');
    my $new_pwd = $c->param('new_password');
    my $retyped_pwd = $c->param('retyped_password');

    if (!$self->authenticate($email, $current_pwd)) { 
      $c->flash({message => 'Your current password is incorrect', alert_class => 'alert-danger'});
      return $c->redirect_to('/gene2phenotype/account');
    }

    if ($new_pwd ne $retyped_pwd) {
      $c->flash({message => 'Passwords don\'t match. Please ensure retyped password matches your new password.', alert_class => 'alert-danger'});
      return $c->redirect_to('/gene2phenotype/account');
    }
    my $success = $auth->htpasswd($email, $new_pwd, {'overwrite' => 1});        
    if ($success) {
      $c->flash({message => 'Successfully updated password', alert_class => 'alert-success'});
      return $c->redirect_to('/gene2phenotype/account');
    } else {
      $c->flash(message => 'Error occurred while resetting your password. Please contact g2p-help@ebi.ac.uk', alert_class => 'alert-danger');
      return $c->redirect_to('/gene2phenotype/account');
    }
  });
  $r->get('/gene2phenotype/login')->to(template => 'login/login');
  $r->get('/gene2phenotype/login/recovery')->to(template => 'login/recovery');
  $r->post('/gene2phenotype/login/recovery/mail')->to('login#send_recover_pwd_mail');
  $r->get('/gene2phenotype/login/recovery/reset')->to('login#validate_pwd_recovery');
  $r->post('/gene2phenotype/login/recovery/update' => sub {
    my $c = shift;
    my $auth = new Apache::Htpasswd({ passwdFile => $password_file, ReadOnly => 0, UseMD5 => 1,});
    my $email = $c->param('email');
    my $new_pwd = $c->param('new_password');
    my $retyped_pwd = $c->param('retyped_password');
    my $authcode = $c->param('authcode');
    my $saved_authcode = $c->session('code');
    my $saved_email = $c->session('email');
    if ($authcode eq $saved_authcode) {
      if ($new_pwd eq $retyped_pwd) {
        my $success = $auth->htpasswd($email, $new_pwd, {'overwrite' => 1});        
        if ($success) {
          $c->session(logged_in => 1);
          $c->stash(logged_in => 1);
          $c->flash({message => 'Successfully updated password', alert_class => 'alert-success'});
          return $c->redirect_to('/gene2phenotype');
        } else {
          $c->flash(message => 'Error occurred while resetting your password. Please contact g2p-help@ebi.ac.uk', alert_class => 'alert-danger');
          return $c->redirect_to('/gene2phenotype');
        }
      }
    }
    $c->flash(message => 'Error occurred while resetting your password. Please contact g2p-help@ebi.ac.uk', alert_class => 'alert-danger');
    return $c->redirect_to('/gene2phenotype');
  });

  $r->get('/gene2phenotype/reset')->to(template => 'login', change_pwd => 1);
  $r->get('/gene2phenotype/logout')->to('login#on_user_logout');
  
  $r->post('/gene2phenotype/login')->to('login#on_user_login');
  $r->post('/gene2phenotype/reset')->to('login#reset_pwd');

  $r->get('/gene2phenotype/gfd')->to('genomic_feature_disease#show');

# :action=add, delete, update, add_comment, delete_comment
  $r->get('/gene2phenotype/gfd/authorised/update')->to('genomic_feature_disease#update_visibility');
  $r->get('/gene2phenotype/gfd/category/update')->to('genomic_feature_disease#update');
  $r->get('/gene2phenotype/gfd/organ/update')->to('genomic_feature_disease#update_organ_list');
  $r->get('/gene2phenotype/gfd/disease/update')->to('genomic_feature_disease#update_disease');
  $r->get('/gene2phenotype/gfd/attributes/:action')->to(controller => 'genomic_feature_disease_attributes');
  $r->get('/gene2phenotype/gfd/phenotype/:action')->to(controller => 'genomic_feature_disease_phenotype');
  $r->get('/gene2phenotype/gfd/publication/:action')->to(controller => 'genomic_feature_disease_publication');
  $r->get('/gene2phenotype/gfd/comment/:action')->to(controller => 'genomic_feature_disease_comment');
  $r->get('/gene2phenotype/gfd/create')->to('genomic_feature_disease#create');
  $r->get('/gene2phenotype/gfd/add')->to('genomic_feature_disease#add');
  $r->get('/gene2phenotype/gfd/delete')->to('genomic_feature_disease#delete');
  $r->get('/gene2phenotype/gfd/duplicate')->to('genomic_feature_disease#duplicate');

  $r->get('/gene2phenotype/gene')->to('genomic_feature#show');
  $r->get('/gene2phenotype/disease')->to('disease#show');
  $r->get('/gene2phenotype/disease/update/')->to('disease#update');

  $r->get('/gene2phenotype/search')->to('search#results');

  $r->get('/gene2phenotype/ajax/publication')->to('publication#get_description');

  $r->get('/gene2phenotype/ajax/gene_location' => sub {
    my $c = shift;
    my $gene_symbol = $c->param('gene_symbol');    
    my $http = HTTP::Tiny->new();
    my $request = "http://rest.ensembl.org/lookup/symbol/homo_sapiens/$gene_symbol";
    my $response = $http->get($request, {
      headers => { 'Content-type' => 'application/json' }
    });
    if (!$response->{success}) {
      $c->render(json => {});
      return;  
    }
    my $hash = decode_json($response->{content});
    my $assembly_name = $hash->{assembly_name};
    my $seq_region_name = $hash->{seq_region_name};
    my $start = $hash->{start};
    my $end = $hash->{end};
    my $strand = $hash->{strand};
    if ($strand == 1) {
      $strand = 'forward strand';
    } else {
      $strand = 'reverse strand';
    }
    my $location = "$assembly_name $seq_region_name $start-$end $strand";
    $c->render(json => {gene_location => $location});  
  }); 

  $r->get('/gene2phenotype/ajax/populate_onotology_tree' => sub {
    my $c = shift;
    my $type = 'search';
    if ($c->param('type')) {
      $type = $c->param('type');
    }

    my ($id, $GFD_id, $phenotype_name);

    if ($type eq 'search') {
      $phenotype_name = $c->param('str');
    }

    if ($type eq 'expand') {
      $id = $c->param('id');
      $GFD_id = $c->param('GFD_id');
    }

    my $registry = $c->app->defaults('registry');

    my @phenotype_ids = ();

    my $ontology = $registry->get_adaptor( 'Multi', 'Ontology', 'OntologyTerm' );
    my $ontology_name = 'HPO';
    my @terms = ();
    my @query_output = ();

    if ($type eq 'expand') {
      my $GFD_adaptor = $registry->get_adaptor('homo_sapiens', 'gene2phenotype', 'genomicfeaturedisease');
      my $GFD = $GFD_adaptor->fetch_by_dbID($GFD_id);
      my $GFDPhenotypes = $GFD->get_all_GFDPhenotypes;
      foreach my $GFDPhenotype (@$GFDPhenotypes) {
        push @phenotype_ids, $GFDPhenotype->{phenotype_id};
      }
      if ("$id" eq '#') {
        @terms = @{$ontology->fetch_all_roots($ontology_name)};
      } else {
        my $parent_term = $ontology->fetch_by_dbID($id);
        @terms = @{$ontology->fetch_all_by_parent_term($parent_term)};
      }
      foreach my $term (@terms) {
        my @children = @{$term->children};
        push @query_output, {
          id => $term->dbID,
          text => $term->name,
          children => (scalar @children > 0) ? \1 : \0,
          state => {selected => (grep {$_ == $term->dbID} @phenotype_ids) ? \1 : \0},
        };
      }
    }

    if ($type eq 'search') {
      my $terms = $ontology->fetch_all_by_name($phenotype_name);
      foreach my $term (@$terms) {
        my $is_root = $term->is_root;
        if ($is_root) {
          push @query_output, $term->dbID;
        } else {
          while (!$is_root) {
            my @parents = @{$term->parents};
            my $parent = $parents[0];
            push @query_output, $term->dbID;
            $term = $parents[0];
            $is_root = $term->is_root;
          }
          push @query_output, $term->dbID;
        }
      }
    }
    $c->render(json => \@query_output);  
  });

  $r->get('/gene2phenotype/ajax/autocomplete' => sub {
    my $c = shift;
    my $term = $c->param('term');
    my $type = $c->param('query_type');

    my $dbh = $c->app->defaults('dbh');

    my $query = '';

    if ($type eq 'query_phenotype_name') {
      $query = 'select name AS value FROM phenotype where name like ? AND source="HP"';
    }
    elsif ($type eq 'query_gene_name') {
      $query = 'select gene_symbol AS value FROM genomic_feature where gene_symbol like ?';
    }
    elsif ($type eq 'query_disease_name') {
      $query = 'select name AS value FROM disease where name like ?';
    }
    else { # query
      $query = 'select search_term AS value FROM search where search_term like ?';
    }

    my $sth = $dbh->prepare($query);
    $sth->execute('%' . $term . '%') or die $dbh->errstr;
    my @query_output = ();
    while ( my $row = $sth->fetchrow_hashref ) {
      push @query_output, $row;
    }
    $c->render(json => \@query_output);  
  });

  $r->get('/gene2phenotype/ajax/phenotype/add')->to('genomic_feature_disease_phenotype#add');
  $r->get('/gene2phenotype/ajax/phenotype/delete_from_tree')->to('genomic_feature_disease_phenotype#delete_from_tree');

  $r->get('/cgi-bin/#script_name/*path_info' => {path_info => ''}, sub {
    my $c = shift;
    my $script_name = $c->stash('script_name');
    my $home =  $c->app->home;
    $c->cgi->run( script => "$home/cgi-bin/$script_name");
  });
  $r->get('/gene2phenotype/downloads')->to(template => 'downloads');
  $r->get('/gene2phenotype/about')->to(template => 'about');
  $r->get('/gene2phenotype/g2p_vep_plugin')->to(template => 'g2p_vep_plugin');
  $r->get('/gene2phenotype/create_panel')->to(template => 'create_panel');
  $r->get('/gene2phenotype/terminology')->to(template => 'terminology');

  $r->get('/gene2phenotype/downloads/#file_name' => sub {
    my $c = shift;
    my $host   = $c->req->url->to_abs->host;
    $log->debug("download file $host");
    my $file_name = $c->stash('file_name');
    my $is_logged_in = $c->session('logged_in');
    my $user_panels = $c->session('panels');
    my $panel_name = $file_name;
    $panel_name =~ s/G2P\.csv\.gz//;
    $file_name =~ s/\.csv\.gz//;
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
    $year += 1900;
    $mon++;
    my $stamp = join('_', ($mday, $mon, $hour, $min, $sec));
    my $file_time_stamp = join('_', $mday, $mon, $year);
    $file_name .= "_$file_time_stamp.csv";
    my $tmp_dir = "$downloads_dir/$stamp";
    mkpath($tmp_dir);
    $log->debug("download file $host $panel_name $year $mon $mday");
    download_data($tmp_dir, $file_name, $registry_file, $is_logged_in, $user_panels, $panel_name);
    $c->render_file('filepath' => "$tmp_dir/$file_name.gz", 'filename' => "$file_name.gz", 'format' => 'zip', 'cleanup' => 1);
    rmtree($tmp_dir);
  });

  $r->get('/gene2phenotype/curator/no_publication')->to('curator#no_publication');
  $r->get('/gene2phenotype/curator/restricted_entries')->to('curator#restricted');

}

sub g2p_defaults {
  my $self = shift;
  my $registry_file = shift; 
  my $registry = 'Bio::EnsEMBL::Registry';

  $registry->load_all($registry_file);
  my $DBAdaptor = $registry->get_DBAdaptor('human', 'gene2phenotype');
  my $dbh = $DBAdaptor->dbc->db_handle;

  $self->defaults(panel_imgs => []);
  $self->defaults(registry => $registry);
  $self->defaults(dbh => $dbh);
  $self->defaults(panel => 'ALL');
  $self->defaults(panels => ['ALL']);
  $self->defaults(logged_in => 0);
  $self->defaults(alert_class => '');
}

1;
