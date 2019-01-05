# nsd cookbook
[![Chef cookbook](https://img.shields.io/cookbook/v/nsd.svg?style=flat-square)]()
[![license](https://img.shields.io/github/license/aspyatkin/nsd-cookbook.svg?style=flat-square)]()  
A Chef cookbook to install nsd master and slaves along with initial zone configuration.

## Resources

The examples below configure one master (`ns1.example.com`) and two slave servers (`ns2.example.com` and `ns3.example.com`), all of which host two zones - `example.com` itself and `test.com`. SOA records will contain `hostmaster@example.com` as an email address.

### nsd_master

```ruby
nsd_master 'ns1.example.com' do
  port 53
  ipv4_address '1.1.1.1'
  ipv6_address '2001:0db8:0a0b:12f0:0000:0000:0000:0001'
  contact 'hostmaster@example.com'
  bind_addresses %w(1.1.1.1 2001:0db8:0a0b:12f0:0000:0000:0000:0001)
  enable_ipv6 true
  keys({
    'ns2.example.com' => '7DzUnLpx9H...',
    'ns3.example.com' => '1ADEn1fqOo...'
  })
  slaves({
    'ns2.example.com' => {
      'ipv4_address' => '2.2.2.2',
      'ipv6_address' => '2001:0db8:0a0b:12f0:0000:0000:0000:0002'
    },
    'ns3.example.com' => {
      'ipv4_address' => '3.3.3.3',
      'ipv6_address' => '2001:0db8:0a0b:12f0:0000:0000:0000:0003'
    }
  })
  zones %w(example.com test.com)
  action :install
end
```

### nsd_slave

```ruby
nsd_slave 'ns2.example.com' do
  port 53
  bind_addresses %w(2.2.2.2 2001:0db8:0a0b:12f0:0000:0000:0000:0002)
  enable_ipv6 true
  key '7DzUnLpx9H...'
  zones %w(example.com test.com)
  master_ipv4_address '1.1.1.1'
  action :install
end

```

```ruby
nsd_slave 'ns3.example.com' do
  port 53
  bind_addresses %w(3.3.3.3 2001:0db8:0a0b:12f0:0000:0000:0000:0003)
  enable_ipv6 true
  key '1ADEn1fqOo...'
  zones %w(example.com test.com)
  master_ipv4_address '1.1.1.1'
  action :install
end

```

## AXFR keys

A zone is modified only on a master server. Then the changes are transferred to slave servers. It is presupposed that each slave server has its own secret key. Secret management is up to the user utilizing `nsd_master` and `nsd_slave` resources.

A key may be generated with this command:

```sh
$ dd if=/dev/random count=1 bs=32 2> /dev/null | base64
```

## Limitations
This cookbook does not set up any firewall rules.

## License
MIT @ [Alexander Pyatkin](https://github.com/aspyatkin)
