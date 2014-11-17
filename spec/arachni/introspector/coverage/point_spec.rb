class Foo
    def stuff
    end
end

describe Arachni::Introspector::Coverage::Point do
    subject { Arachni::Introspector::Coverage::Point.new( data ) }
    let(:data) { Factory[:point_data] }

    def new_point
        Arachni::Introspector::Coverage::Point.new( Factory[:point_data] )
    end

    it 'supports Marshal serialization' do
        expect( Marshal.load( Marshal.dump( subject ) ).id ).to eq subject.id

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

        it 'sets an incremental #id' do
            id1 = new_point.id
            id2 = new_point.id
            id3 = new_point.id

            expect(id3 - id2).to be 1
            expect(id2 - id1).to be 1
        end
    end

    describe '#stack_frame' do
        it "returns an #{described_class::StackFrame}" do
            expect(subject.stack_frame).to be_kind_of described_class::StackFrame
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
                expect(point.context).to be_kind_of Binding
                expect(point.timestamp).to be_kind_of Time
            end.enable{}

            checked = false
            TracePoint.new do |tp|
                next if !tp.defined_class
                checked = true

                point = described_class.from_trace_point( tp )

                expect(point.path).to eq tp.path
                expect(point.line_number).to eq tp.lineno
                expect(point.class_name).to eq tp.defined_class.name
                expect(point.method_name).to eq tp.method_id
                expect(point.event).to eq tp.event
                expect(point.context).to be_kind_of Binding
                expect(point.timestamp).to be_kind_of Time
            end.enable do
                Foo.new.stuff
            end

            expect(checked).to be_truthy
        end
    end
end
