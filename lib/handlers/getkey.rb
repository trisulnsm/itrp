module ITRP 

class Cmd_getkey  < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :counter
		@attach_cmd  = ''
		@trigger = 'getkey'
	end



	def enter(cmdline)

        patt = cmdline.scan(/getkey (.*)/).flatten

        print("Search [#{patt[0]}]\n")
        req =mk_request(TRP::Message::Command::SEARCH_KEYS_REQUEST,
                         :counter_group => appstate(:cgguid),
                         :label  => patt[0])


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

