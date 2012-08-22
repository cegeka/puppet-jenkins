#!/usr/bin/env rspec

require 'spec_helper'

describe 'jenkins' do
  it { should contain_class 'jenkins' }
end
