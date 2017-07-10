package Gene2phenotype::Controller::GenomicFeatureDiseaseComment;
use base qw(Gene2phenotype::Controller::BaseController);

sub add {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id'); 
  my $GFD_comment = $self->param('GFD_comment'); 

  if ($GFD_comment) {
    my $email = $self->session('email');
    my $model = $self->model('genomic_feature_disease_comment');
    my $GFD_id = $self->param('GFD_id');
    my $email = $self->session('email');  
    $model->add($GFD_id, $GFD_comment, $email);
    $self->feedback_message('ADDED_COMMENT_SUC');
  } else {
    $self->feedback_message('EMPTY_COMMENT');
  }
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

sub delete {
  my $self = shift;
  my $GFD_comment_id = $self->param('GFD_comment_id');
  my $GFD_id = $self->param('GFD_id');
  my $email = $self->session('email');  
  my $model = $self->model('genomic_feature_disease_comment');
  $model->delete($GFD_comment_id, $email);
  $self->feedback_message('DELETED_COMMENT_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

1;
