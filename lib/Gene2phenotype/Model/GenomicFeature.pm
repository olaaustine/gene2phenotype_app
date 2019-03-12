package Gene2phenotype::Model::GenomicFeature;
use Mojo::Base 'MojoX::Model';
use JSON;
use HTTP::Tiny;
use Data::Dumper;
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

  my $gf_attribs = {
    gene_symbol => $gene_symbol,
    mim => $mim,
    ensembl_stable_id => $ensembl_stable_id,
    synonyms => $synonyms,
  };

  my $genomic_feature_statistic_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureStatistic');
  my $genomic_feature_statistics = $genomic_feature_statistic_adaptor->fetch_all_by_GenomicFeature($gf);

  if (scalar @$genomic_feature_statistics) {
    my @statistics = ();
    foreach (@$genomic_feature_statistics) {
      my $clustering = ( $_->clustering) ? 'Mutatations are considered clustered.' : '';
      push @statistics, {
        'p-value' => $_->p_value,
        'dataset' => $_->dataset,
        'clustering' => $clustering,
      }
    }
    $gf_attribs->{statistics} = \@statistics;
  }
  return $gf_attribs;
 
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

sub _get_canonical_transcript_id {
  my $ensembl_gene_id = shift;
  my $ext = "/lookup/id/$ensembl_gene_id?expand=1";
  my $data = _fetch_data($ext);
  my @transcripts = @{$data->{'Transcript'}};
  my ($canonical_transcript) = grep {$_->{'is_canonical'}} @transcripts;
  my $transcript_id = $canonical_transcript->{'id'};
  return $transcript_id; 
}

sub fetch_variants_rest {
  my $self = shift;
  my $dbID = shift;
  my $registry = $self->app->defaults('registry');
  my $genomic_feature_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genomicfeature');
  my $gf = $genomic_feature_adaptor->fetch_by_dbID($dbID);
  my $gene_stable_id = $gf->ensembl_stable_id;

  my $canonical_transcript_id = _get_canonical_transcript_id($gene_stable_id); 

  my $ext = "/overlap/id/$canonical_transcript_id?feature=variation&variant_set=ClinVar";
  my $data = _fetch_data($ext);

  my @variants_for_VEP = ();

  my @variations_tmpl = ();
  my $counts = {};
  foreach my $variant (@$data) {
    my @clinical_significance = @{$variant->{clinical_significance}};
    if (grep {$_ eq 'pathogenic'} @clinical_significance) {
      my $id = $variant->{id};
      push @variants_for_VEP, $id;
    }
  }

  my @variant_sets = ();
  my @new_set = ();
  my $count = 0;
  foreach my $variant (@variants_for_VEP) {
    if ($count < 500) {
      push @new_set, $variant;
      $count++;
    } else {
      my @copy_set = @new_set;
      push @variant_sets, \@copy_set;
      @new_set = ();
      $count = 0;
      push @new_set, $variant;
    }
  }
  push @variant_sets, \@new_set;

  if (@variants_for_VEP) { 
    foreach my $subset (@variant_sets) {
      my $content = encode_json({ids => $subset});
      my $VEP_results = _fetch_data_post('/vep/human/id', $content);
      foreach my $VEP_result (@$VEP_results) {
        my $most_severe_consequence = $VEP_result->{'most_severe_consequence'}; 
        my @allele_string = split('/', $VEP_result->{allele_string});
        my $ref_allele = $allele_string[0]; 
        my $variant_name = $VEP_result->{id};
        my $seq_region_name = $VEP_result->{seq_region_name};
        my $start = $VEP_result->{start};
        my $end = $VEP_result->{end};
        foreach my $transcript_consequence (@{$VEP_result->{transcript_consequences}}) {
          my @consequence_terms = @{$transcript_consequence->{consequence_terms}};
          my $transcript_id = $transcript_consequence->{transcript_id};
          if ((grep {$_ eq $most_severe_consequence} @consequence_terms ) && ($transcript_id eq $canonical_transcript_id)) {
            my $variant_allele = $transcript_consequence->{variant_allele} || '-';
            my $polyphen_prediction = $transcript_consequence->{polyphen_prediction} || '-';
            my $sift_prediction = $transcript_consequence->{sift_prediction} || '-';
            my $amino_acid_change = $transcript_consequence->{amino_acids} || '-';
            $counts->{$most_severe_consequence}++;

            push @variations_tmpl, {
              location => "$seq_region_name:$start-$end",
              variant_name => $variant_name,
              variant_source => 'dbSNP',
              allele_string => "$ref_allele/$variant_allele",
              consequence => $most_severe_consequence,
              transcript_stable_id => $transcript_id,
              pep_allele_string => $amino_acid_change,
              polyphen_prediction => $polyphen_prediction,
              sift_prediction => $sift_prediction, 
            };
          }
        }
      }

      $count = 0;
    }
  }
  my @array = ();
  while (my ($consequence, $count) = each %$counts) {
    push @array, {'label' => $consequence, 'value' => $count, 'color' => $consequence_colors->{$consequence} || '#d0d6fe'};
  }
  my $encoded_counts = encode_json(\@array);
  return { 'tmpl' => \@variations_tmpl, 'counts' => $encoded_counts };

}

sub _fetch_data {
  my $ext = shift;
  my $http = HTTP::Tiny->new();

  my $server = 'http://grch37.rest.ensembl.org';
  my $response = $http->get($server.$ext, {
    headers => { 'Content-type' => 'application/json' }
  });

  my $hash = decode_json($response->{content});
#  local $Data::Dumper::Terse = 1;
#  local $Data::Dumper::Indent = 1;
#  print STDERR Dumper $hash;
#  print STDERR "\n";

  return $hash;
}

sub _fetch_data_post {
  
my $http = HTTP::Tiny->new();
  my $ext = shift;
  my $content = shift; 
  my $server = 'http://grch37.rest.ensembl.org';
  my $response = $http->request('POST', $server.$ext, {
    headers => { 
      'Content-type' => 'application/json',
      'Accept' => 'application/json'
    },
    content => $content
  });

  my $hash = decode_json($response->{content});
#  local $Data::Dumper::Terse = 1;
#  local $Data::Dumper::Indent = 1;
#  print STDERR Dumper $hash;
#  print STDERR "\n";

  return $hash;

}



1;
