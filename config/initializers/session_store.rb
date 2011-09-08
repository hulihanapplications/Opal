Rails.application.class.configure do 
  config.session_store  :active_record_store , :key => "_opal_session"# alternative: :mem_cache_store 
  #config.secret_token  = "MeFa2RudracRED8trEbuswuZApR7xudAthabeSwAste9Ebremac8EdE5ebaBa7"
end

