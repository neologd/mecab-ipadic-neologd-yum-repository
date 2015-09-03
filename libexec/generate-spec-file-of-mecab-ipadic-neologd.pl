#!/usr/bin/env perl

# Copyright (C) 2015 Toshinori Sato (@overlast)
#
#       https://github.com/neologd/mecab-ipadic-neologd
#
# Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use warnings;
use utf8;
use autodie;
use Encode;
use FindBin;

&main();

our $rerease = 1;
sub _read_changelog {
    my $changelog_path = $FindBin::Bin."/../ChangeLog";
    open my $file_in, "<", $changelog_path;
    my $changelog = "";
    my $prev_ymd_key = "";
    while (my $line = <$file_in>) {
        if ($line =~ m|^# Release ([0-9]{4})([0-9]{2})([0-9]{2})-(0[1-9]{1})|) {
            my $year = $1;
            my $month = $2;
            my $day = $3;
            my $rel = $4;
            my $ymd_key = $year-$month-$day;
            if ($prev_ymd_key ne $ymd_key) {
                my $str = "* $year-$month-$day  Toshinori Sato  <overlasting at g mail>\n";
                $changelog .= $str;
                $prev_ymd_key = $ymd_key;
            }
            $line =~ s|^ ||g;
            $line =~ s|\*|-|g;
            $line =~ s|\#|*|g;
            $changelog .= "\t".$line;
        } else {
            $line =~ s|^ ||g;
            $line =~ s|\*|-|g;
            $line =~ s|\#|*|g;
            $changelog .= "\t".$line;
        }
    }
    close $file_in;
    return $changelog;
}

sub _generate_spec {
    my ($package_path, $ymd, $version) = @_;
    #my $neologd_changelog = _read_changelog();
    #die "ChangeLog is not found." unless ($neologd_changelog);
    my $spec_template = << "__TEMPLATE__";
\%define _topdir $FindBin::Bin/../package/rpm

Name: mecab-ipadic-neologd
Summary: Neologism dictionary based on the language resources on the Web for mecab-ipadic
Group: Applications/Text
Version: $ymd
License: Apache License, Version 2.0; Check also https://github.com/neologd/mecab-ipadic-neologd/blob/master/COPYING
Release: 1
BuildArch: x86_64
Packager: Toshinori Sato(\@overlast)

Source: \%{name}-\%{version}.tar.gz

Requires: mecab mecab-ipadic

\%description

# If we have to patch
\%prep

\%setup -q

\%build

\%configure
ls -al configure.in
sed -i -e 's|--dicdir`/ipadic\"|--dicdir`/mecab-ipadic-neologd\"|p' configure.in
ls -al configure.in
./configure
/usr/local/libexec/mecab/mecab-dict-index -f UTF8 -t UTF8
make


\%install
# install programs
sed -i -e 's|/usr/local/lib/mecab/dic/mecab-ipadic-neologd|/usr/lib64/mecab/dic/mecab-ipadic-neologd|p' Makefile
sed -i -e 's|dic_DATA\ \=\ matrix\.bin|dic_DATA = COPYING matrix.bin|p' Makefile
make install DESTDIR=\$RPM_BUILD_ROOT INSTALL="install -p"

\%clean
rm -rf \$RPM_BUILD_ROOT

\%files
\%defattr(-,root,root)
   /usr/lib64/mecab/dic/mecab-ipadic-neologd/char.bin
   /usr/lib64/mecab/dic/mecab-ipadic-neologd/dicrc
   /usr/lib64/mecab/dic/mecab-ipadic-neologd/left-id.def
   /usr/lib64/mecab/dic/mecab-ipadic-neologd/matrix.bin
   /usr/lib64/mecab/dic/mecab-ipadic-neologd/pos-id.def
   /usr/lib64/mecab/dic/mecab-ipadic-neologd/rewrite.def
   /usr/lib64/mecab/dic/mecab-ipadic-neologd/right-id.def
   /usr/lib64/mecab/dic/mecab-ipadic-neologd/sys.dic
   /usr/lib64/mecab/dic/mecab-ipadic-neologd/unk.dic
   /usr/lib64/mecab/dic/mecab-ipadic-neologd/COPYING

\%changelog
* Mon Sep 03 2015 Toshinori Sato <overlasting at g mail>
- Aperiodic data update on 2015-09-03

* Mon Sep 01 2015 Toshinori Sato <overlasting at g mail>
- Periodic data update on 2015-09-01

* Mon Aug 24 2015 Toshinori Sato <overlasting at g mail>
- Aperiodic data update on 2015-08-24

__TEMPLATE__
    return $spec_template;
}

sub main {
    my $package_path = $ARGV[0];
    my $ymd = $ARGV[1];
    my $version = $ARGV[2];

    my $template = &_generate_spec($package_path, $ymd, $version);
    print Encode::encode_utf8($template);
    return;
}
