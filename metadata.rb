name 'nsd'
maintainer 'Alexander Pyatkin'
maintainer_email 'aspyatkin@gmail.com'
license 'MIT'
version '0.2.0'
description 'Install and configure NSD'

recipe 'nsd::default', 'Install and configure NSD'

source_url 'https://github.com/aspyatkin/nsd-cookbook' if respond_to?(:source_url)

supports 'ubuntu'

depends 'instance', '~> 2.0.0'
depends 'secret', '~> 1.0.0'
