describe Arachni::HTTP::Request do
    subject { Factory[:request] }

    expect_it { to respond_to :coverage }
    expect_it { to respond_to :coverage= }

    describe '#trace' do
        it 'traces the block and assigns #coverage'
    end

    describe '#to_h' do
        it 'includes :coverage' do
            subject.coverage = 1
            expect(subject.to_h[:coverage]).to eq 1
        end
    end
end
