describe SCNR::Introspector::Configuration do
    subject { described_class }

    expect_it { to respond_to :options }
    expect_it { to respond_to :options= }

    describe '.from_file' do
        it 'loads a configuration file from disk' do
            subject.from_file( fixture_path_for( 'sample.config' ) )

            expect(subject.options).to eq(
                                           application: XssApp,

                                           coverage:    {
                    scope: {
                        path_end_with: 'xss_app.rb'
                    }
                },

                                           scanner:     {
                    audit: {
                        elements: [ :links ]
                    },
                    checks: ['xss'],
                    dom: {
                        pool_size: 0
                    }
                }
            )
        end

        context 'when no file is given' do
            it "loads #{described_class::DEFAULT_FILENAME} from the current working directory" do
                expect(Kernel).to receive(:load).with( "#{Dir.pwd}/#{described_class::DEFAULT_FILENAME}" )
                subject.from_file
            end
        end
    end
end
