# Author::    A.K.M. Ashrafuzzaman  (mailto:ashrafuzzaman.g2@gmail.com)
# License::   MIT-LICENSE

# The purpose of the column module is to define columns that are displayed in the views

require 'query_report/column_module/column'

module QueryReport
  module ColumnModule
    module DSL
      attr_accessor :columns, :column_total_with_colspan
      

      def initialize_columns
        @columns = []
      end

      # Creates a filter and adds to the filters
      # @param name the column on which the filter is done on
      # @option options [Symbol] :type date | text | whatever
      # @option options [String] :as The title of the column, by default it fetches from the I18n column translation, Model.human_attribute_name(column_name)
      # @option options [Boolean] :show_total set true to calculate total for that column. It will render the total in the footer.
      # @option options [Boolean] :only_on_web the column will appear on the web and not appear in PDF, CSV or JSON if set to true
      # @option options [Boolean] :sortable if set to true then sorts on that column, but if the sorting has to be on a joint table then you have to specify the column on which the sorting will happen
      # @option options :rowspan the rows with same values in the same column will span if set to true
      # @option options :pdf[:width] pass width of the column in the pdf
      #
      # @example Row span
      #   column :invoiced_to_name, rowspan: true
      #   column :invoice_title
      #   column :invoice_date, rowspan: :invoiced_to_name
      #   ┌───────────┬────────────┬─────────────────┐
      #   │ Name      │  Invoice   │   Invoiced on   │
      #   ├───────────┼────────────┼─────────────────┤
      #   │           │  Invoice1  │                 │
      #   │ Jitu      ├────────────┤    2-2-2014     │
      #   │           │  Invoice2  │                 │
      #   ├───────────┼────────────┼─────────────────┤
      #   │ Setu      │  Invoice3  │    2-2-2014     │
      #   └───────────┴────────────┴─────────────────┘
      #
      # @example Show total
      #   column :invoiced_to_name, rowspan: true
      #   column :invoice_title
      #   column :total_charged, show_total: true
      #   ┌───────────┬────────────┬─────────────────┐
      #   │ Name      │  Invoice   │   Total charge  │
      #   ├───────────┼────────────┼─────────────────┤
      #   │           │  Invoice1  │      100        │
      #   │ Jitu      ├────────────┼─────────────────┤
      #   │           │  Invoice2  │      120        │
      #   ├───────────┼────────────┼─────────────────┤
      #   │ Setu      │  Invoice3  │       80        │
      #   ├───────────┴────────────┼─────────────────┤
      #   │                  Total │      300        │
      #   └────────────────────────┴─────────────────┘
      # The translation key used for total is 'query_report.total'
      #
      # @example Sorting
      #  column :invoice_date, sortable: true
      #  column :invoice_to, sortable: 'users.name'
      #
      # If you want to sort a column which is a column of the active record model that the query returns,
      # then just set true to make the column sortable.
      # If the column is from another table then you have to specify the column name.
      #
      # @example Pdf options
      #  column :invoice_date, pdf: {width: 20}
      # This is how you can control the width of the column in the pdf
      def column(name, options={}, &block)
        options[:visible] = true
        options[:only_on_web] = false
        @columns << Column.new(self, name, options, block)        
      end

      # @return [Array<Hash>] the footer for the table with total with appropriate colspan and content
      # Sample output
      #  [{content: "Total", colspan: '2'}, 200, 300]
      def column_total_with_colspan
        p 'column_total_with_colspan'
        column_rowspan = nil
        total_with_colspan = []
        colspan = 0
        total_text_printed = false
        columns.each do |column|
             if column.has_total? || column.has_grand_total?
              if colspan > 0
                title = total_text_printed ? '' : I18n.t('query_report.total')
                total_with_colspan << (colspan == 1 ? {content: title} : {content: title, colspan: colspan})
              end
              total_with_colspan << {content: column.total(column), align: column.align}
              total_text_printed = true
              colspan = 0
            else
              if column.visible?
                colspan += 1
              end
            end
          end
        if colspan > 0
          total_with_colspan << {content: '', colspan: colspan}
        end
        total_with_colspan
      end
      def column_total_with_colspan2
        p 'column_total_with_colspan'
        total_with_colspan = []
        colspan = 0
        total_text_printed = false
        columns.each do |column|
          p 'grand_total?'
           p column.has_grand_total?
             if column.has_total? || column.has_grand_total?
              if colspan > 0
                title = total_text_printed ? '' : I18n.t('query_report.total')
                total_with_colspan << (colspan == 1 ? {content: title} : {content: title, colspan: colspan})
              end
              total_with_colspan << {content: column.total, align: column.align}
              total_text_printed = true
              colspan = 0
            else
              if column.visible?
                colspan += 1
              end
            end
          end
        if colspan > 0
          total_with_colspan << {content: '', colspan: colspan}
        end
        total_with_colspan
      end
      # @return [Array<Hash>] the footer for the table with total with appropriate colspan and content
      # Sample output
      #  [{content: "Total", colspan: '2'}, 200, 300]
      def column_subtotal_with_colspan( value )

        column_rowspan = nil
        subtotal_with_colspan = []
        colspan = 0
        total_text_printed = false
        columns.each do |column|           
            if !column.rowspan?
              if colspan > 0
                title = total_text_printed ? '' : I18n.t('query_report.sub_total')
                subtotal_with_colspan << (colspan == 1 ? {content: title.to_s} : {content: title.to_s, colspan: colspan})
              end
              subtotal_with_colspan << {content: column.sub_total(column_rowspan,value,column).to_s, align: column.align}
              total_text_printed = true
              colspan = 0
            else
              column_rowspan = column
              colspan += 1
            end
        end

        if colspan > 0
          subtotal_with_colspan << {content: '', colspan: colspan}
        end
       
        subtotal_with_colspan
      end

      def column_subtotal_with_colspan2( value )
       # p value
        #p 'column_subtotal_with_colspan in dsl'
        subtotal_with_colspan = []
        colspan = 0
        total_text_printed = false
        columns.each do |column|
           
            if !column.rowspan?
              # p 'has_subtotal ' + column.has_subtotal?.to_s
              if colspan > 0
                title = total_text_printed ? '' : I18n.t('query_report.sub_total')
                subtotal_with_colspan << (colspan == 1 ? {content: title.to_s} : {content: title.to_s, colspan: colspan})
              end
              #p value[:index_f].to_s + ' - ' + value[:index_t].to_s
              subtotal_with_colspan << {content: column.sub_total2(value[:index_f], value[:index_t]).to_s, align: column.align}
              #p ' entro aca '
               #p '1 ' + subtotal_with_colspan.to_s
              total_text_printed = true
              colspan = 0
            else
             # if column.visible?
                colspan += 1
              #end
            end
        end
        if colspan > 0
          subtotal_with_colspan << {content: '', colspan: colspan}
        end       
        subtotal_with_colspan
      end
    end
  end
end