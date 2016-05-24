package Gene2phenotype::Controller::GenomicFeatureDisease;
use Mojo::Base 'Mojolicious::Controller';

sub show {
  my $self = shift;
  my $model = $self->model('genomic_feature_disease');  
  my $dbID = $self->param('dbID');
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

  my $return = $model->update_GFD_category($GFD_id, $category_attrib_id);

  $self->render(text => "Update GFD category $return");  
}


1;
