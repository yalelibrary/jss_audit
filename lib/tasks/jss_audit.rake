#Here are the commands for running the rake task in each environment
#Development:   rake fedora:audit
#Test:          RAILS_ENV=test bundle exec rake fedora:audit
#Prodcution:    RAILS_ENV=production rake fedora:audit
require 'net/http'
#require 'rsolr'
require 'json'
require 'open3'
require 'fileutils'
require 'open-uri'
require 'csv'
require 'pathname'
require 'net/ssh'
#require 'rake/remote_task'


#base url of solr path
BASE_SOLR_URL = "http://127.0.0.1:8035/apache-solr-3.3.0/"
BASE_IMAGE_URL = "http://dcoll.library.yale.edu/fedora/objects/"
IMAGE_POST_URL = "/datastreams/JPG/content"
HOST = "172.18.56.56"
USER = "llz6"
PASS = "xxxxx"


#Email to send report to
EMAIL_RECIPIENT = 'maggie.zhao@yale.edu'


#LOG_FILE = "#{log_path}/purge_fedora_solr.log"

def get_title_level_bibs
  result = ""
  solr_query = "#{BASE_SOLR_URL}/select"
  solr_query = solr_query + '?indent=on&fq=LEVEL:title&fl=BIBID,PID,TITLE,numFound&wt=json&start=0&rows=600'
  solr_uri = URI(solr_query)

  solr_response = Net::HTTP.get(solr_uri)
  solr_json = JSON.parse("#{solr_response}")
  result_num = solr_json['response']['numFound'].to_i
  solr_docs =solr_json['response']['docs']
  #puts "-----------Found title level object #{result_num}------------------"
  #puts "BIBID, Fedora PID, Title"
  results = []

    solr_docs.each do |p|
   #  puts "#{p['BIBID']}, #{p['PID']}, #{p['TITLE']}"
     results.push  p['BIBID']
      result << p['BIBID'] + ","
    end
    puts "#{result}"
    results
  end

#puts "BIBID        Number of Volumes:              Barcode: "

def get_volume_level(bibs)
  results =[]
  count = 0;

  bibs.each do |b|
    solr_query = "#{BASE_SOLR_URL}select"
    solr_query = solr_query + "?indent=on&fq=LEVEL:volume AND BIBID:" + b + "&fl=BIBID,PID, VOLUME, SIP,numFound&wt=json&start=0&rows=600"
    #http://127.0.0.1:8035/apache-solr-3.3.0/select/?indent=on&fq=LEVEL:volume%20AND%20BIBID:911609&fl=numFound&wt=xml&start=0&rows=600

    solr_uri = URI(solr_query)
    #puts ("solr_query for getting volume levels : #{solr_query} for bibid: #{b}\n")

    solr_response = Net::HTTP.get(solr_uri)
    solr_json = JSON.parse("#{solr_response}")
    result_num = solr_json['response']['numFound'].to_i
    solr_docs =solr_json['response']['docs']
    count = count + result_num;
   ##puts "---BIBID: #{b}, Volume: #{result_num}"

   ##puts "BIBID, PID, VOLUME, SIP"
    solr_docs.each do |p|
      #results.push p['BIBID']
    ## puts "#{b}, #{p['PID']}, #{p['VOLUME']}, #{p['SIP']}"
      puts "#{p['SIP']}"
    end
  end
  puts "total volume level: #{count}"
  results
end

def get_volume_level_pids
  results =[]
  count = 0;
  result = "";
  solr_query = "#{BASE_SOLR_URL}select"
  solr_query = solr_query + "?indent=on&fq=LEVEL:volume &fl=BIBID,PID, VOLUME, SIP,numFound&wt=json&start=0&rows=600"
    #http://127.0.0.1:8035/apache-solr-3.3.0/select/?indent=on&fq=LEVEL:volume%20AND%20BIBID:911609&fl=numFound&wt=xml&start=0&rows=600

  solr_uri = URI(solr_query)

  solr_response = Net::HTTP.get(solr_uri)
  solr_json = JSON.parse("#{solr_response}")
  result_num = solr_json['response']['numFound'].to_i
  solr_docs =solr_json['response']['docs']
  count = count + result_num;
  solr_docs.each do |p|
    count +=1
      #results.push p['BIBID']
      ## puts "#{b}, #{p['PID']}, #{p['VOLUME']}, #{p['SIP']}"
    #puts "#{p['PID']}"
    results.push(p['PID'])
    result << p['PID'] + ","
  end
  #puts "total volume level: #{count}"
  #results
  puts "#{result}"
