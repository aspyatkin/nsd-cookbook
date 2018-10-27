id = 'nsd'

default[id]['enable_ipv6'] = false

default[id]['master']['fqdn'] = nil
default[id]['master']['bind_addresses'] = []
default[id]['master']['ipv4_address'] = nil
default[id]['master']['ipv6_address'] = nil
default[id]['master']['contact'] = nil
default[id]['slaves'] = {}  # slave NS FQDN: { bind_addresses: slave bind addresses, ipv4_address: slave IPv4 address, ipv6_address: slave IPv6 address }
default[id]['zones'] = []

default[id]['packages']['master'] = %w(
  nsd
)

default[id]['packages']['slave'] = %w(
  nsd
)

default[id]['service']['name'] = 'nsd'
default[id]['service']['conf_dir'] = '/etc/nsd'

default[id]['service']['user'] = 'nsd'
default[id]['service']['uid'] = 500
default[id]['service']['group'] = 'nsd'
default[id]['service']['gid'] = 500
