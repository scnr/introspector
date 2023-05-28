describe SCNR::Introspector::Coverage::Resource do
    subject { SCNR::Introspector::Coverage::Resource.new path }
    let(:path) { helper_path_for('target.rb') }

    describe '#initialize' do
        it 'loads a resource by path' do
            expect(subject.lines.map(&:content).join("\n")).to eq IO.binread(path).rstrip
        end

        it 'sets #path' do
            expect(subject.path).to eq path
        end

        context 'when the path is invalid' do
            let(:path) { 'blahblah' }

            it "raises #{Errno::ENOENT}" do
                expect{ subject }.to raise_error Errno::ENOENT
            end
        end
    end

    describe '#[]' do
        it 'retrieves a line by its number' do
            expect(subject[2]).to be_kind_of described_class::Line
            expect(subject[2].number).to eq 2
        end

        context 'when the index does not exist' do
            it 'return nil' do
                expect(subject[999999]).to be_nil
            end
        end
    end

    describe '#hit_lines' do
        it 'returns lines which have been hit' do
            subject[0].hit(1)
            subject[2].hit(1)
            subject[3].hit(0)
            subject[4].hit(0)

            expect(subject.hit_lines).to eq [subject[0], subject[2]]
        end
    end

    describe '#missed_lines' do
        it 'returns lines which have been missed' do
            subject[0].hit(0)
            subject[2].hit(0)
            subject[3].hit(1)
            subject[4].hit(1)

            expect(subject.missed_lines).to eq [subject[0], subject[2]]
        end
    end

    describe '#skipped_lines' do
        it 'returns lines which have been missed' do
            subject[0].hit(0)
            subject[1].hit(1)
            subject[2].hit(0)
            subject[3].hit(1)

            expect(subject.skipped_lines).to eq subject.lines - [subject[0], subject[1], subject[2], subject[3] ]
        end
    end

    describe '#included_lines' do
        it 'returns lines which have not been skipped' do
            subject[0].hit(0)
            subject[1].hit(1)
            subject[2].hit(0)
            subject[3].hit(1)

            expect(subject.included_lines).to eq subject.lines - subject.skipped_lines
        end
    end

    describe '#hit_percentage' do
        it 'returns the percentage of hit lines' do
            subject[0].hit(1)
            subject[1].hit(1)
            subject[2].hit(1)
            subject[3].hit(0)
            subject[4].hit(0)

            expect(subject.hit_percentage).to eq 60.0
        end
    end

    describe '#miss_percentage' do
        it 'returns the percentage of missed lines' do
            subject[0].hit(1)
            subject[1].hit(1)
            subject[2].hit(1)
            subject[3].hit(0)
            subject[4].hit(0)

            expect(subject.miss_percentage).to eq 40.0
        end
    end

    describe '#empty?' do
        context 'when #lines are empty' do
            it 'returns true' do
                subject.lines.clear
                expect(subject).to be_empty
            end
        end

        context 'when #lines are not empty' do
            it 'returns true' do
                expect(subject.lines).to be_any
                expect(subject).to_not be_empty
            end
        end
    end
end
