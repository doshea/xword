require 'yaml'
require 'erb'

describe 'cable.yml production configuration' do
  let(:yaml_content) { ERB.new(File.read(Rails.root.join('config', 'cable.yml'))).result }
  let(:config)       { YAML.safe_load(yaml_content, permitted_classes: [Integer]) }
  let(:production)   { config['production'] }

  it 'sets ssl_params to handle TLS Redis URLs from Heroku' do
    expect(production['ssl_params']).to be_present
  end
end
