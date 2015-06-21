require 'spec_helper'
require 'supports/sample'

describe Tanemaki do
  it 'has a version number' do
    expect(Tanemaki::VERSION).not_to be nil
  end

  shared_examples_for 'seed' do
    it { expect(result).to be_a(Array) }
    it { expect(result.size).to eq(7) }

    it 'all result are instance' do
      result.each do |seeded|
        expect(seeded).to be_a(Sample::Normal)
      end
    end

    context 'when raise exception' do
      it 'no block, raise exception' do
        expect { seeder.seed(Sample::AllRequired, :new) }.to raise_exception
      end

      it 'block given, rescue exception' do
        result = seeder.seed(Sample::AllRequired, :new) do |e, row|
          expect(e).to be_a(Exception)
          expect(row.has_value?(:job)).to be_falsey
        end

        expect(result.size).to eq(5)
      end
    end
  end

  describe do
    let(:seeder) { Tanemaki.("#{__dir__}/fixtures/seed.csv") }

    context 'ready' do
      it { expect(seeder).to be_a(Tanemaki::Seeder) }
      it { expect(seeder.named_csv).to be_a(Array) }
      it { expect(seeder.named_csv.size).to eq(7) }
    end


    context 'seed' do
      let(:result) { seeder.seed(Sample::Normal, :new) }

      include_examples 'seed'
    end

    context 'random' do
      let(:result) { seeder.random(Sample::Normal, :new) }

      include_examples 'seed'
    end

    context 'evaluate column' do
      context 'using scope' do
        let(:result) { seeder.evaluate(:age, eval_scope: self).seed(Sample::Normal, :new) }
        let(:array) { [0, 1, 2, 3, 4] }

        include_examples 'seed'

        it { expect(result.first.age).to eq(3) }
        it { expect(result.last.age).to be_a(Fixnum) }
      end

      context 'using default scope' do
        let(:result) do
          Tanemaki.default_eval_scope(self)
          seeder.evaluate(:age).seed(Sample::Normal, :new)
        end
        let(:array) { [0, 1, 2, 3, 4] }

        include_examples 'seed'

        it { expect(result.first.age).to eq(3) }
        it { expect(result.last.age).to be_a(Fixnum) }
      end

      context 'using default scope =' do
        let(:result) do
          Tanemaki.default_eval_scope = self
          seeder.evaluate(:age).seed(Sample::Normal, :new)
        end
        let(:array) { [0, 1, 2, 3, 4] }

        include_examples 'seed'

        it { expect(result.first.age).to eq(3) }
        it { expect(result.last.age).to be_a(Fixnum) }
      end
    end

    context 'select' do
      it 'over arguments raise exception' do
        expect { seeder.seed(Sample::OnlyName, :new) }.to raise_exception
      end

      it 'select only required, not raise exception' do
        expect { seeder.select(:name).seed(Sample::OnlyName, :new) }.not_to raise_exception
      end
    end

    context 'enchant class method' do
      context do
        let(:seeder) { Sample::Normal.tanemaki("#{__dir__}/fixtures/seed.csv", method: :new) }
        let(:result) { seeder.seed }

        include_examples 'seed'
      end

      context 'chain (send local valuables)' do
        let(:seeder) { Sample::Normal.tanemaki("#{__dir__}/fixtures/seed.csv", method: :new) }

        context do
          let(:result) { seeder.evaluate(:age, eval_scope: self).seed }

          include_examples 'seed'
        end

        context do
          let(:result) { seeder.select(:name, :age).seed }

          include_examples 'seed'
        end

        context do
          let(:result) { seeder.random }

          include_examples 'seed'
        end
      end
    end
  end

  describe 'with nameless parameters' do
    let(:seeder) { Tanemaki.("#{__dir__}/fixtures/nameless_seed.csv") }

    context 'seed' do
      let(:result) { seeder.seed(Sample::NamelessParam, :new) }

      it 'all result are instance' do
        result.each do |seeded|
          expect(seeded).to be_a(Sample::NamelessParam)
        end
      end
    end

    context 'evaluate' do

      let(:result) { seeder.select(:name).evaluate(0).seed(Sample::NamelessParam, :new) }

      it 'all result are instance' do
        result.each do |seeded|
          expect(seeded.forum).to be_a(Symbol)
        end
      end
    end
  end
end
