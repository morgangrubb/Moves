require 'crawl'

class Move < ActiveRecord::Base
  belongs_to :category
  belongs_to :difficulty
  belongs_to :lead_start_hand, :class_name => 'Hand'
  belongs_to :lead_finish_hand, :class_name => 'Hand'
  belongs_to :follow_start_hand, :class_name => 'Hand'
  belongs_to :follow_finish_hand, :class_name => 'Hand'
  
  has_many :move_beats, :dependent => :destroy
  
  # accepts_nested_attributes_for :move_beats

  validates_presence_of :name
  validates_presence_of :url

  LOCAL_MOVIE_PATH = Rails.root.join('public', 'movies')

  before_save :fetch_movie

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
end
