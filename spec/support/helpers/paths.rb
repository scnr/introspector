def root_path
    File.expand_path( File.dirname( __FILE__ ) + '/../../..' )
end

def spec_path
    "#{root_path}/spec"
end

def support_path
    "#{spec_path}/support"
end

def fixtures_path
    "#{support_path}/fixtures"
end

def fixture_path_for( file )
    "#{fixtures_path}/#{file}"
end

def helpers_path
    "#{support_path}/helpers"
end

def helper_path_for( file )
    "#{helpers_path}/#{file}"
end
