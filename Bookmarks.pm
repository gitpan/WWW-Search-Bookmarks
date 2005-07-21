package WWW::Search::Bookmarks;

use strict;
use Carp;
use XMLRPC::Lite;
use XML::Simple;
use WWW::Search qw(generic_option);
use WWW::SearchResult;
use Data::Dumper;
use vars qw(@ISA $VERSION);
no warnings qw(redefine);

@ISA = qw(WWW::Search);
$VERSION = "0.1";

=head1 NAME

WWW::Search::Bookmarks - Search a Bookmarks server via SOAP

=head1 SYNOPSIS

  use WWW::Search;
  my $search = WWW::Search->new('Bookmarks');
  $search->native_query('world of warcraft linux');
  while (my $result = $search->next_result() ) {
    print $result->url, "\n";
    print $result->description, "\n";
    print "tags: ".join(' - ', @{$result->{tags}})."\n";
  }

=head1 DESCRIPTION

This class is an Bookmarks specialization of WWW::Search. It handles
searching a Bookmarks server F<http://bookmarks.socklabs.com.com/> using its
XMLRPC API  F<http://bookmarks.socklabs.com/docs/api>.

All interaction should be done through WWW::Search objects.

This module uses XMLRPC::Lite and XML::Simple to do all the dirty work.

=cut

sub native_setup_search {
	my($self, $query) = @_;
	$self->{server} = 'http://bookmarks.socklabs.com/' unless $self->{server};
	$self->{_offset} = 0;
	$self->{_query} = $query;
}

sub native_retrieve_some {
	my ($self) = @_;

	my $search = XMLRPC::Lite->proxy($self->{server}.'xmlrpc')
		->call('Bookmarks.XMLRPC.search', keyword => $self->{_query} )
		->result;
	return unless defined $search;

	if ($search) {
		my $xs = new XML::Simple();
		my $ref = $xs->XMLin("<search>$search</search>", KeyAttr => {tag => 'id'}, ForceArray => ['tag'], SuppressEmpty => 1);
		foreach my $url ( @{$ref->{url}} ) {
			my $hit = WWW::SearchResult->new();
			$hit->title($url->{domain}.$url->{uri});
			$hit->url($url->{domain}.$url->{uri});
			$hit->description($url->{description} || '');
			$hit->{tags} = [ map { $url->{tag}{$_}{content} } keys %{$url->{tag}} ];
			push @{$self->{cache}}, $hit;
		}
	}
	return;
}

1;

=head1 AUTHOR

Nick Gerakines E<lt>F<nick@socklabs.com>E<gt>

=head1 COPYRIGHT

Copyright (C) 2005, Nick Gerakines

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

=cut
