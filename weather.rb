# encoding: utf-8
#
# Программа «Прогноз погоды» Версия 2.0 (Сегодня и завтра)
#
# Данные берем из XML метеосервиса
# http://www.meteoservice.ru/content/export.html
#

# Подключаем библиотеку для загрузки данных по http-протоколу
require 'net/http'

# Подключаем библиотеку для парсинга XML
require 'rexml/document'

require_relative './lib/meteoservice'

# Этот код необходим только при использовании русских букв на Windows
if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

CITIES = {
    33381 => 'Дзержинск',
    56 => 'Октябрьский',
    7501 => 'Мурино',
    99 => 'Новосибирск',
    59 => 'Пермь',
    115 => 'Орел',
    121 => 'Чита',
    141 => 'Братск',
    199 => 'Краснодар'
}.invert.freeze

city_names = CITIES.keys

puts "Прогноз погоды"
puts "Погоду для какого города вы хотите узнать:"

city_names.each_with_index { |a, b | puts "#{b + 1}. #{a}" }
user_input = STDIN.gets.to_i
unless user_input.between?(1, city_names.size)
  user_input = STDIN.gets.to_i
  puts "Выберите номер города."
end

city_id = CITIES[city_names[user_input - 1]]

url = "https://xml.meteoservice.ru/export/gismeteo/point/#{city_id}.xml"

response = Net::HTTP.get_response(URI.parse(url))
doc = REXML::Document.new(response.body)

city_name = URI.unescape(doc.root.elements['REPORT/TOWN'].attributes['sname'])

# Достаем все XML-теги <FORECAST> внутри тега <TOWN> и преобразуем их в массив
forecast_nodes = doc.root.elements['REPORT/TOWN'].elements.to_a

# Выводим название города и все прогнозы по порядку
puts city_name
puts

forecast_nodes.each do |node|
  puts Meteoservice.from_xml(node)
  puts
end