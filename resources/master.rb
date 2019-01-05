resource_name :nsd_master
property :fqdn, String, name_property: true

property :user, String, default: 'nsd'
property :group, String, default: 'nsd'
property :uid, Integer, default: 500
property :gid, Integer, default: 500

property :port, Integer, default: 53
property :service, String, default: 'nsd'
property :conf_dir, String, default: '/etc/nsd'
property :log_file, String, default: '/var/log/nsd'
property :pid_file, String, default: '/run/nsd/nsd.pid'

property :ipv4_address, String, required: true
property :ipv6_address, [String, NilClass], default: nil
property :contact, String, required: true
property :bind_addresses, Array, required: true
property :enable_ipv6, [TrueClass, FalseClass], default: false
property :keys, Hash, required: true
property :slaves, Hash, required: true
property :zones, Array, required: true

default_action :install

action :install do
  nsd_user new_resource.user do
    group new_resource.group
    uid new_resource.uid
    gid new_resource.gid
    action :create
  end

  %w(
    nsd
  ).each do |pkg_name|
    package pkg_name do
      action :install
    end
  end

  service_resource = "service[#{new_resource.service}]"

  service new_resource.service do
    action [:start, :enable]
  end

  instance = ::ChefCookbook::Instance::Helper.new(node)

  zone_dir = ::File.join(new_resource.conf_dir, 'zones')

  directory zone_dir do
    owner instance.root
    group node['root_group']
    mode 0755
    action :create
  end

  template ::File.join(new_resource.conf_dir, 'nsd.conf') do
    cookbook 'nsd'
    source 'nsd.master.conf.erb'
    owner instance.root
    group node['root_group']
    variables(
      port: new_resource.port,
      bind_addresses: new_resource.bind_addresses,
      enable_ipv6: new_resource.enable_ipv6,
      service_user: new_resource.user,
      zone_dir: zone_dir,
      log_file: new_resource.log_file,
      pid_file: new_resource.pid_file,
      keys: new_resource.keys,
      slaves: new_resource.slaves,
      zones: new_resource.zones
    )
    mode 0644
    sensitive true
    action :create
    notifies :restart, "service[#{new_resource.service}]", :delayed
  end

  new_resource.zones.each do |zone_fqdn|
    nsd_zone zone_fqdn do
      zone_dir zone_dir
      master_fqdn new_resource.fqdn
      master_ipv4_address new_resource.ipv4_address
      master_ipv6_address new_resource.ipv6_address
      master_contact new_resource.contact
      slaves new_resource.slaves
      action :create
    end
  end
end
