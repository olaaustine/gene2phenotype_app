package Gene2phenotype::Controller::Publication;
use base qw(Gene2phenotype::Controller::BaseController);

use Bio::EnsEMBL::G2P::Utils::Net qw(do_GET);
use JSON;

sub get_description {
  my $self = shift;
  my $pmid = $self->param('pmid');
  my $http_proxy = $self->app->defaults('http_proxy');
  my $proxy = $self->app->defaults('proxy');
  my $url = "https://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ext_id:$pmid%20src:med&format=json";
  my $content = do_GET($url, $http_proxy, $proxy);
  my $json = get_description_from_europepmc($content);
  if ($json) {
    $self->render(json => $json);
  } else {
    # If we cannot get the publication description from EuropePMC then let's try Pubmed:
    $url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=$pmid&retmode=json";
    $content = do_GET($url, $http_proxy, $proxy);
    $json = get_description_from_pubmed($content, $pmid);
    $self->render(json => $json);
  }
}

sub get_description_from_europepmc {
  my $content = shift;
  my $hash = decode_json($content);
  my $result = $hash->{resultList}->{result}->[0];
  # Europ. J. Pediat. 149: 574-576, 1990.
  # journalTitle. journalVolume: pageInfo, pubYear.
  my $title = $result->{title};
  my $journalTitle = $result->{journalTitle};
  my $journalVolume = $result->{journalVolume};
  my $pageInfo = $result->{pageInfo};
  my $pubYear = $result->{pubYear};
  my @source_components = ();
  push @source_components, $journalTitle if ($journalTitle);
  if ($journalVolume) {
    if ($pageInfo || $pubYear) {
      push @source_components, "$journalVolume:";
    } else {
      push @source_components, "$journalVolume";
    }
  }
  if ($pageInfo) {
    if ($pubYear) {
      push @source_components, "$pageInfo,";
    } else {
      push @source_components, "$pageInfo";
    }
  }
  if ($pubYear) {
    push @source_components, "$pubYear";
  }
  my $source = join(' ', @source_components);
  return {title => $title, source => $source} if ($title);
  return undef;
}

sub get_description_from_pubmed {
  my $content = shift;
  my $pmid = shift;
  my $hash = decode_json($content);
  my $result = $hash->{result}->{$pmid};
  my $title = $result->{title};
  my $journalTitle = $result->{source};
  my $journal_info = $result->{elocationid};
  my $json = {};
  $json->{title} = $title if (defined $title);
  $json->{source} = "$journalTitle $journal_info" if (defined $journalTitle && defined $journal_info);
  return $json if ($title);
  return undef;
}


1;
