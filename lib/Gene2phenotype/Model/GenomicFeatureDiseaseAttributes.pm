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
package Gene2phenotype::Model::GenomicFeatureDiseaseAttributes;
use Mojo::Base 'MojoX::Model';


sub add {
  my $self = shift;
  my $GFD_id = shift;
  my $email = shift;
  my $allelic_requirement_attrib_ids = shift;
  my $mutation_consequence_attrib_id = shift;

  my $registry = $self->app->defaults('registry');  
  my $GFDAction_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureDiseaseAction');
  my $user_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'user');
  my $user = $user_adaptor->fetch_by_email($email);

  my $GFDAction = Bio::EnsEMBL::G2P::GenomicFeatureDiseaseAction->new(
    -genomic_feature_disease_id => $GFD_id,
    -allelic_requirement_attrib => $allelic_requirement_attrib_ids,
    -mutation_consequence_attrib => $mutation_consequence_attrib_id,
  );

  $GFDAction_adaptor->store($GFDAction, $user);
}

sub update {
  my $self = shift;
  my $email = shift;
  my $allelic_requirement_attrib_ids = shift;
  my $mutation_consequence_attrib_id = shift;
  my $GFD_action_id = shift;

  my $registry = $self->app->defaults('registry');  
  my $GFDAction_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureDiseaseAction');
  my $user_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'user');
  my $user = $user_adaptor->fetch_by_email($email);

  my $GFDAction = $GFDAction_adaptor->fetch_by_dbID($GFD_action_id);
  $GFDAction->allelic_requirement_attrib($allelic_requirement_attrib_ids);  
  $GFDAction->mutation_consequence_attrib($mutation_consequence_attrib_id);
  $GFDAction_adaptor->update($GFDAction, $user);
}


sub delete {
  my $self = shift;
  my $GFD_id = shift;
  my $email = shift;
  my $GFD_action_id = shift;

  my $registry = $self->app->defaults('registry');  
  my $GFDAction_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureDiseaseAction');
  my $user_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'user');
  my $user = $user_adaptor->fetch_by_email($email);

  my $GFDAction = $GFDAction_adaptor->fetch_by_dbID($GFD_action_id);  

  $GFDAction_adaptor->delete($GFDAction, $user);
}


1;