end

def get_page_level
  results =[]
  count = 0
  bibCount = 0

  bibs.each do |b|
    solr_query = "#{BASE_SOLR_URL}select"
    solr_query = solr_query + "?indent=on&fq=LEVEL:page AND BIBID:" + b + "&fl=BIBID,PID, PARENTPID, VOLUME, PAGE,SIP,numFound&wt=json&start=0&rows=5000"
    #http://127.0.0.1:8035/apache-solr-3.3.0/select/?indent=on&fq=LEVEL:page%20AND%20BIBID:911609&fl=numFound&wt=xml&start=0&rows=6000
    bibCount = bibCount +1
    solr_uri = URI(solr_query)
    # puts ("solr_query for getting volume levels : #{solr_query} for bibid: #{b}\n")

    solr_response = Net::HTTP.get(solr_uri)
    solr_json = JSON.parse("#{solr_response}")
    result_num = solr_json['response']['numFound'].to_i
    solr_docs =solr_json['response']['docs']
    count= count + result_num
    puts "BIBID: #{b}, pages: #{result_num} "
    #puts "-----------solr doc #{solr_docs}"
    puts "BIBID, PID, PARENTPID, PAGE, VOLUME, IMAGE_URL"
    solr_docs.each do |p|
      results.push p['BIBID']
      puts "#{b}, #{p['PID']}, #{p['PARENTPID']},#{p['PAGE']},#{p['VOLUME']},#{BASE_IMAGE_URL}#{p['PID']}#{IMAGE_POST_URL}"
    end
  end
  puts "total page level number #{count} total bib number #{bibCount}"
  results
end


def get_page_level_pid(bibs)
  result = ""
  results =[]
  count = 0
  bibCount = 0

  bibs.each do |b|
    solr_query = "#{BASE_SOLR_URL}select"
    solr_query = solr_query + "?indent=on&fq=LEVEL:page AND BIBID:" + b + "&fl=BIBID,PID, PARENTPID, VOLUME, PAGE,SIP,numFound&wt=json&start=0&rows=3000000"
    #http://127.0.0.1:8035/apache-solr-3.3.0/select/?indent=on&fq=LEVEL:page%20AND%20BIBID:911609&fl=numFound&wt=xml&start=0&rows=6000
    bibCount = bibCount +1
    solr_uri = URI(solr_query)
    # puts ("solr_query for getting volume levels : #{solr_query} for bibid: #{b}\n")

    solr_response = Net::HTTP.get(solr_uri)
    solr_json = JSON.parse("#{solr_response}")
    result_num = solr_json['response']['numFound'].to_i
    solr_docs =solr_json['response']['docs']
    count= count + result_num
    #puts "BIBID: #{b}, pages: #{result_num} "
    #puts "-----------solr doc #{solr_docs}"
    #puts "BIBID, PID, PARENTPID, PAGE, VOLUME, IMAGE_URL"
    solr_docs.each do |p|
      #results.push p['pidid']
      puts "#{p['PID']}"
      result = result + p['PID'] + ","
    end
  end
  #puts "total page level number #{count} total bib number #{bibCount}"
  #put "#{result}"
end

def get_page_level_pid_2
  result = ""
  solr_query = "#{BASE_SOLR_URL}select"
  solr_query = solr_query + "?indent=on&fq=LEVEL:page &fl=BIBID,PID,numFound&wt=json&start=0&rows=3000000"
  #http://127.0.0.1:8035/apache-solr-3.3.0/select/?indent=on&fq=LEVEL:page%20AND%20BIBID:911609&fl=numFound&wt=xml&start=0&rows=6000
  solr_uri = URI(solr_query)

  solr_response = Net::HTTP.get(solr_uri)
  solr_json = JSON.parse("#{solr_response}")
  solr_docs =solr_json['response']['docs']
  solr_docs.each do |p|
    result <<  p['PID'] + ","
  end
  puts "#{result}"
end

