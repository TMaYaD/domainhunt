class DomainsController < InheritedResources::Base
  actions :index

  def data_table
    render json: DomainsDatatable.new(view_context), content_type: Mime::JSON.to_s
  end

  def hide
    success = Domain.find(params[:name]).hide
    render json: { status: status }
  end

  def like
    success = Domain.find(params[:name]).toggle_like
    render json: { status: status }
  end

end
