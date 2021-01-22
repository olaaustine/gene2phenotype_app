=head1 LICENSE
 
See the NOTICE file distributed with this work for additional information
regarding copyright ownership.
 
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
=cut
package Gene2phenotype::Controller::Search;
use base qw(Gene2phenotype::Controller::BaseController);

sub results {
  my $self = shift;
  my $model = $self->model('search');

  my $search_term = $self->param('search_term');
  $search_term =~ s/'/\\'/g;
  my $panel = $self->param('panel');

  my @authorised_panels = ();     

  if (!$search_term) {
    return $self->redirect_to("/gene2phenotype/");
  }

  my $search_type = $model->identify_search_type($search_term);

  my $logged_in = $self->stash('logged_in');
  my $authorised_panels = $self->stash('authorised_panels');

  if (!grep {$panel eq $_} @$authorised_panels) {
    return $self->redirect_to("/gene2phenotype/");
  }

  my $is_authorised = ($logged_in) ? 1 : 0;

  my @search_panels = ();
  if ($panel eq 'ALL') {
    @search_panels = grep { $_ ne 'ALL' } @$authorised_panels;
  } else {
    push @search_panels, $panel;
  }

  my $search_results;
  if ($search_type eq 'gene_symbol') {
    $search_results = $model->fetch_all_by_gene_symbol($search_term, \@search_panels, $is_authorised);
  } elsif ($search_type eq 'disease_name') {
    $search_results = $model->fetch_all_by_disease_name($search_term, \@search_panels, $is_authorised);
  } elsif ($search_type eq 'contains_search_term') {
    $search_results = $model->fetch_all_by_substring($search_term, \@search_panels, $is_authorised); 
  } else {
    $search_results = undef;
  }

  my $lgm_search_results;
  if ($search_type eq 'gene_symbol') {
    $lgm_search_results = $model->fetch_all_lgms_by_gene_symbol($search_term, \@search_panels, $is_authorised);
  } elsif ($search_type eq 'disease_name') {
    $lgm_search_results = $model->fetch_all_lgms_by_disease_name($search_term, \@search_panels, $is_authorised);
  } 

  $self->stash(lgm_search_results => $lgm_search_results);
  $self->stash(search_results => $search_results);
  $self->stash(search_term => $search_term);
  $self->session(last_url => "/gene2phenotype/search?panel=$panel&search_term=$search_term");

  if ($is_authorised ) {
    $self->render(template => 'user/searchresults');
  } else {
    $self->render(template => 'searchresults');
  }
}

1;
