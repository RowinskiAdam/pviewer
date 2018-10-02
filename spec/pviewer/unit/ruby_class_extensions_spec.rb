require 'spec_helper'

RSpec.describe Array do
  describe '#remove_every' do
    subject {[1, 2, 3, 4].remove_every(2, 0)}
    it {is_expected.to eq [1, 3]}
  end

  describe '#clip' do
    subject {[1, 2, 3, 4].clip}
    it {is_expected.to eq [1, 2, 3]}
  end
end

RSpec.describe Hash do
    describe '#deep_merge_pv!' do
      subject {{x: 1, y: {z1: 2}}.deep_merge_pv!(y: {z2: 3})}
      it {is_expected.to eq(x: 1, y: {z1: 2, z2: 3})}
    end

    describe '#except' do
      subject {{x: 1, y: 2, z: 3}.except(:y)}
      it {is_expected.to eq(x: 1, z: 3)}
    end

    describe '#compact' do
      subject {{x: nil, y: 2, z: nil}.compact}
      it {is_expected.to eq(y: 2)}
    end
end
