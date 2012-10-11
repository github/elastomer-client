require File.expand_path('../test_helper', __FILE__)
require 'elastomer'

class ElastomerIndexTest < MiniTest::Unit::TestCase
  def setup
    @index = Elastomer::Index.new 'test'
  end

  # build term filter
  # --------------------------------------------------------------------
  def test_build_term_filter
    hash = @index.build_term_filter( :language, 'Ruby' )
    assert_equal({:term => {'language' => 'Ruby'}}, hash)
  end

  def test_build_term_filter_with_array_value
    hash = @index.build_term_filter( :language, ['Ruby', 'JavaScript', 'C'] )
    assert_equal({:terms => {'language' => ['Ruby', 'JavaScript', 'C']}}, hash)
  end

  def test_build_term_filter_with_negative_field
    hash = @index.build_term_filter( :"-path", 'vendor/' )
    assert_equal({:not => {:filter => {:term => {'path' => 'vendor/'}}}}, hash)
  end

  def test_build_term_filter_with_negative_field_and_array_value
    hash = @index.build_term_filter( :"-path", %w[vendor/ test/ spec/] )
    assert_equal({:not => {:filter => {:terms => {'path' => %w[vendor/ test/ spec/]}}}}, hash)
  end

  # build range filter
  # --------------------------------------------------------------------
  def test_build_range_filter_from_term
    hash = @index.build_range_filter( :followers, '42' )
    assert_equal({:term => {'followers' => '42'}}, hash)
  end

  def test_build_range_filter_low
    hash = @index.build_range_filter( :followers, '[20 TO *]' )
    assert_equal({:range => {'followers' => {:from =>'20'}}}, hash)
  end

  def test_build_range_filter_high
    hash = @index.build_range_filter( :repos, '[* TO 100]' )
    assert_equal({:range => {'repos' => {:to =>'100'}}}, hash)
  end

  def test_build_range_filter_both
    hash = @index.build_range_filter( :forks, '[10 TO 100]' )
    assert_equal({:range => {'forks' => {:from => '10', :to =>'100'}}}, hash)
  end

  def test_build_range_filter_silly
    assert_nil @index.build_range_filter( :forks, '[* TO *]' )
  end

  def test_build_range_filter_with_array_value
    hash = @index.build_range_filter( :forks, ['[* TO 42]', '[69 TO *]', '54'] )
    assert_equal({:or => [
        {:range => {'forks' => {:to => '42'}}},
        {:range => {'forks' => {:from => '69'}}},
        {:term => {'forks' => '54'}}
    ]}, hash)
  end

  def test_build_range_filter_with_negative_field
    hash = @index.build_range_filter( :"-followers", '42' )
    assert_equal({:not => {:filter => {:term => {'followers' => '42'}}}}, hash)

    hash = @index.build_range_filter( :"-followers", '[20 TO *]' )
    assert_equal({:not => {:filter => {:range => {'followers' => {:from =>'20'}}}}}, hash)

    hash = @index.build_range_filter( :"-repos", '[* TO 100]' )
    assert_equal({:not => {:filter => {:range => {'repos' => {:to =>'100'}}}}}, hash)

    hash = @index.build_range_filter( :"-forks", '[10 TO 100]' )
    assert_equal({:not => {:filter => {:range => {'forks' => {:from => '10', :to =>'100'}}}}}, hash)

    assert_nil @index.build_range_filter( :"-forks", '[* TO *]' )

    hash = @index.build_range_filter( :"-forks", ['[* TO 42]', '[69 TO *]', '54'] )
    assert_equal({:not => {:filter => {:or => [
        {:range => {'forks' => {:to => '42'}}},
        {:range => {'forks' => {:from => '69'}}},
        {:term => {'forks' => '54'}}
    ]}}}, hash)
  end

  # build query filter
  # --------------------------------------------------------------------
  def test_build_query_filter
    hash = @index.build_query_filter( :location, 'Boulder, CO' )
    assert_equal({:query => {:query_string => {:query => 'Boulder, CO', :default_field => 'location', :default_operator => :AND}}}, hash)
  end

  def test_build_query_filter_with_escapable_characters
    hash = @index.build_query_filter( :location, 'Denton *TX' )
    assert_equal({:query => {:query_string => {:query => 'Denton \\*TX', :default_field => 'location', :default_operator => :AND}}}, hash)
  end

  def test_build_query_filter_with_empty_value
    assert_nil @index.build_query_filter( :location, '' )
  end

  def test_build_query_filter_with_array_value
    hash = @index.build_query_filter( :location, ['Boulder, CO', 'San Francisco', 'Berlin'] )
    assert_equal({:or => [
        {:query => {:query_string => {:query => 'Boulder, CO', :default_field => 'location', :default_operator => :AND}}},
        {:query => {:query_string => {:query => 'San Francisco', :default_field => 'location', :default_operator => :AND}}},
        {:query => {:query_string => {:query => 'Berlin', :default_field => 'location', :default_operator => :AND}}}
    ]}, hash)
  end

  def test_build_query_filter_with_negative_field
    hash = @index.build_query_filter( :"-location", 'Boulder, CO' )
    assert_equal({:not => {:filter => {:query => {:query_string => {:query => 'Boulder, CO', :default_field => 'location', :default_operator => :AND}}}}}, hash)

    hash = @index.build_query_filter( :"-location", 'Denton *TX' )
    assert_equal({:not => {:filter => {:query => {:query_string => {:query => 'Denton \\*TX', :default_field => 'location', :default_operator => :AND}}}}}, hash)

    assert_nil @index.build_query_filter( :"-location", '' )

    hash = @index.build_query_filter( :"-location", ['Boulder, CO', 'San Francisco', 'Berlin'] )
    assert_equal({:not => {:filter => {:or => [
        {:query => {:query_string => {:query => 'Boulder, CO', :default_field => 'location', :default_operator => :AND}}},
        {:query => {:query_string => {:query => 'San Francisco', :default_field => 'location', :default_operator => :AND}}},
        {:query => {:query_string => {:query => 'Berlin', :default_field => 'location', :default_operator => :AND}}}
    ]}}}, hash)
  end
end

