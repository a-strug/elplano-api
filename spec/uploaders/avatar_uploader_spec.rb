require 'rails_helper'

RSpec.describe AvatarUploader do
  let(:lecturer)      { build(:lecturer, avatar: uploaded_file.to_json) }
  let(:uploaded_file) { described_class.new(:cache).upload(file) }
  let(:file)          { File.open(file_fixture('dk.png')) }

  describe 'validations' do
    subject { lecturer.valid? }

    it 'passes with no errors' do
      subject

      expect(lecturer.errors).to be_empty
    end

    context 'when extension is not correct' do
      let(:file) { File.open(file_fixture('video_sample.mp4')) }

      it 'fals with type validation error' do
        subject

        expect(lecturer.errors[:avatar].to_s).to include("type must be one of")
      end
    end

    context 'when file size is not correct' do
      before do
        stub_const('AvatarUploader::MAX_SIZE', 0)
      end

      it 'fals with size validation error' do
        subject

        expect(lecturer.errors[:avatar].to_s).to include('is too large')
      end
    end
  end
end
