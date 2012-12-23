class DomainsController < InheritedResources::Base
  def import
    redirect_to(domains_path, flash: {error: 'Select a file to import'}) and return unless params[:file]

    Domain.import params[:status], params[:file].path
    redirect_to domains_path, notice: 'Domains imported successfully'
  end
end
