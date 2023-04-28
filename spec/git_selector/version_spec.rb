# frozen_string_literal: true

require_relative '../spec_helper'

describe GitSelector do
  it 'has a version number' do
    expect(GitSelector::VERSION).not_to be_nil
  end
end
