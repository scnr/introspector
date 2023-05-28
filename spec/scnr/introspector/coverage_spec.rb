describe SCNR::Introspector::Coverage do
    subject { described_class.new scope: scope }

    let(:scope) do
        described_class::Scope.new
    end
    let(:target_path) do
        Target.new.method(:stuff).source_location.first
    end

    it 'supports Marshal serialization' do
        new_subject = Marshal.load( Marshal.dump( subject ) )

        expect(new_subject).to eq subject
    end

    describe '#retrieve_results' do
        it 'updates #resources with coverage results'
    end

    describe '#import_native' do
        it "updates #resources from #{Coverage}.results"
    end

    describe '#percentage' do
        it 'returns the coverage percentage'
    end
end
