class DomainsController < InheritedResources::Base
  def import
    redirect_to(domains_path, flash: {error: 'Select a file to import'}) and return unless params[:file]

    Domain.import params[:status], params[:file].path
    redirect_to domains_path, notice: 'Domains imported successfully'
  end

  def data_table
    total_records = Domain.count
    total_display_records = Domain.count

    render :json => {
      :aaData               => collection,
      :iTotalDisplayRecords => total_display_records,
      :iTotalRecords        => total_records
    }, :content_type => Mime::JSON.to_s
  end

protected
  def collection
    @domains ||= begin
      offset = params[:iDisplayStart].try(:to_i) || 0
      length = params[:iDisplayLength].try(:to_i) || 20
      Domain.filter offset, length
    end
  end

end
