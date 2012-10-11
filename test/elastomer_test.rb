require File.expand_path('../test_helper', __FILE__)
require 'elastomer'

class ElastomerTest < MiniTest::Unit::TestCase

  # escape_characters
  # --------------------------------------------------------------------
  def test_escape_characters
    assert_equal 'foo \\& bar', Elastomer.escape_characters('foo & bar')
    assert_equal 'foo \\+bar \\-baz', Elastomer.escape_characters('foo +bar -baz')

    assert_equal 'this \\[should\\] be a \\(rather\\) \\{interesting\\} \\^result\\!',
                 Elastomer.escape_characters('this [should] be a (rather) {interesting} ^result!')

    assert_equal 'result = \\(@num > 1\\) \\? num \\- 1 \\: Math.abs\\(num\\) \\* 2',
                 Elastomer.escape_characters('result = (@num > 1) ? num - 1 : Math.abs(num) * 2')
  end

  def test_escape_characters_with_quotes
    assert_equal 'str = "this is a string\\\\n"', Elastomer.escape_characters('str = "this is a string\\n"')
  end

  def test_escape_characters_with_quotes_escaped
    assert_equal 'str = \\"this is a string\\\\n\\"', Elastomer.escape_characters('str = "this is a string\\n"', true)
  end

  def test_escape_characters_with_escaped_quotes
    assert_equal 'str = "this is a string with \\"escaped\\" quotes\\\\n"',
                 Elastomer.escape_characters('str = "this is a string with \\"escaped\" quotes\\n"')
  end

  # parse_query
  # --------------------------------------------------------------------
  def test_parse_query_empty_string
    query, fields = Elastomer.parse_query('')
    assert_equal '', query
    assert_nil fields
  end

  def test_parse_broken_quoted_string
    query, fields = Elastomer.parse_query("\"chart library", [:size, :forks, :fork])
    assert_equal '"chart library', query
  end

  def test_parse_query_string_without_fields
    text = "sample text"
    query, fields = Elastomer.parse_query(text)
    assert_same text, query
    assert_nil fields
  end

  def test_parse_query_string_with_fields
    text = "sample text"
    empty_hash = {}
    query, fields = Elastomer.parse_query(text, :followers)
    refute_same text, query
    assert_equal text, query
    assert_equal empty_hash, fields
  end

  def test_parse_query_string
    query, fields = Elastomer.parse_query( "Chris followers:75", :followers )
    assert_equal 'Chris', query
    assert_equal({:followers => '75'}, fields)

    query, fields = Elastomer.parse_query( "require 'bundler' fork:false language:ruby", :fork, :language )
    assert_equal "require 'bundler'", query
    assert_equal({:fork => 'false', :language => 'ruby'}, fields)

    query, fields = Elastomer.parse_query( "literal query \"repos:44\" language:java", :repos, :language )
    assert_equal 'literal query "repos:44"', query
    assert_equal({:language => 'java'}, fields)

    query, fields = Elastomer.parse_query( "silly forks:42 query language:c++ but it repos:1 works", :forks, :repos, :language )
    assert_equal 'silly query but it works', query
    assert_equal({:forks => '42', :repos => '1', :language => 'c++'}, fields)
  end

  def test_parse_query_string_with_range_fields
    query, fields = Elastomer.parse_query( "range query followers:[25 TO 50] language:java", :followers, :language )
    assert_equal 'range query', query
    assert_equal({:followers => '[25 TO 50]', :language => 'java'}, fields)

    query, fields = Elastomer.parse_query( "forks:[10 TO *] language:ruby", :forks, :language )
    assert_equal '', query
    assert_equal({:forks => '[10 TO *]', :language => 'ruby'}, fields)
  end

  def test_parse_query_string_with_quotes
    empty_hash = {}

    query, fields = Elastomer.parse_query( '""', :noop )
    assert_equal '""', query
    assert_equal empty_hash, fields

    query, fields = Elastomer.parse_query( 'foo "" bar', :noop )
    assert_equal 'foo "" bar', query
    assert_equal empty_hash, fields

    query, fields = Elastomer.parse_query( "\"foo \\\"the bar\\\"\"", :noop )
    assert_equal '"foo \\"the bar\\""', query
    assert_equal empty_hash, fields

    query, fields = Elastomer.parse_query( '\\"\\"', :noop )
    assert_equal '\\"\\"', query
    assert_equal empty_hash, fields

    query, fields = Elastomer.parse_query( '\\" noop:42 \\"', :noop )
    assert_equal '\\" \\"', query
    assert_equal({:noop => '42'}, fields)
  end

  def test_parse_query_with_quoted_fields
    query, fields = Elastomer.parse_query( 'templates language:C++', :language )
    assert_equal 'templates', query
    assert_equal({:language => 'C++'}, fields)

    query, fields = Elastomer.parse_query( 'templates language:"C++"', :language )
    assert_equal 'templates', query
    assert_equal({:language => 'C++'}, fields)

    query, fields = Elastomer.parse_query( 'templates language:"Emacs Lisp"', :language )
    assert_equal 'templates', query
    assert_equal({:language => 'Emacs Lisp'}, fields)

    query, fields = Elastomer.parse_query( 'templates language:"Emacs Lisp', :language )
    assert_equal 'templates Lisp', query
    assert_equal({:language => '"Emacs'}, fields)
  end

  def test_parse_query_with_multiple_fields
    query, fields = Elastomer.parse_query( 'location:"Boulder, CO" location:Boulder', :location )
    assert_equal '', query
    assert_equal({:location => ['Boulder, CO', 'Boulder']}, fields)

    query, fields = Elastomer.parse_query( 'foo language:C++ language:Ruby language:Python language:"Emacs Lisp"', :language )
    assert_equal 'foo', query
    assert_equal({:language => ['C++', 'Ruby', 'Python', 'Emacs Lisp']}, fields)
  end

  def test_parse_query_with_negative_prefix
    query, fields = Elastomer.parse_query( 'to_s -path:vendor/', :fork, :language, :path )
    assert_equal 'to_s', query
    assert_equal({:"-path" => 'vendor/'}, fields)

    query, fields = Elastomer.parse_query( 'to_s -path:vendor/ -path:test/ -path:spec/', :path )
    assert_equal 'to_s', query
    assert_equal({:"-path" => %w[vendor/ test/ spec/]}, fields)
  end
end
