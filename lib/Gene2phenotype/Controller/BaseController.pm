=head1 LICENSE
 
See the NOTICE file distributed with this work for additional information
regarding copyright ownership.
 
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
=cut
package Gene2phenotype::Controller::BaseController;
use Mojo::Base 'Mojolicious::Controller';

use base qw(Exporter);

our %MESSAGES = (
  RESET_PWD_SUC => { msg => 'Password was successfully updated.', type => 'success'}, 
  PWD_ERROR => { msg  => 'Error. Password verification failed.', type => 'danger',},
  PWDS_DONT_MATCH => { msg => 'Error. Retyped and new password don\'t match.', type => 'danger',},
  MISSING_PWDS => { msg => 'Error. You must provide a new password and retype the new password.', type => 'danger',},
  RESET_PWD_ERROR => { msg => 'There was an error resetting you password. Please contact g2p-help@ebi.ac.uk.', type => 'danger'},
  RESET_USERNAME_SUC => { msg => 'Username was successfully updated.', type => 'success',},
  USERNAME_IN_USE => { msg => 'The new username is already taken.', type => 'danger'},
  NEW_USERNAME_MISSING => { msg => 'You need to provide a new username.', type => 'danger',},
  EMAIL_IN_USE => { msg => 'The new email is already taken.', type => 'danger',},
  RESET_EMAIL_SUC => { msg => 'Email was successfully updated.', type => 'success',},
  EMAIL_UNKNOWN => { msg => 'The email address is not known. Please contact g2p-help@ebi.ac.uk.', type => 'danger',},
  SESSION_IDS_DONT_MATCH => { msg => 'Session ids don\'t match. Please contact g2p-help@ebi.ac.uk.', type => 'danger',},
  ERROR_ADD_GENE_DISEASE_PAIR => { msg => 'You must provide a gene name and a disease name.', type => 'danger',},  
  LOGIN_FAILED => { msg => 'Login failed. You entered a wrong password or email address. Try again, reset your password or contact g2p-help@ebi.ac.uk.', type => 'danger',},
  DISEASE_NAME_IN_DB => { msg => 'Disease name is already in database.', type => 'info',},
  UPDATED_DISEASE_ATTRIBS_SUC => { msg => 'Successfully updated disease attributes.', type => 'success',},
  UPDATED_VISIBILITY_STATUS_SUC => { msg => 'Successfully updated visibility status.', type => 'success',},
  UPDATED_MUTATION_CONSEQ_SUC => {msg => 'Succesfully updated mutation consequence', type => 'success',},
  SELECTED_MUTATION_CONSEQ => {msg => "Mutation consequence already selected", type => "danger",},
  SELECTED_ALLELIC_REQUIREMENT => {msg => "Allelic requirement already selected", type => "danger",},
  UPDATED_ALLELIC_REQUIREMENT_SUC => {msg => 'Succesfully updated allelic requirement', type => 'success',},
  UPDATED_CROSS_CUT_SUC => {msg => 'Successfully updated cross cutting modifier', type => 'success',}, 
  SELECTED_CROSS_CUTTING_MODIFIER => {msg => "Cross cutting modifier already selected", type => 'danger'},
  UPDATED_MUT_CON_FLAG_SUC => {msg => "Successfully updated mutation consequence flag", type => 'success',},
  SELECTED_MUTATION_CON_FLAG => {msg => "Mutation consequence flag already selected", type => 'danger'},
  DISEASE_MIM_IN_DB => { msg => 'Disease mim is already in database.', type => 'danger',},
  WRONG_FORMAT_DISEASE_MIM => { msg => 'Invalid format for disease mim. It needs to be a number.', type => 'danger',},
  UPDATED_ORGAN_LIST => { msg => 'Successfully updated organ specificity list.', type => 'success',},
  UPDATED_CONFIDENCE_CATEGORY_SUC => { msg => 'Successfully updated confidence category', type => 'success',},
  ADDED_GFDPHENOTYPE_SUC => { msg => 'Successfully added a new phenotype for the genomic feature disease pair.', type => 'success'},
  ADDED_PUBLICATION_SUC => { msg => 'Successfully added a new publication', type => 'success'},
  DELETED_GFDPHENOTYPE_SUC => { msg => 'Successfully deleted a phenotype entry.', type => 'success'},
  DELETED_GFDPUBLICATION_SUC => { msg => 'Successfully deleted publication entry.', type => 'success'},
  ADDED_COMMENT_SUC => { msg => 'Successfully added a new comment.', type => 'success'},
  EMPTY_COMMENT => { msg => 'Comment is empty and has not been added.', type => 'info'},
  DELETED_GFD_SUC => { msg => 'Successfully deleted gene disease pair', type => 'success'},
  DELETED_GFD_PANEL_SUC => { msg => 'Successfully deleted gene disease pair from panel.', type => 'success'},
  DELETED_COMMENT_SUC => { msg => 'Successfully deleted the comment.', type => 'success'},
  UPDATED_PHENOTYPES_SUC => {msg => 'Successfully updated the list of phenotypes.', type => 'success'},
  DATA_NOT_CHANGED => {msg => 'Data has not changed.', type => 'info'},
  GF_NOT_IN_DB => {msg => 'The gene is not stored in our database. Please choose a gene symbol using the autocomplete search or contact g2p-help@ebi.ac.uk', type => 'danger'},
  GFD_IN_DB => {msg => 'The entry was already stored in the database.', type => 'info'},
  ADDED_GFD_SUC => {msg => 'Successfully added new entry to the database.', type => 'success'},
  LOGIN_FOR_ACCOUNT_INFO => {msg => 'You need to login first to see your account details.', type => 'info'},
  SUCC_ADDED_PHENOTYPE => {msg => 'Successfully added XXX to the list of phenotypes.', type => 'success'},
  ERROR_PHENOTYPE_NOT_IN_DB => {msg => 'The phenotype XXX is not part of HPO. Please contact g2p-help@ebi.ac.uk for help.', type => 'danger'},
  SUCC_DELETED_PHENOTYPE => {msg => 'Successfully deleted XXX from the list of phenotypes.', type => 'success'},
  PHENOTYPE_ALREADY_IN_LIST => {msg => 'Phenotype XXX is already in the list of phenotypes.', type => 'info' },
  PHENOTYPE_INFO_ADDED_IN_DB_ERROR => {msg => 'Successfully added: XXX. Already in the list of phenotypes: XXX. Not part of HPO: XXX.', type => 'info' },
  PHENOTYPE_INFO_ADDED => {msg => 'Successfully added: XXX.', type => 'info' },
  PHENOTYPE_INFO_IN_DB => {msg => 'Already in the list of phenotypes: XXX.', type => 'info' },
  PHENOTYPE_INFO_ERROR => {msg => 'Not part of HPO: XXX.', type => 'info' },
  PHENOTYPE_INFO_ADDED_IN_DB => {msg => 'Successfully added: XXX. Already in the list of phenotypes: XXX.', type => 'info' },
  PHENOTYPE_INFO_ADDED_ERROR => {msg => 'Successfully added: XXX. Not part of HPO: XXX.', type => 'info' },
  PHENOTYPE_INFO_IN_DB_ERROR => {msg => 'Already in the list of phenotypes: XXX. Not part of HPO: XXX.', type => 'info' },
  DUPLICATED_ENTRY_SUC => {msg => 'Successfully duplicated entry.', type => 'success'},
  ENTRY_HAS_NOT_BEEN_DUPLICATED => {msg => 'The entry has not been duplicated.', type => 'info'},
  LGM_MERGE_ERROR_LESS_THAN_TWO_ENTRIES => {msg => 'At least 2 entries are needed for merging.', type => 'danger'},
  LGM_MERGE_ERROR_NOT_LOGGED_IN => {msg => 'You need to login in first in order to be able to merge.', type => 'danger'},
  LGM_MERGE_SUCCESS => {msg => 'Successfully merged duplicated LGM entries', type => 'success'},
);

our @EXPORT_OK = (%MESSAGES); 

sub feedback_message {
  my $self = shift;
  my $feedback = shift;
  my $message = $MESSAGES{$feedback};
  $self->flash({'message' => $message->{msg}, 'alert_class' => 'alert-' . $message->{type}});
}

sub add_phenotypes_message {
  my $self = shift;
  my $feedback = shift;
  my $values = shift;
  my $message = $MESSAGES{$feedback};
  my $message_txt = $message->{msg};
  while (@$values) {
    my $phenotype = shift @$values;
    $message_txt =~ s/XXX/<em>$phenotype<\/em>/;
  }
  $self->flash({'message' => $message_txt, 'phenotype_alert_class' => 'alert-' . $message->{type}});
}

sub edit_phenotypes_message {
  my $self = shift;
  my $feedback = shift;
  my $phenotype = shift;
  my $message = $MESSAGES{$feedback};
  my $message_txt = $message->{msg};
  $message_txt =~ s/XXX/<em>$phenotype<\/em>/;
  $self->flash({'message' => $message_txt, 'phenotype_alert_class' => 'alert-' . $message->{type}});
}

1;
