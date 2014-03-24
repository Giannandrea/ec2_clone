  require "aws-sdk"
  require "check_poller.rb"

class Ec2Clone

def initialize(config_file)
  AWS.config(YAML.load(File.read(config_file)))
end

  def get_name_from_tag(ec2, tag)
    puts "Searching for #{tag}"
    instance = ec2.instances.tagged_values(tag)
    instance.first.id
  end

  def clone_instance(tag, static_ip, region, sec_group)
    puts "Collecting aws instance information \n"
    #Region is EU => "ec2.eu-west-1.amazonaws.com"
    ec2=AWS::EC2.new(:ec2_endpoint => region)
    instance = get_name_from_tag(ec2, tag)
    puts "Cloning #{instance}..."
    return_values = take_instance_infos(ec2, instance, region)
    puts "Informations about sample instance collected \n"
    img_id = create_image(ec2, region, instance)
    puts "Image ready "
    cloned_instance = launch_image(ec2, region, return_values[:name], return_values[:type], return_values[:monitoring], return_values[:az], img_id, static_ip, sec_group)
    puts "Image launched"
    puts "ID : #{cloned_instance.id}"
    cloned_instance
  end

  def take_instance_infos(ec2, id, region)
    i = ec2.instances[id]
    puts "id: #{id} doesn't exist, please use a valid id" and exit unless i.exists?
    puts "Windows platform is not supported" and exit if i.platform == "windows"
    type = i.instance_type
    monitoring = i.monitoring
    name = i.tags[:Name]
    elastic_ip = i.ip_address if i.has_elastic_ip?
    az = i.availability_zone
    return_values = {:name => name, :type => type, :monitoring => monitoring, :elastic_ip => elastic_ip, :az => az}
    return return_values
  end

  def create_image(ec2, region, id)
    i = ec2.instances[id]
    time = Time.new
    name = i.tags[:Name]
    img_name = "#{name}-#{time.year}-#{time.month}-#{time.day}-#{time.hour}-#{time.min}"
    puts "Creating image..."
    test2 = i.create_image(img_name, {:description => img_name, :no_reboot => true})
    puts "#{img_name} image created"
    test = TestHelper.new
    test.wait_for_image(ec2, test2.image_id)
    return test2.image_id
  end

  def launch_image(ec2, region, name, type, monitoring, az, img_id, static_ip, sec_group)
    config = {:count => 1, :monitoring_enabled => true, :availability_zone => az, :image_id => img_id, :instance_type => type}
    config[:security_groups] = ec2.security_groups[sec_group]
    img = ec2.images[img_id]
    inst = img.run_instance(config)
    puts "Launching image #{inst.id}..."
    test = TestHelper.new
    test.wait_for_active_instance(ec2, inst.id)
    inst.associate_elastic_ip(static_ip)
    ec2.tags.create(inst, 'Name')
    inst.tags[:Name] = "#{name}_clone"
    return inst
  end
end
