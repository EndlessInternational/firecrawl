require_relative 'test_helper'

class MapOptionsTest < Minitest::Test

  def test_build_with_search
    options = Firecrawl::MapOptions.build do
      search 'blog'
    end

    assert_equal 'blog', options.to_h[ :search ]
  end

  def test_build_with_limit
    options = Firecrawl::MapOptions.build do
      limit 100
    end

    assert_equal 100, options.to_h[ :limit ]
  end

  def test_build_with_sitemap_modes
    [ :skip, :include, :only ].each do | mode |
      options = Firecrawl::MapOptions.build do
        sitemap mode
      end

      assert_equal mode, options.to_h[ :sitemap ]
    end
  end

  def test_build_with_include_subdomains
    options = Firecrawl::MapOptions.build do
      include_subdomains false
    end

    assert_equal false, options.to_h[ :includeSubdomains ]
  end

  def test_build_with_ignore_query_parameters
    options = Firecrawl::MapOptions.build do
      ignore_query_parameters true
    end

    assert_equal true, options.to_h[ :ignoreQueryParameters ]
  end

  def test_build_with_ignore_cache
    options = Firecrawl::MapOptions.build do
      ignore_cache true
    end

    assert_equal true, options.to_h[ :ignoreCache ]
  end

  def test_build_with_timeout
    options = Firecrawl::MapOptions.build do
      timeout 60000
    end

    assert_equal 60000, options.to_h[ :timeout ]
  end

  def test_build_with_location
    options = Firecrawl::MapOptions.build do
      location 'US' do
        languages [ 'en-US', 'en' ]
      end
    end

    location = options.to_h[ :location ]
    assert_equal 'US', location[ :country ]
    assert_equal [ 'en-US', 'en' ], location[ :languages ]
  end

  def test_build_with_hash
    options = Firecrawl::MapOptions.build( {
      search: 'docs',
      limit: 50,
      include_subdomains: false
    } )

    hash = options.to_h
    assert_equal 'docs', hash[ :search ]
    assert_equal 50, hash[ :limit ]
    assert_equal false, hash[ :includeSubdomains ]
  end

end
