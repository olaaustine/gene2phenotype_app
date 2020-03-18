package Gene2phenotype::Controller::GenomicFeature;
use base qw(Gene2phenotype::Controller::BaseController);

sub show {
  my $self = shift;
  my $model = $self->model('genomic_feature');
  my $gene_id = $self->param('dbID');

  my $gene_attribs = $model->fetch_by_dbID($gene_id);
  $self->stash(gene => $gene_attribs);
  $self->render(template => 'gene_page');
}

1;
