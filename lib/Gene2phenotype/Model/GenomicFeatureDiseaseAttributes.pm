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
