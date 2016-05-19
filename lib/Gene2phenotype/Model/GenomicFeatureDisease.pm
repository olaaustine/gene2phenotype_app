package Gene2phenotype::Model::GenomicFeatureDisease; 
use Mojo::Base 'MojoX::Model';


sub fetch_by_dbID {
  my $self = shift;
  my $dbID = shift;

  my $registry = $self->app->defaults('registry');
  my $GFD_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genomicfeaturedisease');
  my $GFD = $GFD_adaptor->fetch_by_dbID($dbID);

  my $GFD_category = $self->_get_GFD_category($GFD);
  my $GFD_category_list = $self->_get_GFD_category_list($GFD);
  my $attributes = $self->_get_GFD_action_attributes($GFD);
  my $publications = $self->_get_publications($GFD);
  my $phenotypes = $self->_get_phenotypes($GFD);
  my $organs = $self->_get_organs($GFD); 


  my $add_GFD_action = $self->_get_GFD_action_attributes_list('add');
  my $add_AR_loop = $add_GFD_action->{AR};
  my $add_MC_loop = $add_GFD_action->{MC};

  return {
    GFD_id => $dbID,
    GFD_category => $GFD_category,
    GFD_category_list => $GFD_category_list,
    GFD_actions => $attributes,
    publications => $publications,
    phenotypes => $phenotypes,
    organs => $organs,
    add_AR_loop => $add_AR_loop,
    add_MC_loop => $add_MC_loop,
  };

}

sub _get_GFD_category_list {
  my $self = shift;
  my $GFD = shift;
  my $GFD_category = $GFD->DDD_category;
  my $GFD_id = $GFD->dbID;
  my $registry = $self->app->defaults('registry');
  my $attribute_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'attribute');
  my $attribs = $attribute_adaptor->get_attribs_by_type_value('DDD_Category');
  my @list = ();
  foreach my $value (sort keys %$attribs) {
    my $id = $attribs->{$value};
    my $is_selected =  ($value eq $GFD_category) ? 'selected' : '';
    if ($is_selected) {
      push @list, [$value => $id, selected => $is_selected];
    } else {
      push @list, [$value => $id];
    }
  }
  return \@list;
}

sub _get_GFD_category {
  my $self = shift;
  my $GFD = shift;
  my $category = $GFD->DDD_category || 'Not assigned';
  return $category;
}

sub _get_GFD_action_attributes_list {
  my $self = shift;
  my $type = shift;
  my $GFD_action = shift;

  my @ARs = ();
  my $mutation_consequence = '';
  if ($type eq 'edit') {
    @ARs = split(',', $GFD_action->allelic_requirement);
    $mutation_consequence = $GFD_action->mutation_consequence;
  }

  my $registry = $self->app->defaults('registry');
  my $attribute_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'attribute');
  my $attribs = $attribute_adaptor->get_attribs_by_type_value('allelic_requirement');
  my @AR_tmpl = ();
  foreach my $value (sort keys %$attribs) {
    my $id = $attribs->{$value};
    if ($type eq 'edit') {
      my $checked = (grep $_ eq $value, @ARs) ? 'checked' : '';
      push @AR_tmpl, {
        AR_attrib_id => $id,
        AR_attrib_value => $value,
        checked => $checked,
      };
    } else {
      push @AR_tmpl, {
        AR_attrib_id => $id,
        AR_attrib_value => $value,
      };
    }
  }

  $attribs = $attribute_adaptor->get_attribs_by_type_value('mutation_consequence');
  my @MC_tmpl = ();
  foreach my $value (sort keys %$attribs) {
    my $id = $attribs->{$value};
    if ($type eq 'edit') {
      my $selected = ($value eq $mutation_consequence) ? 'selected' : undef;
      if ($selected) {
        push @MC_tmpl, [$value => $id, selected => $selected];
      } else {
        push @MC_tmpl, [$value => $id];
      }
    } else {
      push @MC_tmpl, [ $value => $id ];
    }
  }
  return {AR => \@AR_tmpl, MC => \@MC_tmpl};
}

sub _get_GFD_action_attributes {
  my $self = shift;
  my $GFD = shift;

  my $GFD_actions = $GFD->get_all_GenomicFeatureDiseaseActions();
  my @actions = ();
  foreach my $gfda (@$GFD_actions) {
    my $allelic_requirement = $gfda->allelic_requirement || 'Not assigned';
    my $mutation_consequence_summary = $gfda->mutation_consequence || 'Not assigned';
    my $edit_GFD_action = $self->_get_GFD_action_attributes_list('edit', $gfda);
    push @actions, {
      allelic_requirement => $allelic_requirement,
      mutation_consequence_summary => $mutation_consequence_summary,
      AR_loop => $edit_GFD_action->{AR},
      MC_loop => $edit_GFD_action->{MC},
      GFD_action_id => $gfda->dbID,
    };
  }

  return \@actions;
}

sub _get_publications {
  my $self = shift;
  my $GFD = shift;
  my @publications = ();

  my $GFD_publications = $GFD->get_all_GFDPublications;
  foreach my $GFD_publication (sort {$a->get_Publication->title cmp $b->get_Publication->title} @$GFD_publications) {
    my $publication = $GFD_publication->get_Publication;
    my $comments = $GFD_publication->get_all_GFDPublicationComments;
    my @comments_tmpl = ();
    foreach my $comment (@$comments) {
      push @comments_tmpl, {
        user => $comment->get_User()->username,
        date => $comment->created,
        comment_text => $comment->comment_text,
        GFD_publication_comment_id => $comment->dbID,
        GFD_id => $GFD->dbID,
      };
    }
    my $pmid = $publication->pmid;
    my $title = $publication->title;
    my $source = $publication->source;

    $title ||= 'PMID:' . $pmid;
    $title .= " ($source)" if ($source);

    push @publications, {
      comments => \@comments_tmpl,
      title => $title,
      pmid => $pmid,
      GFD_publication_id => $GFD_publication->dbID,
      GFD_id => $GFD->dbID,
    };
  }
  return \@publications;
}

sub _get_phenotypes {
  my $self = shift;
  my $GFD = shift;

  my @phenotypes = ();
  my $GFD_phenotypes = $GFD->get_all_GFDPhenotypes;
  foreach my $GFD_phenotype (@$GFD_phenotypes) {
    my $phenotype = $GFD_phenotype->get_Phenotype;
    my $stable_id = $phenotype->stable_id;
    my $name = $phenotype->name;
    my $comments = $GFD_phenotype->get_all_GFDPhenotypeComments;
    my @comments_tmpl = ();
    foreach my $comment (@$comments) {
      push @comments_tmpl, {
        user => $comment->get_User()->username,
        date => $comment->created,
        comment_text => $comment->comment_text,
        GFD_phenotype_comment_id => $comment->dbID,
        GFD_id => $GFD->dbID,
      };
    }

    push @phenotypes, {
      GFD_phenotype_comments => \@comments_tmpl,
      stable_id => $stable_id,
      name => $name,
      GFD_phenotype_id => $GFD_phenotype->dbID,
    };
  }
  my @sorted_phenotypes = sort {$a->{name} cmp $b->{name}} @phenotypes;
  return \@phenotypes;
}

sub _get_organs {
  my $self = shift;
  my $GFD = shift;
  my @organ_list = ();
  my $organs = $GFD->get_all_GFDOrgans;
  foreach my $organ (@$organs) {
    my $name = $organ->get_Organ()->name;
    push @organ_list, $name;
  }
  return \@organ_list;
}

1;
