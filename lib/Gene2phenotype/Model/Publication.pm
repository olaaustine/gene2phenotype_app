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

package Gene2phenotype::Model::Publication;
use Mojo::Base 'MojoX::Model';

sub fetch_by_dbID {
  my $self = shift;
  my $dbID = shift;
  my $registry = $self->app->defaults('registry');
  my $publication_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'publication');
  my $publication = $publication_adaptor->fetch_by_dbID($dbID);
  my $pmid = $publication->pmid;
  my $title = $publication->title;
  my $source = $publication->source;

  return {
    publication_id => $dbID,
    pmid => $pmid,
    title => $title,
    source => $source,
  };
}

sub fetch_by_pmid {
  my $self = shift;
  my $pmid_no = shift;
  my $registry = $self->app->defaults('registry');
  my $publication_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'publication');

  my $pmid = $publication_adaptor->fetch_by_PMID($pmid_no);
  return $pmid;
}

sub add {
  my $self = shift;
  my $pmid = shift;
  my $registry = $self->app->defaults('registry');
  my $publication_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'publication');
  
  my $publication =  Bio::EnsEMBL::G2P::Disease->new(
    -name => $pmid,
    -adaptor => $publication_adaptor,
  );

  $publication_adaptor->store($publication);
}
