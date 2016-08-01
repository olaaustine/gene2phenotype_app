package Gene2phenotype::Controller::GenomicFeatureDisease;
use base qw(Gene2phenotype::Controller::BaseController);

sub show {
  my $self = shift;
  my $model = $self->model('genomic_feature_disease');  
  my $disease_model = $self->model('disease');
  my $GF_model = $self->model('genomic_feature');

  my $dbID = $self->param('dbID') || $self->param('GFD_id');

  # check if GFD is authorised
  my $gfd = $model->fetch_by_dbID($dbID); 
  $self->stash(gfd => $gfd);

  my $disease_id = $gfd->{disease_id};
  my $disease_attribs = $disease_model->fetch_by_dbID($disease_id);
  $self->stash(disease => $disease_attribs);

  my $gene_id = $gfd->{gene_id};
  my $gene_attribs = $GF_model->fetch_by_dbID($gene_id);
  my $variations = $GF_model->fetch_variants($gene_id);
  $self->stash(gene => $gene_attribs, variations => $variations);

  $self->session(last_url => "/gene2phenotype/gfd?GFD_id=$dbID");
  $self->render(template => 'gfd');
}

sub add {
  my $self = shift;
}

sub delete {
  my $self = shift;

}

sub update {
  my $self = shift;
  my $category_attrib_id = $self->param('category_attrib_id'); 
  my $GFD_id = $self->param('GFD_id');
  my $model = $self->model('genomic_feature_disease');  
  my $email = $self->session('email');
  $model->update_GFD_category($email, $GFD_id, $category_attrib_id);
  $self->session(last_url => "/gene2phenotype/gfd?GFD_id=$GFD_id");
  $self->feedback_message('UPDATED_DDD_CATEGORY_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

sub update_organ_list {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $organ_id_list = join(',', @{$self->every_param('organ_id')});
  my $model = $self->model('genomic_feature_disease');  
  my $email = $self->session('email');
  $model->update_organ_list($email, $GFD_id, $organ_id_list);
  $self->session(last_url => "/gene2phenotype/gfd?GFD_id=$GFD_id");
  $self->feedback_message('UPDATED_ORGAN_LIST');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

sub update_visibility {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $visibility = $self->param('visibility'); #restricted, authorised 
  my $model = $self->model('genomic_feature_disease');  
  my $email = $self->session('email');
  $model->update_visibility($email, $GFD_id, $visibility);
  $self->session(last_url => "/gene2phenotype/gfd?GFD_id=$GFD_id");
  $self->feedback_message('UPDATED_VISIBILITY_STATUS_SUC');
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

1;
