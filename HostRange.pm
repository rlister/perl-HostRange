=head1 Name

HostRange.pm

=head1 Usage

use HostRange;
my @hosts = HostRange::parse 'foo-[ab][05,09-12].bar.com'

=head1 Patterns

Simple atoms of one character:

  HostRange::parse 'foo-[a-c]'          # ["foo-a", "foo-b", "foo-c"]

Ranges are parsed using the perl ‘..’ operator:

  HostRange::parse 'foo-[a-c]'          # ["foo-a", "foo-b", "foo-c"]

Multiple atoms and ranges separated by commas:

  HostRange::parse 'foo-[1,3-5,9]'      # ["foo-1", "foo-3", "foo-4", "foo-5", "foo-9"]

Combined:

  HostRange::parse 'foo-[ab][01-02]'    # ["foo-a01", "foo-a02", "foo-b01", "foo-b02"]

=cut

package HostRange;

sub parse {
  my $string = shift;

  ## [abc] is split into atoms on single char
  if ( $string =~ s/\[(\w+)\]/\%s/ ) {
    map { parse(sprintf($string, $_)) } split(//, $1);
  }

  ## [01,03-05] is split into multichar atoms or ranges on commas
  elsif ( $string =~ s/\[([\s\w,-]+)\]/%s/ ) {
    map {
      ## range like 03-05
      if ( s/(\w+)-(\w+)/\%s/ ) {
        map { parse(sprintf($string, $_)) } $1..$2;
      }
      ## atom, like 01
      else {
        parse(sprintf($string, $_));
      }
    } split(/\s*,\s*/, $1);
  }

  ## simgple string with nothing to sub
  else {
    $string;
  }
}

1;

__END__
