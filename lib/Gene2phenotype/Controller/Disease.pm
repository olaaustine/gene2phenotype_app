package Gene2phenotype::Controller::Disease;
use base qw(Gene2phenotype::Controller::BaseController);

sub show {
  my $self = shift;
  my $model = $self->model('disease'); 
  my $disease_id = $self->param('dbID');
        
  my $disease_attribs = $model->fetch_by_dbID($disease_id);
  $self->stash(disease => $disease_attribs);  
  $self->render(template => 'disease');
}

sub update {
  my $self = shift;
  my $disease_id = $self->param('disease_id');
  my $mim = $self->param('mim');
  my $name = $self->param('name');

  my $prev_mim = $self->param('prev_mim');
  my $prev_name = $self->param('prev_name');

  my $model = $self->model('disease'); 

  if ($name ne $prev_name || $mim ne $prev_mim) {
    if ($model->already_in_db($disease_id, $name)) {
      $model->update($disease_id, $mim, $name); 
      $self->feedback_message('DISEASE_NAME_IN_DB');
    } else {
      $model->update($disease_id, $mim, $name); 
      $self->feedback_message('UPDATED_DISEASE_ATTRIBS_SUC');
    }
  } else {
    $self->feedback_message('DATA_NOT_CHANGED');
  }
  $self->redirect_to("/disease?dbID=$disease_id");
}

1;
