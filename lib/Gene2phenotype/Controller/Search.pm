package Gene2phenotype::Controller::Search;
use Mojo::Base 'Mojolicious::Controller';

sub results {
  my $self = shift;

  my $model = $self->model('search');

  my $search_term = $self->param('search_term');
  my $panel = $self->param('panel');

  my $search_type = $model->identify_search_type($search_term);

  my $logged_in = $self->stash('logged_in');
  my $only_authorised = ($logged_in) ? 1 : 0;

  my $search_results;
  if ($search_type eq 'gene_symbol') {
    $search_results = $model->fetch_all_by_gene_symbol($search_term, $panel, $only_authorised);
  } elsif ($search_type eq 'disease_name') {
    $search_results = $model->fetch_all_by_disease_name($search_term, $panel, $only_authorised);
  } elsif ($search_type eq 'contains_search_term') {
    $search_results = $model->fetch_all_by_substring($search_term, $panel, $only_authorised); 
  } else {
    $search_results = undef;
  }
  $self->stash(search_results => $search_results);
  $self->stash(search_term => $search_term);
  $self->session(last_url => "/search?panel=$panel&search_term=$search_term");
  $self->render(template => 'searchresults');
}

1;
