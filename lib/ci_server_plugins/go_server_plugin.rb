require 'open-uri'
require 'nokogiri'
require 'yaml'

module Blinky
  module GoCiServer
    
    FLASH_LENGTH = 0.3
    
    def get_server_locations
      blinky_dir = "#{Dir.home}/.blinky"
      config_file = "#{blinky_dir}/config.yml"

      if Dir.exists? blinky_dir
        @servers = YAML.load_file config_file
      else
          Dir.mkdir blinky_dir
        puts "config.yml copied to #{file_name} configure it and try again"
      end
    end

    def watch_go_server
      get_server_locations
      
      @light_state = "off!"
      self.send(@light_state)

      while (true)        
        @projects = []

        parse_cctray
        
        control_light

        sleep(5)
      end    
    end
    
    def parse_cctray
      @servers.each do |server|
        xml = Nokogiri::XML(open(server["url"], :http_basic_authentication=>[server["username"], server["password"]]))
        projects = xml.xpath("//Projects/Project")

        projects.each do |project|
          monitored_project = MonitoredProject.new(project)
          if server["jobs"]
            if server["jobs"].detect {|job| job["name"] == monitored_project.name}
              @projects << monitored_project
            end
          else
            @projects << monitored_project
          end
        end
      end
    end
    
    def control_light
      new_state = "off!"
      if @projects.count == 0
        new_state = "warning!"
      else        
        if @projects.any? { |p| p.last_build_status == "failure" }
          new_state = "failure!"
        else
          if @projects.any? { |p| p.activity == "building" }
            new_state = "building!"
          else
            new_state = "success!"
          end
        end
      end
      
      if new_state != @light_state
        self.send(new_state)
        sleep FLASH_LENGTH
        self.send(@light_state)
        sleep FLASH_LENGTH
        self.send(new_state)
        @light_state = new_state
      end
    end
  end
end

class MonitoredProject
  attr_reader :name, :last_build_status, :activity, :last_build_time, :web_url, :last_build_label

  def initialize(project)
    @activity = project.attributes["activity"].value.downcase
    @last_build_time = Time.parse(project.attributes["lastBuildTime"].value).localtime
    @web_url = project.attributes["webUrl"].value
    @last_build_label = project.attributes["lastBuildLabel"].value
    @last_build_status = project.attributes["lastBuildStatus"].value.downcase
    @name = project.attributes["name"].value
  end
end