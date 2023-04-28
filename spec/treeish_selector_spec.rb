# frozen_string_literal: true

require 'spec_helper'

describe TreeishExtractor do
  describe '#recent_tag_names' do
    subject(:treeish) { described_class.new }

    before do
      allow(Open3)
        .to receive(:popen3)
        .and_return([
          nil,
          StringIO.new("v0.1.0\nv0.1.1\nv0.2.0     "),
          nil,
          nil
        ])
    end

    it { expect(treeish.recent_tag_names).to eq(%w[v0.1.0 v0.1.1 v0.2.0]) }
  end

  describe '#recent_branch_names' do
    subject(:treeish) { described_class.new }

    before do
      allow(Open3)
        .to receive(:popen3)
        .and_return([
          nil,
          StringIO.new("* master\n* (HEAD detached at 7250ef74d)\ndev\nrelease"),
          nil,
          nil
        ])
    end

    it { expect(treeish.recent_branch_names).to eq(%w[master dev release]) }
  end
end
