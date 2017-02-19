describe SCNR::Engine::Issue do
    let(:options) {
        {
            scanner: {
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
        SCNR::Introspector.application = application
    end

    after do
        SCNR::Engine::Framework.reset
        SCNR::Introspector::Scan.reset_options
        SCNR::Introspector.application = @scan = nil
    end

    describe '.with_trace' do
        let(:issue) do
            SCNR::Introspector.scan_and_report(options ).issues.first
        end

        context 'when the issue still exists' do
            it 'returns the reproduced issue with traced requests' do
                traced = issue.with_trace

                expect(traced).to eq issue
                expect(traced.request.trace.points).to be_any
            end
        end

        context 'when the issue does not still exist' do
            it 'returns nil' do
                i = issue

                SCNR::Introspector.application = EmptyApp
                expect(i.with_trace).to be_nil
            end
        end
    end

end
