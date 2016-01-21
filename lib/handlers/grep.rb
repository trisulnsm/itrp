module ITRP

class Cmd_grep   < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = ''
		@trigger = 'grep'
	end

	def enter(cmdline)

		patt = cmdline.scan(/grep\s+(\w+)/).flatten.first 

		req =TrisulRP::Protocol.mk_request(TRP::Message::Command::GREP_REQUEST,
			 :time_interval => appstate(:time_interval),
			 :pattern_text => patt  )

		rows = []
		TrisulRP::Protocol.get_response_zmq(@appenv.zmq_endpt,req) do |resp|
			sz = resp.sessions.size
			(0..sz-1).each  do |i|
                s = resp.sessions[i]
                rows << [ s.session_key,  s.time_interval.from.tv_sec, s.time_interval.to.tv_sec, s.key1A.label, s.key1Z.label, resp.hints[i]]
			end
		end

		table = Terminal::Table.new( 
				:headings => %w(key tmFrom tmTo IPA IPZ hints ),
				:rows => rows)
		puts(table) 

        if cmdline  =~ /savefilter/

            
            fkeys  = rows.collect{ |r| r[0] }.join(",")
            @appenv.context_data[:filter] = '{99A78737-4B41-4387-8F31-8077DB917336}='  + fkeys  
            puts "Filter string saved as @appenv.context_data[:filter] " + @appenv.context_data[:filter] 

        end


	end

end
end

