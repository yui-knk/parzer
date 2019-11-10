module Parzer
  class BisonWrapper
    # ["a", ";", "(", ")"]
    def initialize(chars)
      @chars = chars
      @_tokens = chars_to_index
      @_i = 0
    end

    def next_token
      r = @_tokens[@_i]
      @_i += 1
      r
    end

    private

    def token_map
      h = {}

      Parzer.tokens.each_with_index do |t, i|
        h[t] = i

        case
        when /\A"(.)"\z/ =~ t
          h[$1] = i
        when /\A'(.)'\z/ =~ t
          h[$1] = i
        end
      end

      h
    end

    def chars_to_index
      _token_map = token_map

      @chars.map do |c|
        _token_map[c] || (raise "#{c} is invalid, see #{_token_map.keys}")
      end + [0] # Add "$end" to end
    end
  end
end
