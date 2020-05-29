#!/usr/bin/env ruby

require 'nokogiri'
require 'httparty'

class Paac
  PERMITED_ACTIONS={'today' => 'Temperatura Máxima', 'av_min' => 'Temperatura Mínima', 'av_max' => 'Temperatura Máxima'}
  BARCELONA_CITIES = 102
  AFFILIATE_ID = ''
  BASE_URL = 'http://api.tiempo.com/index.php?api_lang=es'
  BASE_URL_CITIES = "#{Paac::BASE_URL}&division=#{Paac::BARCELONA_CITIES}&affiliate_id=#{Paac::AFFILIATE_ID}"

  attr_reader :cityId, :tempHash, :command, :city

  def initialize(command, city)
    @command = command
    @city = city.downcase
    @cityId = nil
    @tempHash = {}
  end

  def getCity()
    raise 'option error: av_min ''<city>'', av_max ''<city>'', today=''<city>'', are options allowed' if Paac::PERMITED_ACTIONS[command].nil?
    citiesUrl = "#{Paac::BASE_URL}&division=#{Paac::BARCELONA_CITIES}&affiliate_id=#{Paac::AFFILIATE_ID}"
    cityData = getData(citiesUrl)
    getCityId(cityData)
  end

  def getDataTemperatures
    cityWeatherurl = "#{Paac::BASE_URL}&localidad=#{@cityId}&affiliate_id=#{Paac::AFFILIATE_ID}"
    temperatureData = getData(cityWeatherurl)
    getTemperatures(temperatureData)
    printAvg()
  end

  def printAvg
    case @command
      when 'today'
        puts "Current temperature: #{@tempHash[1]}"
      else
        puts @command.eql?('av_max') ? 'Maximum Average: ' + calculateAverage(@tempHash).to_s  : 'Minimum Average: ' + calculateAverage(@tempHash).to_s
    end
  end

  def getTemperatures(tmpTemperatureData=nil)
    raise 'temperature data not sent' if tmpTemperatureData.nil? || tmpTemperatureData.eql?('')
    begin
      xmlWeatherPath = "/report/location/var[name='#{Paac::PERMITED_ACTIONS[@command]}']/data/forecast"
      tmpTemperatureData.xpath(xmlWeatherPath).each do |tmp|
        @tempHash.merge!(Hash[tmp.[]('data_sequence').to_i, tmp.[]('value').to_i])
      end
      raise 'No temperatures available' if @tempHash.length == 0
    rescue StandardError
      raise 'Error while getting weather conditions'
    end
  end

  def getCityId(tmpCityData=nil)
    raise 'data not sent' if tmpCityData.nil? || tmpCityData.eql?('')
    begin
      xmlCityPath = "/report/location/data/name"
      tmpCityData.xpath(xmlCityPath).each do |c|
        if c.children.to_s.gsub(/[']/, '').downcase.eql?(@city)
          @cityId = c.[]('id')
          break
        end
      end

      raise 'City not found' if @cityId.nil?
    rescue StandardError
      raise 'Error while getting city info'
    end
  end

  private
    def getData(url=nil)
      raise 'check function parameters' if url.nil? || url.eql?('')
      response = HTTParty.get(url)
      if response.code == 200
        return Nokogiri::XML(response.to_s)
      elsif
        raise 'Error while getting data'
      end
    end

    def calculateAverage(watherData=nil)
      return watherData.values.inject{ |sum, n| sum + n }/(watherData.length)
    rescue StandardError => e
      puts e
      raise 'Error while calculating average'
    end
end


begin
  command = ARGV[0].gsub(/^-{1}/, '')
  city = ARGV[1]

  raise 'parameters not present' if command.nil? || command.eql?('') || city.nil? || city.eql?('')

  test = Paac.new(command, city)
  test.getCity()
  test.getDataTemperatures()

rescue Nokogiri::XML::SyntaxError => e
  puts e
rescue StandardError => e
  puts e
end