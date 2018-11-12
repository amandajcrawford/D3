require 'sinatra'
require 'sinatra/reloader'


# The true and false symbol that will be entered and truth table size

class String
    def numeric?
      Float(self) != nil rescue false
    end
end

class Truth_Table
    attr_reader :size, :f_symbol, :t_symbol, :table, :r_size

    def initialize tf_size, truth_symbol, false_symbol
        @size = tf_size
        @r_size =  2**tf_size
        @t_symbol = truth_symbol
        @f_symbol = false_symbol  
        @table = nil
        generate_truth_table 
    end

    # Generate truth table matrix 
    def generate_truth_table
        @table = Array.new(@size)
        row = Array.new(@r_size, @f_symbol)
        true_state = false # 0 = false_symbol, 1 = truth symbol

        # Generate t/f placement values in table 
        @size.downto(1) do |i|
            row = Array.new(@r_size, @f_symbol)   
            rot_val = (2 ** i) / 2
            
            # Format with t/f values using log
            @r_size.times do |j|
                if true_state
                    row[j] = t_symbol
                end

                if (j + 1) % rot_val == 0
                    true_state = !true_state
                end
            end

            # Calculate row index 
            t_idx = size - i
            # Add row to table
            @table[t_idx] = row
            true_state = false 
        end
        @table = @table.transpose
    end

    def and 
        and_column = Array.new(@r_size, f_symbol)
        # And each column in the table 
        @table.each.with_index do |row, idx|
            val = row.each_cons(2).all? { |a,b| a == b } && row.any? {|a| a == @t_symbol}
            if val
                and_column[idx] = @t_symbol
            end
        end 
        and_column
    end 

    def or
        or_column = Array.new(@r_size, f_symbol)
        # And each column in the table 
        @table.each.with_index do |row, idx|
            val = row.any? {|a| a == @t_symbol}
            if val
                or_column[idx] = @t_symbol
            end
        end
        or_column 
    end 

    def xor
        xor_column = Array.new(@r_size, f_symbol)
        # And each column in the table 
        @table.each.with_index do |row, idx|
            val = row.count {|a| a == @t_symbol}
            if val == 1
                xor_column[idx] = @t_symbol
            end
        end 
        xor_column
    end 
end 

get '/' do

    cheat = false
    submitted = false
    valid = true
    size = 3
    t_symbol = 'T'
    f_symbol = 'F'
    table = Truth_Table.new(size, t_symbol, f_symbol)
    
    ps = params['size']
    pts = params['t_symbol']
    pfs = params['f_symbol']
    pss = params['submitted']

    if !ps.nil? && valid && ps != ''
        valid = (ps.to_i > 2) 
        size = valid ? ps.to_i : size
    end

    if !pts.nil? && valid && pts != ''
        valid = (!pts.numeric? && pts.length === 1)
        t_symbol = valid ? pts : t_symbol
    end 

    if !pfs.nil? && valid && pfs != ''
        valid = (!pfs.numeric? && pfs.length === 1 && pfs != t_symbol)
        f_symbol = valid ? pfs : f_symbol  
    end

    if !pss.nil?
        submitted = true
    end

    if submitted && valid
        table = Truth_Table.new(size, t_symbol, f_symbol)
    end

    erb :main, :locals => { cheat: cheat, size: size, t_symbol: t_symbol, f_symbol: f_symbol, valid: valid, submitted: submitted, table: table }
end

not_found do
    status 404
    erb :error
  end