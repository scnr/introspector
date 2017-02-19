describe SCNR::Engine::Report do
    subject { Factory[:report] }

    expect_it { to respond_to :coverage }
    expect_it { to respond_to :coverage= }

    describe '#to_rpc_data' do
        it "includes 'coverage'" do
            subject.coverage = 1
            expect(subject.to_rpc_data['coverage']).to eq 1
        end
    end

    describe '.from_rpc_data' do
        it "restores 'coverage'"
    end
end
