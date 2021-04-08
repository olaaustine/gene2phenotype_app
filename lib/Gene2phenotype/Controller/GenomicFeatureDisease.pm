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
  my $genomic_feature_model = $self->model('genomic_feature');

  my $dbID = $self->param('dbID') || $self->param('GFD_id');

  if (!$dbID) {
    return $self->render(template => 'not_found');
  }
  my $gfd;
  my $authorised_panels = $self->stash('authorised_panels');
  my $logged_in = 0;
  if ($self->session('logged_in')) {
    my $user_panels = $self->stash('user_panels');
    $logged_in = 1;
    $gfd = $model->fetch_by_dbID($dbID, $logged_in, $authorised_panels, $user_panels);
  } else {
    $gfd = $model->fetch_by_dbID($dbID, $logged_in, $authorised_panels);
  }
  if (!defined $gfd) {
    return $self->redirect_to("/gene2phenotype/");
  }
  $self->stash(gfd => $gfd);

  my $disease_id = $gfd->{disease_id};
  my $disease_attribs = $disease_model->fetch_by_dbID($disease_id);
  $self->stash(disease => $disease_attribs);

  my $gene_id = $gfd->{gene_id};
  my $gene_attribs = $genomic_feature_model->fetch_by_dbID($gene_id);
  $self->stash(gene => $gene_attribs);

  $self->session(last_url => "/gene2phenotype/gfd?GFD_id=$dbID");

  if ($self->session('logged_in')) {
    $self->render(template => 'user/gfd');
  } else {
    $self->render(template => 'gfd');
  }
}

sub show_add_new_entry_form {
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

    my $allelic_requirements = $gfd_model->get_allelic_requirements;
    $self->stash(allelic_requirements => $allelic_requirements);

    my $mutation_consequences =  $gfd_model->get_mutation_consequences;
    $self->stash(mutation_consequences => $mutation_consequences);

  }

  $self->render(template => 'add_new_entry');
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


1;
