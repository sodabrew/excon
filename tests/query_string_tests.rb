Shindo.tests('Excon query string variants') do
  with_rackup('query_string.ru') do
    connection = Excon.new('http://127.0.0.1:9292')

    tests(":query => {:foo => 'bar'}") do
      response = connection.request(:method => :get, :path => '/query', :query => {:foo => 'bar'})
      query_string = response.body[7..-1] # query string sent

      tests("query string sent").returns('foo=bar') do
        query_string
      end
    end

    tests(":query => {:foo => nil}") do
      response = connection.request(:method => :get, :path => '/query', :query => {:foo => nil})
      query_string = response.body[7..-1] # query string sent

      tests("query string sent").returns('foo') do
        query_string
      end
    end

    tests(":query => {:foo => 'bar', :me => nil}") do
      response = connection.request(:method => :get, :path => '/query', :query => {:foo => 'bar', :me => nil})
      query_string = response.body[7..-1] # query string sent

      test("query string sent includes 'foo=bar'") do
        query_string.split('&').include?('foo=bar')
      end

      test("query string sent includes 'me'") do
        query_string.split('&').include?('me')
      end
    end

    tests(":query => {:foo => 'bar', :me => 'too'}") do
      response = connection.request(:method => :get, :path => '/query', :query => {:foo => 'bar', :me => 'too'})
      query_string = response.body[7..-1] # query string sent

      test("query string sent includes 'foo=bar'") do
        query_string.split('&').include?('foo=bar')
      end

      test("query string sent includes 'me=too'") do
        query_string.split('&').include?('me=too')
      end
    end

    # To emulate the Rails and PHP style of serializing an array, use { 'foo[]' => [ array elements ] }
    tests(":query => {:foo => ['bar', 'baz'], :me => 'too'}") do
      response = connection.request(:method => :get, :path => '/query', :query => {:foo => ['bar', 'baz'], :me => 'too'})
      query_string = response.body[7..-1] # query string sent

      test("query string sent includes 'foo=bar'") do
        query_string.split('&').include?('foo=bar')
      end

      test("query string sent includes 'foo=baz'") do
        query_string.split('&').include?('foo=baz')
      end

      test("query string sent includes 'me=too'") do
        query_string.split('&').include?('me=too')
      end
    end

    # Hash elements in the query hash get serialized by Ruby and then urlencoded
    # TODO support for serializing hash elements in a reasonble way?
    tests(":query => {:foo => {:bar => 'baz'}, :me => 'too'}") do
      response = connection.request(:method => :get, :path => '/query', :query => {:foo => {:bar => 'baz'}, :me => 'too'})
      query_string = response.body[7..-1] # query string sent

      test("query string turns a Hash into an urlencoded mess") do
        query_string.split('&').include?('foo=%7B%3Abar%3D%3E%22baz%22%7D')
      end

      test("query string sent includes 'me=too'") do
        query_string.split('&').include?('me=too')
      end
    end

  end
end
