require File.join(File.dirname(__FILE__), '..', '/spec_helper')
require 'ci_server_plugins/go_server_plugin'
module Blinky
  
    class StubBlinky
    end
  
    describe "GoServerPlugin" do
      
      before(:each) do
       @blinky = StubBlinky.new
       @blinky.extend(GoServerPlugin)
      end
      
      it "creates a .blinky directory in the users home directory" do
      end      
      
      it "displays failure! if any of the builds is broken" do
        
      end
      
      it "displays building! if no failures and build was successful" do
        
      end
      
      it "displays success! if all builds green and not building" do
        
      end
      
      it "displays warning! if there are no builds" do
        
      end
      
      it "flashes betwen the new and old colour briefly when changing state" do
        
      end
    end  
end