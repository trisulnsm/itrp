require 'terminal-table'

module ITRP


class Cmd
	attr_reader :enabled_in_state		
	attr_reader :attach_cmd			   
	attr_reader :trigger			
	attr_reader :children			   

	def initialize(appenv) 
		@children=[]
		@missing=[]
		@appenv=appenv
	end

	def completions(s) 
		@children.collect { |c| c.trigger }.grep(/#{s}/)
	end

	def enter(s); end

	def is_root?
		return @trigger.empty?
	end

	def find_node(linebuffer_arr)

		return self if linebuffer_arr.empty?

		@children.each do |c|
			if c.trigger == linebuffer_arr.first
				return  c.find_node(linebuffer_arr.drop(1))
			end
		end

		return self 
	end

	def place_node(n)

		@missing.reject! do  |m|
			if n.trigger == m.attach_cmd
				n.children << m
				true
			else 
				false
			end
		end

		if n.attach_cmd==@trigger
			@children << n
			return true
		else 
			@children.each do |c|
				return true if c.place_node(n)
			end
		end

		@missing << n
		return false
	end

	def set_time_window
		# get entire time window  
		@appenv.context_data[:time_window]= TrisulRP::Protocol.get_available_time(@appenv.zmq_endpt)
		@appenv.context_data[:time_interval]= mk_time_interval(@appenv.context_data[:time_window])
		print("Connected to #{@appenv.zmq_endpt}\n");
	end

	def treeprint(indentation=0)
		ind=" "*4*indentation
		print "#{ind}#{@trigger}\n"
		@children.each  { |c|  c.treeprint(indentation+1) }
	end

	def appstate(sym)
		@appenv.context_data[sym]
	end

	def print_state
		print("\n")

		tmarr = appstate(:time_window)
		print("Server         :  #{@appenv.zmq_endpt}\n")
		print("Time  window   :  #{Time.at(tmarr[0])} to #{Time.at(tmarr[1])}    #{tmarr[1]-tmarr[0]} seconds \n");
		print("Context        :  #{@appenv.context}\n");
		print("Prompt         :  #{@appenv.prompt}\n");
		if @appenv.context != :any
			print("Selected Group :  #{appstate(:cgname)}\n");
			print("Selected GUID  :  #{appstate(:cgguid)}\n");
			print("Selected Key   :  #{appstate(:cgkey)}\n");
		end

		@appenv.context_data.each do |k,v|
			unless [:time_window, :time_interval, :cgguid, :cgname, :cgkey].member? k
				print("#{k}".ljust(14,' ') + " :  #{v}\n" )
			end
		end
	end


protected
    def wrap(str,width)
      str.gsub!(/(.{1,#{width}})( +|$\n?)|(.{1,#{width}})/, "\\1\\3\n")
    end


	PREFIX_VOLUME = %W(TiB GiB MiB KiB B).freeze
	PREFIX_BW      = %W(Tbps Gbps Mbps Kbps bps).freeze

	def as_size_volume( s )
	  s = s.to_f
	  i = PREFIX_VOLUME.length - 1
	  while s > 512 && i > 0
		i -= 1
		s /= 1024.0
	  end
	  ((s > 9 || s.modulo(1) < 0.1 ? '%d' : '%.1f') % s) + ' ' + PREFIX_VOLUME[i]
	end

	def as_size_bw( s )
	  s = s.to_f
	  i = PREFIX_BW.length - 1
	  while s > 500 && i > 0
		i -= 1
		s /= 1000.0
	  end
	  ((s > 9 || s.modulo(1) < 0.1 ? '%d' : '%.1f') % s) + ' ' + PREFIX_BW[i]
	end


end

end
