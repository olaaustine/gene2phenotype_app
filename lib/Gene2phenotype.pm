package Gene2phenotype;
use Mojo::Base 'Mojolicious';
use Bio::EnsEMBL::Registry;
use Mojo::Home;


# This method will run once at server start
sub startup {
  my $self = shift;

  $self->plugin('CGI');
  $self->plugin('Model');

  $self->defaults(layout => 'base');
  $self->g2p_defaults;

  # Router
  my $r = $self->routes;


  $r->get('/gfd')->to('genomic_feature_disease#show');

  $r->get('/search')->to('search#results');


  $r->get('/cgi-bin/#script_name' => sub {
    my $c = shift;
    my $script_name = $c->stash('script_name');
    my $home =  $c->app->home;
    $c->cgi->run(script => "$home/cgi-bin/$script_name");
  });
  

  # get /gfd
  # get /gene
  # get disease
  # get downloads
  #  
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
}




1;
