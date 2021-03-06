require 'spec_helper'
require 'entities/batch'
require 'entities/equipment'
require 'entities/formula'

describe Batch do
  include_context "steps"
  include_context "formula"
  let(:equipment) { [Equipment.new(name: :oven, step_name: :bake)] }
  let(:formula) { Formula.new(steps: @steps, total_flour_quantity: 1000, ingredients: [flour, water, salt, yeast]) }
  let(:time) { Time.new(2015, 3, 3, 19, 40) }
  let(:subject) { described_class.new(formula: formula, start_time: time) }
  before(:each) { allow(Time).to receive(:now) { time } }

  context '#update_step' do
    it 'updates the history and sets the current step' do
      subject.update_step(:shape)
      expect(subject.current_step_name).to eq(:shape)
      expect(subject.history.length).to eq 5
    end
  end

  context '#using_equipment' do
    it 'shows what equipment is in use' do
      subject.update_step(:bake)
      expect(subject.using_equipment).to eq equipment
    end
  end

  context '#equipment_used_at' do
    context 'baking in oven' do
      it 'shows what equipment will be in use' do
        expect(subject.equipment_used_at(time: Time.new(2015, 3, 4, 13, 1))).to eq equipment
      end
    end
    context 'not using any equipment' do
      it 'shows no equipment' do
        expect(subject.equipment_used_at(time: Time.new(2015, 3, 3, 20, 11))).to eq []
      end
    end
  end

  context '#finish_by' do
    it 'shows average finish time' do
      expect(subject.finish_by).to eq(Time.new(2015, 3, 4, 13, 9))
    end
  end

  context '#step_at' do
    context 'currently on step' do
      it 'gets the current step' do
        expect(subject.step_at(time: Time.new(2015, 3, 3, 19, 50))).to eq(:autolyze)
      end
    end
    context 'next step' do
      it 'gets the next step' do
        expect(subject.step_at(time: Time.new(2015, 3, 3, 20, 11))).to eq(:mix)
      end
    end
    context 'step after next' do
      it 'gets the projected step at given time' do
        expect(subject.step_at(time: Time.new(2015, 3, 3, 20, 16))).to eq(:fold)
      end
    end
    context 'last step' do
      it 'gets the last step' do
        expect(subject.step_at(time: Time.new(2015, 3, 4, 12, 20))).to eq(:bake)
      end
    end
    context 'after last step' do
      it 'returns :finished' do
        expect(subject.step_at(time: Time.new(2015, 3, 4, 13, 10))).to eq(:finished)
      end
    end
  end
end
