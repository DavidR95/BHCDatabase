module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = 'Building Healthy Communities'
    page_title.empty? ? base_title : page_title + ' | ' + base_title
  end
end
