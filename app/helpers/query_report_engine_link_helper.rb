module QueryReportEngineLinkHelper
  def link_to_default_download_report_pdf
    if respond_to? :link_to_download_report_pdf
      link_to_download_report_pdf
    else
      link_to  export_report_url_with_format('pdf'), :target => "_blank" do
        '<i class="material-icons" style="color: rgba(0, 0, 0, 0.54);">picture_as_pdf</i>'.html_safe
      end
    end
  end

  def link_to_default_download_report_csv
    if respond_to? :link_to_download_report_csv
      link_to_download_report_csv
    else
      link_to  export_report_url_with_format('csv'), :target => "_blank" do
        '<i class="material-icons" style="color: rgba(0, 0, 0, 0.54);">file_download</i>'.html_safe
      end
    end
  end

  def link_to_default_download_report_xls
    if respond_to? :link_to_download_report_xls
      link_to_download_report_xls
    else
      link_to  export_report_url_with_format('xlsx'), :target => "_blank" do
        '<i class="material-icons" style="color: rgba(0, 0, 0, 0.54);">view_module</i>'.html_safe
      end
    end
  end


  def link_to_default_email_query_report(target_dom_id)
    if respond_to? :link_to_email_query_report
      respond_to = nil
      link_to_email_query_report(target_dom_id)
    else
      if QueryReport.config.allow_email_report
        link_to  'javascript:void(0)', :onclick => "ReportEmailPopup.openEmailModal('#{target_dom_id}');" do
        '<i class="material-icons" style="color: rgba(0, 0, 0, 0.54);">email</i>'.html_safe
      end
      end
    end
  end
end