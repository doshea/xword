module IconHelper
  ICON_DIR = Rails.root.join('app', 'assets', 'images', 'icons')

  # Lazy per-icon cache: maps name (String) → inner SVG elements (String).
  # Populated on first use; the SVG wrapper is stripped and rebuilt by #icon.
  SVG_CACHE = Hash.new do |h, name|
    raw = File.read(ICON_DIR.join("#{name}.svg"))
    h[name] = raw.sub(/\A\s*<svg[^>]*>/, '').sub(/<\/svg>\s*\z/, '').strip
  end

  # Renders a Lucide icon as an inline SVG element.
  #
  #   icon('pencil')
  #   icon('trash-2', size: 18, class: 'danger-icon')
  #   icon('log-in',  style: 'color: var(--color-accent);')
  #   icon('save',    title: 'Save puzzle')   # adds aria-label for screen readers
  #
  # name   - icon filename without .svg extension (e.g. 'pencil', 'trash-2')
  # size:  - width/height in px (default 20)
  # class: - additional CSS class string or array (merged with 'xw-icon xw-icon--name')
  # style: - inline style string
  # title: - accessible label; omit for purely decorative icons (adds aria-hidden)
  def icon(name, size: 20, **opts)
    css  = ['xw-icon', "xw-icon--#{name}", opts[:class]].flatten.compact.join(' ')
    aria = opts[:title] ? %( role="img" aria-label="#{h(opts[:title])}") : ' aria-hidden="true"'
    style_attr  = opts[:style] ? %( style="#{h(opts[:style])}") : ''
    title_tag   = opts[:title] ? "<title>#{h(opts[:title])}</title>" : ''

    svg = %(<svg xmlns="http://www.w3.org/2000/svg" width="#{size}" height="#{size}" ) +
          %(viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" ) +
          %(stroke-linecap="round" stroke-linejoin="round" class="#{css}"#{aria}#{style_attr}>) +
          title_tag + SVG_CACHE[name.to_s] + '</svg>'

    svg.html_safe
  end
end
