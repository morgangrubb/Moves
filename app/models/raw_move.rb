require 'iconv'

class RawMove < ActiveRecord::Base
  validates_presence_of :url

  def self.find_or_create_by_url(url)
    where(:url => url).first || create(:url => url)
  end
  
  def promote
    puts "Promoting RawMove##{id}"
    
    begin
      move = to_move
      move.update_attributes parse
      move.save
    # rescue Exception => e
    #   puts e.message
    end
  end
  
  def to_move
    Move.find_or_new_by_url url
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
      :move_beats         => get_move_beats
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
  
  def get_move_beats
    move_beats = []
    body_node.css('ul li').each do |node|
      text = node.text
      
      # Break it down
      text =~ /^([^ ]+) (.*)$/
      
      # And make a beat out of it.
      move_beats << MoveBeat.new(:beat => $1, :description => $2) if $2.present?
    end
    move_beats
  end
  
  def valid_utf8?
    (title || '').force_encoding('UTF-8').valid_encoding? && (body || '').force_encoding('UTF-8').valid_encoding?
  end
  
  def fix_utf8!
    if !valid_utf8?
      self.title = fix_utf8 title
      self.body = fix_utf8 body
      save
    end
  end
  
  private

    def fix_utf8(new_value)
      if new_value.is_a? String
        begin
          # Try it as UTF-8 directly
          cleaned = new_value.dup.force_encoding('UTF-8')
          unless cleaned.valid_encoding?
            # Some of it might be old Windows code page
            cleaned = new_value.encode( 'UTF-8', 'Windows-1252' )
          end
          new_value = cleaned
        rescue EncodingError
          # Force it to UTF-8, throwing out invalid bits
          new_value.encode!( 'UTF-8', invalid: :replace, undef: :replace )
        end
      end
    end

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
