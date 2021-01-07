=head1 LICENSE
 
See the NOTICE file distributed with this work for additional information
regarding copyright ownership.
 
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
=cut
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

sub _get_canonical_transcript_id {
  my $ensembl_gene_id = shift;
  my $ext = "/lookup/id/$ensembl_gene_id?expand=1";
  my $data = _fetch_data($ext);
  my @transcripts = @{$data->{'Transcript'}};
  my ($canonical_transcript) = grep {$_->{'is_canonical'}} @transcripts;
  my $transcript_id = $canonical_transcript->{'id'};
  return $transcript_id; 
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