def get_page_level_pid_3
  results =[]
  count = 0
  bibCount = 0

  solr_query = "#{BASE_SOLR_URL}select"
  solr_query = solr_query + "?indent=on&fq=LEVEL:page &fl=PARENT_PID,BIBID,PID,numFound&wt=json&start=0&rows=3000000"
  solr_uri = URI(solr_query)
  solr_response = Net::HTTP.get(solr_uri)
  solr_json = JSON.parse("#{solr_response}")
  solr_docs =solr_json['response']['docs']
  solr_docs.each do |p|
    count +=1
    results.push p['PID']
    puts "pid: #{p['PID']}"
  end
  #puts "total #{count}"
end

def compare_csv_imagesAPI

  pid_count = 0;
  not_found_count = 0
  error_pid=""
  puts "check images in fedora"
  #http://dcoll.library.yale.edu/fedora/objects/slavicbooks:141121/datastreams/JPG/content
  File.read('jss_pids_list.csv').split(",").each do |p|
    pid_count += 1
    #datastream="http://dcoll.library.yale.edu/fedora/objects/#{p}/datastreams/JPG/content"
    datastream="http://dcoll.library.yale.edu/fedora/objects/#{p}/datastreams/JPG?format=xml&validateChecksum=true"
    uri = URI.parse(datastream)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = datastream.start_with? "https"
    begin
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth("fedoraAdmin","fed%thrty5")
      imageserver_response = http.request(request).body.upcase
      #imageserver_response = http.get(uri.request_uri).body.upcase
      if imageserver_response.include?("NO PATH IN DB REGISTRY FOR")  #{p['PID']}]")
        not_found_count +=1
        error_pid << p['PID'] + ','
        puts "NO PATH IN DB REGISTRY FOR [#{p}]"
      else
       # puts "find [ #{p}]"#p['PID']}]"
      end
    rescue Timeout::Error
      error_pid.push j
      print " Timeout::Error for #{p}"
    end
  end
  puts "not found # #{not_found_count}"
  #put "This pids are not found #{error_pid}"

end


def download_parent_childrenpids  #example: pid=slavicbooks:116784
  solr_query = "#{BASE_SOLR_URL}select"
  solr_query = solr_query + "?indent=on&fq=PARENTPID:slavicbooks\\:116784 AND LEVEL:page&fl=BIBID,PID,numFound&wt=json&start=0&rows=3000000"
  #puts "#{solr_query}"
  solr_uri = URI(solr_query)
  error_pid=""
  not_found_count = 0;
  found_count = 0;

  solr_response = Net::HTTP.get(solr_uri)
  solr_json = JSON.parse("#{solr_response}")
  solr_docs =solr_json['response']['docs']
  solr_docs.each do |p|
    datastream="http://dcoll.library.yale.edu/fedora/objects/#{p['PID']}/datastreams/JPG/content"
    uri = URI.parse(datastream)
    #http = Net::HTTP.new()
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = datastream.start_with? "https"
    begin
      imageserver_response = http.get(uri.request_uri).body.upcase
      if imageserver_response.include?("NO PATH IN DB REGISTRY FOR")  #{p['PID']}]")
        #not_found_pid.push p['PID']
        not_found_count +=1
        error_pid << p['PID'] + ','
        puts "NO PATH IN DB REGISTRY FOR [#{p['PID']}]"

      else
        puts "find [ #{p['PID']}]"#p['PID']}]"
        found_count +=1
      end
    rescue Timeout::Error
      error_pid.push j
      print " Timeout::Error for #{p['PID']}"
    end
  end
  puts "not found # #{not_found_count}, found # #{found_count}"
end

