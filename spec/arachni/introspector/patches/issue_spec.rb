describe Arachni::Issue do
    let(:options) {
        {
            framework: {
                checks: ['*'],
                audit:  {
                    elements: [:links]
                },
                browser_cluster: {
                    pool_size: 0
                }
            }
        }
    }
    let(:application) { XssApp }

    before do
        Arachni::Introspector.application = application
    end

    after do
        Arachni::Framework.reset
        Arachni::Introspector::Scan.reset_options
        Arachni::Introspector.application = @scan = nil
    end

    describe '.with_trace' do
        let(:issue) do
            Arachni::Introspector.scan_and_report( options ).issues.
                first.variations.first
        end

        context 'when the issue still exists' do
            it 'returns the reproduced issue with traced requests' do
                traced = issue.with_trace

                expect(traced).to eq issue
                expect(traced.variations.first.request.trace.points).to be_any
            end
        end

        context 'when the issue does not still exist' do
            it 'returns nil' do
                i = issue

                Arachni::Introspector.application = EmptyApp
                expect(i.with_trace).to be_nil
            end
        end
    end

end
