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
  my @gfd_results = ();
  foreach my $disease ( sort { $a->name cmp $b->name } @$diseases) {
    my $gfds = $gfd_adaptor->fetch_all_by_Disease_panels($disease, $search_panels, $is_authorised);
    push @gfd_results, @{$self->_get_gfd_results($gfds)};

  }
  my $genes = $gf_adaptor->fetch_all_by_substring($search_term);
  foreach my $gene ( sort { $a->gene_symbol cmp $b->gene_symbol } @$genes) {
    my $gfds = $gfd_adaptor->fetch_all_by_GenomicFeature_panels($gene, $search_panels, $is_authorised);
    foreach my $gfd_result (@{$self->_get_gfd_results($gfds)}) {
      if (! grep {$gfd_result->{dbID} eq $_->{dbID}} @gfd_results) {
        push @gfd_results, $gfd_result;
      }
    }
  }
  return {gfd_results => \@gfd_results};

}

sub fetch_all_by_gene_symbol {
  my $self = shift;
  my $search_term = shift;
  my $search_panels = shift;
  my $is_authorised = shift;

  my $registry = $self->app->defaults('registry');
  my $gfd_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genomicfeaturedisease'); 
  my $gf_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genomicfeature'); 
 
  my $gene = $gf_adaptor->fetch_by_gene_symbol($search_term); 
  if (!$gene) {
    $gene = $gf_adaptor->fetch_by_synonym($search_term);
  }

  my $gfds = $gfd_adaptor->fetch_all_by_GenomicFeature_panels($gene, $search_panels, $is_authorised);
  my $gfd_results = $self->_get_gfd_results($gfds);
  return {gfd_results => $gfd_results};
}

sub fetch_all_by_disease_name {
  my $self = shift;
  my $search_term = shift;
  my $search_panels = shift;
  my $is_authorised = shift;
  my $registry = $self->app->defaults('registry');
  my $disease_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'disease');
  my $gfd_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genomicfeaturedisease'); 

  my $disease = $disease_adaptor->fetch_by_name($search_term);

  my $gfds = $gfd_adaptor->fetch_all_by_Disease_panels($disease, $search_panels, $is_authorised);
  my $gfd_results = $self->_get_gfd_results($gfds);

  return {gfd_results => $gfd_results};
}

sub _get_gfd_results {
  my $self = shift;
  my $gfds = shift;
  my @gfd_results = ();
  foreach my $gfd (@$gfds) {
    my $genomic_feature = $gfd->get_GenomicFeature;
    my $gene_symbol = $genomic_feature->gene_symbol;
    my $disease = $gfd->get_Disease;
    my $disease_name = $disease->name;
    my $dbID = $gfd->dbID;
    my $panels = join(',', sort @{$gfd->panels});
    my $allelic_requirement = $gfd->allelic_requirement || 'not specified';
    my $mutation_consequence = $gfd->mutation_consequence || 'not specified';  
    push @gfd_results, {
      gene_symbol => $gene_symbol,
      disease_name => $disease_name,
      genotype => $allelic_requirement,
      mechanism => $mutation_consequence,
      search_type => 'gfd',
      dbID => $dbID,
      panels => $panels};
  }
  return \@gfd_results;
}

1;
