Rails.application.class.configure do 
    # Customize Sanitation
    config.action_view.sanitized_allowed_tags = %w{img a table tr td th br b u i strong p span embed object param ul ol li blockquote pre div sub sup h1 h2 h3 h4 h5 h6 iframe}           
    config.action_view.sanitized_allowed_attributes = %w{href title style width height allowfullscreen frameborder allowscriptaccess src type data name value align}
end