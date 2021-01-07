#!/usr/bin/perl -w
# See the NOTICE file distributed with this work for additional information
# regarding copyright ownership.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License. 
use strict;
use CGI;
use JSON qw//;
use Bio::EnsEMBL::Registry;

# HTTP HEADER
print "Content-type: application/json\n\n";

my $cgi = CGI->new();
my $type = 'search';
if ($cgi->param('type')) {
  $type = $cgi->param('type');
} 

my ($id, $GFD_id, $phenotype_name);

if ($type eq 'search') {
  $phenotype_name = $cgi->param('str');
}

if ($type eq 'expand') {
  $id = $cgi->param('id');
  $GFD_id = $cgi->param('GFD_id');
}

my $registry_file = $cgi->param('registry_file');
my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all($registry_file);

my @phenotype_ids = ();
my $ontology = $registry->get_adaptor( 'Multi', 'Ontology', 'OntologyTerm' );
my $ontology_name = 'HPO';
my @terms = (); 
my @query_output = ();


if ($type eq 'expand') {
  my $GFD_adaptor = $registry->get_adaptor('homo_sapiens', 'gene2phenotype', 'genomicfeaturedisease');
  my $GFD = $GFD_adaptor->fetch_by_dbID($GFD_id);
  my $GFDPhenotypes = $GFD->get_all_GFDPhenotypes;
  foreach my $GFDPhenotype (@$GFDPhenotypes) {
    push @phenotype_ids, $GFDPhenotype->{phenotype_id};
  }
  if ("$id" eq '#') {
    @terms = @{$ontology->fetch_all_roots($ontology_name)};
  } else {
    my $parent_term = $ontology->fetch_by_dbID($id);
    @terms = @{$ontology->fetch_all_by_parent_term($parent_term)};
  }
  foreach my $term (@terms) {
    my @children = @{$term->children};
    push @query_output, {
      id => $term->dbID,
      text => $term->name,
      children => (scalar @children > 0) ? JSON::true : JSON::false,
      state => {selected => (grep {$_ == $term->dbID} @phenotype_ids) ? JSON::true : JSON::false},
    };
  }
}
if ($type eq 'search') {
  my $terms = $ontology->fetch_all_by_name($phenotype_name);
  foreach my $term (@$terms) {
    my $is_root = $term->is_root;
    if ($is_root) {
      push @query_output, $term->dbID;
    } else {
      while (!$is_root) {
        my @parents = @{$term->parents};
        my $parent = $parents[0];
        push @query_output, $term->dbID;
        $term = $parents[0];
        $is_root = $term->is_root;
      }  
      push @query_output, $term->dbID;
    } 
  }
}
 
# JSON OUTPUT
# http://www.jstree.com/docs/json/

print JSON::to_json(\@query_output);

