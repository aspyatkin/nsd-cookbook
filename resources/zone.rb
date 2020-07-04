require 'date'

resource_name :nsd_zone

property :fqdn, String, name_property: true
property :zone_dir, String, required: true
property :master_fqdn, String, required: true
property :master_ipv4_address, String, required: true
property :master_ipv6_address, [String, NilClass], default: nil
property :master_contact, String, required: true
property :slaves, Hash, required: true
property :refresh, Integer, default: 3_600
property :retry, Integer, default: 900
property :expire, Integer, default: 1_209_600
property :ttl, Integer, default: 600

default_action :create

action :create do
  zone_file = "#{::File.join(new_resource.zone_dir, new_resource.fqdn)}.zone"

  template zone_file do
    cookbook 'nsd'
    source 'nsd.zone.erb'
    owner 'root'
    group node['root_user']
    variables(
      fqdn: new_resource.fqdn,
      master_fqdn: new_resource.master_fqdn,
      master_ipv4_address: new_resource.master_ipv4_address,
      master_ipv6_address: new_resource.master_ipv6_address,
      master_contact: new_resource.master_contact,
      slaves: new_resource.slaves,
      serial: ::DateTime.now.strftime('%Y%m%d01'),
      refresh: new_resource.refresh,
      retry: new_resource.retry,
      expire: new_resource.expire,
      ttl: new_resource.ttl
    )
    mode 0644
    action :create_if_missing
  end
end
