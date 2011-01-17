class MovesController < ApplicationController

  def index
    @moves = Move.ordered.all
  end

end
