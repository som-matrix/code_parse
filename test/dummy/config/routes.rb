Rails.application.routes.draw do
  mount CodeParse::Engine => "/code_parse"
end
