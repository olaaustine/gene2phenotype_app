package Gene2phenotype::Controller::GenomicFeatureDisease;
use base qw(Gene2phenotype::Controller::BaseController);

sub show {
  my $self = shift;
  my $model = $self->model('genomic_feature_disease');  
  my $disease_model = $self->model('disease');
  my $GF_model = $self->model('genomic_feature');

  my $dbID = $self->param('dbID') || $self->param('GFD_id');

  if (!$dbID) {
    return $self->render(template => 'not_found');
  }
  # check if GFD is authorised
  my $logged_in = $self->session('logged_in'); 

  my $gfd = $model->fetch_by_dbID($dbID, $logged_in); 

  $self->stash(gfd => $gfd);

  # current panel
  if ($self->session('logged_in')) {
    my $current_panel = $gfd->{panel};
    my @panels = @{$self->session('panels')};
    my @duplicate_to_panels = ();
    foreach my $panel (@panels) {
      if ($panel ne $current_panel) {
        push @duplicate_to_panels, $panel;
      }
    } 
    if (scalar @duplicate_to_panels > 0) {
      $self->stash(duplicate => 1);
      $self->stash(duplicate_to => \@duplicate_to_panels);
    } else {
      $self->stash(duplicate => 0);
      $self->stash(duplicate_to => []);
    }
  } else {
    $self->stash(duplicate => 0);
    $self->stash(duplicate_to => []);
  } 

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

sub duplicate {
  my $self = shift;        
  my $panel = $self->param('panel');
  my $data = $self->every_param('duplicate_data_id');
  my $GFD_id = $self->param('GFD_id');
  my $model = $self->model('genomic_feature_disease');  
  my $email = $self->session('email');

  my $result = $model->duplicate($GFD_id, $panel, $data, $email);
  my $feedback = $result->[1];
  my $gfd = $result->[0];
  $GFD_id = $gfd->dbID;
  $self->feedback_message($feedback);
  return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
}

sub create {
  my $self = shift;
  
  if ($self->session('logged_in')) {
    my $email = $self->session('email');

    my $user_model = $self->model('user');
    my $user = $user_model->fetch_by_email($email);
    my $user_model = $self->model('user');
    my @panels = split(',', $user->panel);
    $self->stash(panels => \@panels);

    my $gfd_model = $self->model('genomic_feature_disease');
    my $GFD_category_list = $gfd_model->get_default_GFD_category_list;
    $self->stash(GFD_category_list => $GFD_category_list);
  }

  $self->render(template => 'create_gfd');
}

sub add {
  my $self = shift;
  my $panel = $self->param('panel');
  my $gene_name = $self->param('gene_name');
  my $disease_name = $self->param('disease_name');
  my $category_attrib_id = $self->param('category_attrib_id');
  my $email = $self->session('email');

  my $model = $self->model('genomic_feature_disease');  
  my $gf_model = $self->model('genomic_feature');
  my $disease_model = $self->model('disease');

  my $disease = $disease_model->fetch_by_name($disease_name);
  if (!$disease) {
    $disease = $disease_model->add($disease_name);
  }

  my $gf = $gf_model->fetch_by_gene_symbol($gene_name); 
  if (!$gf) {
    $self->feedback_message('GF_NOT_IN_DB');
    return $self->redirect_to("/gene2phenotype/gfd/create");
  }
  
  my $gfd = $model->fetch_by_panel_GenomicFeature_Disease($panel, $gf, $disease);

  if ($gfd) {
    my $GFD_id = $gfd->dbID;
    return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
  } else {
    $gfd = $model->add($panel, $gf, $disease, $category_attrib_id, $email);
    my $GFD_id = $gfd->dbID;
    return $self->redirect_to("/gene2phenotype/gfd?GFD_id=$GFD_id");
  }
}

sub delete {
  my $self = shift;
  my $GFD_id = $self->param('dbID');
  my $model = $self->model('genomic_feature_disease');  
  my $email = $self->session('email');

  $model->delete($email, $GFD_id);
  my $last_url = $self->session('last_url');
  $self->feedback_message('DELETED_GFD_SUC');
  return $self->redirect_to($last_url);
}

sub update {
  my $self = shift;
  my $category_attrib_id = $self->param('category_attrib_id'); 
  my $GFD_id = $self->param('GFD_id');
  my $model = $self->model('genomic_feature_disease');  
  my $email = $self->session('email');
  $model->update_GFD_category($email, $GFD_id, $category_attrib_id);
  $self->session(last_url => "/gene2phenotype/gfd?GFD_id=$GFD_id");
  $self->feedback_message('UPDATED_CONFIDENCE_CATEGORY_SUC');
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

sub update_disease {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $disease_id = $self->param('disease_id');
  my $name = $self->param('name');
  my $mim = $self->param('mim');
  my $model = $self->model('genomic_feature_disease');  
  my $email = $self->session('email');
  $model->update_disease($email, $GFD_id, $disease_id, $name, $mim);
  $self->session(last_url => "/gene2phenotype/gfd?GFD_id=$GFD_id");
  $self->feedback_message('UPDATED_DISEASE_ATTRIBS_SUC');
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
