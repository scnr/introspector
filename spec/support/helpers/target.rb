class Target
    def stuff
        @iv1  = [:blah]
        @iv2  = [:blah2]
        lvar  = 1
        lvar2 = 2

        [].join
    end
end

def get_trace_point( events = [], &block )
    TracePoint.new *events do |tp|
        block.call tp
    end.enable do
        Target.new.stuff
    end
end

def get_point( events = [], &block )
    get_trace_point *events do |tp|
        block.call Arachni::Introspector::Coverage::Point.from_trace_point( tp )
    end
end

def get_stack_frame( events = [], &block )
    get_point *events do |point|
        block.call point.stack_frame
    end
end
