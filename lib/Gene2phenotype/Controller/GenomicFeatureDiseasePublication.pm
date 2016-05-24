package Gene2phenotype::Controller::GenomicFeatureDiseasePublication;
use Mojo::Base 'Mojolicious::Controller';


sub add {
  my $self = shift;

  my $GFD_id = $self->param('GFD_id');
  my $source = $self->param('source');
  my $pmid = $self->param('pmid');
  my $title = $self->param('title');

  $self->render(text => "Add publication");
}

sub update {
  my $self = shift;

}

sub delete {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $GFD_publication_id = $self->param('GFD_publication_id');
  
  $self->render(text => "Delete publication");
}

sub add_comment {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $GFD_publication_id = $self->param('GFD_publication_id');
  my $GFD_publication_comment = $self->param('GFD_publication_comment');

  $self->render(text => "Add comment");
}


sub delete_comment {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $GFD_publication_id = $self->param('GFD_publication_id');

  $self->render(text => "Delete comment");
}


1;
