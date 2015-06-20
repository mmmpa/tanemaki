module Sample
  class Base
    attr_reader :name, :gender, :job, :age


    def initialize(name: nil, gender: nil, job: nil, age: nil)
      @name = name
      @gender = gender
      @job = job
      @age = age
    end
  end

  class Normal < Base

  end

  class OnlyName < Base
    def initialize(name: nil)
      super
    end
  end

  class AllRequired < Base
    def initialize(name:, gender:, job:, age:)
      super
    end
  end
end