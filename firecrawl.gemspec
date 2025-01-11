Gem::Specification.new do | spec |

  spec.name             = 'firecrawl'
  spec.version          = '0.2.0'
  spec.authors          = [ 'Kristoph Cichocki-Romanov' ]
  spec.email            = [ 'rubygems.org@kristoph.net' ]

  spec.summary          = 
    "The Firecrawl gem implements a lightweight interface to the Firecrawl.dev API which takes " \
    "a URL, crawls it and returns html, markdown, or structured data. It is of particular value" \
    "when used with LLM's for grounding."
  spec.description      =
    "The Firecrawl gem implements a lightweight interface to the Firecrawl.dev API. Firecrawl " \
    "can take a URL, scrape the page contents and return the whole page or principal content " \
    "as html, markdown, or structured data.\n" \
    "\n" \
    "In addition, Firecrawl can crawl an entire site returning the pages it encounters or just " \
    "the map of the pages, which can be used for subsequent scraping."
  spec.license          = 'MIT'
  spec.homepage         = 'https://github.com/EndlessInternational/firecrawl'
  spec.metadata         = {
    'source_code_uri'   => 'https://github.com/EndlessInternational/firecrawl',
    'bug_tracker_uri'   => 'https://github.com/EndlessInternational/firecrawl/issues',
#    'documentation_uri' => 'https://github.com/EndlessInternational/firecrawl'
  }

  spec.required_ruby_version = '>= 3.0'
  spec.files            = Dir[ "lib/**/*.rb", "LICENSE", "README.md", "firecrawl.gemspec" ]
  spec.require_paths    = [ "lib" ]

  spec.add_runtime_dependency 'base64'
  spec.add_runtime_dependency 'faraday', '~> 2.7'
  spec.add_runtime_dependency 'dynamicschema', '~> 1.0.0.beta04'

  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'debug', '~> 1.9'
  spec.add_development_dependency 'vcr', '~> 6.3'

end
