require 'date'

id = 'nsd'

secret = ::ChefCookbook::Secret::Helper.new(node)

include_recipe "#{id}::service_user"

node[id]['packages']['master'].each do |pkg_name|
  package pkg_name do
    action :install
  end
end

service_name = node[id]['service']['name']
service_resource = "service[#{service_name}]"

service service_name do
  action [:start, :enable]
end

zone_dir = ::File.join(node[id]['service']['conf_dir'], 'zones')

directory zone_dir do
  owner 'root'
  group node['root_group']
  mode 0755
  action :create
end

service_conf_file = ::File.join(node[id]['service']['conf_dir'], 'nsd.conf')
service_user = node[id]['service']['user']

node[id]['zones'].each do |fqdn|
  zone_file = "#{::File.join(zone_dir, fqdn)}.zone"

  template zone_file do
    source 'nsd.zone.erb'
    owner 'root'
    group node['root_user']
    variables(
      fqdn: fqdn,
      master_fqdn: node[id]['master']['fqdn'],
      master_ipv4_address: node[id]['master']['ipv4_address'],
      master_ipv6_address: node[id]['master']['ipv6_address'],
      master_contact: node[id]['master']['contact'],
      slaves: node[id]['slaves'],
      serial: ::DateTime.now.strftime('%Y%m%d01'),
      ttl: 600
    )
    mode 0644
    action :create_if_missing
  end
end

template service_conf_file do
  source 'nsd.master.conf.erb'
  owner 'root'
  group node['root_group']
  variables(
    enable_ipv6: node[id]['enable_ipv6'],
    service_user: service_user,
    zone_dir: zone_dir,
    log_file: '/var/log/nsd.log',
    pid_file: '/run/nsd/nsd.pid',
    keys: secret.get('nsd:keys', default: {}, prefix_fqdn: false),
    slaves: node[id]['slaves'],
    zones: node[id]['zones']
  )
  mode 0644
  action :create
  notifies :restart, service_resource, :delayed
end
