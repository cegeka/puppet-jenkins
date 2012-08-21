#!/usr/bin/env rspec

require 'spec_helper'

describe 'puppet-jenkins' do
  it { should contain_class 'puppet-jenkins' }
end
