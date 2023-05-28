Factory.define :resource do
    SCNR::Introspector::Coverage::Resource.new(
        helper_path_for( 'target.rb' )
    )
end
