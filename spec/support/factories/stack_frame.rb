Factory.define :stack_frame do
    Arachni::Introspector::Coverage::Point::StackFrame.new( Factory[:point] )
end
