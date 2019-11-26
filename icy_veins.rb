require 'nokogiri'
require 'open-uri'
require 'csv'
require 'optparse'

@options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [OPTION] .. [LINK]"
  opts.on("-l", "--link LINK", "Link (URL) of the Icy Veins build") do |link|
    @options[:link] = link
  end
  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    @options[:verbose] = v
  end

  opts.on("-h", "--help", "Display this message") do
    puts opts
    exit
  end
end

begin
    optparse.parse!
    mandatory = [:link]
    missing = mandatory.select{ |param| @options[param].nil? }
    unless missing.empty?
      raise OptionParser::MissingArgument.new(missing.join(', '))
    end
  rescue OptionParser::InvalidOption, OptionParser::MissingArgument
    puts $!.to_s
    puts optparse
    exit
end

def verbose string
    puts string if @options[:verbose]
end

def list_item_split item
    slot, item_name = item.text.split(?:).map(&:strip)
    img = item.xpath(".//img/@src")
    bnet_url = item.xpath(".//a/@href")
    verbose "\t#{slot} : #{item_name}"
    @items_list << [slot, "=IMAGE(\"#{img}\"; 3)", "=HYPERLINK(\"#{bnet_url}\";\"#{item_name}\")"]
end


## SLOT ;    IMG    ;   ITEM
## HELM ; URL_IMG   ;   url("Helm of ...")

verbose "\n"
PAGE_URL = @options[:link]
verbose "Parsing '#{PAGE_URL}' ..."
FILE_OUTPUT = PAGE_URL.split(?/).last + ".csv"
@items_list = []
page = Nokogiri::HTML(open(PAGE_URL))

# Build name, top of page
build_name = page.xpath("//div[@class='page_title']/h1/text()")
verbose "Build name : #{build_name}"


# 1. Items, images and links to Bnet ref
# 2. Legendary gems
# 3. Kanai's cube
ids = %w[gear-setup legendary-gems kanais-cube]
ids.each do |id, index|
    verbose "Parsing #{id} ..."
    @items_list << [id, nil, nil]
    list = page.xpath("//div[.//h3[@id='#{id}']]/following-sibling::ul[1]/li" )
    list.each do |item|
        list_item_split item
    end
end
verbose "\n"
CSV.open(FILE_OUTPUT, 'w+') do |csv|
    csv << [build_name, nil, nil]
    csv << [PAGE_URL, nil, nil]
    csv << ["to_import", nil, nil]
    @items_list.each do |item|
        csv << item
    end
end
verbose "Output written in file '#{FILE_OUTPUT}'"
