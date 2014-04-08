require 'rbconfig'
require 'at_time'

class GrowlNotifier
  def initialize(growl, speak, name)
    @growl = growl
    @speak = speak
    @name = name

    @growlnotify=`which growlnotify`.strip
    @icon = nil

    if @growlnotify == ""
      raise "I didn't find growlnotify. Make sure it is in your PATH."
    end

    # Set the icon to use See growlnotify(1)
    if File.exist?('applet.icns')
      # If we're running in the application bundle...
      @icon=%w(-I ../..)
    else
      fn = File.join(RbConfig::CONFIG['datadir'], 'creme',
                    'Crystal_Clear_app_bell.png')
      if File.exist?(fn)
        # expect it in datadir
        @icon=['--image', fn]
      else
        # borrow iCal's icon
        @icon=%w(-a iCal.app)
      end
    end
  end

  def growl(timespec, msg, show_time)
    time = AtTime.parse_timespec(timespec)
    puts "Sleeping #{(time - Time.now).round} seconds" if DEBUG
    pid = fork do
      # close stdout/stderr for the benefit of the applescript subshell
      $stderr.close
      $stdout.close

      while time - Time.now > 0
        sleep 1
      end

      if @speak
        fork do
          ary = []
          ary += %W(-v #{SAY_VOICE}) rescue nil
          ary += [msg]
          exec 'say', *ary
        end
      end

      if @growl
        fork do
          msg += " (#{time.iso8601})" if show_time
          ary = %W(-s -n #{GROWL_NAME})
          ary += @icon if @icon
          ary += %W(-m #{msg})
          puts ary.inspect if DEBUG
          exec @growlnotify, *ary
        end
      end
    end
    puts "#{time} (#{pid})"
    Process.detach(pid)
  end
end
