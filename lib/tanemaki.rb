require 'tanemaki/version'
require 'csv'

module Tanemaki
  class << self
    def call(*args)
      ready(*args)
    end


    def ready(path, options = {})
      Seeder.(Parser.(path), {eval_scope: @eval_scope}.merge(options))
    end


    def default_eval_scope(eval_scope)
      self.default_eval_scope = eval_scope
    end


    def default_eval_scope=(eval_scope)
      @eval_scope = eval_scope
    end
  end


  class Parser
    class << self
      def call(*args)
        ready(*args)
      end


      def ready(path)
        header, *lines = CSV.read(path)
        nameless = []
        readiness = header.map.with_index do |name, index|
          if name
            name.to_sym
          else
            nameless.push(index)
            nil
          end
        end

        lines.map do |line|
          nameless_parameter = []
          line.each_with_index.each_with_object({}) do |(col, index), result|
            if nameless.include?(index)
              nameless_parameter.push(col) if col
            else
              result[readiness[index]] = col if col
            end
          end.merge(namelass_parameter_array: nameless_parameter)
        end
      end
    end
  end


  class Seeder
    def self.call(*args)
      new(*args)
    end


    def initialize(named_csv, options = {})
      @named_csv = named_csv
      @evaluate = options[:evaluatable] || []
      @eval_scope = options[:eval_scope]
      @klass = options[:klass]
      @method = options[:method] || :create
    end


    def evaluate(*column_names, eval_scope: nil)
      Seeder.(@named_csv, for_chain.merge(eval_scope: eval_scope || @eval_scope, evaluatable: column_names))
    end


    def named_csv
      @named_csv
    end


    def random(klass = nil, method_name = nil, &block)
      Seeder.(@named_csv.shuffle, for_chain).seed(klass, method_name, &block)
    end


    def seed(klass = nil, method = nil, &block)
      @named_csv.map do |row|
        readiness, nameless = begin
          result = evaluated(row.dup)
          [result, result.delete(:namelass_parameter_array)]
        end

        begin
          (klass || @klass).send((method || @method), *nameless, **readiness)
        rescue => e
          raise e unless block_given?

          block.(e, row)
          nil
        end
      end.compact
    end


    def select(*column_names)
      Seeder.(@named_csv.map do |row|
        column_names.each_with_object({}) do |name, new_row|
          new_row[name] = row[name]
        end
      end, for_chain)
    end


    private
    def evaluated(row)
      return row if @evaluate.size == 0

      row[:namelass_parameter_array].map!.with_index do |value, index|
        next value unless @evaluate.include?(index)

        do_eval(value)
      end

      row.each_pair.each_with_object({}) do |(key, value), result|
        next result[key] = value unless @evaluate.include?(key)

        result[key] = do_eval(value)
      end
    end


    def do_eval(value)
      return eval(value) unless @eval_scope

      @eval_scope.instance_eval do
        eval(value)
      end
    rescue
      value
    end


    def for_chain
      {
          evaluatable: @evaluate,
          eval_scope: @eval_scope,
          klass: @klass,
          method: @method
      }
    end
  end
end


class Object
  def tanemaki(path, options = {})
    Tanemaki.(path, options.merge(klass: self))
  end


  alias :tnmk :tanemaki
end
