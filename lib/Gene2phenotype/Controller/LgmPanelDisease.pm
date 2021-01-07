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
package Gene2phenotype::Controller::LgmPanelDisease;
use base qw(Gene2phenotype::Controller::BaseController);

sub show {
  my $self = shift;
  my $lgm_panel_disease_id = $self->param('id');
  my $model = $self->model('lgm_panel_disease');
  my $lgms = $model->fetch_by_dbID($lgm_panel_disease_id); 
  $self->stash(lgms => $lgms); 
  $self->render(template => 'lgm_panel_disease');
}

1;
