RSpec.describe IconHelper, type: :helper do
  describe '#icon' do
    it 'renders an SVG element with the correct class' do
      svg = helper.icon('check')
      expect(svg).to include('xw-icon')
      expect(svg).to include('xw-icon--check')
      expect(svg).to include('<svg')
    end

    it 'raises when the icon file does not exist' do
      expect { helper.icon('nonexistent-icon-name') }.to raise_error(Errno::ENOENT)
    end
  end

  describe 'all icon references in views' do
    icon_dir = Rails.root.join('app', 'assets', 'images', 'icons')
    available = Dir.glob(icon_dir.join('*.svg')).map { |f| File.basename(f, '.svg') }.to_set

    # Collect every icon('name') call across all HAML templates
    haml_files = Dir.glob(Rails.root.join('app', 'views', '**', '*.haml'))
    referenced = haml_files.flat_map { |f|
      File.read(f).scan(/icon\(['"]([^'"]+)['"]\)/).flatten
    }.uniq.sort

    referenced.each do |name|
      it "has an SVG file for icon('#{name}')" do
        expect(available).to include(name),
          "icon('#{name}') is referenced in a view but #{icon_dir}/#{name}.svg does not exist"
      end
    end
  end
end
