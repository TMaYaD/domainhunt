class DomainsDatatable
  delegate :params, :distance_of_time_in_words_to_now, :content_tag, :link_to, :hide_domains_path, :like_domains_path, :best_in_place, :comments_path, to: :@view

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
        release_date(domain),
        end_date(domain),
        hide_link(domain),
        comment_form(domain)
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

  def release_date(domain)
    domain.release_date ? distance_of_time_in_words_to_now(domain.release_date) : 'n/a'
  end

  def end_date(domain)
    domain.end_date ? distance_of_time_in_words_to_now(domain.end_date) : 'n/a'
  end

  def comment_form(domain)
    best_in_place domain.comment, :body, path: comments_path(id: domain.id), nil: 'Comment'
  end
end
