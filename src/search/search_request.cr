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

            def initialize(@image_links : Int32 = 0, @links : Int32 = 0)
            end
        end
    
        # Text snippets the LLM identifies as most relevant from each page.
        class Highlights
            include JSON::Serializable

            # The number of snippets to return for each result.
            @[JSON::Field(key: "highlightsPerUrl")]
            property highlights_per_url : Int32 = 1

            # The number of sentences to return for each snippet.
            @[JSON::Field(key: "numSentences")]
            property num_sentences : Int32 = 5

            # Custom query to direct the LLM's selection of highlights.
            property query : String?

            def initialize(@image_links : Int32 = 0, @links : Int32 = 0, @highlights_per_url : Int32 = 1, @num_sentences : Int32 = 5, @query : String? = nil)
            end
        end

        enum LiveCrawl
            Never
            Fallback
            Always
            Auto
        end

        property extras : Extras = Extras.new

        property highlights : Highlights = Highlights.new

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

        # Includes a specific text in the search results.
        # @param text [String] The text to include in the search results.
        # @return [SearchRequest] The updated SearchRequest instance.
        def includes(text : String) : self
            self.include_text = [text]
            self
        end

        # Only returns results from the specified domains.
        # @param domains [Array(String)] The domains to include in the search results.
        # @return [SearchRequest] The updated SearchRequest instance.
        def only_from(domains : Array(String)) : self
            self.include_domains = domains
            self
        end

        # Only returns results published after the specified date.
        # @param time [Time] The date after which results should be published.
        # @return [SearchRequest] The updated SearchRequest instance.
        def newer_than(time : Time) : self
            self.start_published_date = time
            self
        end

        # Only returns results published before the specified date.
        # @param time [Time] The date before which results should be published.
        # @return [SearchRequest] The updated SearchRequest instance.
        def older_than(time : Time) : self
            self.end_published_date = time
            self
        end

        # Only returns results crawled after the specified date.
        # @param time [Time] The date after which results should be crawled.
        # @return [SearchRequest] The updated SearchRequest instance.
        def crawled_after(time : Time) : self
            self.start_crawl_date = time
            self
        end

        # Only returns results crawled before the specified date.
        # @param time [Time] The date before which results should be crawled.
        # @return [SearchRequest] The updated SearchRequest instance.
        def crawled_before(time : Time) : self
            self.end_crawl_date = time
            self
        end

        # Chainable methods for modifying contents
        # Sets the number of highlights per URL, the number of sentences for each highlight, and an optional query for highlights.
        # @param count [Int32] The number of highlights to return per URL.
        # @param num_sentences [Int32] The number of sentences to return for each highlight (default is 3).
        # @param query [String?] An optional custom query for highlights.
        # @return [SearchRequest] The updated SearchRequest instance.
        def with_highlights(count : Int32 = 1, num_sentences : Int32 = 3, query : String? = nil) : self
            self.contents.highlights.highlights_per_url = count
            self.contents.highlights.num_sentences = num_sentences
            self.contents.highlights.query = query
            self
        end

        # Sets the number of sentences to return for each highlight.
        # @param count [Int32] The number of sentences to return for each highlight.
        # @return [SearchRequest] The updated SearchRequest instance.
        def with_num_sentences(count : Int32) : self
            self.contents.highlights.num_sentences = count
            self
        end

        # Sets a custom query for the highlights.
        # @param query [String] The custom query for the highlights.
        # @return [SearchRequest] The updated SearchRequest instance.
        def with_highlight_query(query : String) : self
            self.contents.highlights.query = query
            self
        end

        # Sets a custom query for the summary.
        # @param query [String] The custom query for the summary.
        # @return [SearchRequest] The updated SearchRequest instance.
        def with_summary_query(query : String) : self
            self.contents.summary_query = query
            self
        end

        # Sets the number of subpages to crawl.
        # @param count [Int32] The number of subpages to crawl.
        # @return [SearchRequest] The updated SearchRequest instance.
        def with_sub_pages(count : Int32) : self
            self.contents.sub_pages = count
            self
        end

        # Sets the target subpages for crawling.
        # @param target [Array(String)] The target subpages for crawling.
        # @return [SearchRequest] The updated SearchRequest instance.
        def with_subpage_target(target : Array(String)) : self
            self.contents.subpage_target = target
            self
        end

        # Sets the live crawling behavior.
        # @param live_crawl [LiveCrawl] The live crawling behavior to set.
        # @return [SearchRequest] The updated SearchRequest instance.
        def with_live_crawl(live_crawl : LiveCrawl) : self
            self.contents.live_crawl = live_crawl
            self
        end

        # Sets the timeout for live crawling.
        # @param timeout [Int32] The timeout duration for live crawling.
        # @return [SearchRequest] The updated SearchRequest instance.
        def with_live_crawl_timeout(timeout : Int32) : self
            self.contents.live_crawl_timeout = timeout
            self
        end

        # Chainable methods for modifying extras
        # Sets the number of image links to return.
        # @param count [Int32] The number of image links to return.
        # @return [SearchRequest] The updated SearchRequest instance.
        def with_image_links(count : Int32) : self
            self.contents.extras.image_links = count
            self
        end

        # Sets the number of URLs to return from each webpage.
        # @param count [Int32] The number of URLs to return.
        # @return [SearchRequest] The updated SearchRequest instance.
        def with_links(count : Int32) : self
            self.contents.extras.links = count
            self
        end
    end
end