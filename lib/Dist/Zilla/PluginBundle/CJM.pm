#---------------------------------------------------------------------
package Dist::Zilla::PluginBundle::CJM;
#
# Copyright 2009 Christopher J. Madsen
#
# Author: Christopher J. Madsen <perl@cjmweb.net>
# Created:  4 Oct 2009
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either the
# GNU General Public License or the Artistic License for more details.
#
# ABSTRACT: Build a distribution like CJM
#---------------------------------------------------------------------

our $VERSION = '4.02';
# This file is part of {{$dist}} {{$dist_version}} ({{$date}})

use Moose;
use Moose::Autobox;
with 'Dist::Zilla::Role::PluginBundle::Easy';

=head1 DESCRIPTION

This is the plugin bundle that CJM uses. It is equivalent to:

  [VersionFromModule]

  [GatherDir]
  [PruneCruft]
  [ManifestSkip]
  [MetaJSON]
  [MetaYAML]
  [License]
  [PodSyntaxTests]
  [PodCoverageTests]
  [ExtraTests]
  [PodLoom]
  data = tools/loom.pl
  [MakeMaker]
  [MetaConfig]
  [MatchManifest]
  [GitVersionCheckCJM]
  [TemplateCJM]

  [Repository]
  git_remote  = github

  [@Git]
  allow_dirty = Changes
  commit_msg  = Updated Changes for %{MMMM d, yyyy}d%{ trial}t release of %v
  tag_format  = %v%t
  tag_message = Tagged %N %v%{ (trial release)}t
  push_to     = github master

  [TestRelease]
  [UploadToCPAN]
  [ArchiveRelease]
  directory = cjm_releases

If the C<manual_version> argument is given to the bundle,
VersionFromModule is omitted.  If the C<builder> argument is given, it
is used instead of MakeMaker.  If the C<pod_template> argument is
given, it is passed to PodLoom as its C<template>.

=cut

sub configure
{
  my $self = shift;

  my $arg = $self->payload;

  $self->add_plugins('VersionFromModule')
      unless $arg->{manual_version};

  $self->add_plugins(
    qw(
      GatherDir
      PruneCruft
      ManifestSkip
      MetaJSON
      MetaYAML
      License
      PodSyntaxTests
      PodCoverageTests
      ExtraTests
    ),
    [PodLoom => {
      data => 'tools/loom.pl',
      $self->config_slice({
        pod_template => 'template',
      })->flatten,
    } ],
    # either MakeMaker or ModuleBuild:
    [ ($arg->{builder} || 'MakeMaker') =>
      scalar $self->config_slice(qw( eumm_version mb_version ))
    ],
    qw(
      MetaConfig
      MatchManifest
      GitVersionCheckCJM
      TemplateCJM
    ),
    [ Repository => { git_remote => 'github' } ],
  );

  $self->add_bundle(Git => {
    allow_dirty => 'Changes',
    commit_msg  => 'Updated Changes for %{MMMM d, yyyy}d%{ trial}t release of %v',
    tag_format  => '%v%t',
    tag_message => 'Tagged %N %v%{ (trial release)}t',
    push_to     => 'github master',
  });

  $self->add_plugins(
    'TestRelease',
    'UploadToCPAN',
    [ ArchiveRelease => { directory => 'cjm_releases' } ],
  );
} # end configure

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=for Pod::Coverage
configure
