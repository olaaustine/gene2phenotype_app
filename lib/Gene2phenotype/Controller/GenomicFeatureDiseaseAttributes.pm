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
package Gene2phenotype::Controller::GenomicFeatureDiseaseAttributes;
use base qw(Gene2phenotype::Controller::BaseController);

sub add {
  my $self = shift;
  my $allelic_requirement_attrib_ids = join(',', @{$self->every_param('allelic_requirement_attrib_id')}); 
  my $mutation_consequence_attrib_id = $self->param('mutation_consequence_attrib_id');
  my $GFD_id = $self->param('GFD_id');

  my $email = $self->session('email');
  my $model = $self->model('genomic_feature_disease_attributes');
  $model->add($GFD_id, $email, $allelic_requirement_attrib_ids, $mutation_consequence_attrib_id);
  $self->feedback_message('ADDED_GFD_ACTION_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

sub update {
  my $self = shift;
  my $allelic_requirement_attrib_ids = join(',', @{$self->every_param('allelic_requirement_attrib_id')}); 
  my $mutation_consequence_attrib_id = $self->param('mutation_consequence_attrib_id');
  my $GFD_id = $self->param('GFD_id');
  my $GFD_action_id = $self->param('GFD_action_id');

  my $email = $self->session('email');
  my $model = $self->model('genomic_feature_disease_attributes');
  $model->update($email, $allelic_requirement_attrib_ids, $mutation_consequence_attrib_id, $GFD_action_id);
  $self->feedback_message('UPDATED_GFD_ACTION_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

sub delete {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $GFD_action_id = $self->param('GFD_action_id');
  my $email = $self->session('email');
  my $model = $self->model('genomic_feature_disease_attributes');
  $model->delete($GFD_id, $email, $GFD_action_id);
  $self->feedback_message('DELETED_GFD_ACTION_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

1;
