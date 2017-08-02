module QueryReport
  module Record
    attr_accessor :query

    def model_class
      query.klass if query.respond_to? :klass
    end

    def array_record?
      query.kind_of?(Array)
    end

    def filtered_query
      @filtered_query
    end

    def filtered_paginated_query
      @filtered_paginated_query
    end

    def search
      @search
    end

    def apply
      @filtered_query ||= array_record? ? query : apply_filters(query.clone, @params)
      @filtered_paginated_query ||= array_record? ? query : apply_pagination(@filtered_query, @params)
    end
    def columns
      @columns
    end
    # Returns records
    # @param format [Symbol] supports [:html|:json|:csv|:pdf]
    # @return [Array<Hash>] The key for the hash will be the translated keys
    # [{'Name' => 'Ashraf', 'Email' => 'test@jitu.email'},
    #  {'Name' => 'Razeen', 'Email' => 'test@razeen.email'}]
    def records
      apply
      record_to_map = array_record? ? query.clone : filtered_paginated_query
      @records ||= map_record(record_to_map, true)
    end

    def records_without_pagination
    apply
      record_to_map = array_record? ? query.clone : filtered_query
      @records_without_pagination ||= map_record(record_to_map, false)
    end

    def map_record(query, render_from_view)

      @columns = @columns.delete_if { |col| col.only_on_web? } unless render_from_view

      query.map do |record|
        array = @columns.collect { |column| 
        
          [column.humanize, sanitize_value(column.value(record), render_from_view)] 
          
        }
        Hash[*array.flatten]
        
      end
    end

    def has_any_rowspan?
      @has_any_rowspan = @columns.any?(&:rowspan?) if @has_any_rowspan.nil?
      @has_any_rowspan
    end
    def has_any_subtotal?
      @has_any_subtotal = @columns.any?(&:show_subtotal?) if @has_any_subtotal.nil?
      @has_any_subtotal
    end
    def records_to_render
      @records_to_render ||= map_rowspan(records)
    end

    def all_records_to_render
      @all_records_to_render ||= map_rowspan(records_without_pagination)
    end

    def map_rowspan(recs)
      return recs unless has_any_rowspan?

      last_reset_index = @columns.select(&:rowspan?).inject({}) { |hash, column| hash[column.humanize] = 0; hash }
      rowspan_column_hash = @columns.select(&:rowspan?).inject({}) { |hash, column| hash[column.humanize] = column.rowspan_column_humanized; hash }
      subtotal_column_hash = @columns.select(&:has_subtotal?).inject({}) { |hash, column| hash[column.humanize] = column.subtotal_column_humanized; hash }
      prev_row = {}
      recs.each_with_index do |row, index|
        
        last_reset_index.each do |col, last_index|
          rowspan_col = rowspan_column_hash[col]

          rowspan_content = content_from_element(row[rowspan_col]) #picking the current content of the rowspan column
          prev_rowspan_content = content_from_element(prev_row[rowspan_col]) #picking the last rowspan content stored

          content = content_from_element(row[col])
          prev_content = content_from_element(prev_row[col])

          if index == 0 || rowspan_content != prev_rowspan_content || content != prev_content
            last_reset_index[col] = index
            row[col] = {content: content, rowspan: 1, sub_total: true, index_f: index, index_t: 0}
          elsif rowspan_content == prev_rowspan_content
            recs[last_index][col][:rowspan] += 1
            recs[last_index][col][:index_t]  = index
          end

        end

        prev_row = row
      end

      #cleaning up the un needed row values
      recs.each do |row|
        last_reset_index.each do |col, last_index|
          row.delete col unless row[col].kind_of?(Hash)
        end
      end

    end

    def content_from_element(content)
      content.kind_of?(Hash) ? content[:content] : content
    end

    private
    def sanitize_value(data, render_from_view)
      data = strip_tags(data) if !render_from_view && data.present? && data.is_a?(String)
      data
    end
  end
end