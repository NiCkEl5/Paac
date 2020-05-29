require_relative '../paac.rb'
require 'test/unit'
require 'nokogiri'

class Testpaac < Test::Unit::TestCase
  BASE_DIR = File.dirname(File.expand_path(__FILE__))
  def setup
    @o = Paac.new('av_min', 'Barcelona')
  end

  def test_creation
    assert_instance_of(Paac, @o)
    assert_not_equal(nil, @o.command)
    assert_not_equal(nil, @o.city)
  end

  def test_getCityId
    cityDoc = File.open( BASE_DIR + "/citiesData.xml") { |f| Nokogiri::XML(f) }
    @o.getCityId(cityDoc)
    assert_not_equal(nil, @o.cityId)
  end

  def test_getTemperatures
    cityDoc = File.open( BASE_DIR + "/citiesData.xml") { |f| Nokogiri::XML(f) }
    weatherDoc = File.open( BASE_DIR + "/temperatureData.xml") { |f| Nokogiri::XML(f) }
    @o.getCityId(cityDoc)
    @o.getTemperatures(weatherDoc)
    assert_not_equal({}, @o.tempHash)
  end

  # def test_getCity
  #   @o.getCity()
  #   assert_not_equal(nil, @o.cityId)
  # end

  # def test_fullcycle
  #   @o.getCity()
  #   @o.getDataTemperatures()
  #   assert_not_equal({}, @o.tempHash)
  # end
end