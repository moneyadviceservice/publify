class Page < Content
  validates_presence_of :title, :body
  validates_uniqueness_of :name

  include ConfigManager

  serialize :settings, Hash

  before_save :set_permalink
  after_save :shorten_url

  def set_permalink
    self.name = title.to_permalink if name.blank?
  end

  content_fields :body

  def self.default_order
    'name ASC'
  end

  def self.search_with(search_hash)
    super(search_hash).order('title ASC')
  end

end
