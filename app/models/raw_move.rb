class RawMove < ActiveRecord::Base
  validates_presence_of :url

  def self.find_or_create_by_url(url)
    where(:url => url).first || create(:url => url)
  end
  
  def promote
    move = Move.find_or_new_by_url url
    move.update_attributes parse
    move.save
  end

  def parse
    {
      :name               => get_name,
      :movie_url          => get_movie,
      # :category           => get_category,
      # :difficulty         => get_difficulty,
      # :lead_start_hand    => get_lead_start_hand,
      # :lead_finish_hand   => get_lead_finish_hand,
      # :follow_start_hand  => get_follow_start_hand,
      # :follow_finish_hand => get_follow_finish_hand,
      # :spins              => get_spins,
      # :beats              => get_beats,
      # :description        => get_description
    }
  end
  
  def get_name
    link_data =~ /Move Name":"([^"]+)"/i
    $1
  end
  
  def get_movie
    embed = body_node.css('embed')
    if embed.length.zero?
      nil
    elsif embed.length == 1
      embed.first.attributes['src'].text
    else
      raise "Excess embedded objects in RawMove##{id}"
    end
  end
  
  def body_node
    @doc ||= Nokogiri::HTML body
  end
end
