require 'spec_helper_acceptance'

describe 'jenkins' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      repo = <<-EOS
        include cegekarepos::cegeka
        Yum::Repo <| title == 'cegeka-custom-noarch' |>
      EOS
      pp = <<-EOS
        include ::jenkins
      EOS

      apply_manifest(repo)
      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it { is_expected.to contain_package('jenkins') }
    it { is_expected.to contain_service('jenkins') }

  end
end

