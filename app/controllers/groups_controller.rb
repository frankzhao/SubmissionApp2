class GroupsController < ApplicationController
  before_filter :require_logged_in
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
