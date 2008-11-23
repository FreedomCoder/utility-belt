# original clipboard code: http://project.ioni.st/post/1334#snippet_1334
# turned it into a class to make it flexxy:
# http://gilesbowkett.blogspot.com/2007/09/improved-auto-pastie-irb-code.html
# Extended to handle windows and linux as well
require 'platform'

module UtilityBelt
  class Clipboard
    
    def self.available?
      @@implemented || false
    end
    
    case Platform::IMPL
    when :macosx

      def self.read
        IO.popen('pbpaste') {|clipboard| clipboard.read}
      end

      def self.write(stuff)
        IO.popen('pbcopy', 'w+') {|clipboard| clipboard.write(stuff)}
      end
      @@implemented = true
   
    when :linux
      
      if File.exist?('/usr/bin/xsel') || File.exist?('/usr/local/bin/xsel') || File.exist?('/usr/X11/bin/xsel')
             
        def self.read
          IO.popen('xsel') {|clipboard| clipboard.read}
        end
      
        def self.write(stuff)
          IO.popen('xsel -i', 'w+') {|clipboard| clipboard.write(stuff)}
        end
        @@implemented = true
      else
        raise "You need to install package xsel\n 
              ubuntu,debian: sudo apt-get install xsel\n
              Gentoo: sudo emerge xsel\n
              fedora,centos,opensuse: yum install xsel\n"
      end
    when :mswin

      begin
        # Try loading the win32-clipboard gem
        require 'win32/clipboard'

        def self.read
          Win32::Clipboard.data
        end

        def self.write(stuff)
          Win32::Clipboard.set_data(stuff)
        end
        @@implemented = true

      rescue LoadError
        raise "You need the win32-clipboard gem for clipboard functionality!"
      end
  
    else
      raise "No suitable clipboard implementation for your platform found!"
    end
    
  end
end

Clipboard = UtilityBelt::Clipboard if Object.const_defined? :IRB
