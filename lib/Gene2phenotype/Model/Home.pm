package Gene2phenotype::Model::Home;
use Mojo::Base 'MojoX::Model';

sub fetch_updates {
  my $self = shift;
  my $logged_in = shift;
  my $authorised_panels = shift;
  my $registry = $self->app->defaults('registry');
  my $GFDL_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'genomicfeaturediseaselog');
  my $panel_adaptor = $registry->get_adaptor('human', 'gene2phenotype', 'panel');

  my @results = ();

  my @panels = map { $_->name } @{$panel_adaptor->fetch_all_visible_Panels};
  foreach my $panel (@{$panel_adaptor->fetch_all_visible_Panels}) {
    # if in authorised panels show all entries
    my $only_visible_entries = (!grep{$_ eq $panel->name} @$authorised_panels) ? 1 : 0;
    my $updates = $GFDL_adaptor->fetch_latest_updates($panel->name, 10, $only_visible_entries);
    push @results, { panel => $panel->name, updates => $self->format_updates($updates)};
  }  

  foreach my $panel_name (@$authorised_panels) {
    next if ($panel_name eq 'ALL');
    if (!grep{$_ eq $panel_name} @panels) {
      my $updates = $GFDL_adaptor->fetch_latest_updates($panel_name, 10);
      push @results, { panel => $panel_name, updates => $self->format_updates($updates)};
    }
  }
  return \@results;
}

sub format_updates {
  my $self = shift;
  my $updates = shift;
  my @results = ();
  foreach my $update (@$updates) {
    my ($date, $time) = split(/\s/, $update->created);    
    push @results, {
      date => $date,
      gene_symbol => $update->gene_symbol,
      disease_name => $update->disease_name,
      GFD_ID => $update->genomic_feature_disease_id,
      search_type => 'gfd' 
    }
  }
  return \@results;
}


1;
