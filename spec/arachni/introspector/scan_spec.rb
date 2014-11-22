describe Arachni::Introspector::Scan do
    subject { described_class.new( XssApp, options ) }
    let(:options) { {} }

    before { Arachni::Framework.reset }

    describe '#initialize' do
        it 'sets #app' do
            expect(subject.app).to be XssApp
        end

        it 'disables platform fingerprinting' do
            expect(subject.framework.options.fingerprint?).to be_falsey
        end

        it 'sets default platforms' do
            expect(subject.framework.options.platforms).to include :ruby
            expect(subject.framework.options.platforms).to include :rack
            expect(subject.framework.options.platforms).to include Arachni::Introspector.os
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
                described_class.new( XssApp, options )
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

                    it 'uses the app name' do
                        expect(described_class.new( described_class ).framework.options.url).to eq 'http://arachni-introspector-scan/'
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

                context 'when not given' do
                    let(:options) do
                        {}
                    end

                    it "loads #{described_class}::DEFAULT_CHECKS" do
                        expected =  subject.framework.checks.parse(
                            described_class::DEFAULT_CHECKS
                        ) - described_class::UNLOAD_CHECKS.map(&:to_s)

                        expect(subject.framework.checks.keys).to eq expected
                    end
                end
            end

            context 'when no elements have been specified' do
                it 'audits links, forms and cookies' do
                    expect(subject.framework.options.audit.links?).to be_truthy
                    expect(subject.framework.options.audit.forms?).to be_truthy
                    expect(subject.framework.options.audit.cookies?).to be_truthy
                    expect(subject.framework.options.audit.headers?).to be_falsey
                end
            end
        end

        context 'Rails' do
            it 'is sets the DB platform'
        end
    end

    describe '#start' do
        let(:options) do
            {
                framework: {
                    checks: 'xss'
                }
            }
        end

        it 'starts the scan' do
            expect(subject.status).to be :ready
            subject.start
            expect(subject.status).to be :done

            expect(subject.report.issues).to be_any
        end

        context 'when the scan has already started' do
            let(:options) do
                {}
            end

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
                end.join
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

    describe '#abort' do
        it 'aborts a running scan' do
            subject.start_in_thread
            subject.abort
            expect(subject).to be_aborted
        end
    end

    describe '#clean_up' do
        it "resets the #{Arachni::Framework}" do
            expect(subject.framework).to receive(:reset)
            expect(Rack::Handler::ArachniIntrospector).to receive(:shutdown)

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
        end
    end

    describe '#resume' do
        it 'resumes a paused scan' do
            subject.start_in_thread
            subject.pause

            sleep 0.1 while !subject.paused?

            subject.resume

            expect(subject).to be_running
        end
    end

end
