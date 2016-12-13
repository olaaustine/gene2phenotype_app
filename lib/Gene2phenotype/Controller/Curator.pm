package Gene2phenotype::Controller::Curator;
use Mojo::Base 'Mojolicious::Controller';

sub no_publication {
  my $self = shift;
  my $logged_in = $self->stash('logged_in');
  my $is_authorised = ($logged_in) ? 1 : 0;

  if ($is_authorised) {
    my $user_model = $self->model('user');
    my $gfd_model = $self->model('genomic_feature_disease');
    my $email = $self->session('email');  

    my $user = $user_model->fetch_by_email($email); 
    my @panels = split(',', $user->panel);
    my @results = ();    
    foreach my $panel (@panels) {
      my $gfds = $gfd_model->fetch_all_by_panel_without_publication($panel);
      push @results, {
        panel => $panel,
        gfds => $gfds,
      };
    }
    $self->stash( gfds_no_publication => \@results);
    $self->render(template => 'curation_no_publication');
  } else {
    return $self->redirect_to("/gene2phenotype/");
  }
}

sub restricted {
  my $self = shift;
  my $logged_in = $self->stash('logged_in');
  my $is_authorised = ($logged_in) ? 1 : 0;

  if ($is_authorised) {
    my $user_model = $self->model('user');
    my $gfd_model = $self->model('genomic_feature_disease');
    my $email = $self->session('email');  

    my $user = $user_model->fetch_by_email($email); 
    my @panels = split(',', $user->panel);
    my @results = ();    
    foreach my $panel (@panels) {
      my $gfds = $gfd_model->fetch_all_by_panel_restricted($panel);
      push @results, {
        panel => $panel,
        gfds => $gfds,
      };
    }
    $self->stash( gfds_restricted => \@results);
    $self->render(template => 'curation_restricted');
  } else {
    return $self->redirect_to("/gene2phenotype/");
  }
}

1;
