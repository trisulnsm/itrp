module ITRP

class Cmd_options   < Cmd 
	def initialize (e)
		super(e)
		@enabled_in_state = :any
		@attach_cmd  = 'set'
		@trigger = 'options'
	end

	def completions(patt)
		 [ "maxitems", "cgkey", "resolve_keys" ].grep( /^#{Regexp.escape(patt)}/i)
	end

	def enter(cmdline)

		terms = cmdline.scan( /(\w+)\s*=\s*([\w\-_\.\:,]+)+/ )

		terms.each do |a|
			val = case a[0]
				when 'maxitems';  a[1].to_i
				when 'resolve_keys';  a[1] == "true"
				else; a[1]
			end
			@appenv.context_data.store( a[0].to_sym,   val )
		end

	end

end
end


