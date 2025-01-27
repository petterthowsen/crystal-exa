require "json"

module Exa

    class Contents
        include JSON::Serializable

        class Extras
            include JSON::Serializable
            
            # Number of images to return for each result.
            @[JSON::Field(key: "imageLinks")]
            property image_links : Int32 = 0

            # Number of URLs to return from each webpage.
            property links : Int32 = 0
        end
    
        # Text snippets the LLM identifies as most relevant from each page.
        class Highlights
            include JSON::Serializable

            # The number of snippets to return for each result.
            @[JSON::Field(key: "highlightsPerUrl")]
            highlights_per_url : Int32 = 1

            # The number of sentences to return for each snippet.
            @[JSON::Field(key: "numSentences")]
            num_sentences : Int32 = 5

            query : String?
        end

        enum LiveCrawl
            Never
            Fallback
            Always
            Auto
        end

        property extras : Extras?

        # Types of live crawling behavior
        @[JSON::Field(key: "liveCrawl")]
        property live_crawl : LiveCrawl = LiveCrawl::Auto

        # Timeout for live crawl
        @[JSON::Field(key: "liveCrawlTimeout")]
        property live_crawl_timeout : Int32 = 1000

        # The number of subpages to crawl.
        # The actual number crawled may be limited by system constraints.
        @[JSON::Field(key: "subPages")]
        property sub_pages : Int32 = 0

        # Keyword to find specific subpages of search results.
        # Can be a single string or an array of strings, comma delimited.
        @[JSON::Field(key: "subpageTarget")]
        property subpage_target : Array(String)?

        # Custom query for the LLM-generated summary.
        property summary_query : String?

        def initialize()
        end
    end

    # Represents a request to the /search endpoint
    #
    # [API docs](https://docs.exa.ai/reference/search)
    class SearchRequest
        include JSON::Serializable

        enum Category
            Company
            ResearchPaper
            News
            Pdf
            Github
            Tweet
            PersonalSite
            LinkedInProfile
            FinancialReport
        end
        
        # The type of search.
        # Neural uses an embeddings-based model, keyword is google-like SERP.
        # Default is auto, which automatically decides between keyword and neural.
        enum Type
            Keyword
            Neural
            Auto
        end

        # The query to search for.
        property query : String

        # The category of the search.
        property category : Category?

        # Specifies how the search contents should be returned.
        property contents : Contents = Contents.new

        # The type of search.
        property type : Type = Type::Auto

        # Number of results to return (up to thousands of results available for custom plans)
        # Required range: x < 10
        @[JSON::Field(key: "numResults")]
        property num_results : Int32 = 10
        
        # Crawl date refers to the date that Exa discovered a link.
        # Results will include links that were crawled before this date.
        # Serialized to ISO 8601 format.
        @[JSON::Field(key: "endCrawlDate", converter: Exa::ISO_8601_DATE)]
        property end_crawl_date : Time?

        # Only links with a published date before this will be returned.
        # Serialized to ISO 8601 format.
        @[JSON::Field(key: "endPublishedDate", converter: Exa::ISO_8601_DATE)]
        property end_published_date : Time?

        # List of domains to exclude from search results.
        @[JSON::Field(key: "excludeDomains")]
        property exclude_domains : Array(String) = [] of String

        # List of strings that must not be present in webpage text of results.
        # ! NOTE: Currently, only 1 string is supported, of up to 5 words.
        @[JSON::Field(key: "excludeText")]
        property exclude_text : Array(String) = [] of String

        # List of domains to include in the search.
        # If specified, results will only come from these domains.
        @[JSON::Field(key: "includeDomains")]
        property include_domains : Array(String) = [] of String

        # List of strings that must be present in webpage text of results.
        # Currently, only 1 string is supported, of up to 5 words.
        @[JSON::Field(key: "includeText")]
        property include_text : Array(String) = [] of String

        # Crawl date refers to the date that Exa discovered a link.
        # Results will include links that were crawled after this date.
        # Must be specified in ISO 8601 format.
        @[JSON::Field(key: "startCrawlDate", converter: Exa::ISO_8601_DATE)]
        property start_crawl_date : Time?

        # Only links with a published date after this will be returned.
        # Must be specified in ISO 8601 format.
        @[JSON::Field(key: "startPublishedDate", converter: Exa::ISO_8601_DATE)]
        property start_published_date : Time?

        # Autoprompt converts your query to an Exa-style query.
        # Enabled by default for auto search, optional for neural search, and not available for keyword search.
        @[JSON::Field(key: "useAutoprompt")]
        property use_autoprompt : Bool = true

        def initialize(
            @query : String,
            @category : Category? = nil,
            @type : Type = Type::Auto,
            @num_results : Int32 = 10,
            @use_autoprompt : Bool = true
        )
        end

        def includes(text : String) : self
            self.include_text = [text]
            self
        end

        def only_from(domains : Array(String)) : self
            self.include_domains = domains
            self
        end

        def newer_than(time : Time) : self
            self.start_published_date = time
            self
        end

        def older_than(time : Time) : self
            self.end_published_date = time
            self
        end

        def crawled_after(time : Time) : self
            self.start_crawl_date = time
            self
        end

        def crawled_before(time : Time) : self
            self.end_crawl_date = time
            self
        end
    end
end