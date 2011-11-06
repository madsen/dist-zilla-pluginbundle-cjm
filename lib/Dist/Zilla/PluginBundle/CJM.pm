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
# ABSTRACT: DEPRECATED plugin bundle for CJM
#---------------------------------------------------------------------

our $VERSION = '4.11';
# This file is part of {{$dist}} {{$dist_version}} ({{$date}})

use Moose;
extends 'Dist::Zilla::PluginBundle::Author::CJM';

=head1 DESCRIPTION

B<This bundle is deprecated.>

This is the old name for the plugin bundle that CJM uses.  The new
name is L<Author::CJM|Dist::Zilla::PluginBundle::Author::CJM>, to
avoid cluttering up the PluginBundle namespace.

Just replace

  [@CJM]

with

  [@Author::CJM / CJM]

(The C< / CJM> is not necessary; but it shortens the prefix on log messages.)

=cut

before configure => sub {
  my $self = shift;

  # Bundles don't have a logger, so we'll fake it:
  warn('[' . $self->name .
       "] This bundle is deprecated.  Please switch to \@Author::CJM\a\n");
}; # end before configure

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=for Pod::Coverage
configure
