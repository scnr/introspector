Factory.define :point_data do
    {
        path:        __FILE__,
        line_number: 19,
        class_name:  'Stuff',
        method_name: :blah,
        event:       :call,
        context:     binding,
        timestamp:   Time.now
    }
end

Factory.define :point do
    SCNR::Engine::HTTP::Request::Trace::Point.new(Factory[:point_data] )
end
