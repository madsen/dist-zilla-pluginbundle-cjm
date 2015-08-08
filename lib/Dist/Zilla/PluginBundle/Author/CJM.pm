#---------------------------------------------------------------------
package Dist::Zilla::PluginBundle::Author::CJM;
#
# Copyright 2011 Christopher J. Madsen
#
# Author: Christopher J. Madsen <perl@cjmweb.net>
# Created:  19 Oct 2011
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

our $VERSION = '4.35';
# This file is part of {{$dist}} {{$dist_version}} ({{$date}})

use Moose;
with 'Dist::Zilla::Role::PluginBundle::Easy';

=head1 SYNOPSIS

In dist.ini:

  [@Author::CJM / CJM]

=head1 DESCRIPTION

This is the plugin bundle that CJM uses. It is equivalent to:

  [VersionFromModule]

  [GatherDir]
  [PruneCruft]
  [ManifestSkip]
  [MetaJSON]
  [MetaYAML]
  [License]
  [Test::PrereqsFromMeta]
  [PodSyntaxTests]
  [PodCoverageTests]
  [PodLoom]
  data = tools/loom.pl
  [MakeMaker]
  [RunExtraTests]
  [MetaConfig]
  [MatchManifest]
  [RecommendedPrereqs]
  [CheckPrereqsIndexed]
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

=attr builder

Use the specified plugin instead of MakeMaker.

=attr changelog_re

Passed to TemplateCJM.

=attr check_files

Passed to GitVersionCheckCJM as its C<finder>.

=attr check_recommend

Passed to RecommendedPrereqs as its C<finder>.

=attr check_recommend_tests

Passed to RecommendedPrereqs as its C<test_finder>.

=attr eumm_version

Passed to MakeMaker (or its replacement C<builder>).

=attr mb_class

Passed to MakeMaker (or its replacement C<builder>).

=attr mb_version

Passed to MakeMaker (or its replacement C<builder>).

=attr manual_version

If true, VersionFromModule is omitted.

=attr pod_finder

Passed to both PodLoom and TemplateCJM as their C<finder>.

=attr pod_template

Passed to PodLoom as its C<template>.

=attr remove_plugin

The named plugin is removed from the bundle (may be specified multiple
times).  This exists because you can't pass multi-value parameters
through L<@Filter|Dist::Zilla::PluginBundle::Filter>.

=attr skip_index_check

Passed to CheckPrereqsIndexed as its C<skips>.

=attr template_date_format

Passed to TemplateCJM as its C<date_format>.  Defaults to C<MMMM d, y>.

=attr template_file

Passed to TemplateCJM as its C<file>.

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
      Test::PrereqsFromMeta
      PodSyntaxTests
      PodCoverageTests
    ),
    [PodLoom => {
      data => 'tools/loom.pl',
      %{ $self->config_slice({
        pod_finder   => 'finder',
        pod_template => 'template',
      }) },
    } ],
    # either MakeMaker or ModuleBuild:
    [ ($arg->{builder} || 'MakeMaker') =>
      scalar $self->config_slice(qw( eumm_version mb_version mb_class ))
    ],
    qw(
      RunExtraTests
      MetaConfig
      MatchManifest
    ),
    [ RecommendedPrereqs => scalar $self->config_slice({
        check_recommend => 'finder',
        check_recommend_tests => 'test_finder',
    }) ],
    [ CheckPrereqsIndexed => scalar $self->config_slice({
        skip_index_check => 'skips'
    }) ],
    [ GitVersionCheckCJM => scalar $self->config_slice({
        check_files => 'finder'
    }) ],
    [ TemplateCJM => {
        date_format => 'MMMM d, y',
        %{$self->config_slice(
          'changelog_re',
          { pod_finder           => 'finder',
            template_date_format => 'date_format',
            template_file        => 'file',
          })},
      } ],
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

  if (my $remove = $arg->{remove_plugin}) {
    my $prefix  = $self->name . '/';
    my %remove = map { $prefix . $_ => 1 } @$remove;
    my $plugins = $self->plugins;
    @$plugins = grep { not $remove{$_->[0]} } @$plugins;
  }
} # end configure

sub mvp_multivalue_args { qw(check_files check_recommend check_recommend_tests
                             remove_plugin
                             pod_finder skip_index_check template_file) }

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=for Pod::Coverage
configure
mvp_multivalue_args
