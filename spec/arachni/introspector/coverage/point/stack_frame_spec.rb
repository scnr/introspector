describe Arachni::Introspector::Coverage::Point::StackFrame do
    subject { described_class.new point }
    let(:point) { Factory[:point] }

    describe '#initialize' do
        it 'sets #point' do
            expect(described_class.new( point ).point).to eq point
        end

        it 'sets #callers' do
            # Make sure we grabbed the real stack callers, before the interpreter
            # popped them during execution.
            expect(subject.callers.size).to be > subject.point.context.callers.size
        end
    end

    describe '#callers' do
        it 'returns bindings of caller frames' do
            expect(subject.callers).to be_any

            subject.callers.each do |c|
                expect(c).to be_kind_of Binding
            end
        end
    end

    describe '#context' do
        it 'returns a binding for this frame' do
            expect(subject.context).to eq point.context
        end
    end

    describe '#eval' do
        it 'evaluates code under the context of the frame' do
            get_stack_frame :call do |frame|
                expect(frame.eval('__method__')).to be :stuff
            end
        end
    end

    describe '#method_definition' do
        it 'returns the path and line number to the container method' do
            get_stack_frame :call do |frame|
                expect(frame.method_definition).to eq Target.new.method(:stuff).source_location
            end
        end
    end

    describe '#container_method' do
        it 'returns the name of the container method' do
            get_stack_frame do |frame|
                next if frame.point.method_name != :join
                expect(frame.container_method).to be :stuff
            end
        end
    end

    describe '#object' do
        it 'returns the context instance' do
            get_stack_frame :call do |frame|
                expect(frame.object).to be_kind_of Target
            end
        end
    end

    describe '#local_variables' do
        it 'returns the local variables of the context' do
            get_stack_frame :return do |frame|
                expect(frame.local_variables).to eq({
                    lvar:  1,
                    lvar2: 2
                })
            end
        end
    end

    describe '#instance_variables' do
        it 'returns the instance variables of the context' do
            get_stack_frame :return do |frame|
                expect(frame.instance_variables).to eq({
                    :@iv1 => [:blah],
                    :@iv2 => [:blah2]
                })
            end
        end
    end
end
