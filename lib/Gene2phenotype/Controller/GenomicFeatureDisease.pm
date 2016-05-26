package Gene2phenotype::Controller::GenomicFeatureDisease;
use Mojo::Base 'Mojolicious::Controller';

sub show {
  my $self = shift;
  my $model = $self->model('genomic_feature_disease');  
  my $dbID = $self->param('dbID') || $self->param('GFD_id');
  my $gfd = $model->fetch_by_dbID($dbID); 
  $self->stash(gfd => $gfd);
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
  return $self->redirect_to("/gfd?GFD_id=$GFD_id");
}


1;
