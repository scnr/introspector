Factory.define :stack_frame do
    Arachni::HTTP::Client::Coverage::Point::StackFrame.new( Factory[:point] )
end
