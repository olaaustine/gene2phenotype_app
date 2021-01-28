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
package Gene2phenotype::Model::LocusGenotypeMechanism; 
use Mojo::Base 'MojoX::Model';
sub fetch_by_dbID {
  my $self = shift;
  my $dbID = shift;

  my $registry = $self->app->defaults('registry');
  my $lgm_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'LocusGenotypeMechanism');
  my $lgm = $lgm_adaptor->fetch_by_dbID($dbID);
  my $locus_type = $lgm->locus_type;

  my $genotype = $lgm->genotype;
  my $mechanism = $lgm->mechanism;

  my $lgm_panels = $lgm->get_all_LGMPanels;

  my $panel_to_disease = {};
  my @disease_names = ();

  foreach my $lgm_panel (@{$lgm_panels}) {
    my $panel_name = $lgm_panel->get_Panel->name;
    my $lgm_panel_diseases = $lgm_panel->get_all_LGMPanelDiseases;
    my $disease_confidence = $lgm_panel->confidence_category;
    my @disease_synonyms = ();
    my $default_disease_name = '';
    foreach my $lgm_panel_disease (@{$lgm_panel_diseases}) {
      my $disease_name = $lgm_panel_disease->get_Disease->name;
      if ($lgm_panel_disease->default_name) {
        $default_disease_name = $disease_name;
      } else {
        push @disease_synonyms, $disease_name;
      }
    }
    push @disease_names, {
      panel_name => $panel_name,
      disease_confidence => $disease_confidence,
      default_disease_name => $default_disease_name,
      disease_synonyms => \@disease_synonyms
    };
  }

  my $lgm_phenotypes = $lgm->get_all_LGMPhenotypes;
  my @phenotypes = ();
  foreach my $lgm_phenotype (@{$lgm_phenotypes}) {
    my $phenotype = $lgm_phenotype->get_Phenotype;
    my $user = $lgm_phenotype->get_User->username;
    my $created = $lgm_phenotype->created;

    push @phenotypes, {
      name => $phenotype->name,
      created => "$user $created",
    }
  }

  my $lgm_publications = $lgm->get_all_LGMPublications;
  my @publications = ();
  foreach my $lgm_publication (@{$lgm_publications}) {
    my $publication = $lgm_publication->get_Publication;
    my $user = $lgm_publication->get_User->username;
    my $created = $lgm_publication->created;

    push @publications, {
      title => $publication->title,
      pmid => $publication->pmid,
      created => "$user $created",
    }
  }

  if ($locus_type eq 'allele') {
    my $allele_feature_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'AlleleFeature');
    my $input_allele_feature = $allele_feature_adaptor->fetch_by_dbID($lgm->locus_id);
    my $hgvs_protein = $input_allele_feature->name;
    my $allele_features = $allele_feature_adaptor->fetch_all_by_hgvs_protein($hgvs_protein);
    my @transcript_alleles = ();
    foreach my $allele_feature (@{$allele_features}) { 
      foreach my $transcript_allele (@{$allele_feature->get_all_TranscriptAlleles}) {
        push @transcript_alleles, {
          hgvs_protein => $allele_feature->name,
          hgvs_genomic => $allele_feature->hgvs_genomic,
          transcript_stable_id => $transcript_allele->transcript_stable_id,
          consequence_types => $transcript_allele->consequence_types, 
          cadd => $transcript_allele->cadd,
          is_input_allele_feature => ($allele_feature->hgvs_genomic eq $input_allele_feature->hgvs_genomic) ? 1 : 0
        };
      }
    }
    return {
      genotype => $genotype,
      mechanism => $mechanism,
      locus_name => $input_allele_feature->name,
      disease_names => \@disease_names,
      panel_to_disease => $panel_to_disease,
      transcript_alleles => \@transcript_alleles,
      phenotypes => \@phenotypes,
      publications => \@publications,
    };

  }
  if ($locus_type eq 'gene') {
    my $gene_feature_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GeneFeature');
    my $gene_feature = $gene_feature_adaptor->fetch_by_dbID($lgm->locus_id);

    return {
      genotype => $genotype,
      mechanism => $mechanism,
      locus_name => $gene_feature->gene_symbol,
      disease_names => \@disease_names,
      panel_to_disease => $panel_to_disease,
      phenotypes => \@phenotypes,
      publications => \@publications,
    };
  }

  if ($locus_type eq 'placeholder') {
    my $placeholder_feature_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'PlaceholderFeature');
    my $placeholder_feature = $placeholder_feature_adaptor->fetch_by_dbID($lgm->locus_id);
    my $locus_name = $placeholder_feature->placeholder_name;
    return {
      restricted_mutation_set => 1,
      genotype => $genotype,
      mechanism => $mechanism,
      locus_name => $locus_name,
      disease_names => \@disease_names,
      panel_to_disease => $panel_to_disease,
      phenotypes => \@phenotypes,
      publications => \@publications,
    };
  }
}

1;
