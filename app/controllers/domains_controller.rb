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
      scope = Domain.offset(offset).limit(length)
      scope = scope.filter(:numbers, false)         unless params[:numbers]
      scope = scope.filter(:hyphenated, false)      unless params[:hyphenated]
      scope = scope.filter(:tld, params[:tld])      if params[:tld].present?
      scope = scope.sort(:length).min(params[:min]) if params[:min].present?
      scope = scope.sort(:length).max(params[:max]) if params[:max].present?
      scope
    end
  end

end
