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

  class EmberProductionFilter < Rake::Pipeline::Filter
    def generate_output(inputs, output)
      inputs.each do |input|
        result = File.read(input.fullpath)
        result.gsub!(%r{^(\s)+ember_(assert|deprecate|warn)\((.*)\).*$}, "")
        output.write result
      end
    end
  end



  class EmberStub < Rake::Pipeline::Filter
    def generate_output(inputs, output)
      inputs.each do |input|
        file = File.read(input.fullpath)
        out = "(function() {\nvar Ember = { assert: function() {} };\n"

        out << file
        out << "\nexports.precompile = Ember.Handlebars.precompile;"
        out << "\nexports.EmberHandlebars = Ember.Handlebars;"
        out << "\n})();"
        output.write out
      end
    end
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



class CustomHandlebarsPrecompiler < Rake::Pipeline::Filter
  class << self
    def context
      unless @context
        contents = <<END
exports = {};
function require() {
  #{File.read("#{Th.submodule_path2}th-client-core/vendor/precompile/handlebars.1.0.0-rc.3.js")};
  return Handlebars;
}

#{File.read("dist/ember-template-compiler.js")}
function precompileEmberHandlebars(string) {
  return exports.precompile(string).toString();
}
END
        @context = ExecJS.compile(contents)
      end
      @context
    end
  end

  def initialize(options={}, &block)
    super(&block)
    @inline = options[:inline]
    @base_path = options[:base_path]
  end

  def precompile_inline_templates(data)
     data.gsub!(%r{(defaultTemplate(?:\s*=|:)\s*)precompileTemplate\(['"](.*)['"]\)}) do
       "#{$1}Ember.Handlebars.template(#{self.class.context.call("precompileEmberHandlebars", $2)})"
     end
  end

  def precompile_hbs_templates(name, data)
   "\nEmber.TEMPLATES['#{name}'] = Ember.Handlebars.template(#{self.class.context.call("precompileEmberHandlebars", data)});\n"
  end

  def generate_output(inputs, output)

    inputs.each do |input|
      result = File.read(input.fullpath)
      if @inline 
        precompile_inline_templates(result)
      else 

        name = File.basename(input.path, '.hbs')

      #name = File.basename(input.path, '.hbs')
      #data = File.read(input.fullpath)
      #result = precompile_templates(name, data)
        
        #name = input.path.dup
        #name.slice!(@base_path)
        #name.slice! ".hbs"
        result = precompile_hbs_templates(name, result)
      end
      output.write result
    end
  end
end


class AddHandlebarsDependencies < Rake::Pipeline::Filter

    def generate_output(inputs, output)

					contents = <<END
 minispade.require('rsvp');
 minispade.require('container');
 minispade.require('ember-debug');
 minispade.require('ember-metal');
 minispade.require('ember-runtime');
 minispade.require('ember-application');
 minispade.require('ember-views');
 minispade.require('ember-states');
 minispade.require('metamorph');
 minispade.require('ember-handlebars');
END

      output.write contents

      inputs.each do |input|
        output.write input.read
      end

		end

end



end
