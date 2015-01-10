describe Arachni::Introspector::Scan do
    subject { @subject = described_class.new( application, options ) }
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
    end

    after do
        if @subject
            @subject.thread.join if @subject.thread
            @subject.clean_up
        end

        Arachni::Framework.reset
        Arachni::Options.reset
        @subject = nil
    end

    describe '#initialize' do
        it 'sets #application' do
            expect(subject.application).to be XssApp
        end

        it 'disables platform fingerprinting' do
            expect(subject.framework.options.fingerprint?).to be_falsey
        end

        it 'sets default platforms' do
            expect(subject.framework.options.platforms).to include :ruby
            expect(subject.framework.options.platforms).to include :rack
            expect(subject.framework.options.platforms).to include Arachni::Introspector.os
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
                    framework: {
                        checks: 'xss'
                    }
                }
            end

            it "sets #{Arachni::Options}" do
                expect(Arachni::Options).to receive(:update).with(options[:framework])
                @subject = described_class.new( application, options )
            end

            describe ':host' do
                let(:options) do
                    {
                        host: 'stuff'
                    }
                end

                it 'sets the hostname' do
                    expect(subject.framework.options.url).to eq "http://#{options[:host]}/"
                end

                context 'when not given' do
                    let(:options) do
                        {}
                    end
                    let(:application) { described_class }

                    it 'uses the application name' do
                        expect(subject.framework.options.url).to eq 'http://arachni-introspector-scan/'
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
                    expect(subject.framework.options.url).to eq "http://#{options[:host]}:#{options[:port]}/"
                end

                context 'when not given' do
                    let(:options) do
                        {}
                    end

                    it 'uses 80' do
                        expect(subject.framework.options.url).to eq 'http://xssapp/'
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
                    expect(subject.framework.options.url).to eq "http://#{options[:host]}/#{options[:path]}"
                end

                context 'when not given' do
                    let(:options) do
                        {}
                    end

                    it 'uses /' do
                        expect(subject.framework.options.url).to eq 'http://xssapp/'
                    end
                end
            end

            describe ':checks' do
                let(:options) do
                    {
                        framework: {
                            checks: 'xss'
                        }
                    }
                end

                it 'sets the checks' do
                    expect(subject.framework.checks.keys).to eq [options[:framework][:checks]]
                end
            end
        end
    end

    describe '#start' do
        context 'when idle' do
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

            it 'starts the scan' do
                expect(subject.status).to be :ready
                subject.start
                expect(subject.status).to be :done

                expect(subject.report.issues).to be_any
            end
        end

        context 'when the scan has already started' do
            it "raises #{described_class::Error::StillRunning}" do
                subject.start_in_thread

                expect do
                    subject.start
                end.to raise_error described_class::Error::StillRunning
            end
        end

        context 'when the scan has already been used' do
            it "raises #{described_class::Error::Dirty}" do
                subject.start

                expect do
                    subject.start
                end.to raise_error described_class::Error::Dirty
            end
        end
    end

    describe '#start_in_thread' do
        let(:options) do
            {
                framework: {
                    checks: 'xss'
                }
            }
        end

        it 'starts the scan in a thread' do
            expect(subject.status).to be :ready
            subject.start_in_thread.join
            expect(subject.status).to be :done
        end

        context 'when a block has been given' do
            it 'is called once the scan finishes' do
                expect(subject.status).to be :ready
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
                issue = subject.report.issues.first.variations.first
                subject.clean_up

                @subject = described_class.new( application )
                expect(@subject.recheck_issue( issue )).to eq issue
            end
        end

        context 'when the issue does not still exist' do
            it 'returns nil' do
                subject.start
                issue = subject.report.issues.first.variations.first
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
            expect(subject).to be_aborted
        end
    end

    describe '#clean_up' do
        it "resets the #{Arachni::Framework}" do
            expect(subject.framework).to receive(:reset).twice
            expect(Rack::Handler::ArachniIntrospector).to receive(:shutdown).twice

            subject.clean_up
        end

        context 'when the scan is running' do
            it "raises #{described_class::Error::StillRunning}" do
                subject.start_in_thread

                expect do
                    subject.clean_up
                end.to raise_error described_class::Error::StillRunning
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

end
