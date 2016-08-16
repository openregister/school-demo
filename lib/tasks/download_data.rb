tmp_dir = './tmp/data'
`mkdir #{tmp_dir}`
%w[uk
street
school
school-type
school-tag
school-phase
school-gender
school-federation
school-admissions-policy
register
place
local-authority
local-authority-type
field
diocese
denomination
datatype
address].each do |r|
  puts ''
  puts '===='
  puts r
  data_file = "#{tmp_dir}/#{r}/#{r}.tsv"
  if File.exist? data_file
    puts "file already exists: #{data_file}"
  else
    `mkdir #{tmp_dir}/#{r}`
    count = `curl http://#{r}.discovery.openregister.org/ | grep -A 1 'Total records:' | grep dd |  sed 's/.*records">//' | sed 's/<span.*//'`
    pages = (Integer(count.strip) / 5000) + 1

    files = []
    1.upto(pages) do |i|
      url = "http://#{r}.discovery.openregister.org/records.tsv?page-index=#{i}&page-size=5000"
      tmp_file = "#{tmp_dir}/#{r}/#{r}-#{"%05d" % (i)}.tsv"
      cmd = "curl --output '#{tmp_file}' '#{url}'"
      puts cmd
      `#{cmd}`
      cmd = if i == 1
              "cat #{tmp_file} > #{data_file}"
            else
              "sed 1d #{tmp_file} >> #{data_file}"
            end
      puts cmd
      `#{cmd}`
      `rm #{tmp_file}`
    end

    puts "expected: #{count}"
    puts "got: #{`sed 1d #{tmp_dir}/#{r}/#{r}.tsv | wc -l`}"
  end
end

osfile = "#{tmp_dir}/os-open-names/places.tsv"
unless File.exist? osfile
  `mkdir #{tmp_dir}/os-open-names`
  cmd = "curl --output #{osfile} https://raw.githubusercontent.com/openregister/place-data/master/lists/os-open-names/places.tsv"
  puts cmd
  `#{cmd}`
end