def check_images_datastream
  solr_query = "#{BASE_SOLR_URL}select"
  solr_query = solr_query + "?indent=on&fq=LEVEL:page &fl=BIBID,PID,numFound&wt=json&start=0&rows=3000000"
  #http://127.0.0.1:8035/apache-solr-3.3.0/select/?indent=on&fq=LEVEL:page%20AND%20BIBID:911609&fl=numFound&wt=xml&start=0&rows=6000
  # puts "#{solr_query}";
  solr_uri = URI(solr_query)

  solr_response = Net::HTTP.get(solr_uri)
  solr_json = JSON.parse("#{solr_response}")
  solr_docs =solr_json['response']['docs']

  pid_count = 0;
  not_found_count = 0
  not_found_pid = []
  error_pid=""
  puts "check images in fedora"
  #http://dcoll.library.yale.edu/fedora/objects/slavicbooks:141121/datastreams/JPG/content
  solr_docs.each do |p|
    pid_count += 1
    #datastream = "https://imageserver.library.yale.edu/" + p + "/500.jpg?q=1"
    datastream="http://dcoll.library.yale.edu/fedora/objects/#{p['PID']}/datastreams/JPG/content"
    #puts "#{datastream}"
    #server /usr/local/fed35/fedora_store_rss/data/datastreams
    #datastream /wcsfs00.its.yale.internal/FC_Ladybird-807001-YUL/fedora_store_dcolltest/data/datastreams
    uri = URI.parse(datastream)
    #http = Net::HTTP.new()
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = datastream.start_with? "https"
    begin
      imageserver_response = http.get(uri.request_uri).body.upcase
      if imageserver_response.include?("NO PATH IN DB REGISTRY FOR")  #{p['PID']}]")
        #not_found_pid.push p['PID']
        not_found_count +=1
        not_found_pid << p['PID'] + ','
        puts "NO PATH IN DB REGISTRY FOR [#{p['PID']}]"

    else
      puts "find [ #{p['PID']}]"#p['PID']}]"
    end
    rescue Timeout::Error
      error_pid.push j
      print " Timeout::Error for #{p['PID']}"
    end
  end
  puts "not found # #{not_found_count}"
  put "This pids are not found #{not_found_pid}"
end

def check_sample_images
  pid_count = 0;
  image_count = 0;
  not_found_count = 0
  not_found_pid = []
  error_pid = []
  puts "check images in fedora"
  #http://dcoll.library.yale.edu/fedora/objects/slavicbooks:141121/datastreams/JPG/content
  pids = ["slavicbooks:141110222","slavicbooks:141117","slavicbooks:141091","slavicbooks:140368","slavicbooks:140364"]
  #http://dcoll.library.yale.edu/fedora/objects/slavicbooks:141117/datastreams/JPG/content
  #http://dcoll.library.yale.edu/fedora/objects/slavicbooks:141096/datastreams/JPG/content
  #http://dcoll.library.yale.edu/fedora/objects/slavicbooks:141091/datastreams/JPG/content
  #http://dcoll.library.yale.edu/fedora/objects/slavicbooks:140369/datastreams/JPG/content
  #http://dcoll.library.yale.edu/fedora/objects/slavicbooks:141122/datastreams/JPG/content
  #http://dcoll.library.yale.edu/fedora/objects/slavicbooks:141090/datastreams/JPG/content
  #http://dcoll.library.yale.edu/fedora/objects/slavicbooks:140368/datastreams/JPG/content
  #http://dcoll.library.yale.edu/fedora/objects/slavicbooks:140364/datastreams/JPG/content

    pids.each do |p|
    pid_count += 1
    #datastream = "https://imageserver.library.yale.edu/" + p + "/500.jpg?q=1"
    #datastream="http://dcoll.library.yale.edu/fedora/objects/#{p}/datastreams/JPG/content"
    datastream="http://dcoll.library.yale.edu/fedora/objects/#{p}/datastreams/JPG?
    puts "#{datastream}"
    #server /usr/local/fed35/fedora_store_rss/data/datastreams
    #datastream /wcsfs00.its.yale.internal/FC_Ladybird-807001-YUL/fedora_store_dcolltest/data/datastreams
    uri = URI.parse(datastream)
    #http = Net::HTTP.new()
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = datastream.start_with? "https"

    begin
      #puts "#{http.get(uri.request_uri)}"
      #request = http.get(uri.request_uri)
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth("fedoraAdmin","fed%thrty5")
      imageserver_response = http.request(request).body.upcase
      #imageserver_response = http.get(uri.request_uri).body.upcase
       puts "#{imageserver_response}"
      if imageserver_response.include?("NO PATH IN DB REGISTRY FOR")  #{p['PID']}]")
        #not_found_pid.push p['PID']
        not_found_count +=1
        puts "NO PATH IN DB REGISTRY FOR [#{p}]"
        error_pid.push(p)
      else
        puts "find [ #{p}]"#p['PID']}]"
      end
    rescue Timeout::Error
      error_pid.push j
      print " Timeout::Error for #{p}"
    end
    end
  puts "#{not_found_count}"
  puts "#{error_pid}"
end

