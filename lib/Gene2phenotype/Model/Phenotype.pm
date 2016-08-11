package Gene2phenotype::Model::Phenotype;
use Mojo::Base 'MojoX::Model';

sub fetch_by_dbID {
  my $self = shift;
  my $dbID = shift;
  my $registry = $self->app->defaults('registry');
  my $phenotype_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'phenotype');
  my $phenotype = $phenotype_adaptor->fetch_by_dbID($dbID);
  return $phenotype;
}

1;
