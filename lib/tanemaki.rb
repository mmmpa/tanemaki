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
        header.map!(&:to_sym)
        lines.map do |line|
          line.each_with_index.each_with_object({}) do |(col, index), result|
            result[header[index]] = col if col
          end
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
        readiness = evaluated(row)
        begin
          (klass || @klass).send((method || @method), **readiness)
        rescue => e
          raise e unless block_given?

          block.(row, e)
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

      row.each_pair.each_with_object({}) do |(k, v), result|
        next result[k] = v unless @evaluate.include?(k)

        result[k] = begin
          return eval(v) unless @eval_scope

          @eval_scope.instance_eval do
            eval(v)
          end
        rescue
          v
        end
      end
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
