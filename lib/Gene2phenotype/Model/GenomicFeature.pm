package Gene2phenotype::Model::GenomicFeature;
use Mojo::Base 'MojoX::Model';
use JSON;

my $consequence_colors = {
  'intergenic_variant'                 => '#636363',
  'intron_variant'                     => '#02599c',
  'upstream_gene_variant'              => '#91a2b8',
  'downstream_gene_variant'            => '#91a2b8',
  '5_prime_UTR_variant'                => '#7ac5cd',
  '3_prime_UTR_variant'                => '#7ac5cd',
  'splice_region_variant'              => '#ff7f50',
  'splice_donor_variant'               => '#FF581A',
  'splice_acceptor_variant'            => '#FF581A',
  'frameshift_variant'                 => '#9400D3',
  'transcript_ablation'                => '#ff0000',
  'transcript_amplification'           => '#ff69b4',
  'inframe_insertion'                  => '#ff69b4',
  'inframe_deletion'                   => '#ff69b4',
  'synonymous_variant'                 => '#76ee00',
  'stop_retained_variant'              => '#76ee00',
  'missense_variant'                   => '#d8b600',
  'start_lost'                         => '#ffd700',
  'stop_gained'                        => '#ff0000',
  'stop_lost'                          => '#ff0000',
  'mature_mirna_variant'               => '#99FF00',
  'non_coding_transcript_exon_variant' => '#32cd32',
  'non_coding_transcript_variant'      => '#32cd32',
  'no_consequence'                     => '#68228b',
  'incomplete_terminal_codon_variant'  => '#ff00ff',
  'nmd_transcript_variant'             => '#ff4500',
  'hgmd_mutation'                      => '#8b4513',
  'coding_sequence_variant'            => '#99FF00',
  'failed'                             => '#cccccc',
  'tfbs_ablation'                      => '#a52a2a',
  'tfbs_amplification'                 => '#a52a2a',
  'tf_binding_site_variant'            => '#a52a2a',
  'regulatory_region_variant'          => '#a52a2a',
  'regulatory_region_ablation'         => '#a52a2a',
  'regulatory_region_amplification'    => '#a52a2a',
  'protein_altering_variant'           => '#FF0080',
  'NMD_transcript_variant'             => '#007fff',
};

sub fetch_by_dbID {
  my $self = shift;
  my $dbID = shift;
  my $registry = $self->app->defaults('registry');
  my $genomic_feature_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genomicfeature');
  my $gf = $genomic_feature_adaptor->fetch_by_dbID($dbID);
  my $gene_symbol = $gf->gene_symbol;
  my $mim = $gf->mim;
  my $ensembl_stable_id = $gf->ensembl_stable_id;
  my $synonyms = join(', ', @{$gf->get_all_synonyms});

  return {
    gene_symbol => $gene_symbol,
    mim => $mim,
    ensembl_stable_id => $ensembl_stable_id,
    synonyms => $synonyms,
  };
}

sub fetch_by_gene_symbol {
  my $self = shift;
  my $gene_symbol = shift;
  my $registry = $self->app->defaults('registry');
  my $genomic_feature_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genomicfeature');
  my $gf = $genomic_feature_adaptor->fetch_by_gene_symbol($gene_symbol);
  return $gf;
}

sub fetch_variants {
  my $self = shift;
  my $dbID = shift;
  my $registry = $self->app->defaults('registry');
  my $genomic_feature_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genomicfeature');
  my $gf = $genomic_feature_adaptor->fetch_by_dbID($dbID);
  my $ensembl_variation_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'ensemblvariation');

  my $ensembl_variations = $ensembl_variation_adaptor->fetch_all_by_GenomicFeature($gf);

  my @variations_tmpl = ();
  my $counts = {};
  foreach my $variation (@$ensembl_variations) {
    my $assembly = 'GRCh38';
    my $seq_region_name = $variation->seq_region;
    my $seq_region_start = $variation->seq_region_start;
    my $seq_region_end = $variation->seq_region_end;

    my $coords = "$seq_region_start-$seq_region_end";

    if ($seq_region_start == $seq_region_end) {
      $coords = $seq_region_start;
    }

    my $source = $variation->source;

    my $allele_string = $variation->allele_string;

    my $consequence = $variation->consequence;
    $counts->{$consequence}++;

    my $variant_name = $variation->name;

    my $transcript_stable_id = $variation->feature_stable_id;
    # alternate allele
    my $polyphen_prediction = $variation->polyphen_prediction || '-';
    my $sift_prediction = $variation->sift_prediction || '-';
    my $pep_allele_string = $variation->amino_acid_string || '-';
    push @variations_tmpl, {
      location => "$seq_region_name:$coords",
      variant_name => $variant_name,
      variant_source => $source,
      allele_string => $allele_string,
      consequence => $consequence,
      transcript_stable_id => $transcript_stable_id,
      pep_allele_string => $pep_allele_string,
      polyphen_prediction => $polyphen_prediction,
      sift_prediction => $sift_prediction, 
    };
  }
  my @array = ();
  while (my ($consequence, $count) = each %$counts) {
    push @array, {'label' => $consequence, 'value' => $count, 'color' => $consequence_colors->{$consequence} || '#d0d6fe'};
  }
  my $encoded_counts = encode_json(\@array);
  return { 'tmpl' => \@variations_tmpl, 'counts' => $encoded_counts };
}

1;
