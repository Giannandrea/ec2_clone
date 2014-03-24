module CheckPoller
  def poll(msg=nil, seconds=nil, delay=nil)
    seconds ||= 2.0
    giveupat = Time.now + seconds
    delay = 0.1
    failure = nil

    while Time.now < giveupat do
      result = yield
      return result if result
      sleep delay
    end
    msg ||= "polling failed"
    raise msg
  end

  module_function :poll
end

class TestHelper
  include CheckPoller

  def wait_for_image(ec2, id)
    #ec2=AWS::EC2.new(:ec2_endpoint => region)
    puts "Image creation failed" and exit if ec2.images[id].state == :failed
    poll("Image didn't come online quick enough", 5600, 30) do
      ec2.images[id].state == :available
    end
  end

  def wait_for_active_instance(ec2, id)
    #ec2=AWS::EC2.new(:ec2_endpoint => region)
    puts "Instance launch failed" and exit if ec2.instances[id].status == :terminated
    poll("Instance hasn't been launched quick enough", 1800, 30) do
      ec2.instances[id].status == :running
    end
  end
end
