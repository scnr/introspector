describe Arachni::Introspector do
    subject { described_class }
    let(:options) {
        {
            framework: {
                checks: ['*'],
                audit:  {
                    elements: [:links]
                }
            }
        }
    }
    let(:application) { XssApp }

    before do
        # No need for browsers in these tests...
        Arachni::Options.browser_cluster.pool_size = 0

        described_class.clear_os_cache
        @host_os = RbConfig::CONFIG['host_os']
    end

    after do
        RbConfig::CONFIG['host_os'] = @host_os

        if @scan
            @scan.thread.join if @scan.thread
            @scan.clean_up
        end

        Arachni::Framework.reset
        Arachni::Options.reset
        @scan = nil
    end

    describe '.os' do
        context "when RbConfig::CONFIG['host_os']' contains" do
            %w(msys mingw cygwin bccwin wince emc).each do |string|
                context string do
                    it 'returns :windows' do
                        RbConfig::CONFIG['host_os'] = "blah #{string} blah"
                        expect(described_class.os).to be :windows
                    end
                end
            end

            context 'linux' do
                it 'returns :linux' do
                    RbConfig::CONFIG['host_os'] = 'blah linux blah'
                    expect(described_class.os).to be :linux
                end
            end

            ['darwin,' 'mac os', 'bsd'].each do |string|
                context string do
                    it 'returns :bsd' do
                        RbConfig::CONFIG['host_os'] = "blah #{string} blah"

                        expect(described_class.os).to be :bsd
                    end
                end
            end

            context 'solaris' do
                it 'returns :solaris' do
                    RbConfig::CONFIG['host_os'] = 'blah solaris blah'

                    expect(described_class.os).to be :solaris
                end
            end

            context 'other' do
                it "fails with #{Arachni::Platform::Error::Invalid}" do
                    RbConfig::CONFIG['host_os'] = 'blah'

                    expect { described_class.os }.to raise_error Arachni::Platform::Error::Invalid
                end
            end
        end
    end

    describe '.scan' do
        let(:options) do
            {
                framework: {
                    checks: 'xss',
                    audit: {
                        elements: [:links]
                    }
                }
            }
        end

        it 'starts a scan' do
            @scan = subject.scan( application, options )

            expect(@scan.status).to be :done
            expect(@scan.report.issues).to be_any
        end

        context 'when a block is given' do
            it 'cleans up the environment after it calls it' do
                subject.scan( application, options ) do |scan|
                    expect(scan).to receive(:clean_up)
                end
            end

            it 'calls it after the scan completes' do
                subject.scan( application, options ) do |scan|
                    expect(scan).to be_done
                end
            end

            it 'passes the scan to it' do
                subject.scan( application, options ) do |scan|
                    expect(scan).to be_kind_of described_class::Scan
                end
            end

            it 'returns the block return value' do
                expect(subject.scan( application, options ) { :stuff }).to be :stuff
            end
        end
    end

    describe '.scan_in_thread' do
        let(:options) do
            {
                framework: {
                    checks: 'xss',
                    audit: {
                        elements: [:links]
                    }
                }
            }
        end

        it 'starts the scan in a thread' do
            @scan = subject.scan_in_thread( application, options )
            @scan.thread.join
            expect(@scan).to be_done
        end

        context 'when a block has been given' do
            it 'is called once the scan finishes' do
                subject.scan_in_thread( application, options ) do |scan|
                    @scan = scan
                    expect(@scan).to be_kind_of described_class::Scan
                    expect(@scan).to be_done
                end
            end
        end
    end

    describe '.scan_and_report' do
        let(:options) do
            {
                framework: {
                    checks: 'xss',
                    audit: {
                        elements: [:links]
                    }
                }
            }
        end

        it 'performs a scan and returns the report' do
            report = described_class.scan_and_report( application, options )
            expect(report.issues).to be_any
        end

        it 'cleans up the environment' do
            expect_any_instance_of(described_class::Scan).to receive(:clean_up)

            described_class.scan_and_report( application, options )
        end
    end

    describe '.recheck_issue' do
        let(:issue) do
            described_class.scan_and_report( application, options ).issues.first.variations.first
        end

        context 'when the issue still exists' do
            it 'returns the reproduced issue' do
                expect(subject.recheck_issue( application, issue, options )).to eq issue
            end
        end

        context 'when the issue does not still exist' do
            it 'returns nil' do
                expect(subject.recheck_issue( EmptyApp, issue, options )).to be_nil
            end
        end
    end

end
