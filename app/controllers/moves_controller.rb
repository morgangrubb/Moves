class MovesController < ApplicationController

  def index
    @moves = Move.ordered.all
  end

  def show
    @move = Move.find params[:id]
  end

end
