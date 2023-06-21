module ITRP 

#
# any fields in the TRP proto file  most used 
# pattern=
# label=
#
class Cmd_searchkey  < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :counter
		@attach_cmd  = ''
		@trigger = 'searchkey'
	end


    def completions(patt)
		TRP::SearchKeysRequest
		        .fields
				.values
				.collect { |a| a.name.to_s  }
				.grep( /^#{Regexp.escape(patt)}/i)
	end


	def enter(cmdline)

		terms = cmdline.scan( /(\w+)\s*=\s*([\w\-_\.\:,\]\[\$]+)+/ )
		qparams = terms.inject({}) { |acc,t| acc.store( t[0].to_sym, t[1]);acc}

		[:maxitems, :offset ].each do |a|
			qparams[a] = qparams[a].to_i if qparams.key? a
		end

		[:keys].each do |a|
			qparams[a] = qparams[a].split(',')  if qparams.key? a
		end

	    p qparams 
        req =mk_request(TRP::Message::Command::SEARCH_KEYS_REQUEST,
                        {
                             :counter_group => appstate(:cgguid),
							 :get_attributes => true
                        }.merge( qparams))

        rows = []
        get_response_zmq(@appenv.zmq_endpt,req) do |resp|
            resp.keys.each do |k|

				attr  =  k.attributes.collect  do |a|
					"#{a.attr_name}=#{a.attr_value}"
				end
                rows << [ k.key, k.label, k.readable, attr.join(",") ]

            end
        end


        table = Terminal::Table.new( :headings => %w(Key  Label Readable Attributes ), :rows => rows)
        puts(table) 

    end

end
end

