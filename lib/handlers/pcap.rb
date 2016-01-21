module ITRP

class Cmd_pcap   < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = ''
		@trigger = 'pcap'
	end

	def enter(cmdline)

		patt = cmdline.scan(/pcap\s+([\w=_:\.\-]+)/).flatten.first 

        expr = patt

        if expr == "usefilter" 
        p @appenv  
            expr = @appenv.context_data[:filter]
        end 


        expr.gsub!(/flow=/,"{99A78737-4B41-4387-8F31-8077DB917336}=")
        puts "Using filter " + expr 

		req =TrisulRP::Protocol.mk_request(TRP::Message::Command::PCAP_REQUEST,
			 :time_interval => appstate(:time_interval),
			 :filter_expression => expr, 
			 :save_file => "/tmp/kk.pcap")

		rows = []
		TrisulRP::Protocol.get_response_zmq(@appenv.zmq_endpt,req) do |resp|
		
			p resp
		end

	end

end
end

