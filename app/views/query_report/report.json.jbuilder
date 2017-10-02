pg = 1
begin
	pg = params[:page]
rescue
	pg = 1
end

paginated_report  =  @report.apply_pagination(@report.query,page: pg)

json.status :ok
json.message 'Report rendered in json'


before_value, value, idx,rowspan_value = nil,nil, 0, nil
columns_names = Array.new
records = Array.new


@report.columns.each do |column|
	if column.visible?
		columns_names.push(column.humanize)
	end
end

@report.records_to_render.each_with_index do |record, index|

	@report.columns.each do |column|
        if column.visible?
        	value = record[column.humanize]
			if value.kind_of?(Hash) 
				rowspan_value = value[:content]
				value = value[:content].pretty_type(column.get_type)
			elsif record.has_key?(column.humanize) 
				value = value.pretty_type(column.get_type) 
			end      	
		records.push(value)
        end
	end

	if before_value!= nil and before_value[:index_t] == index
		@report.column_subtotal_with_colspan(rowspan_value).each do |total_with_colspan|
			records.push(total_with_colspan[:content] )
		end
        before_value = nil
        value = nil		
	end

 #      #Se recorren las columnas para obtener el valor que contiene la información del la Agrupación
      @report.columns.each do |column| 
          value = record[column.humanize]
          #Si continene información de agrupacion
          if value.kind_of?(Hash) 
            before_value = value
          end
      end
      idx=+1
end
# if report.has_total?

#      report.column_total_with_colspan.each_with_index do |total_with_colspan, total_index|
#           json.total total_with_colspan[:content]
#      end


# else
# end

json.data do
	json.columns_names columns_names
	json.records records
end
json.partial! 'query_report/paginating', model: paginated_report