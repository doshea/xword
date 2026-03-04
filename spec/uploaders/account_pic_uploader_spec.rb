describe AccountPicUploader do
  describe '#download_allowlist' do
    let(:uploader) { AccountPicUploader.new }

    it 'restricts remote downloads to HTTP/HTTPS URLs' do
      expect(uploader.download_allowlist).to be_present
      expect(uploader.download_allowlist.any? { |r| 'https://example.com/pic.jpg' =~ r }).to be true
      expect(uploader.download_allowlist.any? { |r| 'http://example.com/pic.jpg' =~ r }).to be true
    end

    it 'blocks non-HTTP protocols' do
      expect(uploader.download_allowlist.any? { |r| 'file:///etc/passwd' =~ r }).to be false
      expect(uploader.download_allowlist.any? { |r| 'ftp://internal/data' =~ r }).to be false
      expect(uploader.download_allowlist.any? { |r| 'gopher://169.254.169.254/' =~ r }).to be false
    end
  end
end
