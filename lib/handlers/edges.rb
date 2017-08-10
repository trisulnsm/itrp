module ITRP

class Cmd_edges < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :counter
		@attach_cmd  = ''
		@trigger = 'edges'
	end



    def enter(cmdline)

        patt = cmdline.scan(/edges\s+(.*)/).flatten

		p patt 

		use_key = patt.empty? ? appstate(:cgkey)  : patt[0]

		# meter names 
		req =mk_request(TRP::Message::Command::GRAPH_REQUEST,
						 :time_interval =>  appstate( :time_interval), 
						 :subject_group => @appenv.context_data[:cgguid],
						 :subject_key => use_key )

		rows  = [] 

		print "Request sent at  #{Time.now}\n"
	
		TrisulRP::Protocol.get_response_zmq(@appenv.zmq_endpt,req) do |resp|

			print resp

		end

	end

end
end

