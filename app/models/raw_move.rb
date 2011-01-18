require 'iconv'

class RawMove < ActiveRecord::Base
  validates_presence_of :url

  def self.find_or_create_by_url(url)
    where(:url => url).first || create(:url => url)
  end
  
  def promote
    puts "Promoting RawMove##{id}"
    
    begin
      move = Move.find_or_new_by_url url
      move.update_attributes parse
      move.save
    # rescue Exception => e
    #   puts e.message
    end
  end

  def parse
    {
      :name               => get_name,
      :movie_url          => get_movie,
      :category           => get_category,
      :difficulty         => get_difficulty,
      :lead_start_hand    => get_lead_start_hand,
      :lead_finish_hand   => get_lead_finish_hand,
      :follow_start_hand  => get_follow_start_hand,
      :follow_finish_hand => get_follow_finish_hand,
      :spins              => get_spins,
      :beats              => get_beats,
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
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    @doc ||= Nokogiri::HTML ic.iconv(body + ' ')[0..-2]
  end
  
  def get_category
    begin
      cat = get_piece('category')
      Category.find_or_create_by_name cat if cat.present?
    rescue Exception => e
      link_data =~ %r("Category":"([A-Za-z]+)")
      Category.where(["name LIKE ?", "#{$1}%"]).first if $1.present?
    end
  end
  
  def get_difficulty
    begin
      d = get_piece('difficulty')
      Difficulty.find_or_create_by_name d if d.present?
    rescue Exception => e
      link_data =~ %r("Difficulty":"([A-Za-z]+)")
      Difficulty.where(["name LIKE ?", "#{$1}%"]).first if $1.present?
    end
  end
  
  def get_lead_start_hand
    Hand.find_or_create_by_name hands[:lead_start] if hands[:lead_start].present?
  end
  
  def get_lead_finish_hand
    Hand.find_or_create_by_name hands[:lead_finish] if hands[:lead_finish].present?
  end
  
  def get_follow_start_hand
    Hand.find_or_create_by_name hands[:follow_start] if hands[:follow_start].present?
  end

  def get_follow_finish_hand
    Hand.find_or_create_by_name hands[:follow_finish] if hands[:follow_finish].present?
  end
  
  def get_spins
    spins = get_piece('spins')
    if spins
      if spins.split(/\s+/).first =~ /yes/i
        true
      else
        false
      end
    end
  end
  
  def get_beats
    beats = get_piece('beats').to_i
    if beats > 0
      beats
    else
      nil
    end
  end
  
  private
    
    def hands
      return @hands if @hands.present?
      
      res = {}
      
      fragment = body_node.css('p').find { |f| f.to_html =~ /Hands:/ }

      if fragment
        fragment = fragment.to_html

        fragment =~ %r(Starting[ -]*Man\s*:\s*</b>([^<]+)<b>\s*Lady\s*:\s*</b>([^<]+)<)
        res[:lead_start]   = $1.strip
        res[:follow_start] = $2.strip

        fragment =~ %r(Finish[ -]*Man\s*:\s*</b>([^<]+)<b>\s*Lady\s*:\s*</b>([^<]+)<)
        res[:lead_finish]   = $1.strip
        res[:follow_finish] = $2.strip
      end

      @hands = res
    end
  
    def get_piece(piece)
      fragment = body_node.to_html.split('<b>').find { |s| s =~ /#{piece}:/i }
      fragment.split('</b>').last.strip if fragment
    end

end
