describe SCNR::Introspector::Coverage::Resource::Line do
    subject { described_class.new options }

    let(:options) do
        {
            resource: resource,
            number:   number,
            content:  content,
            hits:     hits
        }
    end
    let(:resource) do
        Factory[:resource]
    end
    let(:number) { 1 }
    let(:hits) { 10 }
    let(:content) { IO.read( helper_path_for( 'target.rb' ) ).lines.first.rstrip }

    describe '#initialize' do
        describe ':resource' do
            it 'sets #resource' do
                expect(subject.resource).to be resource
            end

            context 'when missing' do
                let(:options) do
                    super().tap { |o| o.delete :resource }
                end

                it 'raises ArgumentError' do
                    expect { subject }.to raise_error ArgumentError
                end
            end
        end

        describe ':number' do
            it 'sets #number' do
                expect(subject.number).to be number
            end

            context 'when missing' do
                let(:options) do
                    super().tap { |o| o.delete :number }
                end

                it 'raises ArgumentError' do
                    expect { subject }.to raise_error ArgumentError
                end
            end
        end

        describe ':content' do
            it 'sets #content' do
                expect(subject.content).to be content
            end

            context 'when missing' do
                let(:options) do
                    super().tap { |o| o.delete :content }
                end

                it 'raises ArgumentError' do
                    expect { subject }.to raise_error ArgumentError
                end
            end
        end

        describe ':hits' do
            it 'sets #hits' do
                expect(subject.hits).to be hits
            end
        end
    end

    describe '#skipped?' do
        context 'when :hits is' do
            context 'nil' do
                let(:hits) { nil }

                it 'returns true' do
                    expect(subject).to be_skipped
                end
            end

            context '0' do
                let(:hits) { 0 }

                it 'returns false' do
                    expect(subject).to_not be_skipped
                end
            end

            context '>= 1' do
                let(:hits) { 1 }

                it 'returns false' do
                    expect(subject).to_not be_skipped
                end
            end
        end
    end

    describe '#missed?' do
        context 'when :hits is' do
            context 'nil' do
                let(:hits) { nil }

                it 'returns false' do
                    expect(subject).to_not be_missed
                end
            end

            context '0' do
                let(:hits) { 0 }

                it 'returns true' do
                    expect(subject).to be_missed
                end
            end

            context '>= 1' do
                let(:hits) { 1 }

                it 'returns false' do
                    expect(subject).to_not be_missed
                end
            end
        end
    end

    describe '#hit?' do
        context 'when :hits is' do
            context 'nil' do
                let(:hits) { nil }

                it 'returns false' do
                    expect(subject).to_not be_hit
                end
            end

            context '0' do
                let(:hits) { 0 }

                it 'returns false' do
                    expect(subject).to_not be_hit
                end
            end

            context '>= 1' do
                let(:hits) { 1 }

                it 'returns true' do
                    expect(subject).to be_hit
                end
            end
        end
    end

    describe '#state' do
        context 'when :hits is' do
            context 'nil' do
                let(:hits) { nil }

                it 'returns :skipped' do
                    expect(subject.state).to be :skipped
                end
            end

            context '0' do
                let(:hits) { 0 }

                it 'returns :missed' do
                    expect(subject.state).to be :missed
                end
            end

            context '>= 1' do
                let(:hits) { 1 }

                it 'returns :hit' do
                    expect(subject.state).to be :hit
                end
            end
        end
    end

    describe '#hit' do
        it 'increases the #hits' do
            h = subject.hits
            subject.hit( 10 )
            expect(subject.hits).to be h + 10
        end
    end

end
