module CodeParse
  module Api
    class ControllersController < ApplicationController
    def index
      data = Parsers::FileParser.new("controller").parse

      render json: data
    rescue => e
      render json: { error: e.message }, status: 500
    end
    end
  end
end
