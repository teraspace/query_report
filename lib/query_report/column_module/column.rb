# Author::    A.K.M. Ashrafuzzaman  (mailto:ashrafuzzaman.g2@gmail.com)
# License::   MIT-LICENSE

# The purpose of the column module is to define columns that are displayed in the views

module QueryReport
  module ColumnModule
    class Column
      include ActionView::Helpers::SanitizeHelper

      attr_reader :report, :name, :column_data, :options, :type, :data

      def initialize(report, column_name, options={}, block = nil)
        @report, @name,  @options = report, column_name, options
        p options
        if options.has_key?(:column_data)
          @column_data = options[:column_data]
        else
          @column_data = @name
        end
        
        @data = block || @name.to_sym
        
         
        if @report.model_class
          @type = @report.model_class.columns_hash[@name.to_s].try(:type) || options[:type] || :string rescue :string
        else
          @type = :string
        end


      end

      def only_on_web?
        @options[:only_on_web] == true
      end

      def sortable?
        @options[:sortable].present? && @options[:sortable] != false
      end
      def name
        @name
      end   
      def visible?
        @options[:visible]
      end
      
      def sort_link_attribute
        @options[:sortable] == true ? name : @options[:sortable]
      end

      def rowspan?
        @options[:rowspan] == true || @options[:rowspan].kind_of?(Symbol)
      end

      def pdf_options
        @options[:pdf] || {}
      end

      def rowspan_column_humanized
        return @rowspan_column_humanized if @rowspan_column_humanized
        rowspan_column_name = @options[:rowspan].kind_of?(Symbol) ? @options[:rowspan] : self.name

        report.columns.each do |column|
          if column.name == rowspan_column_name
            @rowspan_column_humanized = column.humanize
            return @rowspan_column_humanized
          end
        end
        @rowspan_column_humanized = self.humanize
      end

      def humanize
        @humanize ||= options[:as] || begin
          @report.model_class.human_attribute_name(name) if @report.model_class && !@report.array_record?
        end
      end

      def value(record)
        self.data.kind_of?(Symbol) ? (record.respond_to?(self.name) ? record.send(self.name) : record[self.name]) : self.data.call(record)
      end
      def has_column_data?
        @options[:column_data].present? && @options[:column_data] != false
      end
      def has_total?
        @options[:show_total].present? && @options[:show_total] != false
      end

      def align
        @options[:align] || (has_total? ? :right : :left)
      end
      def total
        @total ||= begin
      	 if has_total? 
      	   
        	 	if @options[:show_grand_total]
  	        	report.records_without_pagination.inject(0) do |sum, r|
  	        	  
          		    	if !@options[:column_data] && @options.visible?
          		    	  r = report.content_from_element(r[humanize])
                    else
                      r = report.content_from_element(r[ @report.model_class.human_attribute_name(@column_data) ])
          		    	end
  			            r = strip_tags(r) if r.kind_of? String
  			            
                		sum + r.to_f
  			      end
  			      
        		else
        
          		report.records_to_render.inject(0) do |sum, r|
            			r = report.content_from_element(r[humanize])
            			r = strip_tags(r) if r.kind_of? String
            			sum + r.to_f
          		end

        		end
          else
            nil
          end
        end
      end
      # def total
      #   @total ||= begin
      #     if has_total?
      #       sum = 0
      #       report.records_to_render.each do |r|
      #         r = report.content_from_element(r[humanize])
      #         r = strip_tags(r) if r.kind_of? String
      #         sum = sum + r.to_f
      #       end
      #       sum.kind_of?(Float) ? sum.round(2) : sum
      #     else
      #       nil
      #     end
      #   end
      # end
    end
  end
end