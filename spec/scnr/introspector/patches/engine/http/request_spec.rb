describe SCNR::Engine::HTTP::Request do
    subject { Factory[:request] }

    expect_it { to respond_to :trace }
    expect_it { to respond_to :trace= }

    describe '#with_trace' do
        it 'traces the block and assigns #coverage'
    end

    describe '#to_h' do
        it 'includes :trace' do
            subject.trace = 1
            expect(subject.to_h[:trace]).to eq 1
        end
    end
end
