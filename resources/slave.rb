resource_name :nsd_slave
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

property :bind_addresses, Array, required: true
property :enable_ipv6, [TrueClass, FalseClass], default: false
property :key, String, required: true
property :zones, Array, required: true
property :master_ipv4_address, String, required: true

default_action :install

action :install do
  nsd_user new_resource.user do
    group new_resource.group
    uid new_resource.uid
    gid new_resource.gid
    action :create
  end

  systemd_unit new_resource.service do
    action :nothing
  end
  systemd_unit_resource = "systemd_unit[#{new_resource.service}]"

  service new_resource.service do
    action :nothing
  end
  service_resource = "service[#{new_resource.service}]"

  %w(
    nsd
  ).each do |pkg_name|
    package pkg_name do
      action :install
      notifies :mask, systemd_unit_resource, :before
      notifies :unmask, systemd_unit_resource, :immediately
    end
  end

  zone_dir = ::File.join(new_resource.conf_dir, 'zones')

  directory zone_dir do
    owner 'root'
    group node['root_group']
    mode 0755
    action :create
  end

  template ::File.join(new_resource.conf_dir, 'nsd.conf') do
    cookbook 'nsd'
    source 'nsd.slave.conf.erb'
    owner 'root'
    group node['root_group']
    variables(
      port: new_resource.port,
      bind_addresses: new_resource.bind_addresses,
      enable_ipv6: new_resource.enable_ipv6,
      service_user: new_resource.user,
      zone_dir: zone_dir,
      log_file: new_resource.log_file,
      pid_file: new_resource.pid_file,
      key_name: new_resource.fqdn,
      key_secret: new_resource.key,
      zones: new_resource.zones,
      master_ipv4_address: new_resource.master_ipv4_address
    )
    mode 0644
    sensitive true
    action :create
    notifies :restart, "service[#{new_resource.service}]", :delayed
  end

  service new_resource.service do
    action [:start, :enable]
  end
end
