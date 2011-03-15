require 'mechanize'

class Crawl
  AUTH_URL  = 'http://network.ceroc.com/login/'
  BASE_PATH = 'http://www.network.ceroc.com/Applications/OrganisationManager/admin/moves/'
  ITEM_LIST = {
    :url => BASE_PATH + 'index.php?action=getTableData&class=MyMoveLister&index=&json=1&prevMove=',
    :request => {
      :limit => 25,
      :start => 0
    }
  }
  
  attr_accessor :agent
  
  def initialize
    self.agent = Mechanize.new
    login
  end
  
  def login
    auth =
      if const_defined? AUTH
        AUTH
      else
        YAML.load_file 'config/auth.yml'
      end
    
    page = agent.get AUTH_URL
    
    form          = page.form_with :name => 'loginForm'
    form.username = auth[:username]
    form.passwd   = auth[:password]
    
    page = agent.submit form
  end

  def get_all_items
    start = 0
    list = []
    
    while (list = get_item_list(start)).length > 0 do
      list.each do |link|
        url = BASE_PATH + link.href
        m = RawMove.find_or_create_by_url url
        m.link_data = link.node.to_html
        m.title = get_move_title link
        m.body = agent.get(url).body
        m.save
      end
      
      start += list.length
    end
  end
  
  def get_move_title(link)
    link.text =~ /Move Name\\":\\"([^"])\\""/i
    $1
  end

  def get_item_list(start = 0)
    agent.post(ITEM_LIST[:url], ITEM_LIST[:request].merge(:start => start)).links
  end
  
end
