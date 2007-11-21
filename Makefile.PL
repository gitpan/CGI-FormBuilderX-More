use inc::Module::Install;

name 'CGI-FormBuilderX-More';
all_from 'lib/CGI/FormBuilderX/More.pm';

build_requires 'Test::More';
build_requires 'Test::Deep';
build_requires 'CGI';

requires 'CGI::FormBuilder';
requires 'Sub::Exporter';

auto_install;

WriteAll;

