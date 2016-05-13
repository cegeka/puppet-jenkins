require 'spec_helper_acceptance'

describe 'jenkins' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        Yum::Repo <| title == 'cegeka-custom-noarch' |>
        include ::cegekarepos
        include ::jenkins
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it { is_expected.to contain_package('jenkins') }
    it { is_expected.to contain_service('jenkins') }

  end
end

