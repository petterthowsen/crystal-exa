require "./spec_helper"

API_KEY = begin
    File.read("./spec/api_key.txt")
rescue e
    raise "Please create a file called './spec/api_key.txt' containing your Speechactors API key"
end

describe Exa do
  # TODO: Write tests

  it "can search" do
    client = Exa::Client.new API_KEY

    search = Exa::SearchRequest.new(query: "blog posts about AGI", num_results: 1)
    response = client.search(search)

    puts response.to_pretty_json

    response.should be_a(Exa::SearchResponse)
  end
end
