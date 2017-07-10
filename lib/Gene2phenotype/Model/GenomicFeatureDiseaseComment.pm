package Gene2phenotype::Model::GenomicFeatureDiseaseComment;
use Mojo::Base 'MojoX::Model';

sub add {
  my $self = shift;
  my $GFD_id = shift;
  my $comment = shift;
  my $email = shift;

  my $registry = $self->app->defaults('registry');  
  my $GFDComment_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureDiseaseComment');
  my $user_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'user');

  my $user = $user_adaptor->fetch_by_email($email);

  my $GFDComment = Bio::EnsEMBL::G2P::GenomicFeatureDiseaseComment->new(
    -comment_text => $comment,
    -genomic_feature_disease_id => $GFD_id,
    -adaptor => $GFDComment_adaptor,
  );

  $GFDComment_adaptor->store($GFDComment, $user);
}

sub delete {
  my $self = shift;
  my $GFD_comment_id = shift;
  my $email = shift;    
  my $registry = $self->app->defaults('registry');  
  my $GFDComment_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureDiseaseComment');
  my $user_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'user');
  my $user = $user_adaptor->fetch_by_email($email);
  my $GFD_comment = $GFDComment_adaptor->fetch_by_dbID($GFD_comment_id);  
  $GFDComment_adaptor->delete($GFD_comment, $user);
}

1;
