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

sub fetch_all_lgms_by_gene_symbol {
  my $self = shift;
  my $search_term = shift;
  my $search_panels = shift;
  my $is_authorised = shift;
  my $registry = $self->app->defaults('registry');
  my $disease_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'disease');

  my $gene_feature_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genefeature');
  my $lgm_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'LocusGenotypeMechanism');

  my $gene_feature = $gene_feature_adaptor->fetch_by_gene_symbol($search_term);
  if (!$gene_feature) {
    return {};
  }
  my $lgms = $lgm_adaptor->fetch_all_by_GeneFeature($gene_feature);

  my $lgm_results = $self->_get_lgm_results($lgms);
  my $lgm_results_as_table = $self->_get_lgm_results_as_table($lgms);
  my @gene_names = ();
  push @gene_names, {lgm_results => $lgm_results, gene_name => $search_term, lgm_results_as_table => $lgm_results_as_table};

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
    my $actions = $gfd->get_all_GenomicFeatureDiseaseActions;

    foreach my $action (@$actions) {
      my $allelic_requirement = $action->allelic_requirement || 'not specified';
      my $mutation_consequence = $action->mutation_consequence || 'not specified';  
      push @gfd_results, {gene_symbol => $gene_symbol, disease_name => $disease_name, genotype => $allelic_requirement, mechanism =>  $mutation_consequence, search_type => 'gfd', dbID => $dbID, GFD_panel => $panel};
    }
  }
  return \@gfd_results;
}

sub _get_lgm_results {
  my $self = shift;
  my $lgms = shift;
  my @lgm_results = ();

  foreach my $lgm (@{$lgms}) {
    my $genotype = $lgm->genotype;
    my $mechanism = $lgm->mechanism;
    my $dbID = $lgm->dbID;
    my $locus_type = $lgm->locus_type(); 
    my $locus_name = '';
    my @panels = ();
    my $lgm_panels = $lgm->get_all_LGMPanels;
    foreach my $lgm_panel (@{$lgm_panels}) {
      my $panel_name = $lgm_panel->get_Panel->name;
      my $disease_name = $lgm_panel->get_disease_name;
      push @panels, {panel => $panel_name, disease_name => $disease_name};
    }
    if ($locus_type eq 'allele') {
      my $allele_feature = $lgm->get_AlleleFeature;  
      $locus_name = $allele_feature->name;
      push @lgm_results, {locus_type => 'allele', locus_name => $locus_name,  genotype => $genotype, mechanism => $mechanism, panels=> \@panels};
    } elsif ($locus_type eq 'gene') {
      my $gene_feature = $lgm->get_GeneFeature;
      #push @lgm_results, {locus_name => $locus_name, genotype => $genotype, mechanism =>  $mechanism};
    } 
  } 
  return \@lgm_results;
}

sub _get_lgm_results_as_table {
  my $self = shift;
  my $lgms = shift;
  my $results = {};
  foreach my $lgm (@{$lgms}) {
    my $genotype = $lgm->genotype;
    my $mechanism = $lgm->mechanism;
    my $dbID = $lgm->dbID;
    my $locus_type = $lgm->locus_type(); 
    my @panels = ();
    my $lgm_panels = $lgm->get_all_LGMPanels;
    $results->{"$locus_type\_$genotype\_$mechanism"}->{genotype} = $genotype;
    $results->{"$locus_type\_$genotype\_$mechanism"}->{mechanism} = $mechanism;
    foreach my $lgm_panel (@{$lgm_panels}) {
      my $panel_name = $lgm_panel->get_Panel->name;
      my $lgm_panel_diseases = $lgm_panel->get_all_LGMPanelDiseases;
      foreach my $lgm_panel_disease (@{$lgm_panel_diseases}) {
        my $disease_name = $lgm_panel_disease->get_Disease->name;
        my $lgm_panel_disease_id = $lgm_panel_disease->dbID;
        $results->{"$locus_type\_$genotype\_$mechanism"}->{disease}->{$disease_name}->{dbID} = $lgm_panel_disease_id;
        $results->{"$locus_type\_$genotype\_$mechanism"}->{disease}->{$disease_name}->{panel}->{$panel_name} = 1;
        if ($locus_type eq 'allele') {
          my $allele_feature = $lgm->get_AlleleFeature;  
          my $hgvs_genomic = $allele_feature->hgvs_genomic;
          my $locus_name = $allele_feature->name;
          my $allele_feature_id = $allele_feature->dbID;
          $results->{"$locus_type\_$genotype\_$mechanism"}->{disease}->{$disease_name}->{allele}->{"$hgvs_genomic($locus_name)"} = $dbID;
        } elsif ($locus_type eq 'gene') {
          my $gene_feature = $lgm->get_GeneFeature; 
          my $locus_name = $gene_feature->gene_symbol;
          $results->{"$locus_type\_$genotype\_$mechanism"}->{disease}->{$disease_name}->{gene}->{$locus_name} = $dbID;
        } 
      }
    }
  }
  return $results;
}

1;
