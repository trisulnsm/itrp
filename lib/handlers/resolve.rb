module ITRP

class Cmd_resolve  < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :counter
		@attach_cmd  = ''
		@trigger = 'resolve'
	end

	def enter(cmdline)

		patt = cmdline.scan(/resolve\s+(\S*)/).flatten.first 

        patt.split(',')

		req =mk_request(TRP::Message::Command::KEY_LOOKUP_REQUEST,
						 :counter_group => appstate(:cgguid),
						 :keys  => patt.split(','))


        rows = []
		get_response_zmq(@appenv.zmq_endpt,req) do |resp|
            resp.keys.each do |k|
                rows << [ k.key, k.label, k.readable ]
            end
		end

		table = Terminal::Table.new( :headings => %w(Key  Label Readable ), :rows => rows)
		puts(table) 
    end

end
end
