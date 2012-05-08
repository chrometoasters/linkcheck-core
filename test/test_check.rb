require './lib/tki-linkcheck'
Bundler.require(:test)

require 'minitest/autorun'
require 'webmock/minitest'

class TestCheck < MiniTest::Unit::TestCase
  def setup
    require 'ostruct'
    @doc = OpenStruct.new
    @doc.url = URI('http://example.com/')
    @doc.doc = Nokogiri::HTML(File.new('./test/mocks/anchors.html'))
    $redis = MockRedis.new
    LinkCache.force_flush
  end


  def teardown
    load './lib/tki-linkcheck/redis.rb'
  end


  def test_valid_anchor_returns_nil
    assert_nil Check.new(@doc, 'http://example.com/#divId').validate
    assert_nil Check.new(@doc, 'http://example.com/#namedAnchor').validate
  end


  def test_slashes_dont_matter
    assert_nil Check.new(@doc, 'http://example.com#divId').validate
    assert_nil Check.new(@doc, 'http://example.com/#divId').validate
  end


  def test_invalid_anchor_returns_correct_object
    assert_equal :bad_anchor, Check.new(@doc, 'http://example.com/#someClass').validate
    assert_equal :bad_anchor, Check.new(@doc, 'http://example.com/#nothingAtAll').validate
  end


  def test_invalid_anchor_returns_correct_object
    assert_equal :bad_anchor, Check.new(@doc, 'http://example.com/#someClass').validate
    assert_equal :bad_anchor, Check.new(@doc, 'http://example.com/#nothingAtAll').validate
  end


  def test_http_response_codes_return_correct_objects
    stub_request(:get, "example.com/page1").to_return(:status => 200)
    assert_nil Check.new(@doc, 'http://example.com/page1').validate

    stub_request(:get, "example.com/page10").to_return(:status => 404)
    assert_equal :not_found, Check.new(@doc, 'http://example.com/page10').validate

    stub_request(:get, "example.com/page3").to_return(:status => 403)
    assert_equal :forbidden, Check.new(@doc, 'http://example.com/page3').validate

    stub_request(:get, "anothersite.com/page4").to_return(:status => 301)
    assert_equal :moved_permanently, Check.new(@doc, 'http://anothersite.com/page4').validate

    stub_request(:get, "anothersite.com/page5").to_return(:status => 302)
    assert_nil Check.new(@doc, 'http://anothersite.com/page5').validate

    stub_request(:get, "anothersite.com/page6").to_return(:status => 303)
    assert_nil Check.new(@doc, 'http://anothersite.com/page6').validate

    stub_request(:get, "example.com/page7").to_return(:status => 503)
    assert_equal :unavailable, Check.new(@doc, 'http://example.com/page7').validate

    stub_request(:get, "example.com/page8").to_return(:status => 500)
    assert_equal :unknown, Check.new(@doc, 'http://example.com/page8').validate

    stub_request(:get, "example.com/page9").to_return(:status => 401)
    assert_equal :unknown, Check.new(@doc, 'http://example.com/page9').validate
  end


  def test_http_responses_cached
    stub_request(:get, "example.com/other/page1").to_return(:status => 200)
    assert_nil Check.new(@doc, 'http://example.com/other/page1').validate

    stub_request(:get, "example.com/other/page1").to_return(:status => 404)
    assert_nil Check.new(@doc, 'http://example.com/other/page1').validate

    stub_request(:get, "example.com/other/page2").to_return(:status => 303)
    assert_nil Check.new(@doc, 'http://example.com/other/page2').validate

    stub_request(:get, "example.com/other/page2").to_return(:status => 200)
    assert_nil Check.new(@doc, 'http://example.com/other/page2').validate
  end


  def test_invalid_uris_return_correct_symbol
    assert_equal :ignored_for_scheme, Check.new(@doc, 'some/thing').validate
    assert_equal :ignored_for_uri_class, Check.new(@doc, 'http:// example.com').validate
  end


  def test_local_redirects_ignored
    stub_request(:get, "example.com/page99").to_return(:status => 301)
    assert_nil Check.new(@doc, 'http://example.com/page99').validate

    stub_request(:get, "example.com/page89").to_return(:status => 302)
    assert_nil Check.new(@doc, 'http://example.com/page89').validate

    stub_request(:get, "example.com/page79").to_return(:status => 303)
    assert_nil Check.new(@doc, 'http://example.com/page79').validate
  end
end
