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
package Gene2phenotype::Controller::GenomicFeatureDisease;
use base qw(Gene2phenotype::Controller::BaseController);
use strict;
use warnings;
sub show {
  my $self = shift;
  my $model = $self->model('genomic_feature_disease');
  my $disease_model = $self->model('disease');
  my $GF_model = $self->model('genomic_feature');

  my $dbID = $self->param('dbID') || $self->param('GFD_id');

  if (!$dbID) {
    return $self->render(template => 'not_found');
  }

  my $logged_in = $self->session('logged_in'); 
  my $gfd = $model->fetch_by_dbID($dbID, $logged_in); 

  # Is panel visible and can it be viewed by the curator?  
  my $authorised_panels = $self->stash('authorised_panels');
  my $panel = $gfd->{panel};

  if (!grep {$panel eq $_} @$authorised_panels) {
    return $self->redirect_to("/gene2phenotype/");
  }

  $self->stash(gfd => $gfd);

  my $panel_can_be_edited = 0;
  if ($self->session('logged_in')) {
    my $current_panel = $gfd->{panel};
    my @panels = @{$self->session('panels')};
    if (grep {$panel eq $_} @panels) {
      $panel_can_be_edited = 1;
      my @duplicate_to_panels = ();
      foreach my $panel (@panels) {
        if ($panel ne $current_panel) {
          push @duplicate_to_panels, $panel;
        }
      } 
      if (scalar @duplicate_to_panels > 0) {
        $self->stash(duplicate => 1);
        $self->stash(duplicate_to => \@duplicate_to_panels);
      } else {
        $self->stash(duplicate => 0);
        $self->stash(duplicate_to => []);
      }
    } else {
      $self->stash(duplicate => 0);
      $self->stash(duplicate_to => []);
    }
  } 

  my $disease_id = $gfd->{disease_id};
  my $disease_attribs = $disease_model->fetch_by_dbID($disease_id);
  $self->stash(disease => $disease_attribs);

  my $gene_id = $gfd->{gene_id};
  my $gene_attribs = $GF_model->fetch_by_dbID($gene_id);
  $self->stash(gene => $gene_attribs);

  $self->session(last_url => "/gene2phenotype/gfd?GFD_id=$dbID");

  if ($self->session('logged_in') && $panel_can_be_edited) {
    $self->render(template => 'user/gfd');
  } else {
    $self->render(template => 'gfd');
  }
}

sub duplicate {
  my $self = shift;        
  my $panel = $self->param('panel');
  my $data = $self->every_param('duplicate_data_id');
  my $GFD_id = $self->param('GFD_id');
  my $model = $self->model('genomic_feature_disease');  
  my $email = $self->session('email');

  my $result = $model->duplicate($GFD_id, $panel, $data, $email);
  my $feedback = $result->[1];
  my $gfd = $result->[0];
  $GFD_id = $gfd->dbID;
  $self->feedback_message($feedback);
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}
# show form
sub create {
  my $self = shift;
  
  if ($self->session('logged_in')) {

    my $email = $self->session('email');

    if (defined $self->param('gene_symbol')) {
      $self->stash(gene_symbol => $self->param('gene_symbol'));
    } else {
      $self->stash(gene_symbol => undef);
    }

    my $user_model = $self->model('user');
    my $user = $user_model->fetch_by_email($email);
    my @panels = split(',', $user->panel);
    $self->stash(panels => \@panels);

    my $gfd_model = $self->model('genomic_feature_disease');
    my $confidence_values = $gfd_model->get_confidence_values;
    $self->stash(confidence_values => $confidence_values);

    my $genotypes = $gfd_model->get_genotypes;
    $self->stash(genotypes => $genotypes);

    my $mutation_consequences =  $gfd_model->get_mutation_consequences;
    $self->stash(mutation_consequences => $mutation_consequences);

  }

  $self->render(template => 'create_gfd');
}

