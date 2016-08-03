package Gene2phenotype::Model::User;
use Mojo::Base 'MojoX::Model';

sub fetch_by_email {
  my $self = shift;
  my $email = shift;
  my $registry = $self->app->defaults('registry');
  my $user_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'user');
  my $user = $user_adaptor->fetch_by_email($email);
  return $user;
}
1;
