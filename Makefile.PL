use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME	 => "WWW::Search::Bookmarks",
  VERSION_FROM => 'Bookmarks.pm',
  PREREQ_PM    =>  {
   'XMLRPC::Lite' => "0.60",
   'XML::Simple' => "2.14",
   'WWW::Search' => "2.35",
   'Test::More' => "0.01",
  },
  AUTHOR       => 'Nick Gerakines <nick@socklabs.com>',
  ABSTRACT     => 'WWW::Search::Bookmarks searches a Bookmarks server via XMLRPC'
);


sub MY::libscan {
  my $path = $_[1];
  return '' if $path =~ /\B\.svn\b/;
  return $path;
}
