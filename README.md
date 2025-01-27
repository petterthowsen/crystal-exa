# exa

API Client library for [Exa](https://exa.ai/), the neural search engine.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     exa:
       github: petterthowsen/exa
   ```

2. Run `shards install`

## Usage

```crystal
require "exa"

exa = Exa::Client.new(api_key: "...")
search = Exa::SearchRequest.new(query: "blog posts about AGI", num_results: 5)
response = exa.search(search)

```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/petterthowsen/exa/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Petter Thowsen](https://github.com/petterthowsen) - creator and maintainer
