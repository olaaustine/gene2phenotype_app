package Gene2phenotype::Controller::Search;
use Mojo::Base 'Mojolicious::Controller';

sub results {
  my $self = shift;

  my $model = $self->model('search');

  my $search_term = $self->param('search_term');
  my $panel = $self->param('panel');

  my $search_type = $model->identify_search_type($search_term);

  my $logged_in = $self->stash('logged_in');
  my $only_authorised = ($logged_in) ? 0 : 1;

  my $search_results = $model->fetch_all_by_substring($search_term, $panel, $only_authorised); 

  $self->stash(search_results => $search_results);
  $self->stash(search_term => $search_term);
  $self->session(last_url => "/search?panel=$panel&search_term=$search_term");
  $self->render(template => 'searchresults');
}


# show
# update
# add
# delete 
1;
