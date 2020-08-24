package Gene2phenotype::Model::LgmPanelDisease;
use Mojo::Base 'MojoX::Model';

sub fetch_by_dbID {
  my $self = shift;
  my $dbID = shift;

  my $registry = $self->app->defaults('registry');
  my $lgm_panel_disease_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'LGMPanelDisease');
  my $lgm_panel_disease = $lgm_panel_disease_adaptor->fetch_by_dbID($dbID);

  my $disease = $lgm_panel_disease->get_Disease;
  my $disease_name = $disease->name;

  my $lgm_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'LocusGenotypeMechanism');
  my $lgms = $lgm_adaptor->fetch_all_by_Disease($disease); 

  my $allele_feature_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'AlleleFeature');
  my $gene_feature_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GeneFeature');

  my @locus_to_pmids = (); 
  foreach my $lgm (@{$lgms}) {
    my $genotype = $lgm->genotype;
    my $mechanism = $lgm->mechanism;
    my $publications = $lgm->get_all_LGMPublications;
    my @pmids = map {$_->get_Publication->pmid} @{$publications};
    my $locus_id = $lgm->locus_id;
    my $locus_type = $lgm->locus_type;
    if ($locus_type eq 'allele') {
      my $allele_feature = $allele_feature_adaptor->fetch_by_dbID($locus_id);
      push @locus_to_pmids, {
        locus_type => 'allele',
        genotype => $genotype,
        mechanism => $mechanism,
        hgvs_genomic => $allele_feature->hgvs_genomic,
        hgvs_protein => $allele_feature->name,
        pmids => \@pmids,
      } 
    } else {
      my $gene_feature = $gene_feature_adaptor->fetch_by_dbID($locus_id);
      push @locus_to_pmids, {
        locus_type => 'gene',
        genotype => $genotype,
        mechanism => $mechanism,
        gene_symbol => $gene_feature->gene_symbol,
        pmids => \@pmids,
      } 
    }
  }      
  return {
    locus_to_pmids => \@locus_to_pmids,
    disease_name => $disease_name
  }; 
}
1;
