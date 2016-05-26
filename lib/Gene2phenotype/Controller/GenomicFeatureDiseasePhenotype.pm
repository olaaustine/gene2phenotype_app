package Gene2phenotype::Controller::GenomicFeatureDiseasePhenotype;
use Mojo::Base 'Mojolicious::Controller';

sub update {
  my $self = shift;
  my $phenotype_ids = $self->param('phenotype_ids');
  my $GFD_id = $self->param('GFD_id');
  my $email = $self->session('email');
  my $model = $self->model('genomic_feature_disease_phenotype');
  $model->update_phenotype_list($GFD_id, $email, $phenotype_ids);
  return $self->redirect_to("/gfd?GFD_id=$GFD_id");
}

sub delete {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $GFD_phenotype_id = $self->param('GFD_phenotype_id');
  my $email = $self->session('email');  
  my $model = $self->model('genomic_feature_disease_phenotype');
  $model->delete($GFD_phenotype_id, $email);
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
  return $self->redirect_to("/gfd?GFD_id=$GFD_id");
}

sub delete_comment {
  my $self = shift;
  my $GFD_phenotype_comment_id = $self->param('GFD_phenotype_comment_id');
  my $GFD_id = $self->param('GFD_id');
  my $email = $self->session('email');  
  my $model = $self->model('genomic_feature_disease_phenotype');
  $model->delete_comment($GFD_phenotype_comment_id, $email);
  return $self->redirect_to("/gfd?GFD_id=$GFD_id");
}


1;
