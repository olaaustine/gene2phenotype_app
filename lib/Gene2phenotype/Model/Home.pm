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
package Gene2phenotype::Model::Home;
use Mojo::Base 'MojoX::Model';
use JSON;

sub fetch_statistics {
  my $self = shift;
  my $logged_in = shift;
  my $authorised_panels = shift;
  my $registry = $self->app->defaults('registry');
  my $GFD_panel_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureDiseasePanel');
  my $stats = $GFD_panel_adaptor->get_statistics(); 
  return JSON::to_json($stats);
}

sub fetch_updates {
  my $self = shift;
  my $logged_in = shift;
  my $authorised_panels = shift;
  my $registry = $self->app->defaults('registry');
  my $GFD_panel_log_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureDiseasePanelLog');
  my $panel_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'panel');
  my @results = ();
  my $only_visible_entries = ($logged_in) ? 0 : 1;
  foreach my $panel_name (@$authorised_panels) {
    next if ($panel_name eq 'ALL');
    my $updates = $GFD_panel_log_adaptor->fetch_latest_updates($panel_name, 10, $only_visible_entries);
    push @results, { panel => $panel_name, updates => $self->format_updates($updates)};
  }
  return \@results;
}

sub format_updates {
  my $self = shift;
  my $updates = shift;
  my $registry = $self->app->defaults('registry');
  my $GFD_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureDisease');

  my @results = ();
  foreach my $update (@$updates) {
    my ($date, $time) = split(/\s/, $update->created);    

    my $gfd_id = $update->genomic_feature_disease_id;
    my $gfd = $GFD_adaptor->fetch_by_dbID($gfd_id);    

    my $allelic_requirement = $gfd->allelic_requirement || 'not specified';
    my $mutation_consequence = $gfd->mutation_consequence || 'not specified';
    push @results, {
      date => $date,
      gene_symbol => $gfd->get_GenomicFeature->gene_symbol,
      disease_name => $gfd->get_Disease->name,
      genotype => $allelic_requirement,
      mechanism => $mutation_consequence,
      GFD_ID => $gfd->dbID,
      search_type => 'gfd' 
    };
  }
  return \@results;
}


1;
