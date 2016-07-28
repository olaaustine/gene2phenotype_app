#!/usr/bin/perl -w
 
# PERL MODULES WE WILL BE USING
# http://www.jensbits.com/2011/05/09/jquery-ui-autocomplete-widget-with-perl-and-mysql/
use strict;
use CGI;
use JSON qw//;
use Bio::EnsEMBL::Registry;

# HTTP HEADER
print "Content-type: application/json\n\n";
 
my $cgi = CGI->new();

my $registry_file = $cgi->param('registry_file'); 
my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all($registry_file);
my $DBAdaptor = $registry->get_DBAdaptor('human', 'gene2phenotype');
my $dbh = $DBAdaptor->dbc->db_handle;

my $term = $cgi->param('term');
my $type = $cgi->param('query_type');
my $query = '';

if ($type eq 'query_phenotype_name') {
  $query = 'select name AS value FROM phenotype where name like ?';
} 
elsif ($type eq 'query_gene_name') {
  $query = 'select gene_symbol AS value FROM genomic_feature where gene_symbol like ?';
}
elsif ($type eq 'query_disease_name') {
  $query = 'select name AS value FROM disease where name like ?';
}
else { # query
  $query = 'select search_term AS value FROM search where search_term like ?';
} 
 
my $sth = $dbh->prepare($query);
$sth->execute($term . '%') or die $dbh->errstr;
my @query_output = ();
while ( my $row = $sth->fetchrow_hashref ) {
  push @query_output, $row;
}
$dbh->disconnect();
 
print JSON::to_json(\@query_output);
