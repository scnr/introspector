describe SCNR::Introspector::Scan do
    subject { @subject = described_class.new( application, options ) }
    let(:options) {
        {
            scanner: {
                checks: ['*'],
                audit:  {
                    elements: [:links]
                },
                dom: {
                    pool_size: 0
                }
            }
        }
    }
    let(:application) { XssApp }

    after :each do
        if @subject
            @subject.thread.join if @subject.thread
            @subject.clean_up
        end

        SCNR::Engine::Framework.unsafe.reset
        described_class.reset_options
        @subject = nil
    end

    describe '#initialize' do
        it 'sets #application' do
            expect(subject.application).to be XssApp
        end

        it 'disables platform fingerprinting' do
            subject
            expect(SCNR::Engine::Options.fingerprint?).to be_falsey
        end

        it 'sets default platforms' do
            subject
            expect(SCNR::Engine::Options.platforms).to include :ruby
            expect(SCNR::Engine::Options.platforms).to include :rack
            expect(SCNR::Engine::Options.platforms).to include SCNR::Introspector.os
        end

        context 'when the application is using' do
            context 'ActiveRecord' do
                it 'detects and sets the DB platform'
            end

            context 'DataMapper' do
                it 'detects and sets the DB platform'
            end

            context 'Mongoid' do
                it 'detects and sets the DB platform'
            end

            context 'MongoMapper' do
                it 'detects and sets the DB platform'
            end
        end

        describe 'options' do
            let(:options) do
                {
                    scanner:         {
                        checks: 'xss'
                    },
                    dom: {
                        pool_size: 0
                    }
                }
            end

            it "sets #{SCNR::Engine::Options}" do
                expect(SCNR::Engine::Options).to receive(:update).with(options[:scanner])
                @subject = described_class.new( application, options )
            end

            describe ':host' do
                let(:options) do
                    {
                        host: 'stuff'
                    }
                end

                it 'sets the hostname' do
                    subject
                    expect(SCNR::Engine::Options.url).to eq "http://#{options[:host]}/"
                end

                context 'when not given' do
                    let(:options) do
                        {}
                    end
                    let(:application) { described_class }

                    it 'uses the application name' do
                      subject
                        expect(SCNR::Engine::Options.url).to eq 'http://scnr-introspector-scan/'
                    end
                end
            end

            describe ':port' do
                let(:options) do
                    {
                        host: 'stuff',
                        port: 99
                    }
                end

                it 'sets the port' do
                    subject
                    expect(SCNR::Engine::Options.url).to eq "http://#{options[:host]}:#{options[:port]}/"
                end

                context 'when not given' do
                    let(:options) do
                        {}
                    end

                    it 'uses 80' do
                        subject
                        expect(SCNR::Engine::Options.url).to eq 'http://xssapp/'
                    end
                end
            end

            describe ':path' do
                let(:options) do
                    {
                        host: 'stuff',
                        path: 'test/this/?stuff=true'
                    }
                end

                it 'sets the path' do
                    subject
                    expect(SCNR::Engine::Options.url).to eq "http://#{options[:host]}/#{options[:path]}"
                end

                context 'when not given' do
                    let(:options) do
                        {}
                    end

                    it 'uses /' do
                        subject
                        expect(SCNR::Engine::Options.url).to eq 'http://xssapp/'
                    end
                end
            end

            describe ':checks' do
                let(:options) do
                    {
                        scanner: {
                            checks: 'xss'
                        }
                    }
                end

                it 'sets the checks' do
                    expect(subject.scanner.checks.keys).to eq [options[:scanner][:checks]]
                end
            end
        end
    end

    describe '#start' do
        context 'when idle' do
            let(:options) do
                {
                    scanner:         {
                        checks: 'xss',
                        audit: {
                            elements: [:links]
                        },
                        dom: {
                          pool_size: 0
                        }
                    }
                }
            end

            it 'starts the scan' do
                subject.start
                expect(subject.status).to be :done

                expect(subject.report.issues).to be_any
            end
        end
    end

    describe '#start_in_thread' do
        let(:options) do
            {
                scanner:         {
                    checks: 'xss'
                },
                dom: {
                    pool_size: 0
                }
            }
        end

        it 'starts the scan in a thread' do
            subject.start_in_thread.join
            expect(subject.status).to be :done
        end

        context 'when a block has been given' do
            it 'is called once the scan finishes' do
                subject.start_in_thread do |scan|
                    expect(scan).to be subject
                    expect(subject.status).to be :done
                end
            end
        end
    end

    describe '#thread' do
        context 'when using #start_in_thread' do
            context 'and the scan is still running' do
                it 'returns the thread' do
                    tt = nil
                    subject.start_in_thread do
                        tt = Thread.current
                    end
                    t = subject.thread
                    t.join

                    expect(t).to be tt
                end
            end

            context 'and the scan finished running' do
                it 'returns nil' do
                    subject.start_in_thread.join
                    expect(subject.thread).to be_nil
                end
            end
        end
    end

    describe '#recheck_issue' do
        context 'when the scan is still running' do
            it "raises #{described_class::Error::StillRunning}" do
                subject.start_in_thread

                expect do
                    subject.recheck_issue( nil )
                end.to raise_error described_class::Error::StillRunning
            end
        end

        context 'when the issue still exists' do
            it 'returns the reproduced issue' do
                subject.start
                issue = subject.report.issues.first
                subject.clean_up

                @subject = described_class.new( application, options )
                expect(@subject.recheck_issue( issue )).to eq issue
            end
        end

        context 'when the issue does not still exist' do
            it 'returns nil' do
                subject.start
                issue = subject.report.issues.first
                subject.clean_up

                @subject = described_class.new( EmptyApp )
                expect(@subject.recheck_issue( issue )).to be_nil
            end
        end
    end

    describe '#abort' do
        it 'aborts a running scan' do
            t = subject.start_in_thread
            subject.abort
            sleep 0.1 while !subject.aborted?
            expect(subject).to be_aborted
        end
    end

    describe '#clean_up' do
        it "resets the #{SCNR::Engine::Framework}" do
            expect(subject.scanner).to receive(:reset).at_least(1).times
            expect(Rack::Handler::SCNRIntrospector).to receive(:shutdown)

            subject.clean_up
        end

        context 'when the scan is running' do
            it "raises #{described_class::Error::StillRunning}" do
                pending
                # subject.start_in_thread
                #
                # expect do
                #     subject.clean_up
                # end.to raise_error described_class::Error::StillRunning
            end
        end
    end

    describe '#pause' do
        it 'pauses the scan' do
            subject.pause
            expect(subject).to be_paused
            subject.resume
        end
    end

    describe '#resume' do
        it 'resumes a paused scan' do
            t = subject.start_in_thread

            subject.pause

            subject.resume
            sleep 1 while subject.paused?

            expect(subject).to_not be_paused
        end
    end

    describe '#report' do
        it 'returns the report'
        it 'sets #coverage'

        context 'when #clean_up has been called' do
            it "raises #{described_class::Error::CleanedUp}" do
                subject.clean_up
                expect{ subject.report }.to raise_error described_class::Error::CleanedUp
            end
        end
    end
end
