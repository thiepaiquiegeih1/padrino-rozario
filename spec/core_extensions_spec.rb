RSpec.describe 'Numeric extensions' do
  context '#clamp' do
    it 'clamps values correctly' do
      expect(5.clamp(0, 10)).to eq(5)
      expect(15.clamp(0, 10)).to eq(10)
      expect(-5.clamp(0, 10)).to eq(0)
    end
  end
end
