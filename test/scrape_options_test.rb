require_relative 'test_helper'

class ScrapeOptionsTest < Minitest::Test

  def test_pdf_format_accepts_string
    options = Firecrawl::ScrapeOptions.build do
      action :pdf do
        format 'Legal'
      end
    end

    assert_equal 'Legal', options.to_h[ :actions ].first[ :format ]
  end

  def test_pdf_format_accepts_symbol_and_normalizes
    options = Firecrawl::ScrapeOptions.build do
      action :pdf do
        format :legal
      end
    end

    assert_equal 'Legal', options.to_h[ :actions ].first[ :format ]
  end

  def test_pdf_format_normalizes_lowercase_string
    options = Firecrawl::ScrapeOptions.build do
      action :pdf do
        format 'letter'
      end
    end

    assert_equal 'Letter', options.to_h[ :actions ].first[ :format ]
  end

  def test_pdf_format_normalizes_uppercase_string
    options = Firecrawl::ScrapeOptions.build do
      action :pdf do
        format 'TABLOID'
      end
    end

    assert_equal 'Tabloid', options.to_h[ :actions ].first[ :format ]
  end

  def test_pdf_action_without_format
    options = Firecrawl::ScrapeOptions.build do
      action :pdf do
        landscape true
      end
    end

    assert_nil options.to_h[ :actions ].first[ :format ]
    assert_equal true, options.to_h[ :actions ].first[ :landscape ]
  end

end
