package Gene2phenotype::Model::Search;
use Mojo::Base 'MojoX::Model';

sub identify_search_type {
  my $self = shift;
  my $search_term = shift;
  my $registry = $self->app->defaults('registry');

  my $gf_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genomicfeature'); 

  if ($gf_adaptor->fetch_by_gene_symbol($search_term) || $gf_adaptor->fetch_by_synonym($search_term)) {
    return 'gene_symbol';
  }
  my $disease_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'disease');
  if ($disease_adaptor->fetch_by_name($search_term)) {
    return 'disease_name';
  }
  my $diseases = $disease_adaptor->fetch_all_by_substring($search_term);
  my $genomic_features = $gf_adaptor->fetch_all_by_substring($search_term);
  if (@$diseases || @$genomic_features) {
    return 'contains_search_term';
  }

  return 'no_entry_in_db';
}

sub fetch_all_by_substring {
  my $self = shift;
  my $search_term = shift; 
  my $search_panels = shift;
  my $is_authorised = shift; 

  my $registry = $self->app->defaults('registry');
  my $disease_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'disease');
  my $gfd_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genomicfeaturedisease'); 
  my $gf_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genomicfeature'); 

  my @disease_names = ();
  my $diseases = $disease_adaptor->fetch_all_by_substring($search_term);

  foreach my $disease ( sort { $a->name cmp $b->name } @$diseases) {
    my $disease_name = $disease->name;
    my $dbID = $disease->dbID;
    $disease_name =~ s/$search_term/<b>$search_term<\/b>/gi;
    my $gfds = $gfd_adaptor->fetch_all_by_Disease_panels($disease, $search_panels);
    @$gfds = sort { ( $a->panel cmp $b->panel ) || ( $a->get_GenomicFeature->gene_symbol cmp $b->get_GenomicFeature->gene_symbol ) } @$gfds;
    my $gfd_results = $self->_get_gfd_results($gfds, $is_authorised);
    push @disease_names, {display_disease_name => $disease_name, gfd_results => $gfd_results, search_type => 'disease', dbID => $dbID};

  }
  my @gene_names = ();
  my $genes = $gf_adaptor->fetch_all_by_substring($search_term);
  foreach my $gene ( sort { $a->gene_symbol cmp $b->gene_symbol } @$genes) {
    my $gene_symbol = $gene->gene_symbol;
    my $dbID = $gene->dbID;
    $gene_symbol =~ s/$search_term/<b>$search_term<\/b>/gi;
    my $gfds = $gfd_adaptor->fetch_all_by_GenomicFeature_panels($gene, $search_panels);
    @$gfds = sort { ( $a->panel cmp $b->panel ) || ( $a->get_Disease->name cmp $b->get_Disease->name ) } @$gfds;
    my $gfd_results = $self->_get_gfd_results($gfds, $is_authorised);
    push @gene_names, {gene_symbol => $gene_symbol, gfd_results => $gfd_results, search_type => 'gene_symbol', dbID => $dbID};
  }

  my $results = {};
  
  if (@disease_names) {
    $results->{'disease_names'} = \@disease_names;
  } 
  
  if (@gene_names) {
    $results->{'gene_names'} = \@gene_names;
  } 

  return $results;
}

sub fetch_all_by_gene_symbol {
  my $self = shift;
  my $search_term = shift;
  my $search_panels = shift;
  my $is_authorised = shift;
  my $registry = $self->app->defaults('registry');
  my $disease_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'disease');
  my $gfd_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genomicfeaturedisease'); 
  my $gf_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genomicfeature'); 
 
  my $gene = $gf_adaptor->fetch_by_gene_symbol($search_term); 
  if (!$gene) {
    $gene = $gf_adaptor->fetch_by_synonym($search_term);
  }

  my @gene_names = ();
  my $gene_symbol = $gene->gene_symbol;
  my $dbID = $gene->dbID;

  $gene_symbol =~ s/$search_term/<b>$search_term<\/b>/gi;
  my $gfds = $gfd_adaptor->fetch_all_by_GenomicFeature_panels($gene, $search_panels);
  @$gfds = sort { ( $a->panel cmp $b->panel ) || ( $a->get_Disease->name cmp $b->get_Disease->name ) } @$gfds;
  my $gfd_results = $self->_get_gfd_results($gfds, $is_authorised);
  push @gene_names, {gene_symbol => $gene_symbol, gfd_results => $gfd_results, search_type => 'gene_symbol', dbID => $dbID};

  return {'gene_names' => \@gene_names};
}

sub fetch_all_by_disease_name {
  my $self = shift;
  my $search_term = shift;
  my $search_panels = shift;
  my $is_authorised = shift;
  my $registry = $self->app->defaults('registry');
  my $disease_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'disease');
  my $gfd_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genomicfeaturedisease'); 

  my @disease_names = ();
  my $disease = $disease_adaptor->fetch_by_name($search_term);

  my $disease_name = $disease->name;
  my $dbID = $disease->dbID;
  $disease_name =~ s/$search_term/<b>$search_term<\/b>/gi;
  my $gfds = $gfd_adaptor->fetch_all_by_Disease_panels($disease, $search_panels);
  @$gfds = sort { ( $a->panel cmp $b->panel ) || ( $a->get_GenomicFeature->gene_symbol cmp $b->get_GenomicFeature->gene_symbol ) } @$gfds;
  my $gfd_results = $self->_get_gfd_results($gfds, $is_authorised);
  push @disease_names, {display_disease_name => $disease_name, gfd_results => $gfd_results, search_type => 'disease', dbID => $dbID};

  return {'disease_names' => \@disease_names};
}

sub _get_gfd_results {
  my $self = shift;
  my $gfds = shift;
  my $is_authorised = shift;
  my @gfd_results = ();
  foreach my $gfd (@$gfds) {
    if (!$gfd->is_visible) {
      next if (!$is_authorised);
    }
    my $genomic_feature = $gfd->get_GenomicFeature;
    my $gene_symbol = $genomic_feature->gene_symbol;
    my $disease = $gfd->get_Disease;
    my $disease_name = $disease->name;
    my $dbID = $gfd->dbID;
    my $panel = $gfd->panel;
    push @gfd_results, {gene_symbol => $gene_symbol, disease_name => $disease_name, search_type => 'gfd', dbID => $dbID, GFD_panel => $panel};
  }
  return \@gfd_results;
}

1;
