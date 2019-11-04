require "parzer/lalr_one"
require "parzer/lr_one"
require "parzer/lr_zero"
require "parzer/parzer"
require "parzer/version"

module Parzer
  class << self
    def tokens
      yytname[0...yyntokens]
    end

    def ntokens
      yytname[yyntokens..-1]
    end

    def nsymbols
      yyntokens + yynnts
    end

    def table
      results = []

      (0...yynstates).each do |state_i|
        r = []
        results << r

        # we should check the state expects for each symbol
        (0...nsymbols).each do |symbol_i|
          if symbol_i < yyntokens
            # action table
            pact = yypact[state_i]

            if pact == yypact_ninf
              # goto yydefault;
              add_yydefact(r, state_i)
              next
            end

            yyn = pact + symbol_i

            if (yyn < 0 || yylast < yyn || yycheck[yyn] != symbol_i)
              # goto yydefault;
              add_yydefact(r, state_i)
              next
            end

            # use yytable
            yyn = yytable[yyn]

            if (yyn <= 0)
              # Reduce
              # goto yyreduce;
              r << :"r#{-yyn}"
            else
              # Shift
              r << :"s#{yyn}"
            end

            next
          else
            # GOTO table
            yylhs = symbol_i - yyntokens
            yyi = yypgoto[yylhs] + state_i

            if (0 <= yyi && yyi <= yylast && yycheck[yyi] == state_i)
              r << :"#{yytable[yyi]}"
            else
              r << :"#{yydefgoto[yylhs]}"
            end

            next
          end
        end
      end

      results
    end

    # See: yydefault label
    def add_yydefact(result_row, state_i)
      defact = yydefact[state_i]

      if defact == 0 # 0 means error
        result_row << nil
      else
        result_row << :"r#{defact}"
      end
    end

    def token_map
      h = {}

      tokens.each_with_index do |t, i|
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

    def chars_to_index(chars)
      _token_map = token_map

      chars.map do |c|
        _token_map[c] || (raise "#{c} is invalid, see #{_token_map.keys}")
      end + [0] # Add "$end" to end
    end

    def next_token
      @_tokens ||= chars_to_index(["a", ";", "(", ")"])
      @_i ||= 0
      @_tokens

      r = @_tokens[@_i]
      @_i += 1
      r
    end
  end
end
