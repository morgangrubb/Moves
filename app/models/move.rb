class Move < ActiveRecord::Base
  belongs_to :category
  belongs_to :difficulty
  belongs_to :lead_start_hand, :class_name => 'Hand'
  belongs_to :lead_finish_hand, :class_name => 'Hand'
  belongs_to :follow_start_hand, :class_name => 'Hand'
  belongs_to :follow_finish_hand, :class_name => 'Hand'
  
  has_many :move_beats, :dependent => :destroy

  has_many :move_variants, :class_name => "MoveVariant", :foreign_key => :base_id, :dependent => :destroy
  has_many :variants, :through => :move_variants, :source => :variant

  has_many :move_bases, :class_name => "MoveVariant", :foreign_key => :variant_id, :dependent => :destroy
  has_many :bases, :through => :move_bases, :source => :base
  
  serialize :variant_keys

  validates_presence_of :name
  validates_presence_of :url

  LOCAL_MOVIE_PATH = Rails.root.join('public', 'movies')

  before_save :fetch_movie, :if => :fetch_movie?
  
  after_save :update_variants, :if => :update_variants?

  named_scope :ordered, :order => "name ASC"

  def self.find_or_new_by_url(url)
    where(:url => url).first || new(:url => url)
  end
  
  def to_param
    "#{id}-#{name.gsub(/[^a-z0-9]+/i, '-')}"
  end
  
  def get_movie
    if fetch_movie
      save
    end
  end
  
  def fetch_movie
    return nil if new_record? || local_movie? || movie_url.blank?

    %x(wget #{movie_url} -O #{local_file})
    begin
      if local_file.size > 0
        self.local_movie = true
      end
    rescue Errno::ENOENT => e
      nil
    end
  end
  
  # TODO: Some logic here on when we should be fetching movies.
  def fetch_movie?
    false
  end
  
  def movie_url
    value = super
    if value[0] == '/'
      'http://network.ceroc.com' + value
    else
      value
    end
  end
  
  def local_file
    LOCAL_MOVIE_PATH.join(local_file_name)
  end
  
  def local_file_name
    movie_url =~ /\.([a-z0-9_-]+)$/i
    "#{id}.#{$1.downcase}"
  end
  
  def raw_move
    RawMove.where(:url => url).first
  end
  
  def valid_utf8?
    name.force_encoding('UTF-8').valid_encoding?
  end
  


  # ===============================================
  # = Find variants based in simple text matching =
  # ===============================================

    def update_variants?
      variant_keys.present?
    end

    # sqlite is case sensitive in UNICODE so do this the long way for now.
    def update_variants
      # new_variants = []
      # variant_keys.each do |key|
      #   new_variants += Move.where(["name LIKE ?", "%#{key}%"]).all
      # end

      # Yeah, this is not so pretty.
      regex = /#{variant_keys.join('|')}/i
      puts regex.inspect
      new_variants = Move.all.to_a.find_all { |m| m.name =~ regex }

      # This stuff doesn't change though
      new_variants.uniq!
      new_variants -= [self]
      self.variants.replace new_variants
    end

end
