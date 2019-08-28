require 'pathname'

Facter.add("server_type") do
  confine :kernel => "Linux"
  setcode do
    m = Facter.value('manufacturer')
    h = Facter.value('hostname')
    if m == 'OpenStack Foundation'
      'openstack'
    else
      path = Pathname.new('/proc/1/cgroup')
      return false unless path.readable?
      lxc_hierarchies = path.readlines.map {|l| l.split(":")[2].to_s.start_with? '/lxc/' or l.split(":")[2].to_s.start_with? "/#{h}" }
      init_environ_content = File.read("/proc/1/environ")

      if lxc_hierarchies.include?(true)
        "lxc"
      elsif init_environ_content =~ %r{\x00?container=lxc\x00?}
        "lxc"
      else
        "baremetal"
      end

    end
  end
end
