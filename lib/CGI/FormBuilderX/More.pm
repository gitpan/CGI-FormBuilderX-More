package CGI::FormBuilderX::More;

use warnings;
use strict;

=head1 NAME

CGI::FormBuilderX::More - Additional input gathering/interrogating functionality for CGI::FormBuilder 

=head1 VERSION

Version 0.010

=cut

our $VERSION = '0.010';

=head1 SYNOPSIS

    use CGI::FormBuilderX::More;

    my $form = CGI::FormBuilderX::More( ... );

    if ($form->pressed("edit")) {
        my $input = $form->input_slice(qw/title description/);
        # $input is { title => ..., description => ... } *ONLY*
        ...
    }
    elsif ($form->pressed("view") && ! $form->missing("section")) {
        # the paramter "section" is defined and is not ''
        ...
    }

    ...

    print $form->render;

=head1 DESCRIPTION

CGI::FormBuilderX::More extends CGI::FormBuilder by adding some convenience methods. Specifically,
it adds methods for generating param lists, generating param hash slices, determining whether a param is "missing",
and finding out which submit button was pressed.

=head1 EXPORT

=head2 missing( <value> )

Returns 1 if <value> is not defined or the empty string ('')
Returns 0 otherwise

Note, the number 0 is NOT a "missing" value

=cut

use base qw/CGI::FormBuilder/;

use Sub::Exporter -setup => {
    exports => [
        missing => sub { return sub {
            return ! defined $_[0] || $_[0] eq '';
        } },
    ],
};

=head1 METHODS

=head2 CGI::FormBuilderX::More->new( ... )

Returns a new CGI::FormBuilderX::More object

Configure exactly as you would a normal CGI::FormBuilder object

=head2 pressed( <name> )

Returns the value of ->param(<name>) if <name> exists and has a value
If not, then returns the value of ->param("<name>.x") if "<name>.x" exists and has a value
Otherwise, returns undef

Essentially, you can use this method to find out which button the user pressed. This method does not require
any javascript on the client side to work

It checks "<name>.x" because for image buttons, some browsers only submit the .x and .y values of where the user
pressed.

=cut

sub pressed {
    my $self = shift;
    my $name = shift;
    $name = $self->submitname unless defined $name;

    for ($name, "$name.x") {
        if (defined (my $value = $self->input_param($_))) {
            return $value || '0E0';
        }
    }

    return undef;
}

=head2 missing( <name> )

Returns 1 if value of the param <name> is not defined or the empty string ('')
Returns 0 otherwise

Note, the number 0 is NOT a "missing" value

=cut

sub missing {
    my $self = shift;
    my $name = shift;
    my $value = $self->input_param($name);

    return 0 if $value;
    return 1 if ! defined $value;
    return 1 if $value eq '';
    return 0; # value is 0
}

=head2 input ( <name>, <name>, ..., <name> )

Returns a list of values based on the param names given

By default, this method will "collapse" multi-value params into the first
value of the param. If you'd prefer an array reference of multi-value params
instead, pass the option { all => 1 } as the first argument (a hash reference).

=cut

sub input {
    my $self = shift;
    my $control = {};
    $control = shift if ref $_[0] && ref $_[0] eq "HASH";
    my $all = 0;
    $all = $control->{all} if exists $control->{all};

    my @names = map { ref eq 'ARRAY' ? @$_ : $_ } @_;

    my @params;
    if ($all) {
        for (@names) {
            my @param = $self->input_param($_);
            push @params, 1 == @param ? $param[0] : \@param;
        }
    }
    else {
        for (@names) {
            push @params, scalar $self->input_param($_);
        }
    }
    return wantarray ? @params : $params[0];
}

=head2 input_slice( <name>, <name>, ..., <name> )

Returns a hash of key/value pairs based on the param names given

By default, this method will "collapse" multi-value params into the first
value of the param. If you'd prefer an array reference of multi-value params
instead, pass the option { all => 1 } as the first argument (a hash reference).

=cut

sub input_slice {
    my $self = shift;
    my $control = {};
    $control = shift if ref $_[0] && ref $_[0] eq "HASH";
    my $all = 0;
    $all = $control->{all} if exists $control->{all};

    my @names = map { ref eq 'ARRAY' ? @$_ : $_ } @_;

    if ($all) {
        return map { my @param = $self->input_param($_); ($_ => 1 == @param ? $param[0] : \@param) } @names;
    }
    else {
        return map { ($_ => scalar $self->input_param($_)) } @names;
    }
}

=head2 input_param( <name> )

In list context, returns the all the param values associated with <name>
In scalar context, returns only the first param value associated with <name>

=cut

sub input_param {
    my $self = shift;
    my @param = $self->{params}->param($_[0]);
    return wantarray ? @param : shift @param;
}

=head1 AUTHOR

Robert Krimen, C<< <rkrimen at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-cgi-formbuilderx-more at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=CGI-FormBuilderX-More>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc CGI::FormBuilderX::More


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=CGI-FormBuilderX-More>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/CGI-FormBuilderX-More>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/CGI-FormBuilderX-More>

=item * Search CPAN

L<http://search.cpan.org/dist/CGI-FormBuilderX-More>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2007 Robert Krimen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of CGI::FormBuilderX::More
