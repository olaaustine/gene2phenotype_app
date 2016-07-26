package Gene2phenotype::Controller::GenomicFeatureDiseasePublication;
use base qw(Gene2phenotype::Controller::BaseController);

sub add {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $source = $self->param('source');
  my $pmid = $self->param('pmid');
  my $title = $self->param('title');
  my $email = $self->session('email');
  my $model = $self->model('genomic_feature_disease_publication'); 
  $model->add_publication($GFD_id, $email, $source, $pmid, $title);
  $self->feedback_message('ADDED_PUBLICATION_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

sub delete {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $GFD_publication_id = $self->param('GFD_publication_id');
  my $email = $self->session('email');
  my $model = $self->model('genomic_feature_disease_publication'); 
  $model->delete($GFD_publication_id, $email);
  $self->feedback_message('DELETED_GFDPUBLICATION_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

sub add_comment {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $GFD_publication_id = $self->param('GFD_publication_id');
  my $GFD_publication_comment = $self->param('GFD_publication_comment');
  my $email = $self->session('email');
  my $model = $self->model('genomic_feature_disease_publication'); 
  $model->add_comment($GFD_publication_id, $GFD_publication_comment, $email);
  $self->feedback_message('ADDED_COMMENT_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

sub delete_comment {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $GFD_publication_comment_id = $self->param('GFD_publication_comment_id');
  my $email = $self->session('email');
  my $model = $self->model('genomic_feature_disease_publication'); 
  $model->delete_comment($GFD_publication_comment_id, $email);
  $self->feedback_message('DELETED_COMMENT_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

1;
