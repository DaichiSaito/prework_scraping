# 条件に合致するホテル一覧
require 'nokogiri'
# require 'kconv'
require 'csv'
require 'open-uri'

class HotelIndex

  # 以下を取得するクローラー
  # ホテルID
  # ホテル名
  # キャプション
  # 画像URI
  
  HEADER = ['hotel_id', 'hotel_name', 'hotel_caption', 'image_uri']
  URL = 'https://www.jalan.net/130000/LRG_136200/SML_136205/?stayYear=&stayMonth=&stayDay=&dateUndecided=1&stayCount=1&roomCount=1&adultNum=1&minPrice=0&maxPrice=999999&mealType=0&roomSingle=1&kenCd=130000&lrgCd=136200&smlCd=136205&distCd=01&roomCrack=100000&reShFlg=1&mvTabFlg=0&listId=0&screenId=UWW1402'

  def exec_crawling
    html = open(URL) do |f|
      f.read # htmlを読み込んで変数htmlに渡す
    end
    doc = Nokogiri::HTML.parse(html)

    CSV.open('./hotels.csv', 'w', :headers => HEADER, :write_headers => true) do |csv|
      doc.css('.search-result-cassette').each do |node|
        # yadNo328995 → yad328995 (この後のスクレイピングで必要なのはyadxxxxxxの形だから)
        hotel_id = node.attribute('id').value.gsub('No', '')
        hotel_name = node.css('.hotel-name > h2 > a').text
        hotel_caption = node.css('.s12_33').text
        image_uri = node.css('.hotel-picture > .main > a > img').attribute('src').value
        
        # 画像のダウンロードまでしたい場合はここを走らせる
        # save_image(image_path, id)

        # CSVに書き出し
        csv << [ hotel_id, hotel_name, hotel_caption, image_uri ]
      end
    end
  end

  private

  def save_image(url, yad_id)
    fileName = File.basename(url)
    dirName = './images/'
    filePath = dirName + yad_id + fileName.match(/\.(.*)/)[0]

    # create folder if not exist
    FileUtils.mkdir_p(dirName) unless FileTest.exist?(dirName)

    # write image adata
    open(filePath, 'wb') do |output|
      open(url) do |data|
        output.write(data.read)
      end
    end
  end
end
#クロールの起点となるURLを指定

hotel_index = HotelIndex.new
# crawling.execCrawl
hotel_index.exec_crawling