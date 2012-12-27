class DomainsDatatable
  delegate :params, :content_tag, :link_to, :hide_domains_path, :like_domains_path, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho:                  params[:sEcho].to_i,
      iTotalDisplayRecords:   scope.count,
      iTotalRecords:          Domain.count,
      aaData:                 data
    }
  end

private

  def data
    domains.map do |domain|
      [
        like_link(domain),
        domain.id,
        "$#{domain.min_bid}",
        domain.status,
        domain.release_date,
        domain.end_date,
        hide_link(domain)
      ]
    end
  end

  def domains
    @domains ||= scope.offset(offset).limit(length)
  end

  def scope
    @scope ||= begin
      scope = Domain.filter(:hidden, false)
      scope = scope.filter(:numbers, false)         unless params[:numbers]
      scope = scope.filter(:hyphenated, false)      unless params[:hyphenated]
      scope = scope.filter(:tld, params[:tld])      if params[:tld].present?
      scope = scope.sort(:length).min(params[:min]) if params[:min].present?
      scope = scope.sort(:length).max(params[:max]) if params[:max].present?
      scope
    end
  end

  def offset
    params[:iDisplayStart].try(:to_i) || 0
  end

  def length
    params[:iDisplayLength].try(:to_i) || 20
  end

  def hide_link(domain)
    link_to hide_domains_path(name: domain.id), method: :post, remote: true do
      content_tag :i, nil, class: %w(icon-eye-close)
    end
  end

  def like_link(domain)
    link_to like_domains_path(name: domain.id), method: :post, remote: true do
      content_tag :i, nil, class: "icon-star#{domain.liked ? '' : '-empty'}"
    end
  end
end
