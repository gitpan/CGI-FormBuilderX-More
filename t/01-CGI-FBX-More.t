#!perl -T

use Test::More qw/no_plan/;
use Test::Deep;

use CGI;
use CGI::FormBuilderX::More;

my $query = CGI->new({
    a => 1,
    c => [ 1, 2, 3, 4 ],
    "edit.x" => 0,
    "view" => "View"
});

ok(my $form = CGI::FormBuilderX::More->new(params => $query));
ok($form->missing(qw/b/));
ok(!$form->missing(qw/c/));
ok($form->pressed(qw/edit/));
ok($form->pressed(qw/view/));
ok(!$form->pressed(qw/delete/));
is($form->input(qw/c/), 1);
cmp_deeply([ $form->input(qw/a c/) ], [ 1, 1 ]);
cmp_deeply([ $form->input({ all => 1 }, qw/a c/) ], [ 1, [ 1, 2, 3, 4 ] ]);
