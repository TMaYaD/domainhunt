class DomainsController < InheritedResources::Base
  def import
    Domain.import(params[:status], params[:file])
    redirect_to domains_path, notice: 'Domains imported successfully'
  end
end
