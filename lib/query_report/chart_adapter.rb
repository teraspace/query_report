# Author::    A.K.M. Ashrafuzzaman  (mailto:ashrafuzzaman.g2@gmail.com)
# License::   MIT-LICENSE

# The purpose of the filter module is adapt the chart features form chartify
require 'chartify/factory'

module QueryReport
  module ChartAdapterModule
    attr_reader :charts

    def initialize_charts
      @charts = []
    end

    def chart(chart_type, chart_title, &block)
      apply.clone
      chart_adapter = ChartAdapter.new(query, records_without_pagination, chart_type, chart_title)
      block.call(chart_adapter)
      return if chart_type == nil || chart_title == nil
      @charts << chart_adapter.chart
    end

    class ChartAdapter
      attr_reader :query, :records
      attr_accessor :chart_type, :chart
      delegate :data, :data=, :columns, :columns=, :label_column, :label_column=, to: :chart

      def initialize(query, records, chart_type, chart_title)
        @query = query
        @records = records
        @chart_type = chart_type
        @chart = "Chartify::#{chart_type.to_s.camelize}Chart".constantize.new
        @chart.title = chart_title
      end

      def sum_with(options)
        @chart.data = []

        if query.class==NilClass
          return
        end
        options.each do |column_title, column|
          @chart.data << [column_title, query.sum(column)]
        end
      end
    end
  end
end