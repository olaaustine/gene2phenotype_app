requires 'Mojolicious';
requires 'File::Rsync';
requires 'File::Path';
requires 'Mojolicious::Plugin::ForkCall';
requires 'Mojolicious::Plugin::Mail';
requires 'Mojolicious::Plugin::CGI';
requires 'Mojolicious::Plugin::Model';
requires 'Mojolicious::Plugin::RenderFile';
requires 'Mojolicious::Plugin::Authentication';
requires 'namespace::autoclean';
requires 'Moose';
requires 'XML::RSS::Parser';
requires 'FileHandle';
requires 'HTTP::Tiny';
requires 'IO::Socket::SSL';
requires 'HTML::Entities';
requires 'IPC::Cmd';
requires 'Data::Dumper';
requires 'Perl::OSType';

on 'build' => sub {
    requires 'Module::Build::Pluggable';
    requires 'Module::Build::Pluggable::CPANfile';
};
