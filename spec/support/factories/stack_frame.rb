Factory.define :stack_frame do
    SCNR::Introspector::Trace::Point::StackFrame.new(Factory[:point] )
end
