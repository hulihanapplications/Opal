module PaginationHelper
  def paginate(collection)
    content_tag(:div, :class => "pagination") do
      content_tag(:div, page_entries_info(collection))
      will_paginate(collection) 
    end 
  end
end