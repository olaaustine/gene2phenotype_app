package Gene2phenotype::Controller::Search;
use Mojo::Base 'Mojolicious::Controller';


sub results {
  my $self = shift;

  my $model = $self->model('search');

  my $search_term = $self->param('search_term');

  my $search_type = $model->identify_search_type($search_term);

  my $search_results = $model->fetch_all_by_substring($search_term); 

  $self->stash(search_results => $search_results);
  $self->stash(search_term => $search_term);

  $self->render(template => 'searchresults');
}


# show
# update
# add
# delete 
1;
