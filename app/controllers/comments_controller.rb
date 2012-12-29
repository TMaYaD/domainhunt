class CommentsController < InheritedResources::Base
  before_filter :set_id
  actions :create

private
  def set_id
    params[:comment][:id] = params[:id]
  end
end
