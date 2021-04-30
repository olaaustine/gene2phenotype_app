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
package Gene2phenotype::Controller::GenomicFeatureDiseasePanel;
use base qw(Gene2phenotype::Controller::BaseController);
use strict;
use warnings;

sub add {
  my $self = shift;
  my $target_panel                   = $self->param('panel');
  my $gene_symbol                    = $self->param('gene_symbol');
  my $disease_name                   = $self->param('disease_name');
  my $confidence_attrib_id           = $self->param('confidence_attrib_id');
  my $allelic_requirement_attrib_ids = join(',', sort @{$self->every_param('allelic_requirement_attrib_id')});
  my $mutation_consequence_attrib_id = $self->param('mutation_consequence_attrib_id');

  # Check if logged in
 
  my $email = $self->session('email');
  my $gfd_model = $self->model('genomic_feature_disease');  
  my $gfd_panel_model = $self->model('genomic_feature_disease_panel');

  if (defined $self->param('add_existing_entry_to_panel') && $self->param('add_existing_entry_to_panel') == 1) {
    my $gfd_id = $self->param('gfd_id');
    $self->add_gfd_to_panel($gfd_id);
    return;
  } 
 
  if (defined $self->param('create_new_gfd') && $self->param('create_new_gfd') == 1) {
    my $gfd = $self->create_gfd();
    my $gfd_id = $gfd->dbID;
    $self->add_gfd_to_panel($gfd_id);
    return;
  } 

  my $gf_model = $self->model('genomic_feature');
  my $gf = $gf_model->fetch_by_gene_symbol($gene_symbol); 
  if (!$gf) {
    $self->feedback_message('GF_NOT_IN_DB');
    return $self->redirect_to("/gene2phenotype/gfd/show_add_new_entry_form");
  }

  my $disease_model = $self->model('disease');
  my $disease = $disease_model->fetch_by_name($disease_name);
  if (!$disease) {
    $disease = $disease_model->add($disease_name);
  }

  my $gfds = $gfd_model->fetch_all_by_GenomicFeature_constraints($gf, {
    'mutation_consequence_attrib' => $mutation_consequence_attrib_id,
    'allelic_requirement_attrib' => $allelic_requirement_attrib_ids,
  });
  if (scalar @$gfds == 0) {
    my $gfd = $self->create_gfd();
    my $gfd_id = $gfd->dbID;
    $self->add_gfd_to_panel($gfd_id);
    return;
  } else {
    my $existing_gfds = _get_existing_gfds($gfds, $disease->dbID, $target_panel);
    if ($existing_gfds->{same_disease_target_panel}) {
      my $gfd = $existing_gfds->{same_disease_target_panel};
      my $gfd_id = $gfd->dbID;
      $self->feedback_message('GFD_IN_DB');
      return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$gfd_id");   
    } else {
      my $allelic_requirement_to_be_added = $gfd_model->get_value('allelic_requirement', $allelic_requirement_attrib_ids);
      my $mutation_consequence_to_be_added = $gfd_model->get_value('mutation_consequence', $mutation_consequence_attrib_id);
      my $confidence_value_to_be_added = $gfd_model->get_value('confidence_category', $confidence_attrib_id);
      $self->stash(
        existing_gfds => $existing_gfds,
        new_gfd => {
          mutation_consequence_to_be_added =>  $mutation_consequence_to_be_added,
          allelic_requirement_to_be_added => $allelic_requirement_to_be_added,
          gene_symbol => $gene_symbol,
          disease_name => $disease_name,
        },
        confidence_value_to_be_added => $confidence_value_to_be_added,
        confidence_values => $gfd_model->get_confidence_values,
        mutation_consequences =>  $gfd_model->get_mutation_consequences,
        allelic_requirements => $gfd_model->get_allelic_requirements,
        gene_symbol => $gene_symbol,
        disease_name => $disease_name,
        panel => $target_panel
      );
      return $self->render(template => 'add_new_entry');
    }
  }
}

