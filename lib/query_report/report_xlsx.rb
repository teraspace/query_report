module QueryReport
	require 'spreadsheet'
  	class ReportXlsx
   		attr_reader :xlsx, :options, :report

		def initialize(report)
			@report = report
			@options = QueryReport.config.pdf_options
			Spreadsheet.client_encoding = 'UTF-8'
			@book = Spreadsheet::Workbook.new
		end

		def to_xlsx
			start_row = 6
			sheet1 = @book.create_worksheet
			sheet1.row(0).concat [@report.options[:title]]
			# sheet1[1,0] = 'Japan'
			row = sheet1.row(1)
			# row.push 'Creator of Ruby'
			# row.unshift 'Yukihiro Matsumoto'
			# sheet1.row(2).replace [ 'Daniel J. Berger', 'U.S.A.',
			#                         'Author of original code for Spreadsheet::Excel' ]
			# sheet1.row(3).push 'Charles Lowe', 'Author of the ruby-ole Library'
			# sheet1.row(3).insert 1, 'Unknown'
			# sheet1.update_row 4, 'Hannes Wyss', 'Switzerland', 'Author'


			sheet1.row(0).height = 18

			format = Spreadsheet::Format.new :color => :black,
			                                 :weight => :bold,
			                                 :size => 18,
			                                 :vertical_align => :middle


			sheet1.row(0).default_format = format


			#sheet1.merge_cells(0, 0, 1, 1)


			bold = Spreadsheet::Format.new :weight => :bold, :horizontal_align => :center

			priority_high = Spreadsheet::Format.new :color => :red

			columns_lengths = []

			#Setea las Cabeceras por columnas 
			column_headers = Array.new
			@report.columns.each_with_index do |column, index|
				if column.visible? && !column.only_on_web?
					column_headers.push(column.humanize)
					columns_lengths.push ({column.humanize => column.humanize.length})
					sheet1.column(index).width = column.humanize.length + 5
					sheet1.row(start_row).set_format(index, bold)
			    end
			end

			sheet1.row(start_row).replace column_headers

			#Fin Cabeceras

			rowspan_value = nil

			value = nil
			row_values = Array.new
			index_subtotal = 0
			header_rows = start_row + 6
			index_footer = 0
			before_value = nil
			index = 0
			total_span = 0
			@report.all_records_to_render.each_with_index do |record, id|
				index = id
				row_values = Array.new
				index_t = 0
				index_f = 0
				hashed = false	
				@report.columns.each_with_index do |column, id_column| 

					if column.visible? && !column.only_on_web?
						value = record[column.humanize]
						if value.kind_of?(Hash) 
							rowspan_value = value[:content]
							index_t = value[:index_t]
							index_f = value[:index_f]
							row_values.push(rowspan_value.pretty_type(column.get_type))					
						else
							row_values.push(value.pretty_type(column.get_type))
							if value.to_s.include? 'priority_high'
								value.to_s.slice! 'priority_high'
								sheet1.row(index + header_rows).set_format(id_column, priority_high)
							end
						end
				    end

				end

				sheet1.row(index + header_rows).replace row_values
				merge_format = Spreadsheet::Format.new :vertical_align => :middle

				index_t.times do |j|
					sheet1.row(j + header_rows).set_format(0, merge_format)
				end
				
				


				if before_value!= nil and before_value[:index_t] == index
					sheet1.merge_cells(index_f + header_rows, 0, index_t + header_rows, 0)
					row_values = Array.new
					header_rows = header_rows +1
					@report.column_subtotal_with_colspan(rowspan_value).each do |total_with_colspan|      
						row_values.push(total_with_colspan[:content])
					end  
					sheet1.row(index + header_rows).replace row_values
					row_values = Array.new
					header_rows = header_rows +1
					sheet1.row(index + header_rows).replace row_values
				end

				@report.columns.each do |column| 
					value = record[column.humanize]
					#Si continene información de agrupacion
					if value.kind_of?(Hash) 
						before_value = value
					end
			    end



			
			end

			if @report.has_total?
				row_values = Array.new
			
		    	@report.column_total_with_colspan.each_with_index do |total_with_colspan, total_index|
		    		if  total_with_colspan[:colspan] != nil
		    			total_span = total_with_colspan[:colspan]-1
		    			row_values.push(total_with_colspan[:content])
		    			total_span.times do |j|
		    				row_values.push('')
		    			end
		    		else
		    		header_rows = header_rows + 1
		    		row_values.push(total_with_colspan[:content])    			
		    		end



		     	end
		     	#row_values.shift
		        sheet1.row(index + header_rows).replace row_values

		        #sheet.merge_cells(start_row, start_col, end_row, end_col)


		       # sheet1.merge_cells(index + header_rows, 1, index + header_rows, total_span)
			else
		 	end
	        require 'stringio'
	        @data_file = StringIO.new ''
	        @outfile = "Report_for_123.xls"
			@book.write @data_file
			return @data_file
		end
	end
end