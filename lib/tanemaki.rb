require 'tanemaki/version'
require 'csv'

module Tanemaki
  class << self
    def call(*args)
      ready(*args)
    end


    def ready(path)
      Seeder.(Parser.(path))
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


    def initialize(named_csv, scope = nil, *evalable)
      @named_csv = named_csv
      @evalable = *evalable || []
      @scope = scope
    end


    def evalablize(scope = nil, *column_names)
      Seeder.(@named_csv, scope, *column_names)
    end


    def named_csv
      @named_csv
    end


    def random(klass, method_name, &block)
      Seeder.(@named_csv.shuffle).seed(klass, method_name, &block)
    end


    def seed(klass, method_name, &block)
      @named_csv.map do |row|
        readiness = evaled(row)
        begin
          klass.send(method_name, **readiness)
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
      end)
    end


    private
    def evaled(row)
      return row if @evalable.size == 0

      row.each_pair.each_with_object({}) do |(k, v), result|
        next result[k] = v unless @evalable.include?(k)

        result[k] = begin
          return eval(v) unless @scope

          @scope.instance_eval do
            eval(v)
          end
        rescue
          v
        end
      end
    end
  end
end
