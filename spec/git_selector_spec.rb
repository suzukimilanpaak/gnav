# frozen_string_literal: true

require_relative './spec_helper'

describe GitSelector do
  describe '#run' do
    before { allow(GitPrompt).to receive(:new) }

    after { described_class.run }

    it { expect(GitPrompt).to receive(:new) }
  end
end
