package Gene2phenotype::Controller::GenomicFeatureDiseasePhenotype;
use Mojo::Base 'Mojolicious::Controller';

sub update {
  my $self = shift;
  my $phenotype_ids = $self->param('phenotype_ids');
  my $GFD_id = $self->param('GFD_id');

  $self->render(text => "Update phenotype");

}

sub delete {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $GFD_phenotype_id = $self->param('GFD_phenotype_id');

  $self->render(text => "Delete phenotype");

}

sub add_comment {
  my $self = shift;

  my $GFD_phenotype_comment = $self->param('GFD_phenotype_comment');
  my $GFD_phenotype_id = $self->param('GFD_phenotype_id');
  my $GFD_id = $self->param('GFD_id');

  $self->render(text => "Add phenotype comment");
}


sub delete_comment {
  my $self = shift;

  $self->render(text => "Delete phenotype comment");

}


1;
