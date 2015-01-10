Factory.define :resource do
    Arachni::Introspector::Scan::Coverage::Resource.new(
        helper_path_for( 'target.rb' )
    )
end
