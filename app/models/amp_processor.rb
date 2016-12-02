require 'nokogiri'

class AMPProcessor
  attr_reader :article

  TAGS = ['img', 'iframe']

  def initialize(article)
    @article = article
  end

  def call
    process!
    doc.to_s
  end

  private

  def process!
    TAGS.each do |tag|
      self.send("process_#{tag}_tag")
    end
  end

  def doc
    @doc ||= Nokogiri::HTML.fragment(article.html(:body))
  end

  private

  def process_iframe_tag
    doc.search('iframe').each do |iframe|
      iframe.replace "<amp-iframe width='#{iframe['width']}' height='#{iframe['height']}' layout='responsive' sandbox='allow-scripts allow-same-origin' allowfullscreen frameborder='0' src='https:#{iframe['src']}'></amp-iframe>"
    end
  end

  def process_img_tag
    doc.search('img').each do |image|
      sizes = FastImage.size(image['src'])
      if sizes.nil?
        image.remove
      else
        image.replace "<amp-img alt='#{image['alt']}' src='#{image['src']}' layout='responsive' width='#{sizes[0]}' height='#{sizes[1]}'></amp-img>"
      end
    end
  end
end
