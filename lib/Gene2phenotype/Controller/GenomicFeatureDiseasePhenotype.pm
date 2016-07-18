package Gene2phenotype::Controller::GenomicFeatureDiseasePhenotype;
use base qw(Gene2phenotype::Controller::BaseController);

sub update {
  my $self = shift;
  my $phenotype_ids = $self->param('phenotype_ids');
  my $GFD_id = $self->param('GFD_id');
  my $email = $self->session('email');
  my $model = $self->model('genomic_feature_disease_phenotype');
  $model->update_phenotype_list($GFD_id, $email, $phenotype_ids);
  $self->feedback_message('UPDATED_PHENOTYPES_SUC');
  return $self->redirect_to("/gfd?GFD_id=$GFD_id");
}

sub delete {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $GFD_phenotype_id = $self->param('GFD_phenotype_id');
  my $email = $self->session('email');  
  my $model = $self->model('genomic_feature_disease_phenotype');
  $model->delete($GFD_phenotype_id, $email);
  $self->feedback_message('DELETED_GFDPHENOTYPE_SUC');
  return $self->redirect_to("/gfd?GFD_id=$GFD_id");
}

sub add_comment {
  my $self = shift;
  my $GFD_phenotype_comment = $self->param('GFD_phenotype_comment');
  my $GFD_phenotype_id = $self->param('GFD_phenotype_id');
  my $GFD_id = $self->param('GFD_id');
  my $email = $self->session('email');  
  my $model = $self->model('genomic_feature_disease_phenotype');
  $model->add_comment($GFD_phenotype_id, $GFD_phenotype_comment, $email);
  $self->feedback_message('ADDED_COMMENT_SUC');
  return $self->redirect_to("/gfd?GFD_id=$GFD_id");
}

sub delete_comment {
  my $self = shift;
  my $GFD_phenotype_comment_id = $self->param('GFD_phenotype_comment_id');
  my $GFD_id = $self->param('GFD_id');
  my $email = $self->session('email');  
  my $model = $self->model('genomic_feature_disease_phenotype');
  $model->delete_comment($GFD_phenotype_comment_id, $email);
  $self->feedback_message('DELETED_COMMENT_SUC');
  return $self->redirect_to("/gfd?GFD_id=$GFD_id");
}


1;
