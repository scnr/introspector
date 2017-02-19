Factory.define :stack_frame do
    SCNR::Engine::HTTP::Client::Coverage::Point::StackFrame.new(Factory[:point] )
end
