module Exa
    struct Result
        include JSON::Serializable
        
        # If available, the author of the content.
        getter author : String?

        # Array of links from the search result.
        @[JSON::Field(key: "links", root: "extras")]
        getter extras_links : Array(String) = [] of String

        # A URL to the favicon associated with the result.
        getter favicon : String?

        # Array of highlights extracted from the search result content.
        getter highlights : Array(String) = [] of String

        # Array of cosine similarity scores for each highlighted
        @[JSON::Field(key: "highlightScores")]
        getter highlight_scores : Array(Float64) = [] of Float64

        # The temporary ID for the document. Useful for /contents endpoint.
        getter id : String

        # A URL to the image associated with the result, if available.
        getter image : String?
        
        # An estimate of the creation date, from parsing HTML content. Format is YYYY-MM-DD.
        @[JSON::Field(key: "publishedDate", converter: Exa::ISO_8601_DATE)]
        getter published_date : Time?

        # A number from 0 to 1 representing similarity between the query/url and the result.
        getter score : Float64?

        # Array of subpage Results
        getter subpages : Array(Result) = [] of Result

        getter summary : String?

        getter text : String?

        getter title : String

        getter url : String
    end
    
    struct SearchResponse
        include JSON::Serializable

        enum Type
            Neural
            Keyword
        end

        @[JSON::Field(key: "searchType")]
        getter search_type : Type?
        
        getter results : Array(Result)
    end
end