def download_116784_image
  #slavicbooks:4644
  solr_query = "#{BASE_SOLR_URL}select"
  solr_query = solr_query + "?indent=on&fq=PARENTPID:slavicbooks\\:116784 AND LEVEL:page&fl=BIBID,PID,numFound&wt=json&start=0&rows=30000"
  solr_uri = URI(solr_query)


  solr_response = Net::HTTP.get(solr_uri)
  solr_json = JSON.parse("#{solr_response}")
  solr_docs =solr_json['response']['docs']
  solr_docs.each do |p|
    fedora_query = "http://127.0.0.1:8035/fedora/objects/#{p['PID']}/datastreams/JPG/content"
    #http://127.0.0.1:8035/fedora/objects/slavicbooks:116915/datastreams/PDF/content

    fedora_uri = URI(fedora_query)
    fedora_response = Net::HTTP.get(fedora_uri)
    download_image(fedora_query,"/Users/LixiaZhao/good/valkyrie-blacklight-poc/jss_images_116784/#{p['PID'].sub(':','-')}.jpg")
  end
end

def download_image(url, dest)
  open(url) do |u|
    File.open(dest, 'wb') { |f| f.write(u.read) }
  end
end



def ssh_digcoll

  Net::SSH.start( HOST, USER, :password => PASS ) do|ssh|
    #output = ssh.exec!("ls")
    #output = ssh.exec('cd /fedora_store_rss/data/datastreams; grep -r "141096"')
    #output = ssh.exec!('cd /fedora_store_rss/data/datastreams;grep -r "JPG"')
    #output = ssh.exec!('cd /fedora_store_rss/data/datastreams;find . -ipath '*JPG*' -ipath '*slavicbooks_*'
    #output = ssh.exec!('cd /fedora_store_rss/data/datastreams; find . -ipath "*slavicbooks*" -ipath "*JPG*"')
    ##output = ssh.exec!('cd /fedora_store_rss/data/datastreams; find . -ipath "*JPG*"')
    #output = ssh.exec!('cd /fedora_store_rss/data/datastreams; find . -ipath "*slavicbooks*"') > local.csv
    #output = ssh.exec!('cd /fedora_store_rss/data/datastreams; find . -ipath "*153457+JPG*"')
    output = ssh.exec!('cd /fedora_store_rss/data/datastreams; find . -ipath "*PDF*"')
    puts "#{output}"
  end
end

def download_all_images

  #solr_query = "#{BASE_SOLR_URL}select"
  puts "download images from  fedora systems"
   File.read('volume_pids.csv').split(",").each do |p|
     s = p.sub(':','-')
     FileUtils.mkdir_p "/Users/LixiaZhao/good/jss_task/#{s}"
     solr_query = "http://127.0.0.1:8035/apache-solr-3.3.0/select?indent=on&fq=PARENTPID:#{p.sub(':','\\:')} AND LEVEL:page&fl=BIBID,PID,numFound&wt=json&start=0&rows=10000"
     puts "#{solr_query}"
     solr_uri = URI(solr_query)

     solr_response = Net::HTTP.get(solr_uri)
     solr_json = JSON.parse("#{solr_response}")
     solr_docs =solr_json['response']['docs']
     solr_docs.each do |c|
       fedora_query = "http://127.0.0.1:8035/fedora/objects/#{c['PID']}/datastreams/JPG/content"
       #http://127.0.0.1:8035/fedora/objects/slavicbooks:116915/datastreams/PDF/content
       #fedora_uri = URI(fedora_query)
       #fedora_response = Net::HTTP.get(fedora_uri)
       download_image(fedora_query,"/Users/LixiaZhao/good/jss_task/#{s}/#{c['PID'].sub(':','-')}.jpg")
     end
  end
end

namespace :jss_solr do
  desc "Get the list of title level bib ids of JSS collection"
  task :titleBIDs do
    get_title_level_bibs
  end

  desc "Get volume level pids and save in a file"
  task :volume do
    get_volume_level_pids
  end


  desc "Get the list of page level pids of jss collection comma separated string"
  task :page_children_comma do
      get_page_level_pid_2
  end

  desc "Get the list of page level pids of jss collection csv array"
  task :page_children_csv do
    get_page_level_pid_3
  end

  desc "download 332 children images of a sample volume level pids"
  task :download_Sample_Images do
    download_116784_image
  end

  desc "scan fedora image file systems"
  task :scan_file_system do
    ssh_digcoll
  end

  desc "compare page_children_comma output pids with fedeora api to audit if all images are in the fedeora" #or compare two csv output with the python script
  task :audit do
    compare_csv_imagesAPI
  end

  desc "Download all images and put in each volume pids folder"
  task :download_all_images do
    download_all_images
  end
end




