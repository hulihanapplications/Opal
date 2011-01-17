class SimpleCaptchaController < ActionController::Metal
  include ActionController::Streaming
  include SimpleCaptcha::ImageHelpers

  # GET /simple_captcha
  def show
    unless params[:id].blank?
      send_file(
        generate_simple_captcha_image(params[:id]),
        :type => 'image/jpeg',
        :disposition => 'inline',
        :filename => 'simple_captcha.jpg')
    else
      self.response_body = [404, {"Content-Type" => "text/html"}, ["Not Found"]]
    end
  end
end
