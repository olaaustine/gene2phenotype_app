package Gene2phenotype::Model::GenomicFeatureDiseasePublication;
use Mojo::Base 'MojoX::Model';

sub add_publication {
  my $self = shift;
  my $GFD_id = shift;
  my $email = shift;
  my $source = shift;
  my $pmid = shift;
  my $title = shift;

  my $registry = $self->app->defaults('registry');  
  my $GFDPublication_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureDiseasePublication');
  my $text_mining_disease_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'TextMiningDisease');
  my $publication_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'Publication');

  my $user_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'user');
  my $user = $user_adaptor->fetch_by_email($email);

  my $publication;
  if ($pmid) {
    $publication = $publication_adaptor->fetch_by_PMID($pmid); 
  } else {
    $publication = $publication_adaptor->fetch_by_title($title); 
  }

  if (!$publication) {
    $publication = Bio::EnsEMBL::G2P::Publication->new(
      -pmid => $pmid,
      -title => $title,
      -source => $source,
    );
    $publication = $publication_adaptor->store($publication);
  }
  my $GFDPublication = $GFDPublication_adaptor->fetch_by_GFD_id_publication_id($GFD_id, $publication->dbID);
  if (!$GFDPublication) {
    $GFDPublication = Bio::EnsEMBL::G2P::GenomicFeatureDiseasePublication->new(
      -genomic_feature_disease_id => $GFD_id,
      -publication_id => $publication->dbID,
      -adaptor => $GFDPublication_adaptor,
    );
    $GFDPublication_adaptor->store($GFDPublication);
  }

  eval {  $text_mining_disease_adaptor->store_all_by_Publication($publication); }; warn $@ if $@;
}

sub delete {
  my $self = shift;
  my $GFDPublication_id = shift;
  my $email = shift;

  my $registry = $self->app->defaults('registry');  
  my $GFDPublication_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureDiseasePublication');
  my $user_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'user');
  my $user = $user_adaptor->fetch_by_email($email);

  my $GFDPublication = $GFDPublication_adaptor->fetch_by_dbID($GFDPublication_id);  
  $GFDPublication_adaptor->delete($GFDPublication, $user);
}

sub add_comment {
  my $self = shift;
  my $GFD_publication_id = shift;
  my $comment = shift;
  my $email = shift;

  my $registry = $self->app->defaults('registry');
  my $GFDPublicationComment_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GFDPublicationComment');
  my $user_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'user');

  my $user = $user_adaptor->fetch_by_email($email);

  my $GFDPublicationComment = Bio::EnsEMBL::G2P::GFDPublicationComment->new(
    -comment_text => $comment,
    -genomic_feature_disease_publication_id => $GFD_publication_id,
    -adaptor => $GFDPublicationComment_adaptor,
  );

  $GFDPublicationComment_adaptor->store($GFDPublicationComment, $user);
}

sub delete_comment {
  my $self = shift;
  my $GFD_publication_comment_id = shift;
  my $email = shift;

  my $registry = $self->app->defaults('registry');
  my $GFDPublicationComment_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GFDPublicationComment');
  my $user_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'user');

  my $user = $user_adaptor->fetch_by_email($email);

  my $GFD_publication_comment = $GFDPublicationComment_adaptor->fetch_by_dbID($GFD_publication_comment_id);
  $GFDPublicationComment_adaptor->delete($GFD_publication_comment, $user);
}
1;
