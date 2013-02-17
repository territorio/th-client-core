require "rake-pipeline-web-filters"
require 'rake-pipeline-web-filters/filter_with_dependencies'
require "less"
require "execjs"

module Th

  def self.submodule_path
    "../../../"
  end

  def self.submodule_path2
    "./app/submodules/"
  end

class AddMicroLoader < Rake::Pipeline::Filter
  LOADER = File.expand_path( "#{Th.submodule_path}ember.js/packages/loader/lib/main.js", __FILE__)

  def initialize(options={}, &block)
    super(&block)
    @global = options[:global]
  end

  def generate_output(inputs, output)
    output.write "(function() {\n" unless @global

    output.write File.read(LOADER)

    inputs.each do |input|
      output.write input.read
    end

    output.write "\n})();\n" unless @global
  end

  def additional_dependencies(input)
    [ LOADER ]
  end
end

class LessFilter < Rake::Pipeline::Web::Filters::LessFilter

	def initialize(options={}, context = nil, &block)
		super(options, context, &block)
		@options = { :paths => ["#{Th.submodule_path}th-client-views/styles/import"] }
	end

end

class HandlebarsPrecompiler < Rake::Pipeline::Filter
  class << self
    def context

      unless @context

        contents = <<END
#{File.read("#{Th.submodule_path2}ember.js/packages/handlebars/lib/main.js")}
#{File.read("#{Th.submodule_path2}th-client-core/vendor/precompile/ember-runtime.js")}
#{File.read("#{Th.submodule_path2}ember.js/packages/ember-handlebars-compiler/lib/main.js")}
function precompileEmberHandlebars(string) {
  return Ember.Handlebars.precompile(string).toString();
}
END

        @context = ExecJS.compile(contents)

      end
      @context
    end

  end

  def precompile_templates(name, data)
   "\nEmber.TEMPLATES['#{name}'] = Ember.Handlebars.template(#{self.class.context.call("precompileEmberHandlebars", data)});\n"
  end

  def generate_output(inputs, output)

    inputs.each do |input|

      name = File.basename(input.path, '.hbs')
      data = File.read(input.fullpath)
      result = precompile_templates(name, data)
      output.write result

    end
  end
end

class InternalHandlebarsPrecompiler < Rake::Pipeline::Filter
  class << self
    def context

      unless @context

        contents = <<END
#{File.read("#{Th.submodule_path2}ember.js/packages/handlebars/lib/main.js")}
#{File.read("#{Th.submodule_path2}th-client-core/vendor/precompile/ember-runtime.js")}
#{File.read("#{Th.submodule_path2}ember.js/packages/ember-handlebars-compiler/lib/main.js")}
function precompileEmberHandlebars(string) {
  return Ember.Handlebars.precompile(string).toString();
}
END

        @context = ExecJS.compile(contents)

      end
      @context
    end

  end

  def precompile_templates(data)
    # Precompile defaultTemplates
   data.gsub!(%r{(defaultTemplate(?:\s*=|:)\s*)precompileTemplate\(['"](.*)['"]\)}) do
     "#{$1}Ember.Handlebars.template(#{self.class.context.call("precompileEmberHandlebars", $2)})"
   end
  end

  def generate_output(inputs, output)
    inputs.each do |input|
      result = File.read(input.fullpath)
      precompile_templates(result)
      output.write result
    end
  end
end



end
