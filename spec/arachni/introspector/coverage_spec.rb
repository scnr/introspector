def points_to_data( points )
    points.map do |point|
        [point.path, point.line_number, point.class_name, point.method_name,
         point.event]
    end
end

describe Arachni::Introspector::Coverage do
    subject { described_class.new scope: scope }

    let(:scope) do
        described_class::Scope.new
    end
    let(:target_path) do
        Target.new.method(:stuff).source_location.first
    end

    it 'supports Marshal serialization' do
        subject.scope = described_class::Scope.new( path_start_with: target_path )

        subject.trace do
            target = Target.new
            target.stuff
        end

        new_obj = Marshal.load( Marshal.dump( subject ) )
        point_data = points_to_data( new_obj.points )

        expected_data = [
            [ target_path, 2, 'Target', :stuff, :call ],
            [ target_path, 3, 'Target', :stuff, :line ],
            [ target_path, 4, 'Target', :stuff, :line ],
            [ target_path, 5, 'Target', :stuff, :line ],
            [ target_path, 6, 'Target', :stuff, :line ],
            [ target_path, 8, 'Target', :stuff, :line ],
            [ target_path, 8, 'Array',  :join,  :c_call ],
            [ target_path, 8, 'Array',  :join,  :c_return ],
            [ target_path, 9, 'Target', :stuff, :return ]
        ]

        expect(point_data).to eq expected_data

        new_obj.points.each do |point|
            expect(point.coverage).to eq new_obj
        end
    end

    describe '#initialize' do
        context 'when :scope is' do
            context "#{Arachni::Introspector::Coverage::Scope}" do
                it 'sets it' do
                    scope = Arachni::Introspector::Coverage::Scope.new
                    expect(described_class.new( scope: scope ).scope).to be scope
                end
            end

            context 'Hash' do
                it "creates a #{Arachni::Introspector::Coverage::Scope} from it" do
                    path_start_with = '/stuff/blah'

                    expect(described_class.new( scope: {
                        path_start_with: path_start_with
                    }).scope.path_start_with).to eq path_start_with
                end
            end

            context 'nil' do
                it "creates an empty #{Arachni::Introspector::Coverage::Scope}" do
                    expect(described_class.new.scope).to be_empty
                end
            end

            context 'other' do
                it "raises #{Arachni::Introspector::Coverage::Error::InvalidScope}" do
                    expect {
                        described_class.new( scope: '' )
                    }.to raise_error Arachni::Introspector::Coverage::Error::InvalidScope
                end
            end
        end

        context 'when a block has been given' do
            it 'is forwarded to #trace' do
                b = proc{}

                expect_any_instance_of(described_class).to receive(:trace) do |&arg|
                    expect(arg).to be b
                end
                described_class.new(&b)
            end
        end
    end

    describe '#trace' do
        before do
            subject.trace do
                target = Target.new
                target.stuff
            end
        end

        let(:scope) do
            described_class::Scope.new( path_start_with: target_path )
        end
        let(:point_data) do
            points_to_data( subject.points )
        end

        it "traces the block's execution" do
            expected_data = [
                [ target_path, 2, 'Target', :stuff, :call ],
                [ target_path, 3, 'Target', :stuff, :line ],
                [ target_path, 4, 'Target', :stuff, :line ],
                [ target_path, 5, 'Target', :stuff, :line ],
                [ target_path, 6, 'Target', :stuff, :line ],
                [ target_path, 8, 'Target', :stuff, :line ],
                [ target_path, 8, 'Array',  :join,  :c_call ],
                [ target_path, 8, 'Array',  :join,  :c_return ],
                [ target_path, 9, 'Target', :stuff, :return ]
            ]

            expect(point_data).to eq expected_data
        end

        it "assigns 'self' as #{described_class::Point}#coverage" do
            expect(subject.points.map(&:coverage).uniq).to eq [subject]
        end

        it 'returns self' do
            expect(subject.trace{}).to be subject
        end

        context "when #{described_class::Scope}#in?" do
            context 'true 'do
                let(:scope) do
                    described_class::Scope.new(
                        filter: proc do |point|
                            point.defined_class == Target
                        end
                    )
                end

                it 'logs the point' do
                    expected_data = [
                        [ target_path, 2, 'Target', :stuff, :call ],
                        [ target_path, 3, 'Target', :stuff, :line ],
                        [ target_path, 4, 'Target', :stuff, :line ],
                        [ target_path, 5, 'Target', :stuff, :line ],
                        [ target_path, 6, 'Target', :stuff, :line ],
                        [ target_path, 8, 'Target', :stuff, :line ],
                        [ target_path, 9, 'Target', :stuff, :return ]
                    ]

                    expect(point_data).to eq expected_data
                end
            end
        end

        context "when #{described_class::Scope}#without_context?" do
            context 'true' do
                let(:scope) do
                    described_class::Scope.new(
                        with_context: true
                    )
                end

                it "sets #{described_class::Point}#context" do
                    expect(subject.points.first.context).to be_kind_of Binding
                end
            end

            context 'false' do
                let(:scope) do
                    described_class::Scope.new(
                        with_context: false
                    )
                end

                it "does not set #{described_class::Point}#context" do
                    expect(subject.points.first.context).to be_nil
                end
            end
        end
    end
end
