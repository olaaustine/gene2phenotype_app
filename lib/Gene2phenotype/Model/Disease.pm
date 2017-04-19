package Gene2phenotype::Model::Disease;
use Mojo::Base 'MojoX::Model';

sub fetch_by_dbID {
  my $self = shift;
  my $dbID = shift;
  my $registry = $self->app->defaults('registry');
  my $disease_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'disease');
  my $disease = $disease_adaptor->fetch_by_dbID($dbID);
  my $name = $disease->name;
  my $mim = $disease->mim;
  return {
    disease_id => $dbID,
    name => $name,
    mim => $mim,
  };
}

sub fetch_by_name {
  my $self = shift;
  my $name = shift;
  my $registry = $self->app->defaults('registry');
  my $disease_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'disease');
  my $disease = $disease_adaptor->fetch_by_name($name);
  return $disease;
}

sub add {
  my $self = shift;
  my $name = shift;
  my $registry = $self->app->defaults('registry');
  my $disease_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'disease');

  my $disease =  Bio::EnsEMBL::G2P::Disease->new(
    -name => $name,
    -adaptor => $disease_adaptor,
  );
  $disease = $disease_adaptor->store($disease);
}

sub already_in_db {
  my $self = shift;
  my $disease_id = shift;
  my $name = shift;

  my $registry = $self->app->defaults('registry');
  my $disease_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'disease');

  my $disease = $disease_adaptor->fetch_by_name($name);

  if ($disease) {
    return 1;  
  }  
  return 0;
}

sub update {
  my $self = shift;
  my $disease_id = shift;
  my $mim = shift;
  my $name = shift;
  
  my $registry = $self->app->defaults('registry');
  my $disease_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'disease');
  my $disease = $disease_adaptor->fetch_by_dbID($disease_id);
  if ($disease->name ne $name || ($disease->mim && $disease->mim ne $mim)) {

    $disease =  Bio::EnsEMBL::G2P::Disease->new(
      -name => $name,
      -mim => $mim,
      -adaptor => $disease_adaptor,
    );
    $disease = $disease_adaptor->store($disease);
  }
  return $disease->dbID;
}

1;
