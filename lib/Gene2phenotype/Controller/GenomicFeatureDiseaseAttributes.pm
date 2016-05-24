package Gene2phenotype::Controller::GenomicFeatureDiseaseAttributes;
use Mojo::Base 'Mojolicious::Controller';


sub add {
  my $self = shift;

  my $allelic_requirement_attrib_ids = $self->every_param('allelic_requirement_attrib_id'); 
  my $mutation_consequence_attrib_id = $self->param('mutation_consequence_attrib_id');
  my $GFD_id = $self->param('GFD_id');


  $self->render(text => "Add GFDAttributes");
}

sub update {
  my $self = shift;
  my $allelic_requirement_attrib_ids = $self->every_param('allelic_requirement_attrib_id'); 
  my $mutation_consequence_attrib_id = $self->param('mutation_consequence_attrib_id');
  my $GFD_id = $self->param('GFD_id');
  my $GFD_action_id = $self->param('GFD_action_id');

  $self->render(text => "Update GFDAttributes");
}

sub delete {
  my $self = shift;
  my $GFD_id = $self->param('GFD_id');
  my $GFD_action_id = $self->param('GFD_action_id');

  $self->render(text => "Delete GFDAttributes");

}


1;
