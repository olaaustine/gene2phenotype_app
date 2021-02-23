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
  my $GFD_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genomicfeaturedisease');
  my $attribute_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'attribute');
  my $panel_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'panel');

  my @panel_names = map {$_->name} @{$panel_adaptor->fetch_all_visible_Panels};
  my @panels = ();
  foreach my $panel_name (@$authorised_panels, @panel_names) {
    next if ($panel_name eq 'ALL');
    my $panel_id = $attribute_adaptor->attrib_id_for_value($panel_name);
    push @panels, $panel_id;
  }
  my $stats = $GFD_adaptor->get_statistics(\@panels); 
  return JSON::to_json($stats);
}

sub fetch_updates {
  my $self = shift;
  my $logged_in = shift;
  my $authorised_panels = shift;
  my $registry = $self->app->defaults('registry');
  my $GFDL_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genomicfeaturediseaselog');

  my $panel_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'panel');

  my @results = ();

#  my @panels = map { $_->name } @{$panel_adaptor->fetch_all_visible_Panels}; # set in panel table: is_visible
#  foreach my $panel (@{$panel_adaptor->fetch_all_visible_Panels}) {
    # if in authorised panels (curator can edit content) show all entries 
    # if panel is not in authorised_panels only show visible entries
#    my $only_visible_entries = (!grep{$_ eq $panel->name} @$authorised_panels) ? 1 : 0;
    # and logged in
#    my $updates = $GFDL_adaptor->fetch_latest_updates($panel->name, 10, $only_visible_entries);
#    push @results, { panel => $panel->name, updates => $self->format_updates($updates)};
#  }  
  my $only_visible_entries = ($logged_in) ? 0 : 1;
  foreach my $panel_name (@$authorised_panels) {
    next if ($panel_name eq 'ALL');
    my $updates = $GFDL_adaptor->fetch_latest_updates($panel_name, 10, $only_visible_entries);
    push @results, { panel => $panel_name, updates => $self->format_updates($updates)};
  }
  return \@results;
}

sub format_updates {
  my $self = shift;
  my $updates = shift;
  my $registry = $self->app->defaults('registry');
  my $GFD_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genomicfeaturedisease');

  my @results = ();
  foreach my $update (@$updates) {
    my ($date, $time) = split(/\s/, $update->created);    

    my $gfd_id = $update->genomic_feature_disease_id;
    my $gfd = $GFD_adaptor->fetch_by_dbID($gfd_id);    

    my $actions = $gfd->get_all_GenomicFeatureDiseaseActions;

    if (scalar @$actions == 0) {
        push @results, {
          date => $date,
          gene_symbol => $update->gene_symbol,
          disease_name => $update->disease_name,
          genotype => 'not specified',
          mechanism => 'not specified',
          GFD_ID => $update->genomic_feature_disease_id,
          search_type => 'gfd' 
        }
    } else {
      foreach my $action (@$actions) {
        my $allelic_requirement = $action->allelic_requirement || 'not specified';
        my $mutation_consequence = $action->mutation_consequence || 'not specified';
        push @results, {
          date => $date,
          gene_symbol => $update->gene_symbol,
          disease_name => $update->disease_name,
          genotype => $allelic_requirement,
          mechanism => $mutation_consequence,
          GFD_ID => $update->genomic_feature_disease_id,
          search_type => 'gfd' 
        }
      }
    }
  }
  return \@results;
}


1;
