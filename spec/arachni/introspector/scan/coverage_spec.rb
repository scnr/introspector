describe Arachni::Introspector::Scan::Coverage do
    subject { described_class.new scope: scope }

    let(:scope) do
        described_class::Scope.new
    end
    let(:target_path) do
        Target.new.method(:stuff).source_location.first
    end

    it 'supports Marshal serialization' do
        subject.scope = described_class::Scope.new( path_start_with: target_path )
        new_subject   = Marshal.load( Marshal.dump( subject ) )

        expect(new_subject).to eq subject
    end

    describe '#initialize' do
        context 'when :scope is' do
            context "#{described_class::Scope}" do
                it 'sets it' do
                    scope = described_class::Scope.new
                    expect(described_class.new( scope: scope ).scope).to be scope
                end
            end

            context 'Hash' do
                it "creates a #{described_class::Scope} from it" do
                    path_start_with = '/stuff/blah'

                    expect(described_class.new( scope: {
                        path_start_with: path_start_with
                    }).scope.path_start_with).to eq path_start_with
                end
            end

            context 'nil' do
                it "creates an empty #{described_class::Scope}" do
                    expect(described_class.new.scope).to be_empty
                end
            end

            context 'other' do
                it "raises #{described_class::Scope::Error::Invalid}" do
                    expect {
                        described_class.new( scope: '' )
                    }.to raise_error described_class::Scope::Error::Invalid
                end
            end
        end
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
