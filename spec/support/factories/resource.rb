Factory.define :resource do
    SCNR::Introspector::Scan::Coverage::Resource.new(
        helper_path_for( 'target.rb' )
    )
end
