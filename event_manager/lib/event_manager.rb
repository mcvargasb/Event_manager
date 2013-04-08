require 'csv'
require 'sunlight'
require 'erb'

Sunlight::Base.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phonenumbers(number)
  if number.length < 10 || number.length > 11
   number = ""
  end

  if number.length == 11 
   if number[0] == 1
    number = number[1..-1]
   else
    number = ""   
   end
  end

number

  end


def legislators_for_zipcode(zipcode)
  Sunlight::Legislator.all_in_zipcode(zipcode)
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

totalhours = Hash.new(0)
days = Hash.new(0)

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_for_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id,form_letter)

  rdate = row[:regdate]
  date = DateTime.strptime(rdate, "%y/%d/%m %H:%M")

  totalhours[date.hour] += 1
  days[date.strftime("%A")] += 1
 end

peakhours = totalhours.select {|k,v| v == totalhours.values.max}
daysoftheweek = days.select {|k,v| v == days.values.max}.keys.join(", ")

puts "Peak registration hours: "+peakhours.keys.to_s
puts "Days of the week people most do register: "+daysoftheweek


