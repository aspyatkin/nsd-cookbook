# nsd cookbook
[![Chef cookbook](https://img.shields.io/cookbook/v/nsd.svg?style=flat-square)]()
[![license](https://img.shields.io/github/license/aspyatkin/nsd-cookbook.svg?style=flat-square)]()  
A Chef cookbook to install nsd master and slaves along with initial zone configuration.

## Recipes

### nsd::master

Install nsd master and configure zones.

### nsd::slave

Install nsd slave and configure zones.

## Configuration

Better to explain it by an extract from node attributes:

```json
    ...
    "nsd": {
      "enable_ipv6": true,
      "master": {
        "fqdn": "ns1.example.com",
        "ipv4_address": "1.1.1.1",
        "ipv6_address": "2001:0db8:0a0b:12f0:0000:0000:0000:0001",
        "contact": "hostmaster@example.com"
      },
      "slaves": {
        "ns2.example.com": {
          "ipv4_address": "2.2.2.2",
          "ipv6_address": "2001:0db8:0a0b:12f0:0000:0000:0000:0002"
        },
        "ns3.example.com": {
          "ipv4_address": "3.3.3.3",
          "ipv6_address": "2001:0db8:0a0b:12f0:0000:0000:0000:0003"
        }
      },
      "zones": [
        "example.com",
        "test.com"
      ]
    },
    ...
```

This configuration describes one master (`ns1.example.com`) and two slave servers (`ns2.example.com` and `ns3.example.com`), all of which host two zones - `example.com` itself and `test.com`. SOA records will contain `hostmaster@example.com` as an email address.

### AXFR keys

A zone is modified only on a master server. Then the changes are transferred to slave servers. It is presupposed that each slave server has its own secret key which is stored in an encrypted data bag named `nsd`:

```json
{
    "id": "production",
    "keys": {
        "ns2.example.com": "7DzUnLpx9H...",
        "ns3.example.com": "1ADEn1fqOo..."
    }
}
```

A key may be generated with this command:

```sh
$ dd if=/dev/random count=1 bs=32 2> /dev/null | base64
```

## Limitations
This cookbook does not set up any firewall rules.

## License
MIT @ [Alexander Pyatkin](https://github.com/aspyatkin)