sub add {
  my $self = shift;
  my $panel                          = $self->param('panel');
  my $gene_symbol                    = $self->param('gene_symbol');
  my $disease_name                   = $self->param('disease_name');
  my $confidence_attrib_id           = $self->param('confidence_attrib_id');
  my $allelic_requirement_attrib_ids = join(',', sort @{$self->every_param('allelic_requirement_attrib_id')});
  my $mutation_consequence_attrib_id = $self->param('mutation_consequence_attrib_id');

  my $email = $self->session('email');

  my $model = $self->model('genomic_feature_disease');  

  # user has confirmed to add new entry
  if (defined $self->param('add_entry_anyway') && $self->param('add_entry_anyway') == 1) {
    my $gfd = $model->add_by_name(
      $self->param('panel'),
      $self->param('gene_symbol'),
      $self->param('disease_name'),
      $self->param('genotypes_to_be_added'),
      $self->param('mutation_consequence_to_be_added'),
      $self->param('confidence_value_to_be_added'),
      $email
    );
    my $GFD_id = $gfd->dbID;
    $self->feedback_message('ADDED_GFD_SUC');
    return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
  } 

  my $gf_model = $self->model('genomic_feature');
  my $gf = $gf_model->fetch_by_gene_symbol($gene_symbol); 
  if (!$gf) {
    $self->feedback_message('GF_NOT_IN_DB');
    return $self->redirect_to("/gene2phenotype/gfd/create");
  }

  my $disease_model = $self->model('disease');
  my $disease = $disease_model->fetch_by_name($disease_name);
  if (!$disease) {
    $disease = $disease_model->add($disease_name);
  }
  my $gfd = $model->fetch_by_panel_GenomicFeature_Disease($panel, $gf, $disease);
  if ($gfd) {
    my $actions = $gfd->get_all_GenomicFeatureDiseaseActions;
    my $action = $actions->[0];
    if ($action->allelic_requirement_attrib eq $allelic_requirement_attrib_ids && $action->mutation_consequence_attrib eq $mutation_consequence_attrib_id) {
      # if entry already exists go to GFD page
      # show message that entry was already in database
      my $GFD_id = $gfd->dbID;
      $self->feedback_message('GFD_IN_DB');
      return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
    } else {
      # entry with same gene symbol and disease name exists
      $self->stash(message => 'Error: An entry with the same gene symbol and disease name already exists:');
      $self->stash(
        confidence_values => $model->get_confidence_values,
        mutation_consequences =>  $model->get_mutation_consequences,
        genotypes => $model->get_genotypes,
        gene_symbol => $gene_symbol,
        disease_name => $disease_name,
        existing_gfds => [{
          gfd_id => $gfd->dbID,
          gene_symbol => $gfd->get_GenomicFeature->gene_symbol,
          disease_name => $gfd->get_Disease->name,
          allelic_requirement => $action->allelic_requirement,
          mutation_consequence => $action->mutation_consequence,
          panel => $gfd->panel,
        }],
      );
      return $self->render(template => 'create_gfd');
    }
  }

  my $existing_gfds = $model->fetch_all_existing_by_panel_LGM($panel, $gf, $allelic_requirement_attrib_ids, $mutation_consequence_attrib_id);
  if (scalar @{$existing_gfds} > 0) {
    my $genotypes_to_be_added = $model->get_allelic_requirement_by_attrib_ids($allelic_requirement_attrib_ids);
    my $mutation_consequence_to_be_added = $model->get_mutation_consequence_by_attrib_id($mutation_consequence_attrib_id);
    my $confidence_value_to_be_added = $model->get_confidence_value_by_attrib_id($confidence_attrib_id);

    $self->stash(message => 'Warning: Entries with the same gene symbol, allelic requirement and mutation consequence already exist:');
    $self->stash(
      existing_gfds => $existing_gfds,
      confidence_values => $model->get_confidence_values,
      mutation_consequences =>  $model->get_mutation_consequences,
      genotypes => $model->get_genotypes,
      gene_symbol => $gene_symbol,
      disease_name => $disease_name,
      new_entry => {
        entry_to_be_added => join('; ', $gene_symbol, $genotypes_to_be_added, $mutation_consequence_to_be_added, $disease_name, $confidence_value_to_be_added),
        panel => $panel,
        gene_symbol => $gene_symbol,
        disease_name => $disease_name,
        genotypes_to_be_added => $genotypes_to_be_added,
        mutation_consequence_to_be_added => $mutation_consequence_to_be_added,
        confidence_value_to_be_added => $confidence_value_to_be_added
      }
    );
    return $self->render(template => 'create_gfd');
  } 

  $gfd = $model->add($panel, $gf, $disease, $allelic_requirement_attrib_ids, $mutation_consequence_attrib_id, $confidence_attrib_id, $email);
  my $GFD_id = $gfd->dbID;
  $self->feedback_message('ADDED_GFD_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

sub delete {
  my $self = shift;
  my $GFD_id = $self->param('dbID');
  my $model = $self->model('genomic_feature_disease');  
  my $email = $self->session('email');

  $model->delete($email, $GFD_id);
  my $last_url = $self->session('last_url');
  $self->feedback_message('DELETED_GFD_SUC');
  return $self->redirect_to($last_url);
}

sub update {
  my $self = shift;
  my $category_attrib_id = $self->param('category_attrib_id'); 
  my $GFD_id = $self->param('GFD_id');
  my $model = $self->model('genomic_feature_disease');  
  my $email = $self->session('email');
  $model->update_GFD_category($email, $GFD_id, $category_attrib_id);
  $self->session(last_url => "/gene2phenotype/gfd?GFD_id=$GFD_id");
  $self->feedback_message('UPDATED_CONFIDENCE_CATEGORY_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

sub update_organ_list {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $organ_id_list = join(',', @{$self->every_param('organ_id')});
  my $model = $self->model('genomic_feature_disease');  
  my $email = $self->session('email');
  $model->update_organ_list($email, $GFD_id, $organ_id_list);
  $self->session(last_url => "/gene2phenotype/gfd?GFD_id=$GFD_id");
  $self->feedback_message('UPDATED_ORGAN_LIST');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

sub update_disease {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $disease_id = $self->param('disease_id');
  my $name = $self->param('name');
  my $mim = $self->param('mim');
  my $model = $self->model('genomic_feature_disease');  
  my $email = $self->session('email');
  $model->update_disease($email, $GFD_id, $disease_id, $name, $mim);
  $self->session(last_url => "/gene2phenotype/gfd?GFD_id=$GFD_id");
  $self->feedback_message('UPDATED_DISEASE_ATTRIBS_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

sub update_visibility {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $visibility = $self->param('visibility'); #restricted, authorised 
  my $model = $self->model('genomic_feature_disease');  
  my $email = $self->session('email');
  $model->update_visibility($email, $GFD_id, $visibility);
  $self->session(last_url => "/gene2phenotype/gfd?GFD_id=$GFD_id");
  $self->feedback_message('UPDATED_VISIBILITY_STATUS_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

sub merge_all_duplicated_LGM_by_gene_by_panel {
  my $self = shift;
  my $gf_id = $self->param('gf_id');
  my $panel = $self->param('panel');
  my $ar_attrib = $self->param('ar_attrib');
  my $mc_attrib = $self->param('mc_attrib');

  if ($self->session('logged_in')) {
    my $hash   = $self->req->params->to_hash;
    my $model = $self->model('genomic_feature_disease');  
    my $email = $self->session('email');
    my $gfd_ids = $self->every_param('gfd_id');
    my $disease_id = $self->param('disease_id');

    if (scalar @$gfd_ids < 2) {
      $self->feedback_message('LGM_MERGE_ERROR_LESS_THAN_TWO_ENTRIES'); # need at least 2 entries for merging
      return $self->redirect_to("/gene2phenotype/curator/show_all_duplicated_LGM_by_gene?gf_id=$gf_id&panel=$panel&allelic_requirement_attrib=$ar_attrib&mutation_consequence_attrib=$mc_attrib");
    }
    my $gfd = $model->merge_all_duplicated_LGM_by_panel_gene($email, $gf_id, $disease_id, $panel, $gfd_ids);
    my $GFD_id = $gfd->dbID;
    $self->feedback_message('LGM_MERGE_SUCCESS');
    return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
  }
  $self->feedback_message('LGM_MERGE_ERROR_NOT_LOGGED_IN');
  return $self->redirect_to("/gene2phenotype/curator/show_all_duplicated_LGM_by_gene?gf_id=$gf_id&panel=$panel&allelic_requirement_attrib=$ar_attrib&mutation_consequence_attrib=$mc_attrib");
}


1;
