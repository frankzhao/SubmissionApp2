class GroupsController < ApplicationController
  def new
  end

  def create
  end

  def edit
  end

  def show
    @group = Group.find(params[:id])
  end

  def index
  end

  def destroy
  end
end
