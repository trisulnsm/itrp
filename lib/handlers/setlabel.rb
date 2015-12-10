module ITRP

class Cmd_setlabel  < Cmd 

	def initialize (e)
		super(e)
		@enabled_in_state = :counter
		@attach_cmd  = ''
		@trigger = 'setlabel'
	end

	def completions(patt)
		%w( key label desc).grep( /^#{Regexp.escape(patt)}/i)
	end


	def enter(cmdline)

		terms = cmdline.scan( /(\w+)\s*=\s*([\w\-_\.\:,]+)+/ )
		qparams = terms.inject({}) { |acc,t| acc.store( t[0].to_sym, t[1]);acc}

		p qparams 
        req =mk_request(TRP::Message::Command::UPDATE_KEY_REQUEST,
                         :counter_group => appstate(:cgguid),
                         :keys  => [ TRP::KeyDetails.new( qparams ) ] )


        get_response_zmq(@appenv.zmq_endpt,req) do |resp|
			p resp
        end
    end

end
end



