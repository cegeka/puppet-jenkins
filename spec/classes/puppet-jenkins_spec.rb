#!/usr/bin/env rspec

require 'spec_helper'

describe 'jenkins' do
  #$jenkins_version=undef, $jenkins_plugins=undef, $ensure='present'
  let (:params) { { :jenkins_version=> 'latest' , :jenkins_plugins => ['a','b'] , :ensure => 'present' }}
  context "Operating system release 5.8" do
    it { should contain_class 'jenkins' }
    let(:facts) { { :operatingsystem => 'CentOS' } }
  end
end
