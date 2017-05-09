# Author::    A.K.M. Ashrafuzzaman  (mailto:ashrafuzzaman.g2@gmail.com)
# License::   MIT-LICENSE

# The purpose of the column module is to define columns that are displayed in the views

module QueryReport
  module ColumnModule
    class Column
      include ActionView::Helpers::SanitizeHelper

      attr_reader :report, :name, :options, :type, :data

      def initialize(report, column_name, options={}, block = nil)
        @report, @name,  @options = report, column_name, options
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
        @options[:visible].present? && @options[:visible] != false
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

      def subtotal_column_humanized
        return @subtotal_column_humanized if @subtotal_column_humanized
        rowspan_column_name = @options[:show_subtotal].kind_of?(Symbol) ? @options[:show_subtotal] : self.name

        report.columns.each do |column|
          if column.name == rowspan_column_name
            @rowspan_column_name = column.humanize
            return @rowspan_column_name
          end
        end
        @rowspan_column_name = self.humanize
      end

      def humanize
        @humanize ||= options[:as] || begin
          @report.model_class.human_attribute_name(name) if @report.model_class && !@report.array_record?
        end
      end

      def value(record)
        self.data.kind_of?(Symbol) ? (record.respond_to?(self.name) ? record.send(self.name) : record[self.name]) : self.data.call(record)
      end
      def has_type?
         @options[:type].present? && @options[:type] != false
      end
      def get_type
        has_type? ? @options[:type] : false
      end
      def has_total?
        @options[:show_total].present? && @options[:show_total] != false
      end
      def has_grand_total?
        @options[:show_grand_total].present? && @options[:show_grand_total] != false
      end
      def has_subtotal?
        @options[:show_subtotal].present? && @options[:show_subtotal] != false
      end
      def align
        @options[:align] || (has_total? ? :right : :left)
      end

      def total(column)
        if has_subtotal?
          p report.query.sum(column.name.to_sym).class
          return report.query.sum(column.name.to_sym).pretty_type get_type
        else 
          return nil
        end  
      end
     

      def sub_total(key,value,column)
        p 'get_type : ' + get_type.to_s
        @type_total = 'i'
        @sub_total  = 0
        if has_subtotal?
          p report.filtered_query.where(key.name => value ).sum(column.name.to_sym).class
          return report.filtered_query.where(key.name => value ).sum(column.name.to_sym).pretty_type get_type
        else 
          return nil
        end          
      end

      def sub_total2(from, to)

        @type_total = 'i'
        @sub_total  = 0

        report.records_without_pagination.values_at(from..to).inject(0) do |sum, r|
          if ( (r[humanize].to_s.include? ":")  )
            @type_total = 'h'
            r = duration_in_seconds(r[humanize].to_s)
            @sub_total = @sub_total + r.to_i
          else
            @sub_total = @sub_total + r[humanize].to_i
          end
        end


        if @type_total == 'i'
          @sub_total
        elsif @type_total == 'h'
          @sub_total = @sub_total.pretty_duration            
        else
          'nada'
        end

      end
 def total2

          @type_total = 'i'
          @total = 0

          if has_total?
             p 'has_total?'
              report.records_to_render.inject(0) do |sum, r|
                  if ( (r[humanize].to_s.include? ":") || ( r[humanize].to_s.include? "/" ) || (r[humanize].to_s.include? "-") )
                    @type_total = 'h'
                    r = report.content_from_element(duration_in_seconds(r[humanize].to_s))
                  else 
                    r = report.content_from_element(r[humanize])
                  end
                  sum + r.to_f
                  @total = @total + r.to_f
              end
          end
          if has_grand_total?
            p 'has_grand_total?'
              report.records_without_pagination.inject(0) do |sum, r|               
                if ( (r[humanize].to_s.include? ":") || ( (r[humanize].to_s.include? "/")  ))
                    @type_total = 'h'
                    p 'calculate houres'
                    p r[humanize].to_s
                    r = report.content_from_element(duration_in_seconds(r[humanize].to_s))
                    @total = @total + r.to_f
                else
                    r = report.content_from_element(r[humanize])
                    r = strip_tags(r) if r.kind_of? String
                    @total = @total + r.to_f
                end
              end
          end

          if @type_total == 'i'
              @total
          elsif @type_total == 'h'
              @total = @total.pretty_duration
          end
      end

      def duration_in_seconds(input)
        h, m, s = input.split(':').map(&:to_i)
        (h.hours.to_i + m.minutes.to_i + s.seconds.to_i)
      end

    end
  end
end