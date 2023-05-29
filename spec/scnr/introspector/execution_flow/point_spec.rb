describe SCNR::Introspector::ExecutionFlow::Point do
    subject { described_class.new( data ) }
    let(:data) { Factory[:point_data] }

    def new_point
        described_class.new( Factory[:point_data] )
    end

    it 'supports Marshal serialization' do
        data.each do |k, v|
            expect(subject.send(k)).to eq v
        end
    end

    describe '#initialize' do
        it 'sets attributes' do
            data.each do |k, v|
                expect(subject.send(k)).to eq v
            end
        end
    end

    describe '.from_trace_point' do
        it 'creates an instance from a native TracePoint object' do
            TracePoint.new do |tp|
                point = described_class.from_trace_point( tp )

                expect(point.path).to eq tp.path
                expect(point.line_number).to eq tp.lineno
                expect(point.class_name).to eq nil.class.name
                expect(point.method_name).to eq tp.method_id
                expect(point.event).to eq tp.event
                expect(point.timestamp).to be_kind_of Time
            end.enable{}

            checked = false
            get_trace_point :call do |tp|
                checked = true

                point = described_class.from_trace_point( tp )

                expect(point.path).to eq tp.path
                expect(point.line_number).to eq tp.lineno
                expect(point.class_name).to eq tp.defined_class.name
                expect(point.method_name).to eq tp.method_id
                expect(point.event).to eq tp.event
                expect(point.timestamp).to be_kind_of Time
            end

            expect(checked).to be_truthy
        end
    end
end
