package Gene2phenotype::Controller::GenomicFeatureDiseaseAttributes;
use Mojo::Base 'Mojolicious::Controller';


sub add {
  my $self = shift;
  my $allelic_requirement_attrib_ids = join(',', @{$self->every_param('allelic_requirement_attrib_id')}); 
  my $mutation_consequence_attrib_id = $self->param('mutation_consequence_attrib_id');
  my $GFD_id = $self->param('GFD_id');

  my $email = $self->session('email');
  my $model = $self->model('genomic_feature_disease_attributes');
  $model->add($GFD_id, $email, $allelic_requirement_attrib_ids, $mutation_consequence_attrib_id);
  return $self->redirect_to("/gfd?GFD_id=$GFD_id");
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
  return $self->redirect_to("/gfd?GFD_id=$GFD_id");
}

sub delete {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $GFD_action_id = $self->param('GFD_action_id');
  my $email = $self->session('email');
  my $model = $self->model('genomic_feature_disease_attributes');
  $model->delete($GFD_id, $email, $GFD_action_id);
  return $self->redirect_to("/gfd?GFD_id=$GFD_id");
}

1;
