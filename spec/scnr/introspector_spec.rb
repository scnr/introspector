describe SCNR::Introspector do
    subject { described_class }
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
        described_class.application = application

        described_class.clear_os_cache
        @host_os = RbConfig::CONFIG['host_os']
    end

    after do
        RbConfig::CONFIG['host_os'] = @host_os

        if @scan
            @scan.thread.join if @scan.thread
            @scan.clean_up
        end

        SCNR::Engine::Framework.reset
        described_class::Scan.reset_options
        described_class.application = @scan = nil
    end

    expect_it { to respond_to :application }
    expect_it { to respond_to :application= }

    describe '.target_application' do
        context 'when .application has been set' do
            it 'returns it' do
                described_class.application = 1

                expect(described_class.target_application).to be 1
            end
        end

        context 'when .application has not been set' do
            it 'returns .detect_application' do
                described_class.application = nil

                allow(described_class).to receive(:detect_application) { :app }

                expect(described_class.target_application).to be :app
            end
        end
    end

    describe '.detect_application' do
        context 'Rails' do
            it 'automatically detects the application'
        end

        context 'Sinatra' do
            it 'automatically detects the application'
        end
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
                it "fails with #{SCNR::Engine::Platform::Error::Invalid}" do
                    RbConfig::CONFIG['host_os'] = 'blah'

                    expect { described_class.os }.to raise_error SCNR::Engine::Platform::Error::Invalid
                end
            end
        end
    end

    describe '.scan' do
        let(:options) do
            {
                scanner: {
                    checks: 'xss',
                    audit: {
                        elements: [:links]
                    },
                    browser_cluster: {
                        pool_size: 0
                    }
                }
            }
        end

        it 'starts a scan' do
            @scan = subject.scan( options )

            expect(@scan.status).to be :done
            expect(@scan.report.issues).to be_any
        end

        context 'when a block is given' do
            it 'cleans up the environment after it calls it' do
                subject.scan( options ) do |scan|
                    expect(scan).to receive(:clean_up)
                end
            end

            it 'calls it after the scan completes' do
                subject.scan( options ) do |scan|
                    expect(scan).to be_done
                end
            end

            it 'passes the scan to it' do
                subject.scan( options ) do |scan|
                    expect(scan).to be_kind_of described_class::Scan
                end
            end

            it 'returns the block return value' do
                expect(subject.scan( options ) { :stuff }).to be :stuff
            end
        end
    end

    describe '.scan_in_thread' do
        let(:options) do
            {
                scanner: {
                    checks: 'xss',
                    audit: {
                        elements: [:links]
                    },
                    browser_cluster: {
                        pool_size: 0
                    }
                }
            }
        end

        it 'starts the scan in a thread' do
            @scan = subject.scan_in_thread( options )
            @scan.thread.join
            expect(@scan).to be_done
        end

        context 'when a block has been given' do
            it 'is called once the scan finishes' do
                subject.scan_in_thread( options ) do |scan|
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
                scanner: {
                    checks: 'xss',
                    audit: {
                        elements: [:links]
                    },
                    browser_cluster: {
                        pool_size: 0
                    }
                }
            }
        end

        it 'performs a scan and returns the report' do
            report = described_class.scan_and_report( options )
            expect(report.issues).to be_any
        end

        it 'cleans up the environment' do
            expect_any_instance_of(described_class::Scan).to receive(:clean_up)

            described_class.scan_and_report( options )
        end
    end

    describe '.recheck_issue' do
        let(:issue) do
            described_class.scan_and_report( options ).issues.first
        end

        context 'when the issue still exists' do
            it 'returns the reproduced issue' do
                expect(subject.recheck_issue( issue, options )).to eq issue
            end
        end

        context 'when the issue does not still exist' do
            it 'returns nil' do
                i = issue

                described_class.application = EmptyApp
                expect(subject.recheck_issue( i, options )).to be_nil
            end
        end
    end

end
