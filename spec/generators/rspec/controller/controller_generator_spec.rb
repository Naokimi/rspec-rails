# Generators are not automatically loaded by Rails
require 'generators/rspec/controller/controller_generator'
require 'support/generators'

RSpec.describe Rspec::Generators::ControllerGenerator, type: :generator do
  setup_default_destination

  describe 'request specs' do
    subject { file('spec/requests/posts_spec.rb') }

    describe 'generated by default' do
      before do
        run_generator %w[posts]
      end

      describe 'the spec' do
        it { is_expected.to exist }
        it { is_expected.to contain(/require 'rails_helper'/) }
        it { is_expected.to contain(/^RSpec.describe "Posts", #{type_metatag(:request)}/) }
        it { is_expected.to contain('pending') }
      end
    end

    describe 'skipped with a flag' do
      before do
        run_generator %w[posts --no-request_specs]
      end
      it { is_expected.not_to exist }
    end

    describe 'with actions' do
      before do
        run_generator %w[posts index custom_action]
      end

      it { is_expected.to exist }
      it { is_expected.to contain('get "/posts/index"') }
      it { is_expected.to contain('get "/posts/custom_action"') }
    end

    describe 'with namespace and actions' do
      subject { file('spec/requests/admin/external/users_spec.rb') }

      before do
        run_generator %w[admin::external::users index custom_action]
      end

      it { is_expected.to exist }
      it { is_expected.to contain(/^RSpec.describe "Admin::External::Users", #{type_metatag(:request)}/) }
      it { is_expected.to contain('get "/admin/external/users/index"') }
      it { is_expected.to contain('get "/admin/external/users/custom_action"') }
    end
  end

  describe 'view specs' do
    describe 'are not generated' do
      describe 'with no-view-spec flag' do
        before do
          run_generator %w[posts index show --no-view-specs]
        end
        describe 'index.html.erb' do
          subject { file('spec/views/posts/index.html.erb_spec.rb') }
          it { is_expected.not_to exist }
        end
      end
      describe 'with no actions' do
        before do
          run_generator %w[posts]
        end
        describe 'index.html.erb' do
          subject { file('spec/views/posts/index.html.erb_spec.rb') }
          it { is_expected.not_to exist }
        end
      end

      describe 'with --no-template-engine' do
        before do
          run_generator %w[posts index --no-template-engine]
        end

        describe 'index.html.erb' do
          subject { file('spec/views/posts/index.html._spec.rb') }
          it { is_expected.not_to exist }
        end
      end
    end

    describe 'are generated' do
      describe 'with default template engine' do
        before do
          run_generator %w[posts index show]
        end
        describe 'index.html.erb' do
          subject { file('spec/views/posts/index.html.erb_spec.rb') }
          it { is_expected.to exist }
          it { is_expected.to contain(/require 'rails_helper'/) }
          it { is_expected.to contain(/^RSpec.describe "posts\/index.html.erb", #{type_metatag(:view)}/) }
        end
        describe 'show.html.erb' do
          subject { file('spec/views/posts/show.html.erb_spec.rb') }
          it { is_expected.to exist }
          it { is_expected.to contain(/require 'rails_helper'/) }
          it { is_expected.to contain(/^RSpec.describe "posts\/show.html.erb", #{type_metatag(:view)}/) }
        end
      end
      describe 'with haml' do
        before do
          run_generator %w[posts index --template_engine haml]
        end
        describe 'index.html.haml' do
          subject { file('spec/views/posts/index.html.haml_spec.rb') }
          it { is_expected.to exist }
          it { is_expected.to contain(/require 'rails_helper'/) }
          it { is_expected.to contain(/^RSpec.describe "posts\/index.html.haml", #{type_metatag(:view)}/) }
        end
      end
    end

    describe 'are removed' do
      subject { run_generator %w[posts], behavior: :revoke }
      it { is_expected.to match('remove  spec/views/posts') }
    end
  end

  describe 'routing spec' do
    subject { file('spec/routing/posts_routing_spec.rb') }

    describe 'with no flag' do
      before do
        run_generator %w[posts seek and destroy]
      end
      it { is_expected.not_to exist }
    end

    describe 'with --routing-specs  flag' do
      describe 'without action parameter' do
        before do
          run_generator %w[posts --routing-specs]
        end
        it { is_expected.not_to exist }
      end

      describe 'with action parameter' do
        before { run_generator %w[posts seek --routing-specs] }

        it { is_expected.to contain(/require 'rails_helper'/) }
        it { is_expected.to contain(/^RSpec.describe 'PostsController', #{type_metatag(:routing)}/) }
        it { is_expected.to contain(/describe 'routing'/) }
        it { is_expected.to contain(/it 'routes to #seek'/) }
        it { is_expected.to contain(/expect\(get: "\/posts\/seek"\).to route_to\("posts#seek"\)/) }
      end
    end

    describe 'with --no-routing-specs flag' do
      before do
        run_generator %w[posts seek and destroy --no-routing_specs]
      end
      it { is_expected.not_to exist }
    end
  end

  describe 'controller specs' do
    subject { file('spec/controllers/posts_controller_spec.rb') }

    describe 'are not generated' do
      it { is_expected.not_to exist }
    end

    describe 'with --controller-specs flag' do
      before do
        run_generator %w[posts --controller-specs]
      end

      describe 'the spec' do
        it { is_expected.to exist }
        it { is_expected.to contain(/require 'rails_helper'/) }
        it { is_expected.to contain(/^RSpec.describe PostsController, #{type_metatag(:controller)}/) }
      end
    end

    describe 'with --no-controller_specs flag' do
      before do
        run_generator %w[posts --no-controller-specs]
      end
      it { is_expected.not_to exist }
    end
  end
end
