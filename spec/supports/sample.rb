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
    def initialize(*)
      super

      raise 'required' if !@name || !@gender || !@job || !@age
    end
  end

  class NamelessParam < Base
    attr_reader :forum, :year

    def initialize(forum, year, name: nil, gender: nil, job: nil, age: nil)
      @name = name
      @gender = gender
      @job = job
      @age = age
      @forum = forum
      @year = year
    end
  end
end