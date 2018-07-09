# Page Parser

## About

This application allows for quick extraction of headers and links from any webpage.

## Requirements

- Ruby 2.5.1
- PostgreSQL

## Installation

```
bundle install
bundle exec rake db:create db:migrate
```

## API

Exposed API is [JSON API](http://jsonapi.org)-compatible. Only one resource is provided at this time: Page. Following
attributes are available:

- `url` (string) - URL of page that will get parsed.
- `h1` (array of string) - Content of every H1 on parsed page.
- `h2` (array of string) - Content of every H2 on parsed page.
- `h3` (array of string) - Content of every H3 on parsed page.
- `links` (array of string) - URL of every link on parsed page.
- `parsed` (boolean) - Status of parsing. True if parsed successfully, false if not yet parsed or if last parse returned error.
- `error` (string) - Error of last unsuccessful parse, HTTP Status Code compatible (i.e. `404 Not Found`).

Following endpoints are available:

### `POST /pages` - sending new Page for processing

Accepted attributes:

- `url` - URL of page to parse

After saving page it will get processed asynchronously, so another request to resource page will be required.

### `GET /pages` - list of all Pages

Accepted features from JSON API spec: sorting (by id), pagination (using offset).

### `GET /pages/:id` - get single Page

## Performance optimisation

For the sake of minimal amount of external dependencies required to run this project some performance decisions were
made. Here you can find rationale about each one of them, and how to improve performance or prepare for scaling.

### Response Cache

By default Rails are using in-memory cache. The same method was used for JSON API responses cache. This is obviously
suboptimal in longer run, but definitely is enough for small-scale deployments. When time for better cache comes
simply follow [Rails cache configuration guide](http://guides.rubyonrails.org/caching_with_rails.html#cache-stores)
and JSON API will pick up the same cache (it was already preconfigured to do so). The same method can be used to set
`null_store` to reduce memory footprint by disabling cache completely.

### Job Workers scaling

Parsing of pages is done using ActiveJob, for now with default backend (which is Async). Fetching and parsing of page
is done after request returns, so client is not waiting for it to finish, but it's still not most optimal. This process
is mostly IO-bound, so it scales pretty good with modern servers like Puma, but use of external worker is advised in
production environment. In order to do so simply [configure ActiveJob using other adapter](http://guides.rubyonrails.org/active_job_basics.html), and all jobs will pick it up.

## License

(The MIT License)

Copyright © 2018 Bernard Potocki

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
