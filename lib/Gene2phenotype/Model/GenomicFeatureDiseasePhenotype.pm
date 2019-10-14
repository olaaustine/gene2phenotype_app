package Gene2phenotype::Model::GenomicFeatureDiseasePhenotype;
use Mojo::Base 'MojoX::Model';

sub fetch_by_dbID {
  my $self = shift;
  my $GFD_phenotype_id = shift;
  my $registry = $self->app->defaults('registry');  
  my $GFDPhenotype_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureDiseasePhenotype');
  my $GFDPhenotype = $GFDPhenotype_adaptor->fetch_by_dbID($GFD_phenotype_id);
  return $GFDPhenotype;
}

sub fetch_by_GFD_id_phenotype_id {
  my $self = shift;
  my $GFD_id = shift;
  my $phenotype_id = shift;
  my $registry = $self->app->defaults('registry');  
  my $GFDPhenotype_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureDiseasePhenotype');
  my $GFDPhenotype = $GFDPhenotype_adaptor->fetch_by_GFD_id_phenotype_id($GFD_id, $phenotype_id);
  return $GFDPhenotype;
}

sub delete {
  my $self = shift;
  my $GFD_phenotype_id = shift;
  my $email = shift;

  my $registry = $self->app->defaults('registry');  
  my $GFDPhenotype_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureDiseasePhenotype');
  my $user_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'user');

  my $GFDPhenotype = $GFDPhenotype_adaptor->fetch_by_dbID($GFD_phenotype_id);
  my $user = $user_adaptor->fetch_by_email($email);

  $GFDPhenotype_adaptor->delete($GFDPhenotype, $user); 
}

sub add_phenotype {
  my $self = shift;
  my $GFD_id = shift;
  my $phenotype_id = shift;
  my $email = shift;

  my $registry = $self->app->defaults('registry');  
  my $GFD_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureDisease');
  my $GFDPhenotype_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureDiseasePhenotype');
  my $user_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'user');
  my $user = $user_adaptor->fetch_by_email($email);

  my $GFD = $GFD_adaptor->fetch_by_dbID($GFD_id);
  my $GFDP = Bio::EnsEMBL::G2P::GenomicFeatureDiseasePhenotype->new(
    -genomic_feature_disease_id => $GFD_id,
    -phenotype_id => $phenotype_id,
    -adaptor => $GFDPhenotype_adaptor,
  );
  $GFDPhenotype_adaptor->store($GFDP, $user);

}

sub delete_phenotype {
  my $self = shift;
  my $GFD_id = shift;
  my $phenotype_id = shift;
  my $email = shift;

  my $registry = $self->app->defaults('registry');  
  my $GFDPhenotype_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureDiseasePhenotype');
  my $GFDP = $GFDPhenotype_adaptor->fetch_by_GFD_id_phenotype_id($GFD_id, $phenotype_id);

  my $user_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'user');
  my $user = $user_adaptor->fetch_by_email($email);

  $GFDPhenotype_adaptor->delete($GFDP, $user);
}

sub update_phenotype_list {
  my $self = shift;
  my $GFD_id = shift;
  my $email = shift;
  my $update_phenotype_ids_string = shift;

  my $registry = $self->app->defaults('registry');  
  my $GFD_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureDisease');
  my $GFDPhenotype_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GenomicFeatureDiseasePhenotype');
  my $user_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'user');

  my $GFD = $GFD_adaptor->fetch_by_dbID($GFD_id);
  my $user = $user_adaptor->fetch_by_email($email);

  my @phenotype_ids = split(',', $self->get_phenotype_ids_list($GFD));
  my @updated_phenotype_ids = split(',', $update_phenotype_ids_string);
  my @to_delete_ids = ();
  my @to_add_ids = ();

  foreach my $id (@phenotype_ids) {
    if (!grep {$id == $_} @updated_phenotype_ids) {
      push @to_delete_ids, $id;
    }
  }
  foreach my $id (@updated_phenotype_ids) {
    if (!grep {$id == $_} @phenotype_ids) {
      push @to_add_ids, $id;
    }
  }
  if (@to_add_ids) {
    foreach my $phenotype_id (@to_add_ids) {
      my $GFDP = Bio::EnsEMBL::G2P::GenomicFeatureDiseasePhenotype->new(
        -genomic_feature_disease_id => $GFD_id,
        -phenotype_id => $phenotype_id,
        -adaptor => $GFDPhenotype_adaptor,
      );
      $GFDPhenotype_adaptor->store($GFDP);
    }
  }
  if (@to_delete_ids) {
    foreach my $phenotype_id (@to_delete_ids) {
      my $GFDP = $GFDPhenotype_adaptor->fetch_by_GFD_id_phenotype_id($GFD_id, $phenotype_id);
      $GFDPhenotype_adaptor->delete($GFDP, $user);
    }
  }
}

sub get_phenotype_ids_list {
  my $self = shift;
  my $GFD = shift;
  my @phenotype_ids = ();
  my $GFDPhenotypes = $GFD->get_all_GFDPhenotypes;
  foreach my $GFDPhenotype (@$GFDPhenotypes) {
    push @phenotype_ids, $GFDPhenotype->get_Phenotype->dbID;
  }
  return join(',', @phenotype_ids);
}

sub add_comment {
  my $self = shift;
  my $GFD_phenotype_id = shift;
  my $comment = shift;
  my $email = shift;

  my $registry = $self->app->defaults('registry');  
  my $GFDPhenotypeComment_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GFDPhenotypeComment');
  my $user_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'user');

  my $user = $user_adaptor->fetch_by_email($email);

  my $GFDPhenotypeComment = Bio::EnsEMBL::G2P::GFDPhenotypeComment->new(
    -comment_text => $comment,
    -genomic_feature_disease_phenotype_id => $GFD_phenotype_id,
    -adaptor => $GFDPhenotypeComment_adaptor,
  );

  $GFDPhenotypeComment_adaptor->store($GFDPhenotypeComment, $user);
}

sub delete_comment {
  my $self = shift;
  my $GFD_phenotype_comment_id = shift;
  my $email = shift;    

  my $registry = $self->app->defaults('registry');  
  my $GFDPhenotypeComment_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'GFDPhenotypeComment');
  my $user_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'user');

  my $user = $user_adaptor->fetch_by_email($email);

  my $GFD_phenotype_comment = $GFDPhenotypeComment_adaptor->fetch_by_dbID($GFD_phenotype_comment_id);  
  $GFDPhenotypeComment_adaptor->delete($GFD_phenotype_comment, $user);
}

1;
