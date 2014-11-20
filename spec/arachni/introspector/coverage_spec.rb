describe Arachni::Introspector::Coverage do

    it 'supports Marshal serialization'

    describe '#initialize' do
        it 'sets attributes'

        context 'when no :points have been given' do
            it 'defaults to an empty array'
        end

        context 'when :scope is' do
            context Arachni::Introspector::Coverage::Scope do
                it 'sets it'
            end

            context Hash do
                it "creates a #{Arachni::Introspector::Coverage::Scope} from it"
            end

            context 'nil' do
                it "creates an empty #{Arachni::Introspector::Coverage::Scope}"
            end

            context 'other' do
                it "raises #{Arachni::Introspector::Coverage::Error::InvalidScope}"
            end
        end

        context 'when a block has been given' do
            it 'traces its execution'
        end
    end

    describe '#trace' do
        it "traces the block's execution"
        it 'returns self'

        context "when #{described_class::Scope}#out?" do
            context 'returns true' do
                it 'does not log the point'
            end
            context 'returns false' do
                it 'logs the point'
            end
        end
    end

end
