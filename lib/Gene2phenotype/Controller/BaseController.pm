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
  LOGIN_FAILED => { msg => 'Login failed. You entered a wrong password. Try again or reset your password.', type => 'danger',},
  DISEASE_NAME_IN_DB => { msg => 'Disease name is already in database.', type => 'info',},
  UPDATED_DISEASE_ATTRIBS_SUC => { msg => 'Successfully updated disease attributes.', type => 'success',},
  UPDATED_VISIBILITY_STATUS_SUC => { msg => 'Successfully updated visibility status.', type => 'success',},
  DISEASE_MIM_IN_DB => { msg => 'Disease mim is already in database.', type => 'danger',},
  WRONG_FORMAT_DISEASE_MIM => { msg => 'Invalid format for disease mim. It needs to be a number.', type => 'danger',},
  UPDATED_ORGAN_LIST => { msg => 'Successfully updated organ specificity list.', type => 'success',},
  UPDATED_DDD_CATEGORY_SUC => { msg => 'Successfully updated DDD category', type => 'success',},
  UPDATED_GFD_ACTION_SUC => { msg => 'Successfully updated genomic feature disease action.', type => 'success',},
  ADDED_GFD_ACTION_SUC => { msg => 'Successfully added a new genomic feature disease action.', type => 'success'},
  ADDED_GFDPHENOTYPE_SUC => { msg => 'Successfully added a new phenotype for the genomic feature disease pair.', type => 'success'},
  ADDED_PUBLICATION_SUC => { msg => 'Successfully added a new publication', type => 'success'},
  DELETED_GFDPHENOTYPE_SUC => { msg => 'Successfully deleted a phenotype entry.', type => 'success'},
  DELETED_GFDPUBLICATION_SUC => { msg => 'Successfully deleted publication entry.', type => 'success'},
  ADDED_COMMENT_SUC => { msg => 'Successfully added a new comment.', type => 'success'},
  DELETED_GFD_ACTION_SUC => { msg => 'Successfully deleted a genomic feature disease action.', type => 'success'},
  DELETED_GFD_SUC => { msg => 'Successfully deleted gene disease pair', type => 'success'},
  DELETED_COMMENT_SUC => { msg => 'Successfully deleted the comment.', type => 'success'},
  UPDATED_PHENOTYPES_SUC => {msg => 'Successfully updated the list of phenotypes.', type => 'success'},
  DATA_NOT_CHANGED => {msg => 'Data has not changed.', type => 'info'},
  GF_NOT_IN_DB => {msg => 'The gene is not stored in our database. Please choose a gene symbol using the autocomplete search or contact g2p-help@ebi.ac.uk', type => 'danger'},
  LOGIN_FOR_ACCOUNT_INFO => {msg => 'You need to login first to see your account details.', type => 'info'},
  SUCC_ADDED_PHENOTYPE => {msg => 'Successfully added XXX to the list of phenotypes.', type => 'success'},
  SUCC_DELETED_PHENOTYPE => {msg => 'Successfully deleted XXX from the list of phenotypes.', type => 'success'},
);

our @EXPORT_OK = (%MESSAGES); 

sub feedback_message {
  my $self = shift;
  my $feedback = shift;
  my $message = $MESSAGES{$feedback};
  $self->flash({'message' => $message->{msg}, 'alert_class' => 'alert-' . $message->{type}});
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
