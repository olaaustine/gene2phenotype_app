package Gene2phenotype::Controller::GenomicFeatureDiseasePhenotype;
use base qw(Gene2phenotype::Controller::BaseController);

sub add {
  my $self = shift;
  my $phenotype_id = $self->param('phenotype_id');
  my $GFD_id = $self->param('GFD_id');
  my $model = $self->model('genomic_feature_disease_phenotype');
  my $GFDP = $model->add_phenotype($GFD_id, $phenotype_id);
  my $phenotype_name = $GFDP->get_Phenotype->name;
  $self->edit_phenotypes_message('SUCC_ADDED_PHENOTYPE', $phenotype_name);
  $self->render(text => 'ok');
}

sub delete_from_tree {
  my $self = shift;
  my $phenotype_id = $self->param('phenotype_id');
  my $GFD_id = $self->param('GFD_id');
  my $email = $self->session('email');
  my $model = $self->model('genomic_feature_disease_phenotype');
  my $phenotype_model = $self->model('phenotype');
  my $phenotype = $phenotype_model->fetch_by_dbID($phenotype_id); 
  my $phenotype_name = $phenotype->name;

  $model->delete_phenotype($GFD_id, $phenotype_id, $email);
  $self->edit_phenotypes_message('SUCC_DELETED_PHENOTYPE', $phenotype_name);
  $self->render(text => 'ok');
}

sub update {
  my $self = shift;
  my $phenotype_ids = $self->param('phenotype_ids');
  my $GFD_id = $self->param('GFD_id');
  my $email = $self->session('email');
  my $model = $self->model('genomic_feature_disease_phenotype');
  $model->update_phenotype_list($GFD_id, $email, $phenotype_ids);
  $self->feedback_message('UPDATED_PHENOTYPES_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

sub delete {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $GFD_phenotype_id = $self->param('GFD_phenotype_id');
  my $email = $self->session('email');  
  my $model = $self->model('genomic_feature_disease_phenotype');
  $model->delete($GFD_phenotype_id, $email);
  $self->feedback_message('DELETED_GFDPHENOTYPE_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
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
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

sub delete_comment {
  my $self = shift;
  my $GFD_phenotype_comment_id = $self->param('GFD_phenotype_comment_id');
  my $GFD_id = $self->param('GFD_id');
  my $email = $self->session('email');  
  my $model = $self->model('genomic_feature_disease_phenotype');
  $model->delete_comment($GFD_phenotype_comment_id, $email);
  $self->feedback_message('DELETED_COMMENT_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}


1;
