# Author::    A.K.M. Ashrafuzzaman  (mailto:ashrafuzzaman.g2@gmail.com)
# License::   MIT-LICENSE

# The purpose of the helper module is to help controllers with the responders

require 'csv'
require 'query_report/report'
require 'query_report/report_pdf'
require 'query_report/report_xlsx'

module QueryReport
  module Helper
    @csv = nil
    # Generates the reports
    # @param query The base query that the reporter with start with [filters will be applied on it]
    # @option options [Integer] :per_page If given then overrides the default kaminari per page option
    # @option options [Boolean] :custom_view by default false, if set to true then the reporter will look for the file to render
    # @option options [Boolean] :skip_rendering by default false, if set to true then the reporter will not render any thing, you will have to implement the rendering
    def reporter(query, options={}, &block)
      @report ||= QueryReport::Report.new(params, view_context, options)
      @report.query = query
      @report.instance_eval &block
      render_report(options) unless options[:skip_rendering]
      @report
    end

    def render_report(options)
      if (params[:send_as_email].to_i > 0)
        send_pdf_email(params[:email_to], params[:subject], params[:message], action_name, pdf_for_report(options))
      end

      @remote = false
      respond_to do |format|

        if !options[:custom_view]

          format.html { render('query_report/list') }
         
        end

        format.json { 
          render('query_report/report')
         }
        format.csv { send_data generate_csv_for_report(@report.records_without_pagination), :disposition => "attachment;" }
        format.xls { 
          send_data xlsx_for_report(options).string.bytes.to_a.pack("C*"), :type => 'application/excel', :disposition => "attachment;", :filename => @outfile
        }
        format.pdf { send_data pdf_for_report(options), :type => 'application/pdf', :disposition => 'inline' }
      end

    end

    def pdf_for_report(options)
      query_report_pdf_template_class(options).new(@report).to_pdf.render
    end

    def xlsx_for_report(options)
      query_report_xlsx_template_class(options).new(@report).to_xlsx
    end


    def query_report_pdf_template_class(options)
      options = QueryReport.config.pdf_options.merge(options)
      if options[:template_class]
        @template_class ||= options[:template_class].to_s.constantize
        return @template_class
      end
      QueryReport::ReportPdf
    end

    def query_report_xlsx_template_class(options)
      options = QueryReport.config.pdf_options.merge(options)
      if options[:template_class]
        @template_class ||= options[:xlsx_template_class].to_s.constantize
        return @template_class
      end
      QueryReport::ReportXlsx
    end


    def generate_csv_for_report(records)
      if records.size > 0
        columns = records.first.keys
        CSV.generate do |csv|
          csv << columns
          records.each do |record|
            csv << record.values.collect { |val| val.kind_of?(String) ? view_context.strip_links(val) : val }
          end
        end
      else
        nil
      end
    end

    def generate_xls_for_report(records)
      p 'generate_xls_for_report'
      if records.size > 0
        p 'record_size'
        columns = records.first.keys
        @@columns = columns
        CSV.generate do |csv|
          csv << columns
          records.each do |record|
            csv << record.values.collect { |val| val.kind_of?(String) ? view_context.strip_links(val) : val }          
          end

        end



      else
        nil
      end
    end


    def send_pdf_email(email, subject, message, file_name, attachment)
      @user = current_user if defined? current_user
      to = email.split(',')
      ReportMailer.send_report(@user, to, subject, message, file_name, attachment).deliver
    end
  end
end