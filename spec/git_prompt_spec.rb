# frozen_string_literal: true

require_relative './spec_helper'

describe GitPrompt do
  describe '#initialize' do
    subject(:git_prompt) { an_instance_of(described_class) }

    let(:prompt) do
      instance_double(TTY::Prompt).tap do |p|
        allow(p).to receive(:clear!)
        allow(p).to receive(:decorate).and_return('decorated_message')
        allow(p).to receive(:error)
        allow(p).to receive(:on)
        allow(p).to receive(:ok)
        allow(p).to receive(:select)
      end
    end

    before do
      allow(TTY::Prompt).to receive(:new).and_return(prompt)
      allow_any_instance_of(described_class).to receive(:display_select)
    end

    after do
      described_class.new
    end

    it do
      expect_any_instance_of(described_class).to receive(:display_select) .with(:branch, anything)
    end
  end
end
