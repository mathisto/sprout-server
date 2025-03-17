RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

# We'll let Rails handle factory discovery instead of manually finding definitions
# FactoryBot.definition_file_paths = [File.expand_path('../factories', __dir__)]
# FactoryBot.find_definitions 