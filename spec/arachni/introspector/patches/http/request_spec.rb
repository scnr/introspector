describe Arachni::HTTP::Request do
    subject { }

    expect_it { to respond_to :coverage }
    expect_it { to respond_to :coverage= }

    describe '#trace' do
        it 'traces the block and assigns #coverage'
    end

    describe '#to_h' do
        it 'includes :coverage'
    end
end
