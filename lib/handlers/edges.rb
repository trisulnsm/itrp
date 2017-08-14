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

				print "=====  RESPONSE  =====\n"
				print "\tSUBJECT GUID = #{resp.subject_group}\n"
				print "\tSUBJECT KEY  = #{resp.subject_key.key}\n"

			resp.graphs.each do |g|

				print "=====  GRAPH  =====\n"
				print "\t\tTIME FROM = #{Time.at(g.time_interval.from.tv_sec)}\n"
				print "\t\tTIME TO   = #{Time.at(g.time_interval.to.tv_sec)}\n"

				g.vertex_groups.each do |vg|

					vertices_labels = vg.vertex_keys.collect { |k| k.label }.join(',')

					print "\t\t\t---------------------------------------------\n"
					print "\t\t\tVERTEX   GROUP  = #{vg.vertex_group}\n"
					print "\t\t\tVERTICES LABELS = #{vertices_labels}\n"
				end

			end 

		end

	end

end
end

