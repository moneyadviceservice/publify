xm.url do
  xm.loc item.permalink_url
  xm.tag!('news:news') do
    xm.tag!('news:publication') do
      xm.tag!('news:name') do
        xm.text! 'The Money Advice Service'
      end
      xm.tag!('news:language') do |t|
        xm.text! 'en'
      end
    end

    xm.tag!('news:genres') do |t|
      xm.text! item.tags.map(&:display_name).join(', ')
    end
    xm.tag!('news:publication_date') do |t|
      xm.text! item.published_at.strftime('%Y-%m-%d')
    end
    xm.tag!('news:title') do |t|
      xm.text! item.title
    end
  end
end
