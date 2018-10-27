id = 'nsd'

instance = ::ChefCookbook::Instance::Helper.new(node)
secret = ::ChefCookbook::Secret::Helper.new(node)

include_recipe "#{id}::service_user"

node[id]['packages']['slave'].each do |pkg_name|
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

template service_conf_file do
  source 'nsd.slave.conf.erb'
  owner 'root'
  group node['root_group']
  variables(
    bind_addresses: node[id]['slaves'][instance.fqdn]['bind_addresses'] || [],
    enable_ipv6: node[id]['enable_ipv6'],
    service_user: service_user,
    zone_dir: zone_dir,
    log_file: '/var/log/nsd.log',
    pid_file: '/run/nsd/nsd.pid',
    key_name: instance.fqdn,
    key_secret: secret.get("nsd:keys:#{instance.fqdn}", prefix_fqdn: false),
    zones: node[id]['zones'],
    master_ipv4_address: node[id]['master']['ipv4_address']
  )
  mode 0644
  action :create
  notifies :restart, service_resource, :delayed
end