sub create_gfd {
  my $self = shift;
  my $email = $self->session('email');
  my $gfd_model = $self->model('genomic_feature_disease');  
  my $gfd = $gfd_model->add(
    $self->param('gene_symbol'),
    $self->param('disease_name'),
    $self->param('allelic_requirement_to_be_added'),
    $self->param('mutation_consequence_to_be_added'),
    $email
  );
  return $gfd;
}

sub add_gfd_to_panel {
  my $self = shift;
  my $gfd_id = shift;
  my $email = $self->session('email');
  my $gfd_panel_model = $self->model('genomic_feature_disease_panel');

  my $gfd_panel = $gfd_panel_model->add(
    $gfd_id,
    $self->param('panel'),
    $self->param('confidence_value_to_be_added'),
    $email
  );
  $self->feedback_message('ADDED_GFD_SUC');

  $self->redirect_to("/gene2phenotype/gfd?GFD_id=$gfd_id");
}

sub _get_existing_gfds {
  my $gfds = shift;
  my $new_disease_id = shift;
  my $target_panel = shift;
  # Identify:
  # same disease and target panel
  # same disease and non-target panel
  # different disease and target panel
  # different disease and non-target panel
  my $existing_gfds;
  foreach my $gfd (@$gfds) {
    my @disease_name_synonyms = map {$_->get_Disease->name } @{$gfd->get_all_GFDDiseaseSynonyms};
    my $is_target_panel = grep {$target_panel eq $_} @{$gfd->panels};
    my $disease_id = $gfd->get_Disease->dbID;
    my $exisiting_gfd = {
      mutation_consequence =>  $gfd->mutation_consequence,
      allelic_requirement => $gfd->allelic_requirement,
      gene_symbol => $gfd->get_GenomicFeature->gene_symbol,
      disease_name => $gfd->get_Disease->name,
      disease_name_synonyms => \@disease_name_synonyms,
      panels => $gfd->panels,
      gfd_id => $gfd->dbID,
    };
    if ($disease_id == $new_disease_id && $is_target_panel) {
      $existing_gfds->{same_disease_target_panel} = $gfd;
    } elsif ($disease_id == $new_disease_id && !$is_target_panel) {
      push @{$existing_gfds->{same_disease_non_target_panel}}, $exisiting_gfd;
    } elsif ($disease_id != $new_disease_id && $is_target_panel) {
      push @{$existing_gfds->{different_disease_target_panel}}, $exisiting_gfd;
    } else {
      push @{$existing_gfds->{different_disease_non_target_panel}}, $exisiting_gfd;
    }
  }
  return $existing_gfds;
}

sub update_visibility {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $GFD_panel_id = $self->param('GFD_panel_id');
  my $visibility = $self->param('visibility'); #restricted, authorised 
  my $model = $self->model('genomic_feature_disease_panel');  
  my $email = $self->session('email');
  $model->update_visibility($email, $GFD_panel_id, $visibility);
  $self->session(last_url => "/gene2phenotype/gfd?GFD_id=$GFD_id");
  $self->feedback_message('UPDATED_VISIBILITY_STATUS_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

sub update_confidence_category {
  my $self = shift;
  my $category_attrib_id = $self->param('category_attrib_id'); 
  my $GFD_id = $self->param('GFD_id');
  my $GFD_panel_id = $self->param('GFD_panel_id');
  my $model = $self->model('genomic_feature_disease_panel');  
  my $email = $self->session('email');
  $model->update_confidence_category($email, $GFD_panel_id, $category_attrib_id);
  $self->session(last_url => "/gene2phenotype/gfd?GFD_id=$GFD_id");
  $self->feedback_message('UPDATED_CONFIDENCE_CATEGORY_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

sub delete {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $GFD_panel_id = $self->param('GFD_panel_id');
  my $model = $self->model('genomic_feature_disease_panel');
  my $email = $self->session('email');
  $model->delete($email, $GFD_panel_id);
  $self->feedback_message('DELETED_GFD_PANEL_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

1;
