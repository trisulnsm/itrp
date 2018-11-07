# Trisul Remote Protocol iTRP (Interactive TRP) 
#
# NSM (Network Security & Traffic Monitoring) Console App
#
# Full interactive shell app (Work in Progress) 
#
# ruby itrp.rb tcp://192.168.1.8:5555  
#
#
require 'trisulrp'
require 'readline'
require 'fileutils'

require_relative 'cmd_base'
require_relative 'cmd_root'

# Check arguments
raise %q{
  itrp.rb - interactive TRP shell 

  Usage   : itrp.rb  trisul-zmq-endpt 
  Example : itrp.rb  tcp://192.168.1.8:5555 
} unless ARGV.length==1

HISTFILE=File.expand_path("~/.itrp_history")
DEFAULT_PROMPT="iTRP> "

class ITRPEnv
	attr_accessor :prompt 
	attr_accessor :context 
	attr_accessor :context_data  
	attr_accessor :zmq_endpt
end 
Appenv = ITRPEnv.new
Appenv.prompt = DEFAULT_PROMPT
Appenv.zmq_endpt = ARGV.shift 
Appenv.context = :any
Appenv.context_data =  { } 


print("\n\niTRP Interactive TRP Shell for Trisul\n");

class Dispatches

	def initialize()

		# load handlers
		reload

		# root proc 
		@cmd_roots = { :any => ITRP::Cmd_root.new(Appenv) }
		@cmd_roots[:any].set_time_window 


		# build command tree 
		(ITRP::constants-[:Cmd, :Cmd_root]).each do |k|
			kls = ITRP::const_get(k)
			ins = kls.new(Appenv)
			@cmd_roots[ins.enabled_in_state] ||= ITRP::Cmd_root.new(Appenv) 
			@cmd_roots[ins.enabled_in_state].place_node(ins)
		end
		
		# hook up autocompletion 
		Readline.completion_proc = proc do |s| 
			buff = Readline.line_buffer()

			[Appenv.context, :any].uniq.collect do |ctx|
				node  = @cmd_roots[ctx].find_node(buff.split(' '))
				(node or @cmd_roots[:any]).completions(s) 
			end.flatten  
		end

		# history load 
        if File.exist? HISTFILE
            File.readlines(HISTFILE).each do |l|
                Readline::HISTORY.push(l.chop)
            end
        end

	end
	def invoke(cmdline)
		# system commands
		case cmdline.scan(/(\w+)/).flatten.first 
			when 'reload' ; reload 
			when 'quit'   ; quit 
			when 'help'   ; help
			when 'clear'  ; system("clear") 
			else;
		end 

		# dispatch to correct plugin w/ context
		node=nil
		[Appenv.context, :any].uniq.collect do |ctx|
			node  = @cmd_roots[ctx].find_node(cmdline.strip.split(' '))
			if not node.is_root?
				node.enter(cmdline.strip) 
				return
			end
		end
		node.notfound(cmdline) if node.is_root?
	end

	def reload
		print("Loading command handlers ")
		Dir.glob("handlers/*rb") do |f|
			load(f)
			print('.')
		end
		print("done\n\n")
	end

	def help
		@cmd_roots.each do |k,v|
			print "Context :#{k}\n"
			v.treeprint 
		end 
	end

	def quit
		savehistory
		exit 0
	end

	def savehistory
        File.open( HISTFILE, "w") do |h|
            Readline::HISTORY.to_a.uniq.each do |l|
                h.write(l + "\n" ) 
            end
        end
	end


end


dispatches = Dispatches.new()
while cmd = Readline.readline(Appenv.prompt, false)

	next if cmd.strip.empty? 

    begin
        dispatches.invoke(cmd)
        Readline::HISTORY.push(cmd)
		dispatches.savehistory
    rescue Exception => e 
		if e.message == 'exit' ; exit; end
        puts "Error " + e.message 
        puts "Error " + e.backtrace.join("\n") 
    end
end

