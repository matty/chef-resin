name             'resin'
maintainer       'ForeFlight LLC'
maintainer_email 'team@foreflight.com'
license          'Apache2'
description      'Installs Resin.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.25'

depends 'build-essential'
depends 'java'
depends 'ulimit'
depends 'sysctl'
depends 'yum-epel'

supports 'rhel'
supports 'mac_os_x', '~> 10.10.2'
supports 'amazon'