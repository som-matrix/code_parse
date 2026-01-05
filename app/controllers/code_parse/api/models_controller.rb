module CodeParse
  module Api
    class ModelsController < ApplicationController
    def index
      data = Parsers::ModelParser.new.parse

      render json: data
    rescue => e
      render json: { error: e.message }, status: 500
    end
    end
  end
end
