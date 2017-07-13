class TextController < ApplicationController
  def robots
    render text: this_blog.robots
  end
end
