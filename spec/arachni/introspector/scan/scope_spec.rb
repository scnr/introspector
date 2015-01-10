describe Arachni::Introspector::Scan::Coverage::Scope do
    subject { described_class.new options }
    let(:options) {{}}

    describe '#empty?' do
        context 'when the scope has not been configured' do
            it 'returns true' do
                expect(subject).to be_empty
            end
        end

        context 'when the scope has been configured with' do
            context '#path_start_with' do
                it 'returns false' do
                    subject.path_start_with = 's'
                    expect(subject).to_not be_empty
                end
            end

            context '#path_end_with' do
                it 'returns false' do
                    subject.path_end_with = 's'
                    expect(subject).to_not be_empty
                end
            end

            context '#path_include_patterns' do
                it 'returns false' do
                    subject.path_include_patterns = [/stuff/]
                    expect(subject).to_not be_empty
                end
            end

            context '#path_exclude_patterns' do
                it 'returns false' do
                    subject.path_exclude_patterns = [/stuff/]
                    expect(subject).to_not be_empty
                end
            end
        end
    end

    describe '#out?' do
        context 'when #in?' do
            context 'returns true' do
                it 'returns false' do
                    allow(subject).to receive(:in?) { true }
                    expect(subject.out?( 'path' )).to be_falsey
                end
            end
            context 'returns false' do
                it 'returns true' do
                    allow(subject).to receive(:in?) { false }
                    expect(subject.out?( 'path' )).to be_truthy
                end
            end
        end
    end

    describe '#in?' do
        context '#path_start_with' do
            before do
                subject.path_start_with = '/start/with/this'
            end

            context 'matches the start of the path' do
                let(:path) { "#{subject.path_start_with}/stuff/" }

                it 'returns true' do
                    expect(subject.in?( path )).to be_truthy
                end
            end
            context 'does not match the start of the path' do
                let(:path) { "/stuff/#{subject.path_start_with}" }

                it 'returns false' do
                    expect(subject.in?( path )).to be_falsey
                end
            end
        end

        context '#path_end_with' do
            before do
                subject.path_end_with = '/end/with/this'
            end

            context 'matches the end of the path' do
                let(:path) { "/stuff/#{subject.path_end_with}" }

                it 'returns true' do
                    expect(subject.in?( path )).to be_truthy
                end
            end
            context 'does not match the end of the path' do
                let(:path) { "#{subject.path_end_with}/stuff/" }

                it 'returns false' do
                    expect(subject.in?( path )).to be_falsey
                end
            end
        end

        context '#path_include_patterns' do
            before do
                subject.path_include_patterns = [
                    /include-this/,
                    /include-me-too/
                ]
            end

            context 'any match the path' do
                it 'returns true' do
                    expect(subject.in?( '/blah/include-this/stuff/' )).to be_truthy
                    expect(subject.in?( '/blah/include-me-too/stuff/' )).to be_truthy
                end
            end

            context 'none match the path' do
                let(:path) { '/blah/stuff/' }

                it 'returns false' do
                    expect(subject.in?( path )).to be_falsey
                end
            end
        end

        context '#path_exclude_patterns' do
            before do
                subject.path_exclude_patterns = [
                    /exclude-this/,
                    /exclude-me-too/
                ]
            end

            context 'any match the path' do
                it 'returns false' do
                    expect(subject.in?( '/blah/exclude-this/stuff/' )).to be_falsey

                    expect(subject.in?( '/blah/exclude-me-too/stuff/' )).to be_falsey
                end
            end

            context 'none match the path' do
                it 'returns true' do
                    expect(subject.in?( '/blah/stuff/' )).to be_truthy
                end
            end
        end
    end

end
